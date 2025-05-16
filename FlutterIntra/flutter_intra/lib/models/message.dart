class Message {
  final int? id;
  final int senderId;
  final int receiverId; // User ID or Group ID
  final bool isGroupMessage;
  final String content;
  final List<String>? attachments;
  final bool isRead;
  final DateTime createdAt;

  Message({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.isGroupMessage,
    required this.content,
    this.attachments,
    this.isRead = false,
    required this.createdAt,
  });

  // Convert Message object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'isGroupMessage': isGroupMessage ? 1 : 0,
      'content': content,
      'attachments': attachments?.join(','),
      'isRead': isRead ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a Message from a Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      isGroupMessage: map['isGroupMessage'] == 1,
      content: map['content'],
      attachments: map['attachments']?.split(','),
      isRead: map['isRead'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Create a copy of Message with some fields updated
  Message copyWith({
    int? id,
    int? senderId,
    int? receiverId,
    bool? isGroupMessage,
    String? content,
    List<String>? attachments,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      isGroupMessage: isGroupMessage ?? this.isGroupMessage,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
