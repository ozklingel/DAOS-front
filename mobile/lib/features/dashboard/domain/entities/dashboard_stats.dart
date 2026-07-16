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
abstract class EnergyMeter with _$EnergyMeter {
  const factory EnergyMeter({
    @Default(100) int budget,
    @Default(0) int used,
    @Default(100) int remaining,
    @Default(0) int highCount,
    @Default(0) int mediumCount,
    @Default(0) int lowCount,
    @Default(0) int workCount,
    @Default(0) int errandsCount,
    @Default(0) int healthCount,
  }) = _EnergyMeter;
}

@freezed
abstract class DashboardData with _$DashboardData {
  const factory DashboardData({
    required DashboardStats stats,
    required String briefSummary,
    required EnergyMeter energyMeter,
    @Default([]) List<Task> recentHighPriorityTasks,
  }) = _DashboardData;
}
