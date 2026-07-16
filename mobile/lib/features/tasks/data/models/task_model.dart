import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taskmail/features/tasks/domain/entities/task.dart';
import 'package:taskmail/shared/models/task_enums.dart';

part 'task_model.freezed.dart';

@freezed
abstract class TaskModel with _$TaskModel {
  const TaskModel._();

  const factory TaskModel({
    required String id,
    required String title,
    required String status,
    required String priority,
    required double priorityScore,
    @Default('general') String category,
    @Default('medium') String energyLevel,
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
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      priorityScore: (json['priority_score'] ?? json['priorityScore'] as num)
          .toDouble(),
      category: json['category'] as String? ?? 'general',
      energyLevel:
          json['energy_level'] as String? ?? json['energyLevel'] as String? ?? 'medium',
      description: json['description'] as String?,
      senderName:
          json['sender_name'] as String? ?? json['senderName'] as String?,
      senderEmail:
          json['sender_email'] as String? ?? json['senderEmail'] as String?,
      emailSubject:
          json['email_subject'] as String? ?? json['emailSubject'] as String?,
      emailSnippet:
          json['email_snippet'] as String? ?? json['emailSnippet'] as String?,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      snoozedUntil: json['snoozed_until'] != null
          ? DateTime.parse(json['snoozed_until'] as String)
          : json['snoozedUntil'] != null
              ? DateTime.parse(json['snoozedUntil'] as String)
              : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : json['completedAt'] != null
              ? DateTime.parse(json['completedAt'] as String)
              : null,
      createdAt: DateTime.parse(
        (json['created_at'] ?? json['createdAt']) as String,
      ),
      updatedAt: DateTime.parse(
        (json['updated_at'] ?? json['updatedAt']) as String,
      ),
    );
  }

  Task toEntity() => Task(
        id: id,
        title: title,
        status: _parseStatus(status),
        priority: _parsePriority(priority),
        priorityScore: priorityScore,
        category: _parseCategory(category),
        energyLevel: _parseEnergyLevel(energyLevel),
        description: description,
        senderName: senderName,
        senderEmail: senderEmail,
        emailSubject: emailSubject,
        emailSnippet: emailSnippet,
        deadline: deadline,
        snoozedUntil: snoozedUntil,
        completedAt: completedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static TaskStatus _parseStatus(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskStatus.open,
    );
  }

  static TaskPriority _parsePriority(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskPriority.none,
    );
  }

  static TaskCategory _parseCategory(String value) {
    return TaskCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskCategory.general,
    );
  }

  static EnergyLevel _parseEnergyLevel(String value) {
    return EnergyLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EnergyLevel.medium,
    );
  }
}

@freezed
abstract class TaskListResponse with _$TaskListResponse {
  const TaskListResponse._();

  const factory TaskListResponse({
    required List<TaskModel> tasks,
    @Default(0) int total,
    @Default(1) int page,
    @Default(false) bool hasMore,
  }) = _TaskListResponse;

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    final tasksJson = json['tasks'] as List<dynamic>? ?? [];
    return TaskListResponse(
      tasks: tasksJson
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? tasksJson.length,
      page: json['page'] as int? ?? 1,
      hasMore: json['has_more'] as bool? ?? json['hasMore'] as bool? ?? false,
    );
  }

  List<Task> toEntities() => tasks.map((t) => t.toEntity()).toList();
}
