import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;

  AuthController(this._authService);

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
    _user = _authService.currentUser;
    debugPrint('=================_user==============${user?.email}');
  }

  Future<void> _checkLoginStatus() async {
    _isLoggedIn = await _authService.checkLoginStatus();
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    try {
      _user = await _authService.signInWithGoogle();
      _isLoggedIn = _user != null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      _user = await _authService.signInWithEmail(email, password);
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
      _user = await _authService.registerWithEmail(email, password);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> sendEmailVerification() async {
    if (_user != null && !_user!.emailVerified) {
      await _authService.sendEmailVerification();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
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
