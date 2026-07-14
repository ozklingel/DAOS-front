import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taskmail/features/daily_brief/domain/entities/daily_brief.dart';
import 'package:taskmail/features/tasks/data/models/task_model.dart';

part 'daily_brief_model.freezed.dart';

@freezed
abstract class DailyBriefModel with _$DailyBriefModel {
  const DailyBriefModel._();

  const factory DailyBriefModel({
    required String id,
    required String summary,
    required String content,
    required DateTime generatedAt,
    @Default([]) List<TaskModel> highlightedTasks,
    @Default([]) List<String> insights,
  }) = _DailyBriefModel;

  factory DailyBriefModel.fromJson(Map<String, dynamic> json) {
    final tasksJson = json['highlighted_tasks'] ?? json['highlightedTasks'];
    return DailyBriefModel(
      id: json['id'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      generatedAt: DateTime.parse(
        (json['generated_at'] ?? json['generatedAt']) as String,
      ),
      highlightedTasks: tasksJson is List
          ? tasksJson
              .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  DailyBrief toEntity() => DailyBrief(
        id: id,
        summary: summary,
        content: content,
        generatedAt: generatedAt,
        highlightedTasks:
            highlightedTasks.map((t) => t.toEntity()).toList(),
        insights: insights,
      );
}
