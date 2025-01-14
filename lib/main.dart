import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:StrideWell/auth/auth.dart';
import 'package:StrideWell/auth/login_or_register.dart';
import 'package:StrideWell/firebase_options.dart';
import 'package:StrideWell/theme/dark_mode.dart';
import 'package:StrideWell/theme/light_mode.dart';

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
