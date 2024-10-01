import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      background: Color(0xFF3C444C), // Dark grey-blue
      primary: Color(0xFFEB7466), // Salmon orange
      secondary: Color(0xFF4D5C6C), // Dark greyish blue
      surface: Color(0xFF263238), // Dark blue-grey
      onPrimary: Color(0xFFFFFFFF), // White text on primary
      onSecondary: Color(0xFFFFFFFF), // White text on secondary
      inversePrimary: Color(0xFFFAF3E0), // Light peach for inverse situations
    ),
    textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Color(0xFFD3E2E9), // Light greyish blue text for body
          displayColor: Color(0xFFEB7466), // Salmon orange for headlines
        ));
