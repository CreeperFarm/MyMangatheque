import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';

void main() {
  tearDown(() => RuntimeLocalization.setLanguageCode('en'));

  test('normalizes supported and unsupported language codes', () {
    expect(RuntimeLocalization.normalizeLanguageCode('fr-FR'), 'fr');
    expect(RuntimeLocalization.normalizeLanguageCode('en_US'), 'en');
    expect(RuntimeLocalization.normalizeLanguageCode('de-DE'), 'en');
    expect(RuntimeLocalization.normalizeLanguageCode(null), 'en');
  });

  test('localizes service messages without a BuildContext', () {
    RuntimeLocalization.setLanguageCode('fr');
    expect(RuntimeLocalization.text(en: 'Error', fr: 'Erreur'), 'Erreur');

    RuntimeLocalization.setLanguageCode('en');
    expect(RuntimeLocalization.text(en: 'Error', fr: 'Erreur'), 'Error');
  });

  test('localizes administrator sort labels', () {
    RuntimeLocalization.setLanguageCode('fr');
    expect(AdminUserOrderBy.createdAt.label, 'Date de création');
    expect(AdminSortDirection.descending.label, 'Décroissant');

    RuntimeLocalization.setLanguageCode('en');
    expect(AdminUserOrderBy.createdAt.label, 'Creation date');
    expect(AdminSortDirection.descending.label, 'Descending');
  });

  testWidgets('localizes widget messages from the active locale', (
    tester,
  ) async {
    late String translated;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: const <Locale>[Locale('en'), Locale('fr')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            translated = context.localized(en: 'Settings', fr: 'Réglages');
            return const SizedBox();
          },
        ),
      ),
    );

    expect(translated, 'Réglages');
  });
}
