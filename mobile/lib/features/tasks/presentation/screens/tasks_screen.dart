import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:taskmail/features/tasks/presentation/widgets/tasks_filter_sheet.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/shared/widgets/loading_error_widgets.dart';
import 'package:taskmail/shared/widgets/task_card.dart';
import 'package:taskmail/theme/app_colors.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key, this.initialFilter});

  final String? initialFilter;

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _searchController = TextEditingController();
  bool _filterApplied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_filterApplied && widget.initialFilter != null) {
        ref
            .read(tasksFilterProvider.notifier)
            .applyInitialFilter(widget.initialFilter);
        _filterApplied = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tasksAsync = ref.watch(tasksListProvider);
    final filter = ref.watch(tasksFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tasks),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const TasksFilterSheet(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l.searchTasks,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(tasksFilterProvider.notifier).setSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: (v) =>
                  ref.read(tasksFilterProvider.notifier).setSearch(v),
            ),
          ),
          if (filter.status != null || filter.priority != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (filter.status != null)
                      _FilterChip(
                        label: l.taskStatusLabel(filter.status!),
                        onRemove: () => ref
                            .read(tasksFilterProvider.notifier)
                            .setStatus(null),
                      ),
                    if (filter.priority != null)
                      _FilterChip(
                        label: l.taskPriorityLabel(filter.priority!),
                        onRemove: () => ref
                            .read(tasksFilterProvider.notifier)
                            .setPriority(null),
                      ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: tasksAsync.when(
              loading: () => const ShimmerLoading(),
              error: (e, _) => ErrorView(
                error: e,
                onRetry: () => ref.read(tasksListProvider.notifier).refresh(),
              ),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return EmptyStateView(
                    title: l.noTasksFound,
                    subtitle: l.adjustFilters,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(tasksListProvider.notifier).refresh(),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => TaskCard(task: tasks[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
      side: BorderSide.none,
      labelStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }
}
