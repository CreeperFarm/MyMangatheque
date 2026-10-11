import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/recommendations/recommendation_preferences_service.dart';
import 'package:mymangatheque/src/front/components/my_manga_show_tile.dart';

void main() {
  testWidgets('recommendation metadata fits inside a compact tile', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: MyMangaShowTile(
              mangaData: const <String, dynamic>{
                'id': 'volume-1',
                'title': 'Un titre de manga volontairement très long',
                'tomeNumber': 12,
                'coverUrl': '',
              },
              initRoute: '/',
              width: 150,
              height: 220,
              recommendationReason: 'Correspond à vos genres préférés',
              onRecommendationFeedback: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Tome 12'), findsOneWidget);
    expect(
      find.byType(PopupMenuButton<RecommendationFeedbackAction>),
      findsOneWidget,
    );
  });
}
