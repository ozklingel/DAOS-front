import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taskmail/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:taskmail/features/tasks/data/models/task_model.dart';

part 'dashboard_model.freezed.dart';

@freezed
abstract class DashboardModel with _$DashboardModel {
  const DashboardModel._();

  const factory DashboardModel({
    required DashboardStatsModel stats,
    required String briefSummary,
    @Default([]) List<TaskModel> recentHighPriorityTasks,
  }) = _DashboardModel;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final tasksJson =
        json['recent_high_priority_tasks'] ?? json['recentHighPriorityTasks'];
    return DashboardModel(
      stats: DashboardStatsModel.fromJson(
        json['stats'] as Map<String, dynamic>,
      ),
      briefSummary: (json['brief_summary'] ?? json['briefSummary']) as String,
      recentHighPriorityTasks: tasksJson is List
          ? tasksJson
              .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  DashboardData toEntity() => DashboardData(
        stats: stats.toEntity(),
        briefSummary: briefSummary,
        recentHighPriorityTasks:
            recentHighPriorityTasks.map((t) => t.toEntity()).toList(),
      );
}

@freezed
abstract class DashboardStatsModel with _$DashboardStatsModel {
  const DashboardStatsModel._();

  const factory DashboardStatsModel({
    @Default(0) int criticalCount,
    @Default(0) int openCount,
    @Default(0) int overdueCount,
    @Default(0) int completedThisWeek,
  }) = _DashboardStatsModel;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      criticalCount: json['critical_count'] as int? ??
          json['criticalCount'] as int? ??
          0,
      openCount:
          json['open_count'] as int? ?? json['openCount'] as int? ?? 0,
      overdueCount: json['overdue_count'] as int? ??
          json['overdueCount'] as int? ??
          0,
      completedThisWeek: json['completed_this_week'] as int? ??
          json['completedThisWeek'] as int? ??
          0,
    );
  }

  DashboardStats toEntity() => DashboardStats(
        criticalCount: criticalCount,
        openCount: openCount,
        overdueCount: overdueCount,
        completedThisWeek: completedThisWeek,
      );
}
