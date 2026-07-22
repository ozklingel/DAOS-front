import 'package:dio/dio.dart';
import 'package:taskmail/core/constants/api_constants.dart';
import 'package:taskmail/core/network/api_client.dart';
import 'package:taskmail/features/tasks/data/models/task_model.dart';
import 'package:taskmail/shared/models/task_enums.dart';

class VoiceTaskResult {
  const VoiceTaskResult({
    required this.created,
    required this.message,
    this.task,
    this.transcript,
  });

  final bool created;
  final String message;
  final TaskModel? task;
  final String? transcript;
}

class TasksRemoteDataSource {
  TasksRemoteDataSource(this._client);

  final ApiClient _client;

  Future<TaskListResponse> getTasks({
    String? search,
    TaskStatus? status,
    TaskPriority? priority,
    TaskCategory? category,
    EnergyLevel? energyLevel,
    TaskSortField sortBy = TaskSortField.deadline,
    bool ascending = true,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sortBy': sortBy.apiValue,
      'order': ascending ? 'asc' : 'desc',
    };
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (status != null) query['status'] = status.name;
    if (priority != null) query['priority'] = priority.name;
    if (category != null) query['category'] = category.apiValue;
    if (energyLevel != null) query['energyLevel'] = energyLevel.apiValue;

    final data = await _client.get<Map<String, dynamic>>(
      ApiConstants.tasks,
      queryParameters: query,
      parser: (d) => d as Map<String, dynamic>,
    );
    return TaskListResponse.fromJson(data);
  }

  Future<TaskModel> getTaskById(String id) async {
    final data = await _client.get<Map<String, dynamic>>(
      '${ApiConstants.tasks}/$id',
      parser: (d) => d as Map<String, dynamic>,
    );
    return TaskModel.fromJson(data);
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    TaskPriority? priority,
    TaskCategory? category,
    EnergyLevel? energyLevel,
    DateTime? deadline,
  }) async {
    final body = <String, dynamic>{
      'title': title.trim(),
    };
    if (description != null && description.trim().isNotEmpty) {
      body['description'] = description.trim();
    }
    if (priority != null) body['priority'] = priority.name;
    if (category != null) body['category'] = category.apiValue;
    if (energyLevel != null) body['energyLevel'] = energyLevel.apiValue;
    if (deadline != null) body['deadline'] = deadline.toUtc().toIso8601String();

    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.tasks,
      data: body,
      parser: (d) => d as Map<String, dynamic>,
    );
    return TaskModel.fromJson(data);
  }

  Future<TaskModel> updateTask(
    String id, {
    required TaskAction action,
    DateTime? snoozeUntil,
  }) async {
    final body = <String, dynamic>{'action': action.apiValue};
    if (snoozeUntil != null) {
      body['snoozeUntil'] = snoozeUntil.toIso8601String();
    }

    final data = await _client.patch<Map<String, dynamic>>(
      '${ApiConstants.tasks}/$id',
      data: body,
      parser: (d) => d as Map<String, dynamic>,
    );
    return TaskModel.fromJson(data);
  }

  Future<VoiceTaskResult> createFromVoice({
    String? transcript,
    List<int>? audioBytes,
    String audioFilename = 'voice.wav',
  }) async {
    final map = <String, dynamic>{};
    if (transcript != null && transcript.trim().isNotEmpty) {
      map['transcript'] = transcript.trim();
    }
    if (audioBytes != null && audioBytes.isNotEmpty) {
      map['audio'] = MultipartFile.fromBytes(
        audioBytes,
        filename: audioFilename,
      );
    }
    final form = FormData.fromMap(map);
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.tasksFromVoice,
      data: form,
      options: Options(
        sendTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
      ),
      parser: (d) => d as Map<String, dynamic>,
    );
    final taskJson = data['task'] as Map<String, dynamic>?;
    return VoiceTaskResult(
      created: data['created'] as bool? ?? false,
      message: data['message'] as String? ?? '',
      transcript: data['transcript'] as String?,
      task: taskJson != null ? TaskModel.fromJson(taskJson) : null,
    );
  }
}
