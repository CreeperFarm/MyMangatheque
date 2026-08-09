import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';

/// Localization bridge for code that runs outside the widget tree, such as
/// API clients, validators and diagnostic logs.
class RuntimeLocalization {
  RuntimeLocalization._();

  static const Set<String> supportedLanguageCodes = <String>{'en', 'fr'};

  static String _languageCode = normalizeLanguageCode(
    ui.PlatformDispatcher.instance.locale.languageCode,
  );

  static String get languageCode => _languageCode;

  static void setLanguageCode(String languageCode) {
    _languageCode = normalizeLanguageCode(languageCode);
  }

  static String normalizeLanguageCode(String? languageCode) {
    final normalized = languageCode
        ?.trim()
        .toLowerCase()
        .split(RegExp('[-_]'))
        .first;
    return supportedLanguageCodes.contains(normalized) ? normalized! : 'en';
  }

  static String text({required String en, required String fr}) {
    return _languageCode == 'fr' ? fr : en;
  }

  static void debug({required String en, required String fr}) {
    if (!kDebugMode) return;
    debugPrint(redactSensitiveText(text(en: en, fr: fr)));
  }
}

extension LocalizedBuildContext on BuildContext {
  String localized({required String en, required String fr}) {
    final code = RuntimeLocalization.normalizeLanguageCode(
      Localizations.maybeLocaleOf(this)?.languageCode,
    );
    return code == 'fr' ? fr : en;
  }
}
