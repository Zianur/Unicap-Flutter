import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends ChangeNotifier {
  final AuthService authService;

  AuthController({required this.authService});

  User? _user;
  bool _isLoggedIn = false;
  String? _errorMessage;
  bool _isFirsTimeConnectionCheck = true;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isVerified => _user?.emailVerified ?? false;
  String? get errorMessage => _errorMessage;
  bool get isFirsTimeConnectionCheck => _isFirsTimeConnectionCheck;

  /// user id from firebase
  void getCurrentUser(){
    _user = authService.currentUser;
    debugPrint('=================_user==============${user?.email}');
  }


  Future<void> signInWithGoogle() async {
    try {
      _user = await authService.signInWithGoogle();
      _isLoggedIn = _user != null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      _user = await authService.signInWithEmail(email, password);
      _isLoggedIn = _user != null;
      if (!_user!.emailVerified) {
        _errorMessage = "Email not verified. Please check your inbox.";
        notifyListeners();
        return _errorMessage;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
    return _errorMessage;
  }

  Future<void> registerWithEmail(String email, String password) async {
    try {
      _user = await authService.registerWithEmail(email, password);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> sendEmailVerification() async {
    if (_user != null && !_user!.emailVerified) {
      await authService.sendEmailVerification();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
    _user = null;
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }


  void setFirstTimeConnectionCheck(bool value){
    _isFirsTimeConnectionCheck = value;
    notifyListeners();
  }
}
