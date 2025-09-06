import 'package:fizzi/feature/auth/presentation/pages/login_page.dart';
import 'package:fizzi/feature/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // initially, show login page
  bool showLoginPage = true;

  // toggle between pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(toggleAuthPages: togglePages,);
    } else {
      return RegisterPage(toggleAuthPages: togglePages ,);
    }
  }
}
