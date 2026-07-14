import 'package:flutter/material.dart';
import 'package:taskmail/shared/models/task_enums.dart';
import 'package:taskmail/theme/app_colors.dart';

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final TaskPriority priority;

  Color get _color {
    switch (priority) {
      case TaskPriority.critical:
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.none:
        return AppColors.priorityNone;
    }
  }

  Color get _background {
    switch (priority) {
      case TaskPriority.critical:
      case TaskPriority.high:
        return AppColors.criticalBg;
      case TaskPriority.medium:
        return AppColors.warningBg;
      case TaskPriority.low:
        return AppColors.successBg;
      case TaskPriority.none:
        return AppColors.surfaceElevated;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.label,
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
