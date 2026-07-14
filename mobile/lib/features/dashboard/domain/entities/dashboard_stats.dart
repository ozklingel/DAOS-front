import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taskmail/features/tasks/domain/entities/task.dart';

part 'dashboard_stats.freezed.dart';

@freezed
abstract class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @Default(0) int criticalCount,
    @Default(0) int openCount,
    @Default(0) int overdueCount,
    @Default(0) int completedThisWeek,
  }) = _DashboardStats;
}

@freezed
abstract class DashboardData with _$DashboardData {
  const factory DashboardData({
    required DashboardStats stats,
    required String briefSummary,
    @Default([]) List<Task> recentHighPriorityTasks,
  }) = _DashboardData;
}
