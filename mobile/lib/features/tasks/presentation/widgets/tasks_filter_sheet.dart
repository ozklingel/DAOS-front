import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/shared/models/task_enums.dart';
import 'package:taskmail/theme/app_colors.dart';

class TasksFilterSheet extends ConsumerWidget {
  const TasksFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
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
          Text(l.filterAndSort, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          Text(l.status, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _OptionChip(
                label: l.all,
                selected: filter.status == null,
                onTap: () => notifier.setStatus(null),
              ),
              ...TaskStatus.values.map(
                (s) => _OptionChip(
                  label: l.taskStatusLabel(s),
                  selected: filter.status == s,
                  onTap: () => notifier.setStatus(s),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(l.priority, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _OptionChip(
                label: l.all,
                selected: filter.priority == null,
                onTap: () => notifier.setPriority(null),
              ),
              ...TaskPriority.values.map(
                (p) => _OptionChip(
                  label: l.taskPriorityLabel(p),
                  selected: filter.priority == p,
                  onTap: () => notifier.setPriority(p),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(l.sortBy, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          ...TaskSortField.values.map(
            (field) => RadioListTile<TaskSortField>(
              value: field,
              groupValue: filter.sortBy,
              onChanged: (_) => notifier.setSort(field),
              title: Text(l.taskSortLabel(field)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.ascendingOrder),
            value: filter.ascending,
            onChanged: (_) => notifier.toggleSortOrder(),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.apply),
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
