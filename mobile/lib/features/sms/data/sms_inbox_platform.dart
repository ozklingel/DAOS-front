import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:daos/features/sms/data/sms_ingest_models.dart';

class SmsInboxPlatform {
  static Future<bool> hasPermission() => Permission.sms.isGranted;

  static Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  static Future<List<SmsDeviceMessage>> readRecent({int count = 30}) async {
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
