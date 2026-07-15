import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmail/core/utils/date_formatter.dart';
import 'package:taskmail/features/tasks/domain/entities/task.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/shared/widgets/priority_badge.dart';
import 'package:taskmail/shared/widgets/status_badge.dart';
import 'package:taskmail/shared/models/task_enums.dart';
import 'package:taskmail/theme/app_colors.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.compact = false,
  });

  final Task task;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final isOverdue = task.status == TaskStatus.overdue ||
        (task.deadline != null &&
            task.deadline!.isBefore(DateTime.now()) &&
            task.status == TaskStatus.open);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap ?? () => context.push('/home/tasks/${task.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(compact ? 14 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: compact ? 15 : 16,
                          ),
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PriorityBadge(priority: task.priority),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  StatusBadge(status: task.status),
                  const Spacer(),
                  if (task.senderName != null || task.senderEmail != null) ...[
                    Icon(Icons.mail_outline, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        task.senderName ?? task.senderEmail ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: isOverdue ? AppColors.critical : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.formatDeadline(task.deadline, l, locale: locale),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isOverdue ? AppColors.critical : null,
                          fontWeight: isOverdue ? FontWeight.w600 : null,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
