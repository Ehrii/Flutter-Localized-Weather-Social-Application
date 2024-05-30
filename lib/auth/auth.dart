import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proj/dashboard.dart';
import 'package:proj/login_screen.dart';
import 'package:proj/auth/login_or_register.dart';
import 'package:proj/introduction_screen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            // If user is authenticated, navigate to Dashboard
            return Dashboard();
          } else {
            // If user is not authenticated, show the IntroScreen
            return const LoginOrRegister();
          }
        }
      },
    ),
  );
}

}
