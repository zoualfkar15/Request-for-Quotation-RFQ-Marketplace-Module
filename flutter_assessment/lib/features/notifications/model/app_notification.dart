class AppNotification {
  final int id;
  final String type;
  final String payloadJson;
  final int isRead;
  final int createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.payloadJson,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] as num).toInt(),
      type: (json['type'] ?? '') as String,
      payloadJson: (json['payload_json'] ?? '') as String,
      isRead: (json['is_read'] as num?)?.toInt() ?? 0,
      createdAt: (json['created_at'] as num?)?.toInt() ?? 0,
    );
  }
}


