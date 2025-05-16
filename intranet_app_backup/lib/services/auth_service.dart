import 'package:uuid/uuid.dart';
import 'database_service.dart';
import '../models/user.dart';

class AuthService {
  final DatabaseService _dbService = DatabaseService();

  Future<User?> register(String name, String email, String password, String role) async {
    final db = await _dbService.database;
    try {
      final user = User(
        id: Uuid().v4(),
        name: name,
        email: email,
        password: password,
        role: role,
      );
      await db.insert('users', user.toMap());
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateProfile(User user) async {
    final db = await _dbService.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}