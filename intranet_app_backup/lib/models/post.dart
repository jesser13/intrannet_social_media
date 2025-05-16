class Post {
  final String id;
  final String userId;
  final String content;
  final String? imagePath;
  final String? filePath;
  final String? groupId;
  final String createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.imagePath,
    this.filePath,
    this.groupId,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['userId'],
      content: map['content'],
      imagePath: map['imagePath'],
      filePath: map['filePath'],
      groupId: map['groupId'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'imagePath': imagePath,
      'filePath': filePath,
      'groupId': groupId,
      'createdAt': createdAt,
    };
  }
}