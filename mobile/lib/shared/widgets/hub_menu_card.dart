import 'package:flutter/material.dart';
import 'package:taskmail/features/dashboard/presentation/widgets/glass_card.dart';
import 'package:taskmail/theme/app_colors.dart';

class HubMenuCard extends StatelessWidget {
  const HubMenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitleLines,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final List<String> subtitleLines;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                if (subtitleLines.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...subtitleLines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        line,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.darkTextSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
        ],
      ),
    );
  }
}

IconData hubIconForKey(String key) {
  switch (key) {
    case 'document':
      return Icons.description_outlined;
    case 'ideas':
      return Icons.lightbulb_outline;
    case 'notebook':
      return Icons.menu_book_outlined;
    case 'link':
      return Icons.link;
    case 'archive':
      return Icons.inventory_2_outlined;
    case 'car':
      return Icons.directions_car_outlined;
    case 'finance':
      return Icons.home_work_outlined;
    case 'contacts':
      return Icons.groups_outlined;
    case 'work':
      return Icons.work_outline;
    case 'health':
      return Icons.fitness_center;
    case 'cart':
      return Icons.shopping_cart_outlined;
    case 'restaurant':
      return Icons.restaurant_outlined;
    case 'home':
      return Icons.home_outlined;
    case 'salary':
      return Icons.payments_outlined;
    default:
      return Icons.task_alt_outlined;
  }
}

String formatIls(double amount) {
  final sign = amount >= 0 ? '+' : '-';
  final value = amount.abs().toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
  return '$sign ₪ $value';
}
