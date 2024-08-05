import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade200, // Color of the container/button and appBar
    onSurface: Colors.black87, // Color of the text of the main page
    primary: Colors.grey.shade900, // Color of the text/icon of the button and of the background of floatingActionButton
    onPrimary: Colors.grey.shade100, // Color of the text/icon of floatingActionButton
    secondary: Colors.orange,// Colors.grey.shade200,
    onSecondary: Colors.blue,
    tertiary: Colors.brown,//Colors.white,
    inversePrimary: Colors.lime,// Colors.grey.shade900,
  )
);