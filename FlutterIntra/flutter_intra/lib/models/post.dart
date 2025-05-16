class Post {
  final int? id;
  final int userId;
  final int? groupId; // null if post is public
  final String content;
  final List<String>? attachments; // URLs to images or files
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final int commentsCount;

  Post({
    this.id,
    required this.userId,
    this.groupId,
    required this.content,
    this.attachments,
    required this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  // Convert Post object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'groupId': groupId,
      'content': content,
      'attachments': attachments?.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
    };
  }

  // Create a Post from a Map
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['userId'],
      groupId: map['groupId'],
      content: map['content'],
      attachments: map['attachments']?.split(','),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
    );
  }

  // Create a copy of Post with some fields updated
  Post copyWith({
    int? id,
    int? userId,
    int? groupId,
    String? content,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? commentsCount,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
}
