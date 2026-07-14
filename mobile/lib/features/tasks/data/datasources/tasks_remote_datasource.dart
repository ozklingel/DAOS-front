import 'package:taskmail/core/constants/api_constants.dart';
import 'package:taskmail/core/network/api_client.dart';
import 'package:taskmail/features/tasks/data/models/task_model.dart';
import 'package:taskmail/shared/models/task_enums.dart';

class TasksRemoteDataSource {
  TasksRemoteDataSource(this._client);

  final ApiClient _client;

  Future<TaskListResponse> getTasks({
    String? search,
    TaskStatus? status,
    TaskPriority? priority,
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
}
