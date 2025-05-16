class User {
  final int? id;
  final String username;
  final String email;
  final String password; // Stored as hash in real app
  final String? name;
  final String? profilePicture;
  final String? jobTitle;
  final String? bio;
  final String role; // 'employee' or 'admin'
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.name,
    this.profilePicture,
    this.jobTitle,
    this.bio,
    required this.role,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert User object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'name': name,
      'profilePicture': profilePicture,
      'jobTitle': jobTitle,
      'bio': bio,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create a User from a Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
      profilePicture: map['profilePicture'],
      jobTitle: map['jobTitle'],
      bio: map['bio'],
      role: map['role'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Create a copy of User with some fields updated
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? name,
    String? profilePicture,
    String? jobTitle,
    String? bio,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      jobTitle: jobTitle ?? this.jobTitle,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
