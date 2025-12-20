import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth firebaseAuth;

  AuthService({required this.firebaseAuth});

  User? get currentUser => firebaseAuth.currentUser;

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

      return userCredential.user;
    } catch (e) {
      debugPrint("====================Google Sign-In Error:=================== $e");
      rethrow;  // Re-throw the error for further handling if needed
    }
  }


  // ✅ Sign out
  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await GoogleSignIn().signOut();
  }
}
