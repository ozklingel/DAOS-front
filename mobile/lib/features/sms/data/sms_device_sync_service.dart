import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmail/core/constants/storage_keys.dart';
import 'package:taskmail/core/network/api_client.dart';
import 'package:taskmail/features/sms/data/sms_background_scheduler_stub.dart'
    if (dart.library.io) 'package:taskmail/features/sms/data/sms_background_scheduler_io.dart';
import 'package:taskmail/features/sms/data/sms_background_sync.dart';
import 'package:taskmail/features/sms/data/sms_device_reader.dart';
import 'package:taskmail/features/sms/data/sms_ingest_models.dart';
import 'package:taskmail/features/sms/data/sms_remote_datasource.dart';

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

  /// Foreground / UI-triggered sync of recent inbox SMS.
  Future<SmsIngestResult> syncRecent({int count = 30}) async {
    final messages = await _reader.readRecent(count: count);
    final prefs = await SharedPreferences.getInstance();
    final fresh = await filterUnsyncedSms(prefs, messages);
    if (fresh.isEmpty) {
      return const SmsIngestResult(processed: 0, createdCount: 0, created: []);
    }
    final result = await _remote.ingest(fresh);
    await markSyncedSms(prefs, fresh.map((m) => m.messageId));
    await prefs.setString(
      StorageKeys.smsLastSyncAt,
      DateTime.now().toUtc().toIso8601String(),
    );
    return result;
  }
}

/// Factory for UI layer (uses app Dio/ApiClient).
SmsDeviceSyncService createSmsDeviceSyncService(ApiClient client) {
  return SmsDeviceSyncService(remote: SmsRemoteDataSource(client));
}
