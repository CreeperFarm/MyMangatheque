import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/api/mobile_api_client.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RecommendationFeedbackAction { hidden, irrelevant }

class RecommendationPreferences {
  const RecommendationPreferences({
    this.genres = const <String>{},
    this.preferNewReleases = true,
    this.diversify = true,
    this.allowPopularFallback = true,
    this.configured = false,
  });

  final Set<String> genres;
  final bool preferNewReleases;
  final bool diversify;
  final bool allowPopularFallback;
  final bool configured;

  factory RecommendationPreferences.fromJson(Map<String, dynamic> json) {
    return RecommendationPreferences(
      genres: json['genres'] is List
          ? (json['genres'] as List)
                .map((value) => value.toString())
                .where((value) => value.isNotEmpty)
                .toSet()
          : const <String>{},
      preferNewReleases: json['preferNewReleases'] != false,
      diversify: json['diversify'] != false,
      allowPopularFallback: json['allowPopularFallback'] != false,
      configured: json['configured'] == true,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'genres': genres.toList()..sort(),
    'preferNewReleases': preferNewReleases,
    'diversify': diversify,
    'allowPopularFallback': allowPopularFallback,
    'configured': configured,
  };

  RecommendationPreferences copyWith({
    Set<String>? genres,
    bool? preferNewReleases,
    bool? diversify,
    bool? allowPopularFallback,
    bool? configured,
  }) {
    return RecommendationPreferences(
      genres: genres ?? this.genres,
      preferNewReleases: preferNewReleases ?? this.preferNewReleases,
      diversify: diversify ?? this.diversify,
      allowPopularFallback: allowPopularFallback ?? this.allowPopularFallback,
      configured: configured ?? this.configured,
    );
  }
}

class RecommendationPreferencesService {
  RecommendationPreferencesService({
    AppwriteConnector? connector,
    MobileApiClient? api,
  }) : _connector = connector ?? AppwriteConnector(),
       _api = api ?? MobileApiClient();

  static const String preferencesPath =
      '/api/users/me/recommendation-preferences';
  static const String feedbackPath = '/api/recommendations/feedback';
  static const int _maxLocalFeedback = 500;
  static final ValueNotifier<int> preferencesRevisionNotifier =
      ValueNotifier<int>(0);

  final AppwriteConnector _connector;
  final MobileApiClient _api;

  Future<RecommendationPreferences> loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_preferencesKey);
    if (raw == null || raw.isEmpty) return const RecommendationPreferences();
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map
          ? RecommendationPreferences.fromJson(
              Map<String, dynamic>.from(decoded),
            )
          : const RecommendationPreferences();
    } on FormatException {
      await preferences.remove(_preferencesKey);
      return const RecommendationPreferences();
    }
  }

  Future<void> savePreferences(RecommendationPreferences value) async {
    final preferences = await SharedPreferences.getInstance();
    final configured = value.copyWith(configured: true);
    await preferences.setString(
      _preferencesKey,
      jsonEncode(configured.toJson()),
    );
    preferencesRevisionNotifier.value += 1;
    if (_connector.getConnectedUser() == null) return;
    try {
      final response = await _api.patch(
        preferencesPath,
        body: configured.toJson(),
        requiresApiKey: true,
        requiresBearer: true,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        RuntimeLocalization.debug(
          en: 'Recommendation preferences were saved locally but rejected by the API (${response.statusCode}).',
          fr: 'Les préférences de recommandation ont été enregistrées localement mais refusées par l’API (${response.statusCode}).',
        );
      }
    } on Object catch (error) {
      RuntimeLocalization.debug(
        en: 'Recommendation preference synchronization failed: $error',
        fr: 'La synchronisation des préférences de recommandation a échoué : $error',
      );
    }
  }

  Future<Set<String>> hiddenVolumeIds() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_hiddenKey)?.toSet() ?? <String>{};
  }

  Future<void> recordFeedback(
    String volumeId,
    RecommendationFeedbackAction action, {
    String reason = '',
  }) async {
    final normalizedId = volumeId.trim();
    if (normalizedId.isEmpty) return;
    final preferences = await SharedPreferences.getInstance();
    final hidden = preferences.getStringList(_hiddenKey) ?? <String>[];
    hidden.remove(normalizedId);
    hidden.insert(0, normalizedId);
    await preferences.setStringList(
      _hiddenKey,
      hidden.take(_maxLocalFeedback).toList(),
    );
    if (_connector.getConnectedUser() == null) return;
    try {
      final response = await _api.post(
        feedbackPath,
        requiresApiKey: true,
        requiresBearer: true,
        body: <String, dynamic>{
          'volumeId': normalizedId,
          'action': action == RecommendationFeedbackAction.hidden
              ? 'hide'
              : 'irrelevant',
          if (reason.trim().isNotEmpty) 'reason': reason.trim(),
          'occurredAt': DateTime.now().toUtc().toIso8601String(),
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        RuntimeLocalization.debug(
          en: 'Recommendation feedback was retained locally but rejected by the API (${response.statusCode}).',
          fr: 'Le retour sur la recommandation a été conservé localement mais refusé par l’API (${response.statusCode}).',
        );
      }
    } on Object catch (error) {
      RuntimeLocalization.debug(
        en: 'Recommendation feedback synchronization failed: $error',
        fr: 'La synchronisation du retour de recommandation a échoué : $error',
      );
    }
  }

  Future<void> restore(String volumeId) async {
    final preferences = await SharedPreferences.getInstance();
    final hidden = preferences.getStringList(_hiddenKey) ?? <String>[];
    if (!hidden.remove(volumeId)) return;
    await preferences.setStringList(_hiddenKey, hidden);
  }

  String explanation(Map<String, dynamic> volume) {
    final raw = volume['recommendationMeta'];
    if (raw is! Map) return '';
    final meta = Map<String, dynamic>.from(raw);
    final direct = meta['explanation'] ?? meta['reason'];
    if (direct is String && direct.trim().isNotEmpty) return direct.trim();
    if (direct is Map) {
      final localized =
          direct[RuntimeLocalization.languageCode] ??
          direct['en'] ??
          direct['fr'];
      if (localized != null && localized.toString().trim().isNotEmpty) {
        return localized.toString().trim();
      }
    }
    if (direct is List) {
      final value = direct
          .map((item) => item.toString())
          .firstWhere(
            (item) => item.trim().isNotEmpty,
            orElse: () => '',
          );
      if (value.isNotEmpty) return value;
    }
    final reasons = meta['reasons'];
    if (reasons is List) {
      dynamic first;
      for (final item in reasons) {
        if (item is String || item is Map) {
          first = item;
          break;
        }
      }
      if (first is String) return first;
      if (first is Map) {
        final label = first['label'] ?? first['text'] ?? first['reason'];
        if (label != null) return label.toString();
      }
    }
    final signal = (meta['primarySignal'] ?? meta['signal'] ?? '')
        .toString()
        .toLowerCase();
    return switch (signal) {
      'genre' => RuntimeLocalization.text(
        en: 'Matches genres you enjoy',
        fr: 'Correspond aux genres que vous aimez',
      ),
      'author' => RuntimeLocalization.text(
        en: 'From an author in your collection',
        fr: 'D’un auteur présent dans votre collection',
      ),
      'publisher' || 'editor' => RuntimeLocalization.text(
        en: 'Similar to publishers you read',
        fr: 'Proche des éditeurs que vous lisez',
      ),
      'wishlist' => RuntimeLocalization.text(
        en: 'Inspired by your wishlist',
        fr: 'Inspiré de votre liste d’envies',
      ),
      'followed' => RuntimeLocalization.text(
        en: 'Related to a series you follow',
        fr: 'Lié à une série que vous suivez',
      ),
      'popular' || 'cold_start' => RuntimeLocalization.text(
        en: 'Popular with readers with similar interests',
        fr: 'Populaire auprès de lecteurs aux goûts proches',
      ),
      _ => '',
    };
  }

  String get _scope =>
      _connector.getConnectedUser()?.id.trim().isNotEmpty == true
      ? _connector.getConnectedUser()!.id.trim()
      : 'guest';

  String get _preferencesKey => 'mmt_recommendation_preferences_$_scope';
  String get _hiddenKey => 'mmt_recommendation_hidden_$_scope';
}
