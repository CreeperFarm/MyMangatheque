import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/back/services/recommendations/recommendation_preferences_service.dart';

class RecommendationProfile {
  const RecommendationProfile({
    this.ownedVolumeIds = const <String>{},
    this.followedSubSeriesIds = const <String>{},
    this.genreWeights = const <String, int>{},
    this.authorWeights = const <String, int>{},
    this.publisherWeights = const <String, int>{},
    this.preferences = const RecommendationPreferences(),
  });

  final Set<String> ownedVolumeIds;
  final Set<String> followedSubSeriesIds;
  final Map<String, int> genreWeights;
  final Map<String, int> authorWeights;
  final Map<String, int> publisherWeights;
  final RecommendationPreferences preferences;
}

class RecommendationRankingService {
  RecommendationRankingService({
    AppwriteConnector? connector,
    RecommendationPreferencesService? preferences,
  }) : _connector = connector ?? AppwriteConnector(),
       _preferences = preferences ?? RecommendationPreferencesService();

  final AppwriteConnector _connector;
  final RecommendationPreferencesService _preferences;

  Future<RecommendationProfile> buildProfile() async {
    final preferences = await _preferences.loadPreferences();
    if (_connector.getConnectedUser() == null) {
      return RecommendationProfile(preferences: preferences);
    }
    List<RecordModel> owned = const <RecordModel>[];
    List<RecordModel> followed = const <RecordModel>[];
    try {
      final results = await Future.wait<List<RecordModel>>([
        _connector.getCollectionFullList(
          'owned',
          expand:
              'volume.authors,volume.editors,volume.subSeries.series.genres',
        ),
        _connector.getCollectionFullList('followed'),
      ]);
      owned = results[0];
      followed = results[1];
    } on Object catch (error) {
      RuntimeLocalization.debug(
        en: 'Local recommendation profile fallback is incomplete: $error',
        fr: 'Le profil local de recommandation est incomplet : $error',
      );
    }

    final ownedIds = <String>{};
    final followedIds = <String>{};
    final genres = <String, int>{};
    final authors = <String, int>{};
    final publishers = <String, int>{};
    for (final genre in preferences.genres) {
      _increase(genres, genre, 5);
    }
    for (final record in owned) {
      final data = _volumeData(record.data);
      final volumeId = _firstId(<dynamic>[
        data['id'],
        data[r'$id'],
        record.data['volumeId'],
        record.data['volume'],
      ]);
      if (volumeId.isNotEmpty) ownedIds.add(volumeId);
      final read = record.data['readed'] == true || record.data['read'] == true;
      final weight = read ? 3 : 1;
      for (final token in _categoryTokens(data, const <String>[
        'genres',
        'genre',
      ])) {
        _increase(genres, token, weight);
      }
      for (final token in _categoryTokens(data, const <String>[
        'authors',
        'author',
      ])) {
        _increase(authors, token, weight);
      }
      for (final token in _categoryTokens(data, const <String>[
        'editors',
        'editor',
      ])) {
        _increase(publishers, token, weight);
      }
    }
    for (final record in followed) {
      final id = _firstId(<dynamic>[
        record.data['subSeriesId'],
        record.data['subSeries'],
        record.data['sub_series'],
        record.data['sub_serie'],
      ]);
      if (id.isNotEmpty) followedIds.add(id);
    }
    return RecommendationProfile(
      ownedVolumeIds: ownedIds,
      followedSubSeriesIds: followedIds,
      genreWeights: genres,
      authorWeights: authors,
      publisherWeights: publishers,
      preferences: preferences,
    );
  }

  List<Map<String, dynamic>> rerank(
    List<Map<String, dynamic>> volumes,
    RecommendationProfile profile,
  ) {
    final organic = <_ScoredRecommendation>[];
    final fixed = <int, Map<String, dynamic>>{};
    for (var index = 0; index < volumes.length; index += 1) {
      final volume = Map<String, dynamic>.from(volumes[index]);
      if (_isPromoted(volume)) {
        fixed[index] = volume;
        continue;
      }
      final id = _firstId(<dynamic>[volume['id'], volume[r'$id']]);
      if (id.isNotEmpty && profile.ownedVolumeIds.contains(id)) continue;
      organic.add(_score(volume, profile, index));
    }

    final ranked = <Map<String, dynamic>>[];
    final remaining = List<_ScoredRecommendation>.from(organic);
    final selectedGenres = <String, int>{};
    while (remaining.isNotEmpty) {
      remaining.sort((left, right) {
        final leftPenalty = profile.preferences.diversify
            ? _diversityPenalty(left.genres, selectedGenres)
            : 0;
        final rightPenalty = profile.preferences.diversify
            ? _diversityPenalty(right.genres, selectedGenres)
            : 0;
        return (right.score - rightPenalty).compareTo(
          left.score - leftPenalty,
        );
      });
      final selected = remaining.removeAt(0);
      ranked.add(selected.volume);
      for (final genre in selected.genres) {
        _increase(selectedGenres, genre, 1);
      }
    }

    final result = <Map<String, dynamic>>[];
    var organicIndex = 0;
    for (var index = 0; index < volumes.length; index += 1) {
      final promoted = fixed[index];
      if (promoted != null) {
        result.add(promoted);
      } else if (organicIndex < ranked.length) {
        result.add(ranked[organicIndex++]);
      }
    }
    while (organicIndex < ranked.length) {
      result.add(ranked[organicIndex++]);
    }
    return result;
  }

  _ScoredRecommendation _score(
    Map<String, dynamic> volume,
    RecommendationProfile profile,
    int originalIndex,
  ) {
    final genres = _categoryTokens(volume, const <String>[
      'genres',
      'genre',
    ]);
    final authors = _categoryTokens(volume, const <String>[
      'authors',
      'author',
    ]);
    final publishers = _categoryTokens(volume, const <String>[
      'editors',
      'editor',
    ]);
    final subSeriesId = _firstId(<dynamic>[
      volume['subSeriesId'],
      volume['subSeries'],
      volume['sub_series'],
      volume['sub_serie'],
    ]);
    final meta = volume['recommendationMeta'] is Map
        ? Map<String, dynamic>.from(volume['recommendationMeta'] as Map)
        : <String, dynamic>{};
    var score =
        _number(
          meta['personalizedScore'] ?? meta['score'] ?? volume['score'],
        ) ??
        -originalIndex.toDouble();
    String signal = '';
    var strongest = 0;

    int contribution(Set<String> values, Map<String, int> weights, int factor) {
      var total = 0;
      for (final value in values) {
        total += (weights[value] ?? 0) * factor;
      }
      return total;
    }

    final genreScore = contribution(genres, profile.genreWeights, 4);
    final authorScore = contribution(authors, profile.authorWeights, 6);
    final publisherScore = contribution(
      publishers,
      profile.publisherWeights,
      2,
    );
    final followedScore = profile.followedSubSeriesIds.contains(subSeriesId)
        ? 18
        : 0;
    for (final entry in <(String, int)>[
      ('genre', genreScore),
      ('author', authorScore),
      ('publisher', publisherScore),
      ('followed', followedScore),
    ]) {
      score += entry.$2;
      if (entry.$2 > strongest) {
        signal = entry.$1;
        strongest = entry.$2;
      }
    }
    if (profile.preferences.preferNewReleases) {
      final release = DateTime.tryParse(
        (volume['release'] ?? volume['publicationDate'] ?? '').toString(),
      );
      if (release != null) {
        final age = DateTime.now().difference(release).inDays;
        if (age >= 0 && age <= 365) score += (365 - age) / 73;
      }
    }
    if (signal.isEmpty && profile.preferences.allowPopularFallback) {
      signal = 'popular';
    }
    if ((meta['explanation']?.toString().trim() ?? '').isEmpty &&
        signal.isNotEmpty) {
      meta['primarySignal'] = signal;
      meta['explanation'] = _explanation(signal);
      volume['recommendationMeta'] = meta;
    }
    return _ScoredRecommendation(volume, score, genres);
  }

  Map<String, dynamic> _volumeData(Map<String, dynamic> raw) {
    final expand = raw['expand'];
    for (final value in <dynamic>[
      raw['volume'],
      if (expand is Map) expand['volume'],
      raw,
    ]) {
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    return raw;
  }

  Set<String> _tokens(dynamic value) {
    final values = value is List ? value : <dynamic>[value];
    final result = <String>{};
    for (final item in values) {
      final raw = item is Map
          ? item['id'] ?? item[r'$id'] ?? item['name'] ?? item['title']
          : item;
      final token = _normalize(raw?.toString() ?? '');
      if (token.isNotEmpty) result.add(token);
    }
    return result;
  }

  Set<String> _categoryTokens(
    Map<String, dynamic> record,
    List<String> keys,
  ) {
    final result = <String>{};
    final acceptedKeys = keys.toSet();

    void addValue(dynamic value) {
      if (value is List) {
        for (final item in value) {
          addValue(item);
        }
        return;
      }
      if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        final direct = map['id'] ?? map[r'$id'] ?? map['name'] ?? map['title'];
        if (direct != null) result.addAll(_tokens(direct));
        return;
      }
      result.addAll(_tokens(value));
    }

    void visit(dynamic value, int depth) {
      if (value == null || depth > 5) return;
      if (value is List) {
        for (final item in value) {
          visit(item, depth + 1);
        }
        return;
      }
      if (value is! Map) return;

      final map = Map<String, dynamic>.from(value);
      for (final entry in map.entries) {
        if (acceptedKeys.contains(entry.key)) addValue(entry.value);
        visit(entry.value, depth + 1);
      }
    }

    visit(record, 0);
    return result;
  }

  String _firstId(Iterable<dynamic> values) {
    for (final value in values) {
      final raw = value is Map ? value['id'] ?? value[r'$id'] : value;
      final id = raw?.toString().trim() ?? '';
      if (id.isNotEmpty) return id;
    }
    return '';
  }

  bool _isPromoted(Map<String, dynamic> volume) {
    final source = (volume['source'] ?? '').toString().toLowerCase();
    return source == 'sponsored' ||
        source == 'editorial' ||
        volume['sponsorshipMeta'] != null ||
        volume['editorialMeta'] != null;
  }

  double? _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  int _diversityPenalty(Set<String> genres, Map<String, int> selected) {
    if (genres.isEmpty) return 0;
    return genres
        .map((genre) => selected[genre] ?? 0)
        .fold<int>(0, (sum, value) => sum + value * 8);
  }

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9à-ÿ]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  String _explanation(String signal) => switch (signal) {
    'genre' => RuntimeLocalization.text(
      en: 'Matches genres you enjoy',
      fr: 'Correspond aux genres que vous aimez',
    ),
    'author' => RuntimeLocalization.text(
      en: 'From an author in your collection',
      fr: 'D’un auteur présent dans votre collection',
    ),
    'publisher' => RuntimeLocalization.text(
      en: 'Similar to publishers you read',
      fr: 'Proche des éditeurs que vous lisez',
    ),
    'followed' => RuntimeLocalization.text(
      en: 'Related to a series you follow',
      fr: 'Lié à une série que vous suivez',
    ),
    _ => RuntimeLocalization.text(
      en: 'Popular with readers with similar interests',
      fr: 'Populaire auprès de lecteurs aux goûts proches',
    ),
  };

  static void _increase(Map<String, int> values, String key, int amount) {
    if (key.isEmpty) return;
    values[key] = (values[key] ?? 0) + amount;
  }
}

class _ScoredRecommendation {
  const _ScoredRecommendation(this.volume, this.score, this.genres);

  final Map<String, dynamic> volume;
  final double score;
  final Set<String> genres;
}
