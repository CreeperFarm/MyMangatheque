import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    // Color of the container/button and appBar
    surface: Colors.grey.shade200,

    // Color of the text of the main page
    onSurface: Colors.black87,

    // Color of the text/icon of the button and of the background of floatingActionButton
    primary: Colors.grey.shade900,

    // Color of the text/icon of floatingActionButton
    onPrimary: Colors.grey.shade100,
    primaryContainer: Colors.grey.shade200,
    onPrimaryContainer: Colors.grey.shade700,
    secondary: Colors.grey.shade200,
    onSecondary: Colors.blueGrey.shade900,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade900,
    tertiaryFixed: const Color(0xFF1780A3),
  ),
);
