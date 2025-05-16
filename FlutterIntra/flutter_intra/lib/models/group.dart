class Group {
  final int? id;
  final String name;
  final String description;
  final String? image;
  final bool isPrivate;
  final int creatorId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Group({
    this.id,
    required this.name,
    required this.description,
    this.image,
    required this.isPrivate,
    required this.creatorId,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert Group object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'isPrivate': isPrivate ? 1 : 0,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create a Group from a Map
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      image: map['image'],
      isPrivate: map['isPrivate'] == 1,
      creatorId: map['creatorId'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
    );
  }

  // Create a copy of Group with some fields updated
  Group copyWith({
    int? id,
    String? name,
    String? description,
    String? image,
    bool? isPrivate,
    int? creatorId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      isPrivate: isPrivate ?? this.isPrivate,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
