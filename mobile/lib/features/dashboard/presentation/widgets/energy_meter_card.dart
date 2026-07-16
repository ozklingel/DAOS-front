import 'package:flutter/material.dart';
import 'package:taskmail/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:taskmail/features/dashboard/presentation/widgets/glass_card.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/theme/app_colors.dart';

class EnergyMeterCard extends StatelessWidget {
  const EnergyMeterCard({super.key, required this.meter});

  final EnergyMeter meter;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ratio = meter.budget > 0 ? (meter.used / meter.budget).clamp(0.0, 1.0) : 0.0;
    final barColor = ratio > 0.85
        ? AppColors.critical
        : ratio > 0.6
            ? AppColors.warning
            : AppColors.primary;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, size: 16, color: AppColors.warning),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l.energyMeterTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l.energyMeterSummary(meter.used, meter.budget, meter.remaining),
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.darkGlassBorder,
              color: barColor,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _CountPill(label: l.energyHigh, count: meter.highCount),
              _CountPill(label: l.energyMedium, count: meter.mediumCount),
              _CountPill(label: l.energyLow, count: meter.lowCount),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.categoryBreakdown(
              meter.workCount,
              meter.errandsCount,
              meter.healthCount,
            ),
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.darkTextSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label $count',
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
