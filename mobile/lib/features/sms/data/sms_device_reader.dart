import 'package:flutter/foundation.dart';
import 'package:daos/features/sms/data/sms_ingest_models.dart';
import 'package:daos/features/sms/data/sms_inbox_platform.dart'
    if (dart.library.html) 'package:daos/features/sms/data/sms_inbox_platform_stub.dart';

/// Reads recent inbox SMS on Android. iOS/web have no SMS inbox API — returns empty.
class SmsDeviceReader {
  Future<bool> get isSupported async {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android;
  }

  Future<bool> hasPermission() async {
    if (!await isSupported) return false;
    return SmsInboxPlatform.hasPermission();
  }

  Future<bool> requestPermission() async {
    if (!await isSupported) return false;
    return SmsInboxPlatform.requestPermission();
  }

  Future<List<SmsDeviceMessage>> readRecent({int count = 30}) async {
    if (!await isSupported) return const [];
    if (!await hasPermission()) return const [];
    return SmsInboxPlatform.readRecent(count: count);
  }
}
