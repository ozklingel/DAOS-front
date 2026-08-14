import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daos/core/errors/app_exception.dart';
import 'package:daos/features/settings/data/models/whatsapp_chat_model.dart';
import 'package:daos/features/settings/presentation/providers/settings_provider.dart';
import 'package:daos/l10n/app_localizations.dart';
import 'package:daos/theme/app_colors.dart';

Future<void> showWhatsAppChatsSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.darkBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _WhatsAppChatsSheet(),
  );
}

class _WhatsAppChatsSheet extends ConsumerStatefulWidget {
  const _WhatsAppChatsSheet();

  @override
  ConsumerState<_WhatsAppChatsSheet> createState() => _WhatsAppChatsSheetState();
}

class _WhatsAppChatsSheetState extends ConsumerState<_WhatsAppChatsSheet> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String? _loadWarning;
  bool _chatSyncAvailable = false;
  List<WhatsAppChatModel> _chats = const [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await ref.read(settingsProvider.notifier).getWhatsAppChats();
      if (!mounted) return;
      setState(() {
        _chatSyncAvailable = response.chatSyncAvailable;
        _chats = response.chats;
        _loadWarning = response.greenLoadError;
        _loading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _save(AppLocalizations l) async {
    setState(() => _saving = true);
    try {
      final response =
          await ref.read(settingsProvider.notifier).syncWhatsAppChats(_chats);
      if (!mounted) return;
      setState(() {
        _chats = response.chats;
        _chatSyncAvailable = response.chatSyncAvailable;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.whatsappChatsSaved(response.syncedCount))),
      );
      Navigator.pop(context);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.errorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final filtered = _query.isEmpty
        ? _chats
        : _chats
            .where(
              (chat) => chat.displayName.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Text(
            l.whatsappSelectChatsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l.whatsappSelectChatsHint,
            style: const TextStyle(color: AppColors.darkTextSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _load, child: Text(l.tryAgain)),
                ],
              ),
            )
          else if (!_chatSyncAvailable)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l.whatsappChatSyncUnavailable,
                style: const TextStyle(color: AppColors.darkTextSecondary, height: 1.4),
              ),
            )
          else ...[
            if (_loadWarning != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _loadWarning!,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              decoration: InputDecoration(
                hintText: l.searchChatsHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        l.whatsappNoChatsFound,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.darkTextSecondary),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final chat = filtered[index];
                        final chatIndex = _chats.indexWhere((c) => c.chatId == chat.chatId);
                        return SwitchListTile(
                          value: chat.syncEnabled,
                          onChanged: chatIndex < 0
                              ? null
                              : (enabled) {
                                  setState(() {
                                    _chats = List.of(_chats);
                                    _chats[chatIndex] =
                                        _chats[chatIndex].copyWith(syncEnabled: enabled);
                                  });
                                },
                          title: Text(chat.displayName),
                          subtitle: Text(
                            chat.isGroup ? l.whatsappChatTypeGroup : l.whatsappChatTypeDirect,
                            style: const TextStyle(fontSize: 12),
                          ),
                          secondary: Icon(
                            chat.isGroup ? Icons.groups_outlined : Icons.person_outline,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : () => _save(l),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l.whatsappChatsSaveButton),
            ),
          ],
        ],
      ),
      ),
    );
  }
}
