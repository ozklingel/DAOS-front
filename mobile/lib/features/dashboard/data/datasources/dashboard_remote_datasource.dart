import 'package:taskmail/core/constants/api_constants.dart';
import 'package:taskmail/core/network/api_client.dart';
import 'package:taskmail/features/dashboard/data/models/dashboard_model.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._client);

  final ApiClient _client;

  Future<DashboardModel> getDashboard() async {
    final data = await _client.get<Map<String, dynamic>>(
      ApiConstants.dashboard,
      parser: (d) => d as Map<String, dynamic>,
    );
    return DashboardModel.fromJson(data);
  }
}
