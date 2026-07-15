import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmail/core/errors/app_exception.dart';
import 'package:taskmail/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmail/features/settings/presentation/providers/settings_provider.dart';
import 'package:taskmail/routes/route_names.dart';
import 'package:taskmail/shared/widgets/loading_error_widgets.dart';
import 'package:taskmail/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const ShimmerLoading(itemCount: 4),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(settingsProvider),
        ),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (user != null) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    (user.name ?? user.email)[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(user.name ?? 'User'),
                subtitle: Text(user.email),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Email Connections',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _ConnectionTile(
              provider: 'Gmail',
              icon: Icons.mail,
              connected: user?.gmailConnected ?? false,
              onConnect: () => _connectGmail(context, ref),
              onDisconnect: () => _disconnectGmail(context, ref),
            ),
            _ConnectionTile(
              provider: 'Outlook',
              icon: Icons.email_outlined,
              connected: user?.outlookConnected ?? false,
              onConnect: () => _connectOutlook(context, ref),
              onDisconnect: () => _disconnectOutlook(context, ref),
            ),
            if (user?.gmailConnected == true || user?.outlookConnected == true) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _syncEmails(context, ref),
                icon: const Icon(Icons.sync, size: 18),
                label: const Text('Sync emails now'),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Push notifications'),
              subtitle: const Text('Get reminded about urgent tasks'),
              value: settings.pushNotificationsEnabled,
              onChanged: (v) => ref.read(settingsProvider.notifier).saveSettings(
                    settings.copyWith(pushNotificationsEnabled: v),
                  ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Daily brief'),
              subtitle: const Text('Receive AI summary each morning'),
              value: settings.dailyBriefEnabled,
              onChanged: (v) => ref.read(settingsProvider.notifier).saveSettings(
                    settings.copyWith(dailyBriefEnabled: v),
                  ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Email sync'),
              subtitle: const Text('Continuously analyze new emails'),
              value: settings.emailSyncEnabled,
              onChanged: (v) => ref.read(settingsProvider.notifier).saveSettings(
                    settings.copyWith(emailSyncEnabled: v),
                  ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go(RouteNames.login);
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.critical,
                side: BorderSide(color: AppColors.critical.withValues(alpha: 0.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connectGmail(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authStateProvider.notifier).connectGmail();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gmail connected successfully')),
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _connectOutlook(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authStateProvider.notifier).connectOutlook();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Outlook connected successfully')),
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _disconnectGmail(BuildContext context, WidgetRef ref) async {
    await ref.read(authStateProvider.notifier).disconnectGmail();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gmail disconnected')),
      );
    }
  }

  Future<void> _disconnectOutlook(BuildContext context, WidgetRef ref) async {
    await ref.read(authStateProvider.notifier).disconnectOutlook();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outlook disconnected')),
      );
    }
  }

  Future<void> _syncEmails(BuildContext context, WidgetRef ref) async {
    try {
      final created = await ref.read(settingsProvider.notifier).syncEmails();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              created > 0
                  ? 'Sync complete — $created new task${created == 1 ? '' : 's'} created'
                  : 'Sync complete — no new actionable emails found',
            ),
          ),
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }
}

class _ConnectionTile extends StatelessWidget {
  const _ConnectionTile({
    required this.provider,
    required this.icon,
    required this.connected,
    required this.onConnect,
    required this.onDisconnect,
  });

  final String provider;
  final IconData icon;
  final bool connected;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(provider),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: connected ? AppColors.successBg : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              connected ? 'Connected' : 'Not connected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: connected ? AppColors.success : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: connected ? onDisconnect : onConnect,
            child: Text(connected ? 'Disconnect' : 'Connect'),
          ),
        ],
      ),
    );
  }
}
