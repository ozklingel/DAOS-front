import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taskmail/features/tasks/domain/entities/task.dart';

part 'daily_brief.freezed.dart';

@freezed
abstract class DailyBrief with _$DailyBrief {
  const factory DailyBrief({
    required String id,
    required String summary,
    required String content,
    required DateTime generatedAt,
    @Default([]) List<Task> highlightedTasks,
    @Default([]) List<String> insights,
  }) = _DailyBrief;
}
