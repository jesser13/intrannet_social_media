class AppNotification {
  final String id;
  final String userId;
  final String content;
  final String type;
  final String relatedId;
  final String createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.userId,
    required this.content,
    required this.type,
    required this.relatedId,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      userId: map['userId'],
      content: map['content'],
      type: map['type'],
      relatedId: map['relatedId'],
      createdAt: map['createdAt'],
      isRead: map['isRead'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'type': type,
      'relatedId': relatedId,
      'createdAt': createdAt,
      'isRead': isRead ? 1 : 0,
    };
  }
}