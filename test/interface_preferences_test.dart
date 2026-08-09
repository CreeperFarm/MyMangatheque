import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/front/page/home_page.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    LocalStorage.displayDensityNotifier.value = AppDisplayDensity.comfortable;
    LocalStorage.homeRecommendationOrderNotifier.value =
        HomeRecommendationOrder.recommended;
    LocalStorage.navigationLabelModeNotifier.value =
        AppNavigationLabelMode.always;
    LocalStorage.reducedMotionNotifier.value = false;
  });

  test('persists and restores every interface preference', () async {
    final storage = LocalStorage();
    await storage.setDisplayDensity(AppDisplayDensity.compact);
    await storage.setHomeRecommendationOrder(
      HomeRecommendationOrder.newestFirst,
    );
    await storage.setNavigationLabelMode(
      AppNavigationLabelMode.selectedOnly,
    );
    await storage.setReducedMotion(true);

    LocalStorage.displayDensityNotifier.value = AppDisplayDensity.comfortable;
    LocalStorage.homeRecommendationOrderNotifier.value =
        HomeRecommendationOrder.recommended;
    LocalStorage.navigationLabelModeNotifier.value =
        AppNavigationLabelMode.always;
    LocalStorage.reducedMotionNotifier.value = false;

    expect(await storage.getDisplayDensity(), AppDisplayDensity.compact);
    expect(
      await storage.getHomeRecommendationOrder(),
      HomeRecommendationOrder.newestFirst,
    );
    expect(
      await storage.getNavigationLabelMode(),
      AppNavigationLabelMode.selectedOnly,
    );
    expect(await storage.getReducedMotion(), isTrue);
    expect(
      LocalStorage.displayDensityNotifier.value,
      AppDisplayDensity.compact,
    );
    expect(
      LocalStorage.homeRecommendationOrderNotifier.value,
      HomeRecommendationOrder.newestFirst,
    );
    expect(
      LocalStorage.navigationLabelModeNotifier.value,
      AppNavigationLabelMode.selectedOnly,
    );
    expect(LocalStorage.reducedMotionNotifier.value, isTrue);
  });

  testWidgets('home order preference rearranges recommendations immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MyHomePage(
            title: 'Home',
            recommendationLoader: ({required page, required limit}) async {
              return RecordPage(
                items: <RecordModel>[
                  _recommendation('c', 'Charlie', DateTime(2026, 1, 1)),
                  _recommendation('a', 'Alpha', DateTime(2026, 3, 1)),
                  _recommendation('b', 'Bravo', DateTime(2026, 2, 1)),
                ],
                page: 1,
                totalPages: 1,
                totalItems: 3,
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    LocalStorage.homeRecommendationOrderNotifier.value =
        HomeRecommendationOrder.title;
    await tester.pump();

    final alpha = tester.getTopLeft(
      find.byKey(const ValueKey('home-volume-a')),
    );
    final bravo = tester.getTopLeft(
      find.byKey(const ValueKey('home-volume-b')),
    );
    final charlie = tester.getTopLeft(
      find.byKey(const ValueKey('home-volume-c')),
    );
    expect(alpha.dx, lessThan(bravo.dx));
    expect(bravo.dx, lessThan(charlie.dx));
  });
}

RecordModel _recommendation(String id, String title, DateTime release) {
  return RecordModel(
    id: id,
    collectionId: 'volumes',
    data: <String, dynamic>{
      'id': id,
      'title': title,
      'coverUrl': '',
      'release': release.toIso8601String(),
    },
  );
}
