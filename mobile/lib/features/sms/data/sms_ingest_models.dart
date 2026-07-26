class SmsDeviceMessage {
  const SmsDeviceMessage({
    required this.messageId,
    required this.body,
    this.fromAddress,
    this.receivedAt,
  });

  final String messageId;
  final String body;
  final String? fromAddress;
  final DateTime? receivedAt;

  Map<String, dynamic> toJson() => {
        'message_id': messageId,
        'body': body,
        if (fromAddress != null) 'from_address': fromAddress,
        if (receivedAt != null) 'received_at': receivedAt!.toUtc().toIso8601String(),
      };
}

class SmsIngestCreatedItem {
  const SmsIngestCreatedItem({
    required this.taskId,
    required this.messageId,
    required this.title,
  });

  final String taskId;
  final String messageId;
  final String title;

  factory SmsIngestCreatedItem.fromJson(Map<String, dynamic> json) {
    return SmsIngestCreatedItem(
      taskId: json['task_id'] as String? ?? json['taskId'] as String? ?? '',
      messageId:
          json['message_id'] as String? ?? json['messageId'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );
  }
}

class SmsIngestResult {
  const SmsIngestResult({
    required this.processed,
    required this.createdCount,
    required this.created,
  });

  final int processed;
  final int createdCount;
  final List<SmsIngestCreatedItem> created;

  factory SmsIngestResult.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['created'];
    final created = createdRaw is List
        ? createdRaw
            .whereType<Map>()
            .map((e) => SmsIngestCreatedItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <SmsIngestCreatedItem>[];
    return SmsIngestResult(
      processed: json['processed'] as int? ?? 0,
      createdCount: json['created_count'] as int? ??
          json['createdCount'] as int? ??
          created.length,
      created: created,
    );
  }
}
