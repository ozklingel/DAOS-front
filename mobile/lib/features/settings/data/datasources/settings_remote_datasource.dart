import 'package:taskmail/core/constants/api_constants.dart';
import 'package:taskmail/core/network/api_client.dart';
import 'package:taskmail/features/settings/data/models/settings_model.dart';

class SettingsRemoteDataSource {
  SettingsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<SettingsModel> getSettings() async {
    final data = await _client.get<Map<String, dynamic>>(
      ApiConstants.settings,
      parser: (d) => d as Map<String, dynamic>,
    );
    return SettingsModel.fromJson(data);
  }

  Future<SettingsModel> updateSettings(Map<String, dynamic> updates) async {
    final data = await _client.patch<Map<String, dynamic>>(
      ApiConstants.settings,
      data: updates,
      parser: (d) => d as Map<String, dynamic>,
    );
    return SettingsModel.fromJson(data);
  }

  Future<int> syncEmails() async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.syncEmails,
      parser: (d) => d as Map<String, dynamic>,
    );
    return data['created'] as int? ?? 0;
  }
}
