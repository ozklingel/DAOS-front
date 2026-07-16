import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmail/core/di/providers.dart';
import 'package:taskmail/core/utils/date_formatter.dart';
import 'package:taskmail/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:taskmail/features/tasks/domain/entities/task.dart';
import 'package:taskmail/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/services/analytics_service.dart';
import 'package:taskmail/shared/models/task_enums.dart';
import 'package:taskmail/shared/widgets/loading_error_widgets.dart';
import 'package:taskmail/shared/widgets/priority_badge.dart';
import 'package:taskmail/shared/widgets/status_badge.dart';
import 'package:taskmail/theme/app_colors.dart';

class TaskDetailsScreen extends ConsumerWidget {
  const TaskDetailsScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final taskAsync = ref.watch(taskDetailProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l.taskDetails),
      ),
      body: taskAsync.when(
        loading: () => const ShimmerLoading(itemCount: 1),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(taskDetailProvider(taskId)),
        ),
        data: (task) => _TaskDetailsBody(task: task),
      ),
    );
  }
}

class _TaskDetailsBody extends ConsumerStatefulWidget {
  const _TaskDetailsBody({required this.task});

  final Task task;

  @override
  ConsumerState<_TaskDetailsBody> createState() => _TaskDetailsBodyState();
}

class _TaskDetailsBodyState extends ConsumerState<_TaskDetailsBody> {
  bool _isActionLoading = false;

  Future<void> _performAction(Future<void> Function() action) async {
    setState(() => _isActionLoading = true);
    try {
      await action();
      ref.invalidate(taskDetailProvider(widget.task.id));
      ref.invalidate(tasksListProvider);
      ref.invalidate(dashboardProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _snooze() async {
    final until = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) => const _SnoozeSheet(),
    );
    if (until == null) return;

    await _performAction(() async {
      await ref.read(tasksRepositoryProvider).snoozeTask(widget.task.id, until);
      await ref.read(analyticsServiceProvider).logTaskSnoozed(widget.task.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final task = widget.task;
    final isActionable = task.status == TaskStatus.open ||
        task.status == TaskStatus.overdue ||
        task.status == TaskStatus.snoozed;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  PriorityBadge(priority: task.priority),
                  const SizedBox(width: 8),
                  StatusBadge(status: task.status),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                task.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (task.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                ),
              ],
              const SizedBox(height: 24),
              _DetailRow(
                icon: Icons.schedule,
                label: l.deadline,
                value: DateFormatter.formatDeadline(task.deadline, l, locale: locale),
              ),
              if (task.senderName != null || task.senderEmail != null)
                _DetailRow(
                  icon: Icons.person_outline,
                  label: l.sender,
                  value: task.senderName ?? task.senderEmail ?? '',
                ),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: l.created,
                value: DateFormatter.formatRelative(task.createdAt, l, locale: locale),
              ),
              if (task.emailSubject != null) ...[
                const SizedBox(height: 24),
                Text(
                  l.sourceEmail,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.emailSubject!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 15,
                            ),
                      ),
                      if (task.emailSnippet != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          task.emailSnippet!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isActionable)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isActionLoading
                          ? null
                          : () => _performAction(() async {
                                await ref
                                    .read(tasksRepositoryProvider)
                                    .dismissTask(task.id);
                                await ref
                                    .read(analyticsServiceProvider)
                                    .logTaskDismissed(task.id);
                              }),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(l.dismiss),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isActionLoading ? null : _snooze,
                      icon: const Icon(Icons.snooze, size: 18),
                      label: Text(l.snooze),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isActionLoading
                          ? null
                          : () => _performAction(() async {
                                await ref
                                    .read(tasksRepositoryProvider)
                                    .completeTask(task.id);
                                await ref
                                    .read(analyticsServiceProvider)
                                    .logTaskCompleted(task.id);
                              }),
                      icon: _isActionLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: Text(l.done),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnoozeSheet extends StatelessWidget {
  const _SnoozeSheet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final options = [
      (l.snoozeOneHour, DateTime.now().add(const Duration(hours: 1))),
      (l.snoozeThreeHours, DateTime.now().add(const Duration(hours: 3))),
      (l.snoozeTomorrowMorning, _tomorrowAt9()),
      (l.snoozeNextWeek, DateTime.now().add(const Duration(days: 7))),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.snoozeUntil, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ...options.map(
            (o) => ListTile(
              title: Text(o.$1),
              onTap: () => Navigator.pop(context, o.$2),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  DateTime _tomorrowAt9() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9);
  }
}
