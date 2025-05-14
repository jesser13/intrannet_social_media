import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final AuthService _authService = AuthService();

  User? get user => _user;

  Future<bool> login(String email, String password) async {
    _user = await _authService.login(email, password);
    if (_user != null) {
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password, String role) async {
    _user = await _authService.register(name, email, password, role);
    if (_user != null) {
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> updateProfile(User user) async {
    await _authService.updateProfile(user);
    _user = user;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}