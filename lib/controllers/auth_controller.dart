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
  bool _isLoading = false;


  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isVerified => _user?.emailVerified ?? false;
  String? get errorMessage => _errorMessage;
  bool get isFirsTimeConnectionCheck => _isFirsTimeConnectionCheck;
  bool get isLoading => _isLoading;

  /// user id from firebase
  void getCurrentUser(){
    _user = authService.currentUser;
    debugPrint('=================_user==============${user?.email}');
  }


  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      _user = await authService.signInWithGoogle();
      _isLoggedIn = _user != null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await authService.signOut();
    _user = null;
    _isLoggedIn = false;
    _errorMessage = null;

    _isLoading = false;
    notifyListeners();
  }


  void setFirstTimeConnectionCheck(bool value){
    _isFirsTimeConnectionCheck = value;
    notifyListeners();
  }
}
