import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: const Color.fromARGB(255, 20, 18, 24),
    onSurface: Colors.grey.shade200,
    primary: const Color.fromARGB(255, 255, 255, 255),
    onPrimary: Colors.grey.shade900,
    primaryContainer: Colors.grey.shade800, // Background color of the container
    onPrimaryContainer: Colors.grey.shade200, // Text/Icon color in the container
    secondary: const Color.fromARGB(255, 30, 30, 30),
    onSecondary: Colors.grey.shade400,
    tertiary: const Color.fromARGB(255, 47, 47, 47),
    onTertiary: Colors.white10,
    inversePrimary: Colors.grey.shade300
  ),
);