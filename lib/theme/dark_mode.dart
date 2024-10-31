import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      background: Color(0xFF3C444C), // Dark grey-blue
      primary: Color(0xFF61C1A3), // Salmon orange
      secondary: Color(0xFF285750), // Dark greyish blue
      surface: Color(0xFF1E1E1E), // Dark blue-grey
      onPrimary: Color(0xFFFFFFFF), // White text on primary
      onSecondary: Color(0xFFFFFFFF), // White text on secondary
      inversePrimary: Color(0xFF04493A), // Light peach for inverse situations
    ),
    textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Color(0xFFFFFFFF), // Light greyish blue text for body
          displayColor: Color(0xFF61C1A3), // Salmon orange for headlines
        ));
