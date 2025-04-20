import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

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
      print('----inside signin');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print("Google Sign-In failed");
        return null;
      }

      print("===================Google Sign-In Successful:================== ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _saveUserId(userCredential.user!.uid);
      await _saveLoginStatus(true);

      return userCredential.user;
    } catch (e) {
      print("====================Google Sign-In Error:=================== $e");
      rethrow;  // Re-throw the error for further handling if needed
    }
  }


  // ✅ Sign in with Email
  Future<User?> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

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
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await userCredential.user?.sendEmailVerification();
    return userCredential.user;
  }

  // ✅ Send Email Verification
  Future<void> sendEmailVerification() async {
    if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
      await _auth.currentUser!.sendEmailVerification();
    }
  }

  // ✅ Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    await _saveLoginStatus(false);
  }
}
