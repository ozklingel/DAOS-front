import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmail/core/locale/locale_provider.dart';
import 'package:taskmail/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmail/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:taskmail/features/daily_brief/presentation/providers/daily_brief_provider.dart';
import 'package:taskmail/features/settings/presentation/providers/settings_provider.dart';
import 'package:taskmail/features/settings/presentation/widgets/integrations_sheet.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/routes/route_names.dart';
import 'package:taskmail/shared/widgets/daos_page_scaffold.dart';
import 'package:taskmail/shared/widgets/hub_menu_card.dart';
import 'package:taskmail/shared/widgets/loading_error_widgets.dart';
import 'package:taskmail/theme/app_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).user;
    final settingsAsync = ref.watch(settingsProvider);
    final currentLocale = ref.watch(localeProvider).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DaosPageScaffold(
      title: l.settingsTitle,
      searchHint: l.searchInSettings,
      avatarInitial: user?.name ?? user?.email,
      avatarUrl: user?.avatarUrl,
      onSearchChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
      body: settingsAsync.when(
        loading: () => const ShimmerLoading(itemCount: 4),
        error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(settingsProvider)),
        data: (settings) {
          final cards = [
            _SettingsCardData(
              title: l.accountAndProfile,
              icon: Icons.manage_accounts_outlined,
              lines: [l.updateDetails],
              keywords: [l.accountAndProfile, l.updateDetails, l.profileTitle],
              onTap: () => context.push(RouteNames.profile),
            ),
            _SettingsCardData(
              title: l.displayAndTheme,
              icon: Icons.dark_mode_outlined,
              lines: [
                '${l.darkModeOn}: ${isDark ? 'ON' : 'OFF'}',
                l.choosePrimaryColor,
              ],
              keywords: [l.displayAndTheme, l.language, l.hebrew, l.english],
              onTap: () => _showLanguageSheet(context, ref, settings, currentLocale),
            ),
            _SettingsCardData(
              title: l.notifications,
              icon: Icons.notifications_outlined,
              lines: [l.notificationsManagement],
              keywords: [l.notifications, l.pushNotifications, l.emailSync],
              onTap: () => _showNotificationsSheet(context, ref, settings),
            ),
            _SettingsCardData(
              title: l.integrations,
              icon: Icons.link,
              lines: [
                user?.gmailConnected == true
                    ? '${l.gmail}: ${l.connected}'
                    : '${l.gmail}: ${l.notConnected} — ${l.connectGmailButton}',
                l.connectExternalCalendar,
              ],
              keywords: [l.integrations, l.gmail, l.outlook, l.syncEmailsNow],
              onTap: () => _showIntegrationsSheet(context),
            ),
            _SettingsCardData(
              title: l.securityAndPrivacy,
              icon: Icons.security_outlined,
              lines: [l.securitySettings],
              keywords: [l.securityAndPrivacy],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.comingSoon)),
                );
              },
            ),
            _SettingsCardData(
              title: l.aboutSection,
              icon: Icons.info_outline,
              lines: [l.appVersionLabel, l.termsOfUse],
              keywords: [l.aboutSection, l.signOut],
              onTap: () => _showAboutSheet(context, ref, l),
            ),
          ];

          final filtered = cards.where((c) {
            if (_query.isEmpty) return true;
            return c.keywords.any((k) => k.toLowerCase().contains(_query)) ||
                c.title.toLowerCase().contains(_query);
          }).toList();

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final card = filtered[index];
              return HubMenuCard(
                title: card.title,
                icon: card.icon,
                subtitleLines: card.lines,
                onTap: card.onTap,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showLanguageSheet(
    BuildContext context,
    WidgetRef ref,
    dynamic settings,
    String currentLocale,
  ) async {
    final l = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.language, style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(l.english)),
                ButtonSegment(value: 'he', label: Text(l.hebrew)),
              ],
              selected: {currentLocale},
              onSelectionChanged: (selected) async {
                final code = selected.first;
                await ref.read(localeProvider.notifier).setLocale(code);
                await ref.read(settingsProvider.notifier).saveSettings(
                      settings.copyWith(language: code),
                    );
                ref.invalidate(dashboardProvider);
                ref.invalidate(dailyBriefProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNotificationsSheet(
    BuildContext context,
    WidgetRef ref,
    dynamic settings,
  ) async {
    final l = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text(l.pushNotifications),
              subtitle: Text(l.pushNotificationsSubtitle),
              value: settings.pushNotificationsEnabled,
              onChanged: (v) => ref.read(settingsProvider.notifier).saveSettings(
                    settings.copyWith(pushNotificationsEnabled: v),
                  ),
            ),
            SwitchListTile(
              title: Text(l.dailyBriefSetting),
              subtitle: Text(l.dailyBriefSubtitle),
              value: settings.dailyBriefEnabled,
              onChanged: (v) => ref.read(settingsProvider.notifier).saveSettings(
                    settings.copyWith(dailyBriefEnabled: v),
                  ),
            ),
            SwitchListTile(
              title: Text(l.emailSync),
              subtitle: Text(l.emailSyncSubtitle),
              value: settings.emailSyncEnabled,
              onChanged: (v) => ref.read(settingsProvider.notifier).saveSettings(
                    settings.copyWith(emailSyncEnabled: v),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showIntegrationsSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkBackgroundMid,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const IntegrationsSheet(),
    );
  }

  Future<void> _showAboutSheet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.appVersionLabel, style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l.termsOfUse),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (ctx.mounted) context.go(RouteNames.login);
              },
              icon: const Icon(Icons.logout, size: 18),
              label: Text(l.signOut),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.critical,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCardData {
  const _SettingsCardData({
    required this.title,
    required this.icon,
    required this.lines,
    required this.keywords,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final List<String> lines;
  final List<String> keywords;
  final VoidCallback onTap;
}
