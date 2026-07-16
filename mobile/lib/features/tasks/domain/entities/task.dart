import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taskmail/shared/models/task_enums.dart';

part 'task.freezed.dart';

@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    required TaskStatus status,
    required TaskPriority priority,
    required double priorityScore,
    @Default(TaskCategory.general) TaskCategory category,
    @Default(EnergyLevel.medium) EnergyLevel energyLevel,
    String? description,
    String? senderName,
    String? senderEmail,
    String? emailSubject,
    String? emailSnippet,
    DateTime? deadline,
    DateTime? snoozedUntil,
    DateTime? completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Task;
}
