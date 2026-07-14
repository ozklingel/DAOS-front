import 'package:taskmail/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:taskmail/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:taskmail/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remote);

  final DashboardRemoteDataSource _remote;

  @override
  Future<DashboardData> getDashboard() async {
    final model = await _remote.getDashboard();
    return model.toEntity();
  }
}
