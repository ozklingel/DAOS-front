class OutlookInboxEmailPreviewModel {
  const OutlookInboxEmailPreviewModel({
    required this.messageId,
    required this.subject,
    required this.sender,
    required this.snippet,
    this.receivedAt,
    this.isHebrew = false,
    this.hasTaskSignal = false,
    this.alreadyIngested = false,
  });

  final String messageId;
  final String subject;
  final String sender;
  final String snippet;
  final String? receivedAt;
  final bool isHebrew;
  final bool hasTaskSignal;
  final bool alreadyIngested;

  factory OutlookInboxEmailPreviewModel.fromJson(Map<String, dynamic> json) {
    return OutlookInboxEmailPreviewModel(
      messageId: json['message_id'] as String? ?? json['messageId'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      sender: json['sender'] as String? ?? '',
      snippet: json['snippet'] as String? ?? '',
      receivedAt: json['received_at'] as String? ?? json['receivedAt'] as String?,
      isHebrew: json['is_hebrew'] as bool? ?? json['isHebrew'] as bool? ?? false,
      hasTaskSignal:
          json['has_task_signal'] as bool? ?? json['hasTaskSignal'] as bool? ?? false,
      alreadyIngested:
          json['already_ingested'] as bool? ?? json['alreadyIngested'] as bool? ?? false,
    );
  }
}

class OutlookInboxPreviewModel {
  const OutlookInboxPreviewModel({
    required this.connected,
    required this.hasRefreshToken,
    required this.accountEmail,
    required this.fetchOk,
    this.inboxCount = 0,
    this.error,
    this.messages = const [],
  });

  final bool connected;
  final bool hasRefreshToken;
  final String accountEmail;
  final bool fetchOk;
  final int inboxCount;
  final String? error;
  final List<OutlookInboxEmailPreviewModel> messages;

  factory OutlookInboxPreviewModel.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? const [];
    return OutlookInboxPreviewModel(
      connected: json['connected'] as bool? ?? false,
      hasRefreshToken:
          json['has_refresh_token'] as bool? ?? json['hasRefreshToken'] as bool? ?? false,
      accountEmail: json['account_email'] as String? ?? json['accountEmail'] as String? ?? '',
      fetchOk: json['fetch_ok'] as bool? ?? json['fetchOk'] as bool? ?? false,
      inboxCount: json['inbox_count'] as int? ?? json['inboxCount'] as int? ?? 0,
      error: json['error'] as String?,
      messages: rawMessages
          .map((m) => OutlookInboxEmailPreviewModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
