import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/di/providers.dart';
import 'package:taskmail/features/dashboard/domain/entities/dashboard_stats.dart';

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardData>(() {
  return DashboardNotifier();
});

class DashboardNotifier extends AsyncNotifier<DashboardData> {
  @override
  Future<DashboardData> build() async {
    return _fetch();
  }

  Future<DashboardData> _fetch() {
    return ref.read(dashboardRepositoryProvider).getDashboard();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
