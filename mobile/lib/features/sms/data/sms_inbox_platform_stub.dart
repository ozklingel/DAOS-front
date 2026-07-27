import 'package:daos/features/sms/data/sms_ingest_models.dart';

/// Web / non-IO stub — SMS inbox is unavailable.
class SmsInboxPlatform {
  static Future<bool> hasPermission() async => false;

  static Future<bool> requestPermission() async => false;

  static Future<List<SmsDeviceMessage>> readRecent({int count = 30}) async =>
      const [];

  static Future<List<SmsDeviceMessage>> readSince(
    DateTime since, {
    int scanCount = 500,
  }) async =>
      const [];
}
