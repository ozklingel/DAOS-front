import 'package:dio/dio.dart';
import 'package:daos/core/constants/api_constants.dart';
import 'package:daos/core/network/api_client.dart';
import 'package:daos/features/settings/data/models/outlook_inbox_preview_model.dart';
import 'package:daos/features/settings/data/models/settings_model.dart';
import 'package:daos/features/settings/data/models/whatsapp_chat_model.dart';

class SettingsRemoteDataSource {
  SettingsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<SettingsModel> getSettings() async {
    final data = await _client.get<Map<String, dynamic>>(
      ApiConstants.settings,
      parser: (d) => d as Map<String, dynamic>,
    );
    return SettingsModel.fromJson(data);
  }

  Future<SettingsModel> updateSettings(Map<String, dynamic> updates) async {
    final data = await _client.patch<Map<String, dynamic>>(
      ApiConstants.settings,
      data: updates,
      parser: (d) => d as Map<String, dynamic>,
    );
    return SettingsModel.fromJson(data);
  }

  Future<({int created, int scanned})> syncEmails() async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.syncEmails,
      parser: (d) => d as Map<String, dynamic>,
    );
    return (
      created: data['created'] as int? ?? 0,
      scanned: data['scanned'] as int? ?? 0,
    );
  }

  Future<OutlookInboxPreviewModel> previewOutlookInbox() async {
    final data = await _client.get<Map<String, dynamic>>(
      ApiConstants.outlookInboxPreview,
      parser: (d) => d as Map<String, dynamic>,
    );
    return OutlookInboxPreviewModel.fromJson(data);
  }

  Future<WhatsAppChatsResponseModel> getWhatsAppChats() async {
    final data = await _client.get<Map<String, dynamic>>(
      ApiConstants.whatsAppChats,
      options: Options(receiveTimeout: ApiConstants.whatsAppChatsReceiveTimeout),
      parser: (d) => d as Map<String, dynamic>,
    );
    return WhatsAppChatsResponseModel.fromJson(data);
  }

  Future<WhatsAppChatsResponseModel> syncWhatsAppChats(
    List<WhatsAppChatModel> chats,
  ) async {
    final data = await _client.put<Map<String, dynamic>>(
      ApiConstants.whatsAppChatsSync,
      data: {'chats': chats.map((c) => c.toJson()).toList()},
      parser: (d) => d as Map<String, dynamic>,
    );
    return WhatsAppChatsResponseModel.fromJson(data);
  }
}
