import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      background: Color(0xFFFAF3E0), // Light peach
      primary: Color(0xFFEB7466), // Soft salmon orange
      secondary: Color(0xFFD3E2E9), // Light greyish blue
      surface: Color(0xFFFAE1CD), // Light peach
      onPrimary: Color(0xFFFFFFFF), // White for text on primary
      onSecondary: Color(0xFF000000), // Black text on secondary
      inversePrimary: Color(0xFF3C444C), // Dark grey-blue
    ),
    textTheme: ThemeData.light().textTheme.apply(
          bodyColor: Color(0xFF3C444C), // Dark grey-blue text color for body
          displayColor: Color(0xFFEB7466), // Salmon orange text for headlines
        ));
