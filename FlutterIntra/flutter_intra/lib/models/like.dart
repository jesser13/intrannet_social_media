class Like {
  final int? id;
  final int postId;
  final int userId;
  final DateTime createdAt;

  Like({
    this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  // Convert Like object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a Like from a Map
  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
      id: map['id'],
      postId: map['postId'],
      userId: map['userId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
