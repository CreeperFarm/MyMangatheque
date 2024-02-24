import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/src/const/navbar_color.dart';

class ThemeBgColorNotifier extends Notifier<Color> {
  @override
  Color build() => lightBgColor;

  void changeThemeBgColor(newThemeColor) {
    state = newThemeColor;
  }
}

final themeBgColorProvider = NotifierProvider<ThemeBgColorNotifier, Color>(() {
  return ThemeBgColorNotifier();
});

class ThemeTextColorNotifier extends Notifier<Color> {
  @override
  Color build() => lightTextColor;

  void changeThemeTextColor(newThemeColor) {
    state = newThemeColor;
  }
}

final themeTextColorProvider = NotifierProvider<ThemeTextColorNotifier, Color>(() {
  return ThemeTextColorNotifier();
});