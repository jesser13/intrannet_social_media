class Comment {
  final int? id;
  final int postId;
  final int userId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Comment({
    this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert Comment object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create a Comment from a Map
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      postId: map['postId'],
      userId: map['userId'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
    );
  }

  // Create a copy of Comment with some fields updated
  Comment copyWith({
    int? id,
    int? postId,
    int? userId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
