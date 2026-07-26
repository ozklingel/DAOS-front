import 'package:taskmail/core/constants/api_constants.dart';
import 'package:taskmail/core/network/api_client.dart';
import 'package:taskmail/features/sms/data/sms_ingest_models.dart';

class SmsRemoteDataSource {
  SmsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<SmsIngestResult> ingest(List<SmsDeviceMessage> messages) async {
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
