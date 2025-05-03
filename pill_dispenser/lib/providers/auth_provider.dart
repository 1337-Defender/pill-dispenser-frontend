// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _userId = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userId => _userId;

  void login(String id) {
    _isLoggedIn = true;
    _userId = id;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userId = '';
    notifyListeners();
  }
}