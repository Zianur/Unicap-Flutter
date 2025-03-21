import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
     final authController = Provider.of<AuthController>(context, listen: false);
      if (authController.isLoggedIn) {
        print("---------------------Google Sign-In failed---------------------");
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<AuthController>(
      builder: (context, authController, _) {
        return Scaffold(
          appBar: AppBar(title: Text("Login")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                if (authController.errorMessage != null)
                  Text(authController.errorMessage!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    String? error = await authController.signInWithEmail(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );

                    if (error == null) {
                    print("Google Sign-In failed");
                    }
                  },
                  child: Text(authController.isLoggedIn ? "Logout" : "Login"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await authController.signInWithGoogle();
                  // print("Google Sign-In failed");
                  },
                  child: Text(authController.isLoggedIn ? "Logout" : "Login with Google"),
                ),
                if (!authController.isVerified)
                  TextButton(
                    onPressed: () async {
                      await authController.sendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Verification email sent!")),
                      );
                    },
                    child: Text("Resend Verification Email"),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
