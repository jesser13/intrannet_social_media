class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String? photo;
  final String? function;
  final String? bio;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.photo,
    this.function,
    this.bio,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      photo: map['photo'],
      function: map['function'],
      bio: map['bio'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'photo': photo,
      'function': function,
      'bio': bio,
    };
  }
}