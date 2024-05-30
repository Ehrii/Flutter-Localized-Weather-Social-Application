import 'package:flutter/material.dart';
import 'package:proj/login_screen.dart';
import 'package:proj/signup_screen.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: showLoginPage
          ? FadeTransition(
              key: const ValueKey('login'),
              opacity: showLoginPage
                  ? const AlwaysStoppedAnimation<double>(1)
                  : const AlwaysStoppedAnimation<double>(0),
              child: LoginScreen(onTap: togglePages),
            )
          : FadeTransition(
              key: const ValueKey('signup'),
              opacity: showLoginPage
                  ? const AlwaysStoppedAnimation<double>(0)
                  : const AlwaysStoppedAnimation<double>(1),
              child: SignUpScreen(onTap: togglePages),
            ),
    );
  }
}
