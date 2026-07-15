import 'package:flutter/material.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/shared/models/task_enums.dart';
import 'package:taskmail/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final TaskStatus status;

  Color get _color {
    switch (status) {
      case TaskStatus.open:
        return AppColors.info;
      case TaskStatus.completed:
        return AppColors.success;
      case TaskStatus.snoozed:
        return AppColors.warning;
      case TaskStatus.dismissed:
        return AppColors.textTertiary;
      case TaskStatus.overdue:
        return AppColors.critical;
    }
  }

  Color get _background {
    switch (status) {
      case TaskStatus.open:
        return AppColors.infoBg;
      case TaskStatus.completed:
        return AppColors.successBg;
      case TaskStatus.snoozed:
        return AppColors.warningBg;
      case TaskStatus.dismissed:
        return AppColors.surfaceElevated;
      case TaskStatus.overdue:
        return AppColors.criticalBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        l.taskStatusLabel(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
