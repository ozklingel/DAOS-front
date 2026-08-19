import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daos/core/di/providers.dart';
import 'package:daos/features/auth/presentation/providers/auth_provider.dart';
import 'package:daos/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:daos/features/hub/presentation/providers/hub_providers.dart';
import 'package:daos/features/settings/data/models/outlook_inbox_preview_model.dart';
import 'package:daos/features/settings/data/models/whatsapp_chat_model.dart';
import 'package:daos/features/settings/domain/entities/app_settings.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});

final emailSyncInProgressProvider = StateProvider<bool>((ref) => false);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    return ref.read(settingsRepositoryProvider).getSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).updateSettings(settings),
    );
  }

  Future<({int created, int scanned})> syncEmails() async {
    return ref.read(settingsRepositoryProvider).syncEmails();
  }

  /// Sync inbox when connected. Refreshes dashboard/tasks. Returns null if skipped.
  Future<({int created, int scanned})?> syncEmailsAndRefresh({
    bool ignoreEnabledFlag = false,
  }) async {
    final user = ref.read(authStateProvider).user;
    if (user == null) return null;
    if (!user.gmailConnected && !user.outlookConnected) return null;

    if (!ignoreEnabledFlag) {
      final settings = state.valueOrNull ?? await future;
      if (!settings.emailSyncEnabled) return null;
    }

    if (ref.read(emailSyncInProgressProvider)) return null;
    ref.read(emailSyncInProgressProvider.notifier).state = true;
    try {
      final result = await syncEmails();
      ref.invalidate(dashboardProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(infoHubProvider);
      return result;
    } finally {
      ref.read(emailSyncInProgressProvider.notifier).state = false;
    }
  }

  Future<OutlookInboxPreviewModel> previewOutlookInbox() async {
    return ref.read(settingsRepositoryProvider).previewOutlookInbox();
  }

  Future<WhatsAppChatsResponseModel> getWhatsAppChats() async {
    return ref.read(settingsRepositoryProvider).getWhatsAppChats();
  }

  Future<WhatsAppChatsResponseModel> syncWhatsAppChats(List<WhatsAppChatModel> chats) async {
    return ref.read(settingsRepositoryProvider).syncWhatsAppChats(chats);
  }
}
