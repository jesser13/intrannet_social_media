class Group {
  final String id;
  final String name;
  final bool isPrivate;
  final String creatorId;

  Group({
    required this.id,
    required this.name,
    required this.isPrivate,
    required this.creatorId,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      isPrivate: map['isPrivate'] == 1,
      creatorId: map['creatorId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isPrivate': isPrivate ? 1 : 0,
      'creatorId': creatorId,
    };
  }
}