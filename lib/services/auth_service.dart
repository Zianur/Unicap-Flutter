import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth firebaseAuth;

  AuthService({required this.firebaseAuth});

  User? get currentUser => firebaseAuth.currentUser;

  // Future<String?> getUserId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('user_id');
  // }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  Future<void> _saveLoginStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', status);
  }

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // ✅ Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('----inside signin');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        debugPrint("Google Sign-In failed");
        return null;
      }

      debugPrint("===================Google Sign-In Successful:================== ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      _saveUserId(userCredential.user!.uid);
      await _saveLoginStatus(true);

      return userCredential.user;
    } catch (e) {
      debugPrint("====================Google Sign-In Error:=================== $e");
      rethrow;  // Re-throw the error for further handling if needed
    }
  }


  // ✅ Sign in with Email
  Future<User?> signInWithEmail(String email, String password) async {
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

    if (userCredential.user != null && userCredential.user!.emailVerified) {
      await _saveLoginStatus(true);
      return userCredential.user;
    } else {
      await signOut();
      throw Exception("Email not verified. Please verify your email.");
    }
  }

  // ✅ Register with Email (Send Verification Email)
  Future<User?> registerWithEmail(String email, String password) async {
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    await userCredential.user?.sendEmailVerification();
    return userCredential.user;
  }

  // ✅ Send Email Verification
  Future<void> sendEmailVerification() async {
    if (firebaseAuth.currentUser != null && !firebaseAuth.currentUser!.emailVerified) {
      await firebaseAuth.currentUser!.sendEmailVerification();
    }
  }

  // ✅ Sign out
  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await GoogleSignIn().signOut();
    await _saveLoginStatus(false);
  }
}
