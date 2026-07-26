import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taskmail/features/sms/data/sms_ingest_models.dart';

/// Reads recent inbox SMS on Android. iOS has no API to read SMS — returns empty.
class SmsDeviceReader {
  Future<bool> get isSupported async {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android;
  }

  Future<bool> hasPermission() async {
    if (!await isSupported) return false;
    return Permission.sms.isGranted;
  }

  Future<bool> requestPermission() async {
    if (!await isSupported) return false;
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<List<SmsDeviceMessage>> readRecent({int count = 30}) async {
    if (!await isSupported) return const [];
    if (!await hasPermission()) return const [];

    final query = SmsQuery();
    final messages = await query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: count,
      sort: true,
    );

    return messages
        .where((m) => (m.body ?? '').trim().isNotEmpty)
        .map((m) {
          final id = m.id?.toString() ??
              '${m.address ?? ''}_${m.date?.millisecondsSinceEpoch ?? 0}_${(m.body ?? '').hashCode}';
          return SmsDeviceMessage(
            messageId: 'android-$id',
            body: m.body!.trim(),
            fromAddress: m.address,
            receivedAt: m.date,
          );
        })
        .toList();
  }
}
