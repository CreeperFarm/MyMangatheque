import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/analytics/promotion_tracking_service.dart';

void main() {
  group('promotion attribution parsing', () {
    test('recognizes a sponsored recommendation and its campaign', () {
      final attribution = promotionAttributionFromManga(
        const <String, dynamic>{
          'id': 'volume-1',
          'sponsorshipMeta': <String, dynamic>{
            'campaignId': 'campaign-1',
            'placement': 'home',
          },
        },
      );

      expect(attribution.isSponsored, isTrue);
      expect(attribution.campaignId, 'campaign-1');
      expect(attribution.placement, 'home');
    });

    test('keeps editorial content separate from sponsored content', () {
      final attribution = promotionAttributionFromManga(
        const <String, dynamic>{
          'source': 'editorial',
          'editorialMeta': <String, dynamic>{'placement': 'catalog'},
        },
      );

      expect(attribution.isEditorial, isTrue);
      expect(attribution.isSponsored, isFalse);
    });

    test('defaults regular recommendations to organic', () {
      final attribution = promotionAttributionFromManga(
        const <String, dynamic>{
          'recommendationMeta': <String, dynamic>{'score': 0.8},
        },
      );

      expect(attribution.source, PromotionSource.organic);
    });
  });
}
