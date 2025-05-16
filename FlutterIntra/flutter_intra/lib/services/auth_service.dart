import 'package:flutter_intra/models/models.dart';
import 'package:flutter_intra/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  final DatabaseService _databaseService = DatabaseService();

  // Register a new user
  Future<User> register({
    required String username,
    required String email,
    required String password,
    String? name,
    String role = 'employee',
  }) async {
    final db = await _databaseService.database;
    
    // Check if username or email already exists
    final existingUser = await db.query(
      'users',
      where: 'username = ? OR email = ?',
      whereArgs: [username, email],
    );
    
    if (existingUser.isNotEmpty) {
      throw Exception('Username or email already exists');
    }
    
    // Create new user
    final user = User(
      username: username,
      email: email,
      password: password, // In a real app, hash the password
      name: name,
      role: role,
      createdAt: DateTime.now(),
    );
    
    // Insert into database
    final id = await db.insert('users', user.toMap());
    
    // Return user with ID
    return user.copyWith(id: id);
  }

  // Login user
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final db = await _databaseService.database;
    
    // Find user by email
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (results.isEmpty) {
      throw Exception('User not found');
    }
    
    final user = User.fromMap(results.first);
    
    // Check password (in a real app, verify hash)
    if (user.password != password) {
      throw Exception('Invalid password');
    }
    
    // Save user to shared preferences
    await _saveUserToPrefs(user);
    
    return user;
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    
    if (userJson == null) {
      return null;
    }
    
    return User.fromMap(jsonDecode(userJson));
  }

  // Update user profile
  Future<User> updateProfile({
    required int userId,
    String? name,
    String? profilePicture,
    String? jobTitle,
    String? bio,
  }) async {
    final db = await _databaseService.database;
    
    // Get current user
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (results.isEmpty) {
      throw Exception('User not found');
    }
    
    final currentUser = User.fromMap(results.first);
    
    // Update user
    final updatedUser = currentUser.copyWith(
      name: name,
      profilePicture: profilePicture,
      jobTitle: jobTitle,
      bio: bio,
      updatedAt: DateTime.now(),
    );
    
    // Update in database
    await db.update(
      'users',
      updatedUser.toMap(),
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    // Update in shared preferences
    await _saveUserToPrefs(updatedUser);
    
    return updatedUser;
  }

  // Save user to shared preferences
  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toMap()));
  }
}
