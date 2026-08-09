import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/recommendations/recommendation_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'preferences round-trip locally for cold-start recommendations',
    () async {
      final service = RecommendationPreferencesService();
      const preferences = RecommendationPreferences(
        genres: <String>{'action', 'historical'},
        preferNewReleases: false,
        diversify: true,
        allowPopularFallback: false,
      );
      final initialRevision =
          RecommendationPreferencesService.preferencesRevisionNotifier.value;

      await service.savePreferences(preferences);
      final restored = await service.loadPreferences();

      expect(restored.genres, preferences.genres);
      expect(restored.preferNewReleases, isFalse);
      expect(restored.diversify, isTrue);
      expect(restored.allowPopularFallback, isFalse);
      expect(restored.configured, isTrue);
      expect(
        RecommendationPreferencesService.preferencesRevisionNotifier.value,
        initialRevision + 1,
      );
    },
  );

  test(
    'hidden recommendations are persisted, bounded and reversible',
    () async {
      final service = RecommendationPreferencesService();

      await service.recordFeedback(
        'volume-1',
        RecommendationFeedbackAction.irrelevant,
      );
      expect(await service.hiddenVolumeIds(), contains('volume-1'));

      await service.restore('volume-1');
      expect(await service.hiddenVolumeIds(), isNot(contains('volume-1')));
    },
  );

  group('recommendation explanations', () {
    final service = RecommendationPreferencesService();

    test('uses the explicit server explanation first', () {
      expect(
        service.explanation(<String, dynamic>{
          'recommendationMeta': <String, dynamic>{
            'explanation': 'Because you read Pluto',
            'primarySignal': 'genre',
          },
        }),
        'Because you read Pluto',
      );
    });

    test('accepts structured reasons and safe signal fallbacks', () {
      expect(
        service.explanation(<String, dynamic>{
          'recommendationMeta': <String, dynamic>{
            'reasons': <Map<String, dynamic>>[
              <String, dynamic>{'label': 'Similar to Monster'},
            ],
          },
        }),
        'Similar to Monster',
      );
      expect(
        service.explanation(<String, dynamic>{
          'recommendationMeta': <String, dynamic>{
            'primarySignal': 'wishlist',
          },
        }),
        isNotEmpty,
      );
    });

    test('never invents an explanation without recommendation metadata', () {
      expect(
        service.explanation(<String, dynamic>{'title': 'Berserk'}),
        isEmpty,
      );
    });
  });
}
