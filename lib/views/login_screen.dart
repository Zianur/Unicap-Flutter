import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicap_cg/common/basewidgets/custom_button_widget.dart';
import 'package:unicap_cg/common/basewidgets/custom_toast_message.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
        builder: (context, authController, _) {
          final double widthSize = MediaQuery.sizeOf(context).width;

          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  authController.user != null
                      ? _buildLoggedInView(context, authController, widthSize)
                      : _buildLoginButton(context, authController)
                ],
              ),
            ),
          );
        }
    );
  }

  Widget _buildLoggedInView(BuildContext context, AuthController authController, double widthSize) {
    return Column(
      children: [
        /// Profile Section
        Container(
          width: widthSize,
          padding: const EdgeInsets.all(20),
          color: Colors.deepPurpleAccent,
          child: Column(
            children: [
              const Icon(Icons.person, size: 200),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.center,
                width: widthSize,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(width: 1, color: Colors.white),
                ),
                child: Text(
                    authController.user?.email ?? '',
                    style: const TextStyle(fontSize: 18, color: Colors.white)
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: CustomButtonWidget(
            isLoading: authController.isLoading,
            buttonText: 'Logout',
            onPressed: () async {
              await authController.signOut();
              CustomToast.showToast('You are now Interacting as Guest', ToastType.warning, null);
            },
            backgroundColor: Colors.red.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, AuthController authController) {
    return Center(
      child: CustomButtonWidget(
        isLoading: authController.isLoading,
        margin: 20,
        onPressed: () async {
          await authController.signInWithGoogle();
          CustomToast.showToast('LoggedIn Successfully', ToastType.success, null);
        },
        buttonText: "Login with Google",
        backgroundColor: Colors.white,
        textStyle: const TextStyle(color: Colors.black, overflow: TextOverflow.ellipsis),
        icon: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          height: 30,
          width: 30,
          child: Image.asset('assets/png/google_icon.png', fit: BoxFit.cover),
        ),
        textColor: Colors.black,
      ),
    );
  }
}