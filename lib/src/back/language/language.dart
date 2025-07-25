import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Language {
  english(flag: '🇺🇸', name: 'English', code: 'en'),
  french(flag: '🇫🇷', name: 'Français', code: 'fr');

  const Language({required this.flag, required this.name, required this.code});

  final String flag;
  final String name;
  final String code;
}

final languageProvider = StateProvider<Language>((ref) {
  final String defaultLocale = Platform.localeName;
  if (defaultLocale.startsWith('fr')) {
    return Language.french;
  } else if (defaultLocale.startsWith('en')) {
    return Language.english;
  } else {
    return Language.english; // Fallback to English
  }
});
