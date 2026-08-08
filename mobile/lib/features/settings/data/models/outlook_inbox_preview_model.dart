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
    this.mailboxEmail,
    this.mailboxUpn,
    this.emailsMatch,
    this.mailReadGranted,
    this.hasMailReadScope,
    this.tokenScopes,
    this.inboxTotalItems = 0,
    this.inboxUnreadItems = 0,
    this.inboxCount = 0,
    this.latestInbox,
    this.error,
    this.messages = const [],
  });

  final bool connected;
  final bool hasRefreshToken;
  final String accountEmail;
  final String? mailboxEmail;
  final String? mailboxUpn;
  final bool? emailsMatch;
  final bool? mailReadGranted;
  final bool? hasMailReadScope;
  final String? tokenScopes;
  final int inboxTotalItems;
  final int inboxUnreadItems;
  final bool fetchOk;
  final int inboxCount;
  final OutlookInboxEmailPreviewModel? latestInbox;
  final String? error;
  final List<OutlookInboxEmailPreviewModel> messages;

  factory OutlookInboxPreviewModel.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? const [];
    final latestRaw = json['latest_inbox'] ?? json['latestInbox'];
    return OutlookInboxPreviewModel(
      connected: json['connected'] as bool? ?? false,
      hasRefreshToken:
          json['has_refresh_token'] as bool? ?? json['hasRefreshToken'] as bool? ?? false,
      accountEmail: json['account_email'] as String? ?? json['accountEmail'] as String? ?? '',
      mailboxEmail: json['mailbox_email'] as String? ?? json['mailboxEmail'] as String?,
      mailboxUpn: json['mailbox_upn'] as String? ?? json['mailboxUpn'] as String?,
      emailsMatch: json['emails_match'] as bool? ?? json['emailsMatch'] as bool?,
      mailReadGranted: json['mail_read_granted'] as bool? ?? json['mailReadGranted'] as bool?,
      hasMailReadScope:
          json['has_mail_read_scope'] as bool? ?? json['hasMailReadScope'] as bool?,
      tokenScopes: json['token_scopes'] as String? ?? json['tokenScopes'] as String?,
      inboxTotalItems:
          json['inbox_total_items'] as int? ?? json['inboxTotalItems'] as int? ?? 0,
      inboxUnreadItems:
          json['inbox_unread_items'] as int? ?? json['inboxUnreadItems'] as int? ?? 0,
      fetchOk: json['fetch_ok'] as bool? ?? json['fetchOk'] as bool? ?? false,
      inboxCount: json['inbox_count'] as int? ?? json['inboxCount'] as int? ?? 0,
      latestInbox: latestRaw is Map<String, dynamic>
          ? OutlookInboxEmailPreviewModel.fromJson(latestRaw)
          : null,
      error: json['error'] as String?,
      messages: rawMessages
          .map((m) => OutlookInboxEmailPreviewModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
