class GroupMember {
  final int? id;
  final int groupId;
  final int userId;
  final String role; // 'member', 'admin'
  final DateTime joinedAt;

  GroupMember({
    this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  // Convert GroupMember object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  // Create a GroupMember from a Map
  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      id: map['id'],
      groupId: map['groupId'],
      userId: map['userId'],
      role: map['role'],
      joinedAt: DateTime.parse(map['joinedAt']),
    );
  }
}
