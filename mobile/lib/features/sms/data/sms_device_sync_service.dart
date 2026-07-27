import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daos/core/constants/storage_keys.dart';
import 'package:daos/core/network/api_client.dart';
import 'package:daos/features/sms/data/sms_background_scheduler_stub.dart'
    if (dart.library.io) 'package:daos/features/sms/data/sms_background_scheduler_io.dart';
import 'package:daos/features/sms/data/sms_background_sync.dart';
import 'package:daos/features/sms/data/sms_device_reader.dart';
import 'package:daos/features/sms/data/sms_ingest_models.dart';
import 'package:daos/features/sms/data/sms_remote_datasource.dart';

class SmsDeviceSyncService {
  SmsDeviceSyncService({
    required SmsRemoteDataSource remote,
    SmsDeviceReader? reader,
  })  : _remote = remote,
        _reader = reader ?? SmsDeviceReader();

  final SmsRemoteDataSource _remote;
  final SmsDeviceReader _reader;

  /// Backend accepts at most this many messages per /sms/ingest call.
  static const int ingestBatchSize = 40;

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
      await initializeBackground();
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
    await SmsBackgroundScheduler.initialize(debug: kDebugMode);
    if (await isEnabled()) {
      await scheduleBackgroundSync();
    }
  }

  Future<void> scheduleBackgroundSync() async {
    if (!await _reader.isSupported) return;
    await SmsBackgroundScheduler.schedulePeriodic();
  }

  Future<void> cancelBackgroundSync() async {
    await SmsBackgroundScheduler.cancel();
  }

  Future<void> clearSyncedIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.smsSyncedIds);
  }

  /// App open / login: send today's inbox SMS when permission is already granted.
  Future<SmsIngestResult?> syncTodaysOnLaunch() async {
    if (!await isAndroidSupported()) return null;
    if (!await hasPermission()) return null;
    // Keep background sync aligned once the user has granted SMS access.
    if (!await isEnabled()) {
      await setEnabled(true);
    }
    return syncToday();
  }

  /// Background / startup sync when user already enabled SMS.
  Future<SmsIngestResult?> syncIfEnabled() async {
    if (!await isAndroidSupported()) return null;
    if (!await isEnabled()) return null;
    if (!await hasPermission()) return null;
    return syncToday();
  }

  /// All SMS received since local midnight → server → tasks.
  Future<SmsIngestResult> syncToday() async {
    final messages = await _reader.readToday();
    debugPrint('SMS: read ${messages.length} messages from today');
    return _ingestMessages(messages);
  }

  /// Foreground / UI-triggered sync of recent inbox SMS.
  Future<SmsIngestResult> syncRecent({int count = 30}) async {
    final messages = await _reader.readRecent(count: count);
    debugPrint('SMS: read ${messages.length} inbox messages');
    return _ingestMessages(messages);
  }

  Future<SmsIngestResult> _ingestMessages(List<SmsDeviceMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final fresh = await filterUnsyncedSms(prefs, messages);
    debugPrint('SMS: ${fresh.length} new messages to send to server');
    if (fresh.isEmpty) {
      return SmsIngestResult(
        processed: messages.length,
        createdCount: 0,
        created: const [],
      );
    }

    var processed = 0;
    var createdCount = 0;
    final created = <SmsIngestCreatedItem>[];

    for (var i = 0; i < fresh.length; i += ingestBatchSize) {
      final end = (i + ingestBatchSize < fresh.length)
          ? i + ingestBatchSize
          : fresh.length;
      final chunk = fresh.sublist(i, end);
      final result = await _remote.ingest(chunk);
      processed += result.processed;
      createdCount += result.createdCount;
      created.addAll(result.created);
      await markSyncedSms(prefs, chunk.map((m) => m.messageId));
    }

    debugPrint('SMS: server processed=$processed created=$createdCount');
    await prefs.setString(
      StorageKeys.smsLastSyncAt,
      DateTime.now().toUtc().toIso8601String(),
    );
    return SmsIngestResult(
      processed: processed,
      createdCount: createdCount,
      created: created,
    );
  }
}

/// Factory for UI layer (uses app Dio/ApiClient).
SmsDeviceSyncService createSmsDeviceSyncService(ApiClient client) {
  return SmsDeviceSyncService(remote: SmsRemoteDataSource(client));
}
