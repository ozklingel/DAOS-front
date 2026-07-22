import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmail/core/di/providers.dart';
import 'package:taskmail/core/errors/app_exception.dart';
import 'package:taskmail/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:taskmail/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/shared/models/task_enums.dart';
import 'package:taskmail/theme/app_colors.dart';

Future<void> showCreateTaskSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.darkSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const CreateTaskSheet(),
  );
}

class CreateTaskSheet extends ConsumerStatefulWidget {
  const CreateTaskSheet({super.key});

  @override
  ConsumerState<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends ConsumerState<CreateTaskSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  TaskCategory _category = TaskCategory.general;
  EnergyLevel _energy = EnergyLevel.medium;
  DateTime? _deadline;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline ?? now),
    );
    if (!mounted) return;
    setState(() {
      if (time == null) {
        _deadline = DateTime(date.year, date.month, date.day, 23, 59);
      } else {
        _deadline = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
    });
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.titleRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final task = await ref.read(tasksRepositoryProvider).createTask(
            title: title,
            description: _descriptionController.text.trim(),
            priority: _priority,
            category: _category,
            energyLevel: _energy,
            deadline: _deadline,
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final router = GoRouter.of(context);
      Navigator.pop(context);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(tasksListProvider);
      messenger.showSnackBar(
        SnackBar(content: Text(l.taskCreatedSuccess(task.title))),
      );
      router.push('/home/tasks/${task.id}');
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.errorMessage(e))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 24),
      child: SingleChildScrollView(
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
            const SizedBox(height: 16),
            Text(l.createTaskSheetTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l.taskTitleField),
              enabled: !_saving,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(labelText: l.taskDescriptionField),
              enabled: !_saving,
            ),
            const SizedBox(height: 16),
            Text(l.priority, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskPriority.values
                  .where((p) => p != TaskPriority.none)
                  .map(
                    (p) => ChoiceChip(
                      label: Text(l.taskPriorityLabel(p)),
                      selected: _priority == p,
                      onSelected: _saving
                          ? null
                          : (_) => setState(() => _priority = p),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(l.category, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskCategory.values
                  .map(
                    (c) => ChoiceChip(
                      label: Text(l.taskCategoryLabel(c)),
                      selected: _category == c,
                      onSelected: _saving
                          ? null
                          : (_) => setState(() => _category = c),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(l.energyLevel, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EnergyLevel.values
                  .map(
                    (e) => ChoiceChip(
                      label: Text(l.energyLevelLabel(e)),
                      selected: _energy == e,
                      onSelected: _saving
                          ? null
                          : (_) => setState(() => _energy = e),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(
                _deadline == null
                    ? l.noDeadline
                    : '${_deadline!.day.toString().padLeft(2, '0')}/'
                        '${_deadline!.month.toString().padLeft(2, '0')}/'
                        '${_deadline!.year} '
                        '${_deadline!.hour.toString().padLeft(2, '0')}:'
                        '${_deadline!.minute.toString().padLeft(2, '0')}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_deadline != null)
                    IconButton(
                      onPressed: _saving
                          ? null
                          : () => setState(() => _deadline = null),
                      icon: const Icon(Icons.clear),
                    ),
                  TextButton(
                    onPressed: _saving ? null : _pickDeadline,
                    child: Text(l.deadline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.createTaskSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
