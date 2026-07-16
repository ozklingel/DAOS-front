import 'package:taskmail/features/tasks/domain/entities/task.dart';
import 'package:taskmail/shared/models/task_enums.dart';

abstract class TasksRepository {
  Future<List<Task>> getTasks({
    String? search,
    TaskStatus? status,
    TaskPriority? priority,
    TaskCategory? category,
    EnergyLevel? energyLevel,
    TaskSortField sortBy = TaskSortField.deadline,
    bool ascending = true,
    int page = 1,
  });

  Future<Task> getTaskById(String id);

  Future<Task> completeTask(String id);
  Future<Task> snoozeTask(String id, DateTime until);
  Future<Task> dismissTask(String id);
}
