import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/recommendations/recommendation_preferences_service.dart';
import 'package:mymangatheque/src/back/services/recommendations/recommendation_ranking_service.dart';

void main() {
  final service = RecommendationRankingService();

  test('owned volumes are excluded from organic recommendations', () {
    final ranked = service.rerank(
      <Map<String, dynamic>>[
        _volume('owned', score: 100),
        _volume('new', score: 1),
      ],
      const RecommendationProfile(ownedVolumeIds: <String>{'owned'}),
    );

    expect(ranked.map((volume) => volume['id']), <String>['new']);
  });

  test('genres and authors from the user profile improve ranking', () {
    final ranked = service.rerank(
      <Map<String, dynamic>>[
        _volume('unrelated', score: 2, genres: <String>['romance']),
        _volume(
          'matching',
          score: 1,
          genres: <String>['seinen'],
          authors: <String>['urasawa'],
        ),
      ],
      const RecommendationProfile(
        genreWeights: <String, int>{'seinen': 2},
        authorWeights: <String, int>{'urasawa': 2},
      ),
    );

    expect(ranked.first['id'], 'matching');
    expect(
      (ranked.first['recommendationMeta'] as Map)['primarySignal'],
      'author',
    );
    expect(
      (ranked.first['recommendationMeta'] as Map)['explanation'],
      isNotEmpty,
    );
  });

  test('diversity avoids filling the feed with one repeated genre', () {
    final ranked = service.rerank(
      <Map<String, dynamic>>[
        _volume('action-1', score: 20, genres: <String>['action']),
        _volume('action-2', score: 19, genres: <String>['action']),
        _volume('history', score: 15, genres: <String>['historical']),
      ],
      const RecommendationProfile(
        preferences: RecommendationPreferences(diversify: true),
      ),
    );

    expect(ranked.map((volume) => volume['id']), <String>[
      'action-1',
      'history',
      'action-2',
    ]);
  });

  test('sponsored and editorial placements keep their positions', () {
    final ranked = service.rerank(
      <Map<String, dynamic>>[
        _volume('organic-low', score: 1),
        _volume('sponsored', score: 0, source: 'sponsored'),
        _volume('organic-high', score: 20),
        _volume('editorial', score: 0, source: 'editorial'),
      ],
      const RecommendationProfile(),
    );

    expect(ranked.map((volume) => volume['id']), <String>[
      'organic-high',
      'sponsored',
      'organic-low',
      'editorial',
    ]);
  });
}

Map<String, dynamic> _volume(
  String id, {
  required double score,
  List<String> genres = const <String>[],
  List<String> authors = const <String>[],
  String? source,
}) => <String, dynamic>{
  'id': id,
  'genres': genres,
  'authors': authors,
  'recommendationMeta': <String, dynamic>{'score': score},
  if (source != null) 'source': source,
};
