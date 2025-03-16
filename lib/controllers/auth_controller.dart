import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;
  User? _user;

  User? get user => _user;

  AuthController(this._authService) {
    _user = _authService.currentUser;
  }

  Future<void> signInWithGoogle() async {
    _user = await _authService.signInWithGoogle();
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    _user = await _authService.signInWithEmail(email, password);
    notifyListeners();
  }

  Future<void> registerWithEmail(String email, String password) async {
    _user = await _authService.registerWithEmail(email, password);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
