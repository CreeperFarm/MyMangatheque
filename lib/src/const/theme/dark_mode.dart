import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: const Color.fromARGB(255, 20, 18, 24),
    onSurface: Colors.grey.shade200,
    primary: const Color.fromARGB(255, 255, 255, 255),
    onPrimary: Colors.grey.shade900,

    // Background color of the container
    primaryContainer: Colors.grey.shade800,

    // Text/Icon color in the container
    onPrimaryContainer: Colors.grey.shade200,
    secondary: const Color.fromARGB(255, 30, 30, 30),
    onSecondary: Colors.grey.shade400,
    tertiary: const Color.fromARGB(255, 47, 47, 47),
    onTertiary: Colors.white10,
    inversePrimary: Colors.grey.shade300,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade200,
    ),
    displayMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade200,
    ),
    displaySmall: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade200,
    ),
    titleLarge: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade200,
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade200,
    ),
    titleSmall: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade200,
    ),
    bodyLarge: TextStyle(
      fontSize: 20,
      color: Colors.grey.shade200,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      color: Colors.grey.shade200,
    ),
    bodySmall: TextStyle(
      fontSize: 10,
      color: Colors.grey.shade200,
    ),
    labelLarge: TextStyle(
      fontSize: 20,
      color: Colors.grey.shade200,
    ),
    labelMedium: TextStyle(
      fontSize: 15,
      color: Colors.grey.shade200,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      color: Colors.grey.shade200,
    ),
  ),
  primaryTextTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade200,
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade200,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade200,
    ),
    titleLarge: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade200,
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade200,
    ),
    titleSmall: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade200,
    ),
    bodyLarge: TextStyle(
      fontSize: 20,
      color: Colors.grey.shade200,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      color: Colors.grey.shade200,
    ),
    bodySmall: TextStyle(
      fontSize: 10,
      color: Colors.grey.shade200,
    ),
    labelLarge: TextStyle(
      fontSize: 20,
      color: Colors.grey.shade200,
    ),
    labelMedium: TextStyle(
      fontSize: 15,
      color: Colors.grey.shade200,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      color: Colors.grey.shade200,
    ),
  ),
);
