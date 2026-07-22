import 'package:taskmail/features/tasks/data/datasources/tasks_remote_datasource.dart';
import 'package:taskmail/features/tasks/domain/entities/task.dart';
import 'package:taskmail/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:taskmail/shared/models/task_enums.dart';

class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl(this._remote);

  final TasksRemoteDataSource _remote;

  @override
  Future<List<Task>> getTasks({
    String? search,
    TaskStatus? status,
    TaskPriority? priority,
    TaskCategory? category,
    EnergyLevel? energyLevel,
    TaskSortField sortBy = TaskSortField.deadline,
    bool ascending = true,
    int page = 1,
  }) async {
    final response = await _remote.getTasks(
      search: search,
      status: status,
      priority: priority,
      category: category,
      energyLevel: energyLevel,
      sortBy: sortBy,
      ascending: ascending,
      page: page,
    );
    return response.toEntities();
  }

  @override
  Future<Task> getTaskById(String id) async {
    final model = await _remote.getTaskById(id);
    return model.toEntity();
  }

  @override
  Future<Task> createTask({
    required String title,
    String? description,
    TaskPriority? priority,
    TaskCategory? category,
    EnergyLevel? energyLevel,
    DateTime? deadline,
  }) async {
    final model = await _remote.createTask(
      title: title,
      description: description,
      priority: priority,
      category: category,
      energyLevel: energyLevel,
      deadline: deadline,
    );
    return model.toEntity();
  }

  @override
  Future<Task> completeTask(String id) async {
    final model = await _remote.updateTask(id, action: TaskAction.complete);
    return model.toEntity();
  }

  @override
  Future<Task> snoozeTask(String id, DateTime until) async {
    final model = await _remote.updateTask(
      id,
      action: TaskAction.snooze,
      snoozeUntil: until,
    );
    return model.toEntity();
  }

  @override
  Future<Task> dismissTask(String id) async {
    final model = await _remote.updateTask(id, action: TaskAction.dismiss);
    return model.toEntity();
  }
}
