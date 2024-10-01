import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frailtyapp/auth/auth.dart';
import 'package:frailtyapp/auth/login_or_register.dart';
import 'package:frailtyapp/firebase_options.dart';
import 'package:frailtyapp/theme/dark_mode.dart';
import 'package:frailtyapp/theme/light_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      theme: lightTheme,
      darkTheme: darkTheme,
    );
  }
}
