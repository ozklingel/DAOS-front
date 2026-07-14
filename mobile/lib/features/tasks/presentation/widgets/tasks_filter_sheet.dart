import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:taskmail/shared/models/task_enums.dart';
import 'package:taskmail/theme/app_colors.dart';

class TasksFilterSheet extends ConsumerWidget {
  const TasksFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(tasksFilterProvider);
    final notifier = ref.read(tasksFilterProvider.notifier);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Filter & Sort', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          Text('Status', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _OptionChip(
                label: 'All',
                selected: filter.status == null,
                onTap: () => notifier.setStatus(null),
              ),
              ...TaskStatus.values.map(
                (s) => _OptionChip(
                  label: s.label,
                  selected: filter.status == s,
                  onTap: () => notifier.setStatus(s),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Priority', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _OptionChip(
                label: 'All',
                selected: filter.priority == null,
                onTap: () => notifier.setPriority(null),
              ),
              ...TaskPriority.values.map(
                (p) => _OptionChip(
                  label: p.label,
                  selected: filter.priority == p,
                  onTap: () => notifier.setPriority(p),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Sort by', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          ...TaskSortField.values.map(
            (field) => RadioListTile<TaskSortField>(
              value: field,
              groupValue: filter.sortBy,
              onChanged: (_) => notifier.setSort(field),
              title: Text(field.label),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ascending order'),
            value: filter.ascending,
            onChanged: (_) => notifier.toggleSortOrder(),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 13,
      ),
    );
  }
}
