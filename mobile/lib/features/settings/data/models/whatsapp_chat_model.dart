class WhatsAppChatModel {
  const WhatsAppChatModel({
    required this.chatId,
    required this.displayName,
    required this.chatType,
    required this.syncEnabled,
  });

  final String chatId;
  final String displayName;
  final String chatType;
  final bool syncEnabled;

  bool get isGroup => chatType == 'group';

  WhatsAppChatModel copyWith({bool? syncEnabled}) {
    return WhatsAppChatModel(
      chatId: chatId,
      displayName: displayName,
      chatType: chatType,
      syncEnabled: syncEnabled ?? this.syncEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'display_name': displayName,
      'chat_type': chatType,
      'sync_enabled': syncEnabled,
    };
  }

  factory WhatsAppChatModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppChatModel(
      chatId: json['chat_id'] as String? ?? json['chatId'] as String? ?? '',
      displayName:
          json['display_name'] as String? ?? json['displayName'] as String? ?? '',
      chatType: json['chat_type'] as String? ?? json['chatType'] as String? ?? 'direct',
      syncEnabled:
          json['sync_enabled'] as bool? ?? json['syncEnabled'] as bool? ?? false,
    );
  }
}

class WhatsAppChatsResponseModel {
  const WhatsAppChatsResponseModel({
    required this.chatSyncAvailable,
    required this.syncedCount,
    required this.chats,
  });

  final bool chatSyncAvailable;
  final int syncedCount;
  final List<WhatsAppChatModel> chats;

  factory WhatsAppChatsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawChats = json['chats'] as List<dynamic>? ?? const [];
    return WhatsAppChatsResponseModel(
      chatSyncAvailable:
          json['chat_sync_available'] as bool? ?? json['chatSyncAvailable'] as bool? ?? false,
      syncedCount: json['synced_count'] as int? ?? json['syncedCount'] as int? ?? 0,
      chats: rawChats
          .map((item) => WhatsAppChatModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
