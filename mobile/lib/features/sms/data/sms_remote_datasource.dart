import 'package:flutter/foundation.dart';
import 'package:daos/core/constants/api_constants.dart';
import 'package:daos/core/network/api_client.dart';
import 'package:daos/features/sms/data/sms_ingest_models.dart';

class SmsRemoteDataSource {
  SmsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<SmsIngestResult> ingest(List<SmsDeviceMessage> messages) async {
    debugPrint('SMS: POST /sms/ingest with ${messages.length} messages');
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.smsIngest,
      data: {
        'messages': messages.map((m) => m.toJson()).toList(),
      },
      parser: (d) => d as Map<String, dynamic>,
    );
    return SmsIngestResult.fromJson(data);
  }
}
