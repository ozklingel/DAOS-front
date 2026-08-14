import 'package:daos/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:daos/features/settings/data/models/outlook_inbox_preview_model.dart';
import 'package:daos/features/settings/data/models/whatsapp_chat_model.dart';
import 'package:daos/features/settings/domain/entities/app_settings.dart';
import 'package:daos/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._remote);

  final SettingsRemoteDataSource _remote;

  @override
  Future<AppSettings> getSettings() async {
    final model = await _remote.getSettings();
    return model.toEntity();
  }

  @override
  Future<AppSettings> updateSettings(AppSettings settings) async {
    final model = await _remote.updateSettings({
      'pushNotificationsEnabled': settings.pushNotificationsEnabled,
      'dailyBriefEnabled': settings.dailyBriefEnabled,
      'emailSyncEnabled': settings.emailSyncEnabled,
      'dailyBriefTime': settings.dailyBriefTime,
      'language': settings.language,
    });
    return model.toEntity();
  }

  @override
  Future<({int created, int scanned})> syncEmails() => _remote.syncEmails();

  @override
  Future<OutlookInboxPreviewModel> previewOutlookInbox() => _remote.previewOutlookInbox();

  @override
  Future<WhatsAppChatsResponseModel> getWhatsAppChats() => _remote.getWhatsAppChats();

  @override
  Future<WhatsAppChatsResponseModel> syncWhatsAppChats(List<WhatsAppChatModel> chats) =>
      _remote.syncWhatsAppChats(chats);
}
