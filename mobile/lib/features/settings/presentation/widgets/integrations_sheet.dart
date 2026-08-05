import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:daos/core/errors/app_exception.dart';
import 'package:daos/features/auth/presentation/providers/auth_provider.dart';
import 'package:daos/features/settings/data/models/outlook_inbox_preview_model.dart';
import 'package:daos/features/settings/presentation/providers/settings_provider.dart';
import 'package:daos/l10n/app_localizations.dart';
import 'package:daos/routes/route_names.dart';
import 'package:daos/theme/app_colors.dart';

class IntegrationsSheet extends ConsumerStatefulWidget {
  const IntegrationsSheet({super.key});

  @override
  ConsumerState<IntegrationsSheet> createState() => _IntegrationsSheetState();
}

class _IntegrationsSheetState extends ConsumerState<IntegrationsSheet> {
  bool _isConnecting = false;
  bool _isLinkingWhatsApp = false;
  bool _isTestingOutlookInbox = false;

  bool get _isDevAccount {
    final email = ref.read(authStateProvider).user?.email ?? '';
    return email.endsWith('@daos.local') || email.endsWith('@taskmail.local');
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

  Future<void> _previewOutlookInbox(AppLocalizations l) async {
    setState(() => _isTestingOutlookInbox = true);
    try {
      final preview = await ref.read(settingsProvider.notifier).previewOutlookInbox();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => _OutlookInboxPreviewDialog(l: l, preview: preview),
      );
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isTestingOutlookInbox = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).user;
    final gmailConnected = user?.gmailConnected ?? false;
    final outlookConnected = user?.outlookConnected ?? false;
    final whatsappConnected = user?.whatsappConnected ?? false;

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
            if (outlookConnected) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isTestingOutlookInbox ? null : () => _previewOutlookInbox(l),
                icon: _isTestingOutlookInbox
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.inbox_outlined),
                label: Text(l.outlookTestInboxButton),
              ),
            ],
            if (gmailConnected || outlookConnected) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  try {
                    final result = await ref.read(settingsProvider.notifier).syncEmails();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result.created > 0
                                ? l.syncCompleteTasks(result.created)
                                : l.syncCompleteScanned(result.scanned),
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

class _OutlookInboxPreviewDialog extends StatelessWidget {
  const _OutlookInboxPreviewDialog({
    required this.l,
    required this.preview,
  });

  final AppLocalizations l;
  final OutlookInboxPreviewModel preview;

  @override
  Widget build(BuildContext context) {
    final error = preview.error;
    final messages = preview.messages;
    final mailbox = preview.mailboxEmail ?? preview.accountEmail;

    return AlertDialog(
      title: Text(l.outlookInboxPreviewTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: error != null && !preview.fetchOk
            ? Text('$error\n\n${l.outlookInboxPreviewError}')
            : messages.isEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.outlookInboxPreviewSummary(
                          preview.inboxCount,
                          preview.sentCount,
                          preview.junkCount,
                          mailbox,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(l.outlookInboxPreviewEmpty),
                      const SizedBox(height: 8),
                      Text(
                        l.outlookInboxSelfSentHint,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l.outlookInboxPreviewSummary(
                            preview.inboxCount,
                            preview.sentCount,
                            preview.junkCount,
                            mailbox,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.outlookInboxSelfSentHint,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...messages.map((m) {
                          final flags = <String>[
                            l.outlookInboxFolderLabel(m.folder),
                            if (m.isHebrew) l.outlookInboxHebrew,
                            if (m.hasTaskSignal) l.outlookInboxTaskSignal,
                            if (m.alreadyIngested) l.outlookInboxAlreadyIngested,
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.subject,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                if (m.sender.isNotEmpty)
                                  Text(
                                    m.sender,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.darkTextSecondary,
                                    ),
                                  ),
                                if (flags.isNotEmpty)
                                  Text(
                                    flags.join(' · '),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.success,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
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
