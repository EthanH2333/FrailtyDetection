import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      background: Color(0xFFFFFFFF), // Light peach
      primary: Color(0xFF04493A), // Soft salmon orange
      secondary: Color(0xFFD6F5EE), // Light greyish blue
      surface: Color(0xFFFFFFFF), // Light peach
      onPrimary: Color(0xFFFFFFFF), // White for text on primary
      onSecondary: Color(0xFF333F70), // Black text on secondary
      inversePrimary: Color(0xFF1B3028), // Dark grey-blue
    ),
    textTheme: ThemeData.light().textTheme.apply(
          bodyColor: Color(0xFF333F70), // Dark grey-blue text color for body
          displayColor: Color(0xFF04493A), // Salmon orange text for headlines
        ));
