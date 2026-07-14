import 'package:taskmail/features/dashboard/domain/entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<DashboardData> getDashboard();
}
