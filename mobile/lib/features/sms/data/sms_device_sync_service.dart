import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmail/core/constants/api_constants.dart';
import 'package:taskmail/core/constants/storage_keys.dart';
import 'package:taskmail/core/network/api_client.dart';
import 'package:taskmail/features/sms/data/sms_device_reader.dart';
import 'package:taskmail/features/sms/data/sms_ingest_models.dart';
import 'package:taskmail/features/sms/data/sms_remote_datasource.dart';
import 'package:workmanager/workmanager.dart';

const String kSmsSyncTaskName = 'daosSmsSyncTask';
const String kSmsSyncUniqueName = 'daos-sms-sync';

/// Top-level entry for Workmanager (Android background isolate).
@pragma('vm:entry-point')
void smsSyncCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != kSmsSyncTaskName && task != Workmanager.iOSBackgroundTask) {
      return true;
    }
    try {
      await SmsDeviceSyncService.syncFromBackground();
    } catch (e, st) {
      debugPrint('SMS background sync failed: $e\n$st');
    }
    return true;
  });
}

class SmsDeviceSyncService {
  SmsDeviceSyncService({
    required SmsRemoteDataSource remote,
    SmsDeviceReader? reader,
  })  : _remote = remote,
        _reader = reader ?? SmsDeviceReader();

  final SmsRemoteDataSource _remote;
  final SmsDeviceReader _reader;

  Future<bool> isAndroidSupported() => _reader.isSupported;

  Future<bool> hasPermission() => _reader.hasPermission();

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(StorageKeys.smsSyncEnabled) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.smsSyncEnabled, enabled);
    if (enabled) {
      await scheduleBackgroundSync();
    } else {
      await cancelBackgroundSync();
    }
  }

  Future<bool> ensurePermission() async {
    if (await _reader.hasPermission()) return true;
    return _reader.requestPermission();
  }

  Future<void> initializeBackground() async {
    // Auto inbox read is Android-only (iOS has no SMS inbox API).
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    await Workmanager().initialize(
      smsSyncCallbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    if (await isEnabled()) {
      await scheduleBackgroundSync();
    }
  }

  Future<void> scheduleBackgroundSync() async {
    if (!await _reader.isSupported) return;
    await Workmanager().registerPeriodicTask(
      kSmsSyncUniqueName,
      kSmsSyncTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 5),
    );
  }

  Future<void> cancelBackgroundSync() async {
    await Workmanager().cancelByUniqueName(kSmsSyncUniqueName);
  }

  /// Foreground / UI-triggered sync of recent inbox SMS.
  Future<SmsIngestResult> syncRecent({int count = 30}) async {
    final messages = await _reader.readRecent(count: count);
    final fresh = await _filterUnsynced(messages);
    if (fresh.isEmpty) {
      return const SmsIngestResult(processed: 0, createdCount: 0, created: []);
    }
    final result = await _remote.ingest(fresh);
    await _markSynced(fresh.map((m) => m.messageId));
    await _touchLastSync();
    return result;
  }

  /// iOS / manual: submit pasted or shared SMS text.
  Future<SmsIngestResult> ingestManualText(String text, {String? from}) async {
    final body = text.trim();
    if (body.isEmpty) {
      return const SmsIngestResult(processed: 0, createdCount: 0, created: []);
    }
    final id =
        'manual-${DateTime.now().millisecondsSinceEpoch}-${body.hashCode}';
    final result = await _remote.ingest([
      SmsDeviceMessage(
        messageId: id,
        body: body,
        fromAddress: from,
        receivedAt: DateTime.now(),
      ),
    ]);
    await _touchLastSync();
    return result;
  }

  /// Called from Workmanager isolate (no Riverpod).
  static Future<SmsIngestResult?> syncFromBackground() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(StorageKeys.smsSyncEnabled) ?? false)) {
      return null;
    }

    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final access = await storage.read(key: StorageKeys.accessToken);
    if (access == null || access.isEmpty) return null;

    final reader = SmsDeviceReader();
    if (!await reader.hasPermission()) return null;
    final messages = await reader.readRecent(count: 25);
    final fresh = await _filterUnsyncedStatic(prefs, messages);
    if (fresh.isEmpty) return null;

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Authorization': 'Bearer $access',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    final remote = SmsRemoteDataSource(ApiClient(dio));
    final result = await remote.ingest(fresh);
    await _markSyncedStatic(prefs, fresh.map((m) => m.messageId));
    await prefs.setString(
      StorageKeys.smsLastSyncAt,
      DateTime.now().toUtc().toIso8601String(),
    );
    return result;
  }

  Future<List<SmsDeviceMessage>> _filterUnsynced(
    List<SmsDeviceMessage> messages,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    return _filterUnsyncedStatic(prefs, messages);
  }

  static Future<List<SmsDeviceMessage>> _filterUnsyncedStatic(
    SharedPreferences prefs,
    List<SmsDeviceMessage> messages,
  ) async {
    final raw = prefs.getString(StorageKeys.smsSyncedIds);
    final known = <String>{};
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        known.addAll(list.map((e) => e.toString()));
      } catch (_) {}
    }
    return messages.where((m) => !known.contains(m.messageId)).toList();
  }

  Future<void> _markSynced(Iterable<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await _markSyncedStatic(prefs, ids);
  }

  static Future<void> _markSyncedStatic(
    SharedPreferences prefs,
    Iterable<String> ids,
  ) async {
    final raw = prefs.getString(StorageKeys.smsSyncedIds);
    final known = <String>[];
    if (raw != null && raw.isNotEmpty) {
      try {
        known.addAll((jsonDecode(raw) as List<dynamic>).map((e) => e.toString()));
      } catch (_) {}
    }
    for (final id in ids) {
      if (!known.contains(id)) known.add(id);
    }
    // Keep last N ids to bound storage
    final trimmed = known.length > 400 ? known.sublist(known.length - 400) : known;
    await prefs.setString(StorageKeys.smsSyncedIds, jsonEncode(trimmed));
  }

  Future<void> _touchLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKeys.smsLastSyncAt,
      DateTime.now().toUtc().toIso8601String(),
    );
  }
}

/// Factory for UI layer (uses app Dio/ApiClient).
SmsDeviceSyncService createSmsDeviceSyncService(ApiClient client) {
  return SmsDeviceSyncService(remote: SmsRemoteDataSource(client));
}
