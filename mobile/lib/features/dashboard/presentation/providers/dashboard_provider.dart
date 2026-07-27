import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daos/core/di/providers.dart';
import 'package:daos/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:daos/features/tasks/domain/entities/task.dart';
import 'package:daos/shared/models/task_enums.dart';

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardData>(() {
  return DashboardNotifier();
});

final todayTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repo = ref.read(tasksRepositoryProvider);
  final overdue = await repo.getTasks(status: TaskStatus.overdue);
  final open = await repo.getTasks(status: TaskStatus.open);
  final snoozed = await repo.getTasks(status: TaskStatus.snoozed);
  return [...overdue, ...open, ...snoozed];
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
