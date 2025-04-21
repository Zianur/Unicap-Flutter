import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicap_cg/common/basewidgets/custom_button_widget.dart';
import 'package:unicap_cg/views/signup_screen.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final double widthSize = MediaQuery.sizeOf(context).width;
    final double heightSize = MediaQuery.sizeOf(context).width;

    return Consumer<AuthController>(
      builder: (context, authController, _) {
        return Scaffold(
          backgroundColor: Colors.deepPurpleAccent,
          body: Center(
            child: SingleChildScrollView(child: Column(children: [

              authController.user != null ? Column(children: [
                /// profile Section
                Container(
                  width: widthSize,
                  padding: EdgeInsets.all(20),
                  color: Colors.deepPurpleAccent,
                  child: Column(children: [

                    Icon(Icons.person, size: 200),
                    SizedBox(width: 20),

                    Container(
                      alignment: Alignment.center,
                      width: widthSize,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 1, color: Colors.white),
                      ),
                      child: Text(authController.user?.email ?? '', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ]),
                ),
                // SizedBox(height: heightSize * 0.125),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: CustomButtonWidget(
                    buttonText: 'Logout',
                    onPressed: ()=> authController.signOut(),
                    backgroundColor: Colors.red.withValues(alpha: 0.85),
                  ),
                ),

              ]) : Center(
                child: CustomButtonWidget(
                  margin: 20,
                  onPressed: () async {
                    await authController.signInWithGoogle();
                    // print("Google Sign-In failed");
                  },
                  buttonText:"Login with Google",
                  backgroundColor: Colors.white,
                  textStyle: TextStyle(color: Colors.black),
                  icon: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      height: 30,
                      width: 30,
                      child: Image.asset('assets/png/google_icon.png', fit: BoxFit.cover),
                  ),
                  textColor: Colors.black,
                ),
              ),

            ])),
          ),
        );
      }
    );
  }
}
