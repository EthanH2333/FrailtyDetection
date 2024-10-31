import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:StrideWell/auth/login_or_register.dart';
import 'package:StrideWell/pages/home_page.dart';
import 'package:StrideWell/pages/login%20&%20singup/login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // user is logged in
        if (snapshot.hasData) {
          return const HomePage();
        }

        // user is NOT logged in
        else {
          return const LoginOrRegister();
        }
      },
    ));
  }
}
