import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/di/providers.dart';
import 'package:taskmail/features/tasks/domain/entities/task.dart';
import 'package:taskmail/shared/models/task_enums.dart';

class TasksFilterState {
  const TasksFilterState({
    this.search = '',
    this.status,
    this.priority,
    this.category,
    this.energyLevel,
    this.sortBy = TaskSortField.deadline,
    this.ascending = true,
  });

  final String search;
  final TaskStatus? status;
  final TaskPriority? priority;
  final TaskCategory? category;
  final EnergyLevel? energyLevel;
  final TaskSortField sortBy;
  final bool ascending;

  TasksFilterState copyWith({
    String? search,
    TaskStatus? Function()? status,
    TaskPriority? Function()? priority,
    TaskCategory? Function()? category,
    EnergyLevel? Function()? energyLevel,
    TaskSortField? sortBy,
    bool? ascending,
  }) {
    return TasksFilterState(
      search: search ?? this.search,
      status: status != null ? status() : this.status,
      priority: priority != null ? priority() : this.priority,
      category: category != null ? category() : this.category,
      energyLevel: energyLevel != null ? energyLevel() : this.energyLevel,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

final tasksFilterProvider =
    NotifierProvider<TasksFilterNotifier, TasksFilterState>(
  TasksFilterNotifier.new,
);

class TasksFilterNotifier extends Notifier<TasksFilterState> {
  @override
  TasksFilterState build() => const TasksFilterState();

  void setSearch(String value) => state = state.copyWith(search: value);
  void setStatus(TaskStatus? status) =>
      state = state.copyWith(status: () => status);
  void setPriority(TaskPriority? priority) =>
      state = state.copyWith(priority: () => priority);
  void setCategory(TaskCategory? category) =>
      state = state.copyWith(category: () => category);
  void setEnergyLevel(EnergyLevel? level) =>
      state = state.copyWith(energyLevel: () => level);
  void setSort(TaskSortField field) => state = state.copyWith(sortBy: field);
  void toggleSortOrder() =>
      state = state.copyWith(ascending: !state.ascending);

  void applyInitialFilter(String? filter) {
    if (filter == null) return;
    switch (filter) {
      case 'critical':
        state = state.copyWith(priority: () => TaskPriority.critical);
      case 'open':
        state = state.copyWith(status: () => TaskStatus.open);
      case 'overdue':
        state = state.copyWith(status: () => TaskStatus.overdue);
      case 'completed':
        state = state.copyWith(status: () => TaskStatus.completed);
    }
  }
}

final tasksListProvider =
    AsyncNotifierProvider<TasksListNotifier, List<Task>>(TasksListNotifier.new);

class TasksListNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    ref.listen(tasksFilterProvider, (_, __) {
      ref.invalidateSelf();
    });
    return _fetch();
  }

  Future<List<Task>> _fetch() {
    final filter = ref.read(tasksFilterProvider);
    return ref.read(tasksRepositoryProvider).getTasks(
          search: filter.search.isEmpty ? null : filter.search,
          status: filter.status,
          priority: filter.priority,
          category: filter.category,
          energyLevel: filter.energyLevel,
          sortBy: filter.sortBy,
          ascending: filter.ascending,
        );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final taskDetailProvider =
    FutureProvider.family<Task, String>((ref, id) async {
  return ref.read(tasksRepositoryProvider).getTaskById(id);
});
