import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmail/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmail/features/dashboard/presentation/widgets/glass_card.dart';
import 'package:taskmail/features/hub/data/models/hub_models.dart';
import 'package:taskmail/features/hub/presentation/providers/hub_providers.dart';
import 'package:taskmail/features/info/presentation/widgets/asset_reminder_sheet.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/routes/route_names.dart';
import 'package:taskmail/shared/widgets/daos_page_scaffold.dart';
import 'package:taskmail/shared/widgets/hub_menu_card.dart';
import 'package:taskmail/shared/widgets/loading_error_widgets.dart';
import 'package:taskmail/theme/app_colors.dart';

class InfoScreen extends ConsumerStatefulWidget {
  const InfoScreen({super.key});

  @override
  ConsumerState<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends ConsumerState<InfoScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).user;
    final infoAsync = ref.watch(infoHubProvider);

    return DaosPageScaffold(
      title: l.infoTitle,
      searchHint: l.searchInInfo,
      avatarInitial: user?.name ?? user?.email,
      avatarUrl: user?.avatarUrl,
      onSearchChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
      body: infoAsync.when(
        loading: () => const ShimmerLoading(itemCount: 4),
        error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(infoHubProvider)),
        data: (hub) {
          final alerts = hub.activeAlerts.where((r) {
            if (_query.isEmpty) return true;
            return r.title.toLowerCase().contains(_query) ||
                (r.documentLabel ?? '').toLowerCase().contains(_query);
          }).toList();

          final categories = hub.categories.where((c) {
            if (_query.isEmpty) return true;
            if (c.title.toLowerCase().contains(_query)) return true;
            return c.items.any((item) => item.toLowerCase().contains(_query));
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              if (alerts.isNotEmpty) ...[
                Text(
                  l.assetAlertsTitle(alerts.length),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                ...alerts.map(
                  (reminder) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AssetReminderTile(
                      reminder: reminder,
                      l: l,
                      onTap: () => showAssetReminderSheet(context, ref, reminder),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              ...categories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HubMenuCard(
                    title: category.title,
                    icon: hubIconForKey(category.icon),
                    subtitleLines: category.items,
                    onTap: () {
                      final match = _findReminderForCategory(hub.reminders, category.id);
                      if (match != null) {
                        showAssetReminderSheet(context, ref, match);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${category.title} — ${l.comingSoon}')),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  AssetReminderData? _findReminderForCategory(
    List<AssetReminderData> reminders,
    String categoryId,
  ) {
    if (reminders.isEmpty) return null;
    Iterable<AssetReminderData> filtered;
    switch (categoryId) {
      case 'vehicle':
        filtered = reminders.where((r) => r.assetType == 'vehicle_test');
      case 'insurance':
        filtered = reminders.where(
          (r) => r.assetType == 'car_insurance' || r.assetType == 'home_insurance',
        );
      case 'documents':
        filtered = reminders.where((r) => r.assetType == 'document');
      default:
        return null;
    }
    final list = filtered.toList();
    return list.isEmpty ? null : list.first;
  }
}

class _AssetReminderTile extends StatelessWidget {
  const _AssetReminderTile({
    required this.reminder,
    required this.l,
    required this.onTap,
  });

  final AssetReminderData reminder;
  final AppLocalizations l;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(hubIconForKey(reminder.icon), color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                if (reminder.documentLabel != null)
                  Text(
                    reminder.documentLabel!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                Text(
                  assetDaysLabel(l, reminder),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          AssetStatusBadge(status: reminder.status, l: l),
        ],
      ),
    );
  }
}

class AssetAlertsDashboardCard extends ConsumerWidget {
  const AssetAlertsDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final infoAsync = ref.watch(infoHubProvider);

    return infoAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (hub) {
        final alerts = hub.activeAlerts;
        if (alerts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.assetAlertsTitle(alerts.length),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              onTap: () => context.go(RouteNames.info),
              child: Column(
                children: alerts.take(2).map((reminder) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(hubIconForKey(reminder.icon), size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reminder.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                        ),
                        AssetStatusBadge(status: reminder.status, l: l),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
