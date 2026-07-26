import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmail/core/errors/app_exception.dart';
import 'package:taskmail/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmail/features/settings/presentation/providers/settings_provider.dart';
import 'package:taskmail/features/sms/presentation/sms_sync_provider.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/routes/route_names.dart';
import 'package:taskmail/theme/app_colors.dart';

class IntegrationsSheet extends ConsumerStatefulWidget {
  const IntegrationsSheet({super.key});

  @override
  ConsumerState<IntegrationsSheet> createState() => _IntegrationsSheetState();
}

class _IntegrationsSheetState extends ConsumerState<IntegrationsSheet> {
  bool _isConnecting = false;
  bool _isLinkingWhatsApp = false;
  bool _isLinkingSms = false;

  bool get _isDevAccount {
    final email = ref.read(authStateProvider).user?.email ?? '';
    return email.endsWith('@taskmail.local');
  }

  Future<void> _connectGmail(AppLocalizations l) async {
    if (_isDevAccount) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.gmailDevLoginHint)),
      );
      return;
    }

    setState(() => _isConnecting = true);
    try {
      await ref.read(authStateProvider.notifier).connectGmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.gmailConnectedSuccess)),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Future<void> _connectWhatsApp(AppLocalizations l) async {
    final controller = TextEditingController(
      text: ref.read(authStateProvider).user?.whatsappPhone ?? '',
    );
    final phone = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l.connectWhatsAppButton),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l.whatsappPhoneLabel),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('×')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l.connectWhatsAppButton),
            ),
          ],
        );
      },
    );
    if (phone == null || phone.isEmpty || !mounted) return;

    setState(() => _isLinkingWhatsApp = true);
    try {
      await ref.read(authStateProvider.notifier).connectWhatsApp(phone);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.whatsappLinkedSuccess)),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLinkingWhatsApp = false);
    }
  }

  Future<void> _linkSmsPhone(AppLocalizations l) async {
    final controller = TextEditingController(
      text: ref.read(authStateProvider).user?.smsPhone ?? '',
    );
    final phone = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l.connectSmsButton),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l.smsPhoneLabel),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('×')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l.connectSmsButton),
            ),
          ],
        );
      },
    );
    if (phone == null || phone.isEmpty || !mounted) return;

    setState(() => _isLinkingSms = true);
    try {
      await ref.read(authStateProvider.notifier).connectSms(phone);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.smsLinkedSuccess)),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLinkingSms = false);
    }
  }

  Future<void> _pasteSms(AppLocalizations l) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l.smsPasteTitle),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: InputDecoration(labelText: l.smsPasteHint),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('×')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l.smsPasteButton),
            ),
          ],
        );
      },
    );
    if (text == null || text.isEmpty || !mounted) return;
    await ref.read(smsSyncProvider.notifier).pasteAndIngest(text);
    if (!mounted) return;
    _showSmsResult(l);
  }

  void _showSmsResult(AppLocalizations l) {
    final sms = ref.read(smsSyncProvider);
    if (sms.error == 'sms_permission_denied') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.smsPermissionDenied)),
      );
      return;
    }
    if (sms.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(sms.error!)),
      );
      return;
    }
    final created = sms.lastResult?.createdCount ?? 0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(created > 0 ? l.smsSyncResult(created) : l.smsSyncNoTasks),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).user;
    final smsState = ref.watch(smsSyncProvider);
    final gmailConnected = user?.gmailConnected ?? false;
    final outlookConnected = user?.outlookConnected ?? false;
    final whatsappConnected = user?.whatsappConnected ?? false;
    final smsPhoneLinked = user?.smsConnected ?? false;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.integrations,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _ConnectionCard(
              title: l.whatsapp,
              connected: whatsappConnected,
              connectedLabel: l.connected,
              notConnectedLabel: l.notConnected,
              hint: whatsappConnected && user?.whatsappPhone != null
                  ? '${l.whatsappConnectHint}\n${user!.whatsappPhone}'
                  : l.whatsappConnectHint,
              connectLabel: l.connectWhatsAppButton,
              disconnectLabel: l.disconnectWhatsAppButton,
              isLoading: _isLinkingWhatsApp,
              onConnect: () => _connectWhatsApp(l),
              onDisconnect: () => ref.read(authStateProvider.notifier).disconnectWhatsApp(),
            ),
            const SizedBox(height: 12),
            _SmsCard(
              l: l,
              smsState: smsState,
              phoneLinked: smsPhoneLinked,
              linkedPhone: user?.smsPhone,
              isLinkingPhone: _isLinkingSms,
              onEnable: () async {
                await ref.read(smsSyncProvider.notifier).enableAndSync();
                if (mounted) _showSmsResult(l);
              },
              onDisable: () => ref.read(smsSyncProvider.notifier).disable(),
              onSyncNow: () async {
                await ref.read(smsSyncProvider.notifier).syncNow();
                if (mounted) _showSmsResult(l);
              },
              onPaste: () => _pasteSms(l),
              onLinkPhone: () => _linkSmsPhone(l),
              onUnlinkPhone: () => ref.read(authStateProvider.notifier).disconnectSms(),
            ),
            const SizedBox(height: 12),
            _ConnectionCard(
              title: l.gmail,
              connected: gmailConnected,
              connectedLabel: l.connected,
              notConnectedLabel: l.notConnected,
              hint: _isDevAccount
                  ? l.gmailDevLoginHint
                  : (kIsWeb ? l.gmailWebHint : l.gmailConnectHint),
              isLoading: _isConnecting,
              connectLabel: l.connectGmailButton,
              disconnectLabel: l.disconnectGmailButton,
              onConnect: () => _connectGmail(l),
              onDisconnect: () => ref.read(authStateProvider.notifier).disconnectGmail(),
            ),
            if (_isDevAccount) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.go(RouteNames.login);
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(l.signOutAndUseGoogle),
              ),
            ],
            const SizedBox(height: 12),
            _ConnectionCard(
              title: l.outlook,
              connected: outlookConnected,
              connectedLabel: l.connected,
              notConnectedLabel: l.notConnected,
              hint: l.outlookConnectHint,
              connectLabel: l.connect,
              disconnectLabel: l.disconnect,
              isLoading: _isConnecting,
              onConnect: () async {
                setState(() => _isConnecting = true);
                try {
                  await ref.read(authStateProvider.notifier).connectOutlook();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.outlookConnectedSuccess)),
                    );
                  }
                } on AppException catch (e) {
                  // Web redirects away; ignore redirect message
                  if (e.message.contains('Redirecting')) return;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.errorMessage(e))),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isConnecting = false);
                }
              },
              onDisconnect: () => ref.read(authStateProvider.notifier).disconnectOutlook(),
            ),
            if (gmailConnected || outlookConnected) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  try {
                    final created = await ref.read(settingsProvider.notifier).syncEmails();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            created > 0 ? l.syncCompleteTasks(created) : l.syncCompleteNoTasks,
                          ),
                        ),
                      );
                    }
                  } on AppException catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.errorMessage(e))),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.sync),
                label: Text(l.syncEmailsNow),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SmsCard extends StatelessWidget {
  const _SmsCard({
    required this.l,
    required this.smsState,
    required this.phoneLinked,
    required this.linkedPhone,
    required this.isLinkingPhone,
    required this.onEnable,
    required this.onDisable,
    required this.onSyncNow,
    required this.onPaste,
    required this.onLinkPhone,
    required this.onUnlinkPhone,
  });

  final AppLocalizations l;
  final SmsSyncUiState smsState;
  final bool phoneLinked;
  final String? linkedPhone;
  final bool isLinkingPhone;
  final VoidCallback onEnable;
  final VoidCallback onDisable;
  final VoidCallback onSyncNow;
  final VoidCallback onPaste;
  final VoidCallback onLinkPhone;
  final VoidCallback onUnlinkPhone;

  @override
  Widget build(BuildContext context) {
    final connected = smsState.enabled || phoneLinked;
    final hint = smsState.supported
        ? '${l.smsAndroidHint}${phoneLinked && linkedPhone != null ? '\n$linkedPhone' : ''}'
        : '${l.smsManualHint}${phoneLinked && linkedPhone != null ? '\n$linkedPhone' : ''}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkGlassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.sms,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: connected ? AppColors.successBg : AppColors.darkBackgroundMid,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  connected ? l.connected : l.notConnected,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: connected ? AppColors.success : AppColors.darkTextTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.darkTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (smsState.supported) ...[
            SizedBox(
              width: double.infinity,
              child: smsState.enabled
                  ? OutlinedButton(
                      onPressed: smsState.isBusy ? null : onDisable,
                      child: Text(l.smsDisableSync),
                    )
                  : FilledButton(
                      onPressed: smsState.isBusy ? null : onEnable,
                      child: smsState.isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l.smsEnableSync),
                    ),
            ),
            if (smsState.enabled) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: smsState.isBusy ? null : onSyncNow,
                  icon: const Icon(Icons.sms),
                  label: Text(l.smsSyncNow),
                ),
              ),
            ],
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: smsState.isBusy ? null : onPaste,
              child: Text(l.smsPasteButton),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: phoneLinked
                ? OutlinedButton(
                    onPressed: isLinkingPhone ? null : onUnlinkPhone,
                    child: Text(l.disconnectSmsButton),
                  )
                : OutlinedButton(
                    onPressed: isLinkingPhone ? null : onLinkPhone,
                    child: isLinkingPhone
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l.connectSmsButton),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({
    required this.title,
    required this.connected,
    required this.connectedLabel,
    required this.notConnectedLabel,
    required this.hint,
    required this.connectLabel,
    required this.disconnectLabel,
    required this.onConnect,
    required this.onDisconnect,
    this.isLoading = false,
  });

  final String title;
  final bool connected;
  final String connectedLabel;
  final String notConnectedLabel;
  final String hint;
  final String connectLabel;
  final String disconnectLabel;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkGlassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: connected ? AppColors.successBg : AppColors.darkBackgroundMid,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  connected ? connectedLabel : notConnectedLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: connected ? AppColors.success : AppColors.darkTextTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.darkTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: connected
                ? OutlinedButton(
                    onPressed: onDisconnect,
                    child: Text(disconnectLabel),
                  )
                : FilledButton(
                    onPressed: isLoading ? null : onConnect,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(connectLabel),
                  ),
          ),
        ],
      ),
    );
  }
}
