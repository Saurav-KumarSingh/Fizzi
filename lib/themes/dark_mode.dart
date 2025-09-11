import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: const ColorScheme.dark(
    // very dark - app bar + drawer color
    surface: Color(0xFF090909),
    // slightly light
    primary: Color(0xFF696969),
    // dark
    secondary: Color(0xFF141414),
    // slightly dark
    tertiary: Color(0xFF1D1D1D),
    // very light
    inversePrimary: Color(0xFFC3C3C3),
  ), // ColorScheme.dark
  scaffoldBackgroundColor: const Color(0xFF090909),
); // ThemeData