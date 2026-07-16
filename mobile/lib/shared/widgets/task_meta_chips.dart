import 'package:flutter/material.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/shared/models/task_enums.dart';
import 'package:taskmail/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.category});

  final TaskCategory category;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _MetaChip(
      label: l.taskCategoryLabel(category),
      color: _categoryColor(category),
    );
  }
}

class EnergyChip extends StatelessWidget {
  const EnergyChip({super.key, required this.level});

  final EnergyLevel level;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _MetaChip(
      label: l.energyLevelLabel(level),
      color: _energyColor(level),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

Color _categoryColor(TaskCategory category) {
  switch (category) {
    case TaskCategory.work:
      return AppColors.primary;
    case TaskCategory.errands:
      return AppColors.warning;
    case TaskCategory.health:
      return AppColors.success;
    case TaskCategory.general:
      return AppColors.textSecondary;
  }
}

Color _energyColor(EnergyLevel level) {
  switch (level) {
    case EnergyLevel.high:
      return AppColors.critical;
    case EnergyLevel.medium:
      return AppColors.warning;
    case EnergyLevel.low:
      return AppColors.success;
  }
}
