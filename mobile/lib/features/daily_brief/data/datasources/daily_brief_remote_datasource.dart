import 'package:taskmail/core/constants/api_constants.dart';
import 'package:taskmail/core/network/api_client.dart';
import 'package:taskmail/features/daily_brief/data/models/daily_brief_model.dart';

class DailyBriefRemoteDataSource {
  DailyBriefRemoteDataSource(this._client);

  final ApiClient _client;

  Future<DailyBriefModel> getDailyBrief() async {
    final data = await _client.get<Map<String, dynamic>>(
      ApiConstants.dailyBrief,
      parser: (d) => d as Map<String, dynamic>,
    );
    return DailyBriefModel.fromJson(data);
  }
}
