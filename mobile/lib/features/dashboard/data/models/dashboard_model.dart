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
    required EnergyMeterModel energyMeter,
    @Default([]) List<TaskModel> recentHighPriorityTasks,
  }) = _DashboardModel;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final tasksJson =
        json['recent_high_priority_tasks'] ?? json['recentHighPriorityTasks'];
    final energyJson =
        json['energy_meter'] ?? json['energyMeter'] ?? const <String, dynamic>{};
    return DashboardModel(
      stats: DashboardStatsModel.fromJson(
        json['stats'] as Map<String, dynamic>,
      ),
      briefSummary: (json['brief_summary'] ?? json['briefSummary']) as String,
      energyMeter: EnergyMeterModel.fromJson(
        energyJson is Map<String, dynamic> ? energyJson : const {},
      ),
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
        energyMeter: energyMeter.toEntity(),
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

@freezed
abstract class EnergyMeterModel with _$EnergyMeterModel {
  const EnergyMeterModel._();

  const factory EnergyMeterModel({
    @Default(100) int budget,
    @Default(0) int used,
    @Default(100) int remaining,
    @Default(0) int highCount,
    @Default(0) int mediumCount,
    @Default(0) int lowCount,
    @Default(0) int workCount,
    @Default(0) int errandsCount,
    @Default(0) int healthCount,
  }) = _EnergyMeterModel;

  factory EnergyMeterModel.fromJson(Map<String, dynamic> json) {
    return EnergyMeterModel(
      budget: json['budget'] as int? ?? 100,
      used: json['used'] as int? ?? 0,
      remaining: json['remaining'] as int? ?? 100,
      highCount: json['high_count'] as int? ?? json['highCount'] as int? ?? 0,
      mediumCount:
          json['medium_count'] as int? ?? json['mediumCount'] as int? ?? 0,
      lowCount: json['low_count'] as int? ?? json['lowCount'] as int? ?? 0,
      workCount: json['work_count'] as int? ?? json['workCount'] as int? ?? 0,
      errandsCount:
          json['errands_count'] as int? ?? json['errandsCount'] as int? ?? 0,
      healthCount:
          json['health_count'] as int? ?? json['healthCount'] as int? ?? 0,
    );
  }

  EnergyMeter toEntity() => EnergyMeter(
        budget: budget,
        used: used,
        remaining: remaining,
        highCount: highCount,
        mediumCount: mediumCount,
        lowCount: lowCount,
        workCount: workCount,
        errandsCount: errandsCount,
        healthCount: healthCount,
      );
}
