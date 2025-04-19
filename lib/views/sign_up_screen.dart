import 'package:flutter/material.dart';
import 'package:unicap_cg/common/basewidgets/custom_button_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up'), backgroundColor: Colors.deepPurpleAccent, centerTitle: true),
      body: Column(children: [

        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          maxLength: 100,
        ),
        SizedBox(height: 16),

        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          maxLength: 100,
        ),
        SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.all(20),
          child: CustomButtonWidget(
            buttonText: 'SignUp',
            onPressed: (){},
            backgroundColor: Colors.deepPurpleAccent,
          ),
        ),
      ]),
    );
  }
}
