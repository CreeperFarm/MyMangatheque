import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/cache/persistent_cache_store.dart';
import 'package:mymangatheque/src/models/manga/author.dart';
import 'package:mymangatheque/src/models/manga/editor.dart';
import 'package:mymangatheque/src/models/manga/serie.dart';
import 'package:mymangatheque/src/models/manga/sub_serie.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppDisplayDensity { comfortable, compact }

enum HomeRecommendationOrder { recommended, newestFirst, title }

enum AppNavigationLabelMode { always, selectedOnly }

class LocalStorage {
  static final ValueNotifier<AppDisplayDensity> displayDensityNotifier =
      ValueNotifier<AppDisplayDensity>(AppDisplayDensity.comfortable);
  static final ValueNotifier<HomeRecommendationOrder>
  homeRecommendationOrderNotifier = ValueNotifier<HomeRecommendationOrder>(
    HomeRecommendationOrder.recommended,
  );
  static final ValueNotifier<AppNavigationLabelMode>
  navigationLabelModeNotifier = ValueNotifier<AppNavigationLabelMode>(
    AppNavigationLabelMode.always,
  );
  static final ValueNotifier<bool> reducedMotionNotifier = ValueNotifier<bool>(
    false,
  );
  static const _tokenKey = 'token';
  static const _cacheLanguageKey = 'cacheLanguage';
  static const _ownedSubSerieKey = 'ownedSubSerie';
  static const _cacheSeriesKey = 'cacheSeries';
  static const _cacheSubSeriesKey = 'cacheSubSeries';
  static const _cacheVolumesKey = 'cacheVolumes';
  static const _cacheAuthorsKey = 'cacheAuthors';
  static const _cacheEditorsKey = 'cacheEditors';
  static const _adultContentEnabledKey = 'adultContentEnabled';
  static const _scanPreviousVolumesSuggestionEnabledKey =
      'scanPreviousVolumesSuggestionEnabled';
  static const _displayDensityKey = 'displayDensity';
  static const _homeRecommendationOrderKey = 'homeRecommendationOrder';
  static const _navigationLabelModeKey = 'navigationLabelMode';
  static const _reducedMotionKey = 'reducedMotion';
  static const _wantedMissingVolumesKey = 'wantedMissingVolumes';
  static const _releaseAlertsKey = 'releaseAlerts';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final PersistentCacheStore _applicationCache = PersistentCacheStore();

  String _scopedPreferenceKey(String prefix, String? userId) {
    final normalized = userId?.trim() ?? '';
    return normalized.isEmpty
        ? prefix
        : '$prefix:${Uri.encodeComponent(normalized)}';
  }

  Future<Set<T>?> _readCachedModels<T>(
    String namespace,
    String legacyKey,
    T Function(Map<String, dynamic>) decoder,
  ) async {
    Object? data = (await _applicationCache.read(namespace))?.data;
    final preferences = await SharedPreferences.getInstance();
    if (data == null) {
      final legacy = preferences.getString(legacyKey);
      if (legacy == null) return null;
      try {
        data = jsonDecode(legacy);
        await _applicationCache.write(
          namespace,
          data,
          ttl: const Duration(days: 7),
        );
        await preferences.remove(legacyKey);
      } on Object {
        await preferences.remove(legacyKey);
        return null;
      }
    }

    if (data is! List) return null;
    try {
      return data
          .whereType<Map>()
          .map((item) => decoder(Map<String, dynamic>.from(item)))
          .toSet();
    } on Object catch (error) {
      await _applicationCache.remove(namespace);
      RuntimeLocalization.debug(
        en: 'Discarded an invalid cached catalogue entry: $error',
        fr: 'Une entrée de catalogue en cache invalide a été supprimée : $error',
      );
      return null;
    }
  }

  Future<void> _writeCachedModels<T>(
    String namespace,
    String legacyKey,
    Set<T> values,
  ) async {
    await _applicationCache.write(
      namespace,
      values.toList(),
      ttl: const Duration(days: 7),
    );
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(legacyKey);
  }

  // * Token ----------------------------------------------------------------------------------------------------------
  Future<String?> getToken() async {
    RuntimeLocalization.debug(
      en: 'Reading the legacy authentication token from secure storage.',
      fr: 'Lecture du jeton d’authentification historique depuis le stockage sécurisé.',
    );
    final secureToken = await _secureStorage.read(key: _tokenKey);
    if (secureToken != null && secureToken.isNotEmpty) return secureToken;

    final preferences = await SharedPreferences.getInstance();
    final legacyToken = preferences.getString(_tokenKey);
    if (legacyToken == null || legacyToken.isEmpty) return null;
    await _secureStorage.write(key: _tokenKey, value: legacyToken);
    await preferences.remove(_tokenKey);
    RuntimeLocalization.debug(
      en: 'The legacy authentication token was migrated to secure storage.',
      fr: 'Le jeton d’authentification historique a été migré vers le stockage sécurisé.',
    );
    return legacyToken;
  }

  Future<void> setToken(String token) async {
    RuntimeLocalization.debug(
      en: 'Saving the legacy authentication token in secure storage.',
      fr: 'Enregistrement du jeton d’authentification historique dans le stockage sécurisé.',
    );
    await _secureStorage.write(key: _tokenKey, value: token);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
    RuntimeLocalization.debug(
      en: 'The legacy authentication token was deleted from secure storage.',
      fr: 'Le jeton d’authentification historique a été supprimé du stockage sécurisé.',
    );
  }

  // * End of token ----------------------------------------------------------------------------------------------------

  // * Language Code ---------------------------------------------------------------------------------------------------
  Future<String?> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString(_cacheLanguageKey);
    RuntimeLocalization.debug(
      en: 'Reading the saved application language ($language).',
      fr: 'Lecture de la langue enregistrée de l’application ($language).',
    );
    return language;
  }

  Future<void> setLanguageCode(String language) async {
    RuntimeLocalization.debug(
      en: 'Saving the application language ($language).',
      fr: 'Enregistrement de la langue de l’application ($language).',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheLanguageKey, language);
  }

  Future<void> deleteLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheLanguageKey);
    RuntimeLocalization.debug(
      en: 'The saved application language was deleted.',
      fr: 'La langue enregistrée de l’application a été supprimée.',
    );
  }

  // * End of language ------------------------------------------------------------------------------------------------

  // * Owned sub series ------------------------------------------------------------------------------------------------
  String _ownedSubSerieKeyForUser(String? userId) {
    final normalizedUserId = userId?.trim() ?? '';
    if (normalizedUserId.isEmpty) return _ownedSubSerieKey;
    return '$_ownedSubSerieKey:${Uri.encodeComponent(normalizedUserId)}';
  }

  Future<Set<SubSerieForCollection>?> getOwnedSubSerie({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_ownedSubSerieKeyForUser(userId));

    if (jsonString == null) return null;
    try {
      final decoded = json.decode(jsonString);
      if (decoded is! List) return null;
      return decoded
          .whereType<Map>()
          .map(
            (entry) => SubSerieForCollection.fromJson(
              Map<String, dynamic>.from(entry),
            ),
          )
          .toSet();
    } on FormatException catch (error) {
      RuntimeLocalization.debug(
        en: 'The local owned collection cache is invalid: $error',
        fr: 'Le cache local de la collection possédée est invalide : $error',
      );
      await prefs.remove(_ownedSubSerieKeyForUser(userId));
      return null;
    } on Object catch (error) {
      RuntimeLocalization.debug(
        en: 'The local owned collection cache has an invalid shape: $error',
        fr: 'Le cache local de la collection possédée a une structure invalide : $error',
      );
      await prefs.remove(_ownedSubSerieKeyForUser(userId));
      return null;
    }
  }

  Future<void> saveOwnedSubSerie(
    Set<SubSerieForCollection> subSerie, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(subSerie.toList()); // Convert to JSON String
    await prefs.setString(_ownedSubSerieKeyForUser(userId), jsonString);
  }

  Future<void> deleteOwnedSubSerie({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ownedSubSerieKeyForUser(userId));
  }

  // * End of owned sub series ----------------------------------------------------------------------------------------

  // * Cache series ---------------------------------------------------------------------------------------------------
  Future<Set<Serie>?> getCacheSeries() async {
    return _readCachedModels(
      'catalogue.series',
      _cacheSeriesKey,
      Serie.fromJson,
    );
  }

  Future<void> saveCacheSeries(Set<Serie> series) async {
    await _writeCachedModels('catalogue.series', _cacheSeriesKey, series);
  }

  Future<void> deleteCacheSeries() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait<void>([
      prefs.remove(_cacheSeriesKey),
      _applicationCache.remove('catalogue.series'),
    ]);
  }

  // * End of cache series ------------------------------------------------------------------------------------------

  // * Cache sub series ----------------------------------------------------------------------------------------------
  Future<Set<SubSerie>?> getCacheSubSeries() async {
    return _readCachedModels(
      'catalogue.subSeries',
      _cacheSubSeriesKey,
      SubSerie.fromJson,
    );
  }

  Future<void> saveCacheSubSeries(Set<SubSerie> subSeries) async {
    await _writeCachedModels(
      'catalogue.subSeries',
      _cacheSubSeriesKey,
      subSeries,
    );
  }

  Future<void> deleteCacheSubSeries() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait<void>([
      prefs.remove(_cacheSubSeriesKey),
      _applicationCache.remove('catalogue.subSeries'),
    ]);
  }

  // * End of cache sub series ----------------------------------------------------------------------------------------

  // * Cache volumes -------------------------------------------------------------------------------------------------
  Future<Set<Volume>?> getCacheVolumes() async {
    return _readCachedModels(
      'catalogue.volumes',
      _cacheVolumesKey,
      Volume.fromJson,
    );
  }

  Future<void> saveCacheVolumes(Set<Volume> volumes) async {
    await _writeCachedModels('catalogue.volumes', _cacheVolumesKey, volumes);
  }

  Future<void> deleteCacheVolumes() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait<void>([
      prefs.remove(_cacheVolumesKey),
      _applicationCache.remove('catalogue.volumes'),
    ]);
  }

  // * End of cache volumes -------------------------------------------------------------------------------------------

  // * Cache authors -------------------------------------------------------------------------------------------------
  Future<Set<Author>?> getCacheAuthors() async {
    return _readCachedModels(
      'catalogue.authors',
      _cacheAuthorsKey,
      Author.fromJson,
    );
  }

  Future<void> saveCacheAuthors(Set<Author> authors) async {
    await _writeCachedModels('catalogue.authors', _cacheAuthorsKey, authors);
  }

  Future<void> deleteCacheAuthors() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait<void>([
      prefs.remove(_cacheAuthorsKey),
      _applicationCache.remove('catalogue.authors'),
    ]);
  }

  // * End of cache authors -------------------------------------------------------------------------------------------

  // * Cache editors -------------------------------------------------------------------------------------------------
  Future<Set<Editor>?> getCacheEditors() async {
    return _readCachedModels(
      'catalogue.editors',
      _cacheEditorsKey,
      Editor.fromJson,
    );
  }

  Future<void> saveCacheEditors(Set<Editor> editors) async {
    await _writeCachedModels('catalogue.editors', _cacheEditorsKey, editors);
  }

  Future<void> deleteCacheEditors() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait<void>([
      prefs.remove(_cacheEditorsKey),
      _applicationCache.remove('catalogue.editors'),
    ]);
  }

  // * End of cache editors -------------------------------------------------------------------------------------------

  // * Clear all cache ------------------------------------------------------------------------------------------------
  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait<void>([
      prefs.remove(_cacheSeriesKey),
      prefs.remove(_cacheSubSeriesKey),
      prefs.remove(_cacheVolumesKey),
      prefs.remove(_cacheAuthorsKey),
      prefs.remove(_cacheEditorsKey),
      _applicationCache.clear(),
    ]);
  }

  // * End of clear all cache -----------------------------------------------------------------------------------------

  // * Adult content preference ---------------------------------------------------------------------------------------
  Future<bool> getAdultContentEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adultContentEnabledKey) ?? false;
  }

  Future<void> setAdultContentEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adultContentEnabledKey, enabled);
  }

  Future<void> deleteAdultContentEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_adultContentEnabledKey);
  }

  // * End of adult content preference --------------------------------------------------------------------------------

  Future<bool> getScanPreviousVolumesSuggestionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_scanPreviousVolumesSuggestionEnabledKey) ?? true;
  }

  Future<void> setScanPreviousVolumesSuggestionEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_scanPreviousVolumesSuggestionEnabledKey, enabled);
  }

  Future<AppDisplayDensity> getDisplayDensity() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_displayDensityKey);
    final density = AppDisplayDensity.values.firstWhere(
      (density) => density.name == saved,
      orElse: () => AppDisplayDensity.comfortable,
    );
    if (displayDensityNotifier.value != density) {
      displayDensityNotifier.value = density;
    }
    return density;
  }

  Future<void> setDisplayDensity(AppDisplayDensity density) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_displayDensityKey, density.name);
    if (displayDensityNotifier.value != density) {
      displayDensityNotifier.value = density;
    }
  }

  Future<HomeRecommendationOrder> getHomeRecommendationOrder() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_homeRecommendationOrderKey);
    final order = HomeRecommendationOrder.values.firstWhere(
      (item) => item.name == saved,
      orElse: () => HomeRecommendationOrder.recommended,
    );
    if (homeRecommendationOrderNotifier.value != order) {
      homeRecommendationOrderNotifier.value = order;
    }
    return order;
  }

  Future<void> setHomeRecommendationOrder(
    HomeRecommendationOrder order,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_homeRecommendationOrderKey, order.name);
    if (homeRecommendationOrderNotifier.value != order) {
      homeRecommendationOrderNotifier.value = order;
    }
  }

  Future<AppNavigationLabelMode> getNavigationLabelMode() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_navigationLabelModeKey);
    final mode = AppNavigationLabelMode.values.firstWhere(
      (item) => item.name == saved,
      orElse: () => AppNavigationLabelMode.always,
    );
    if (navigationLabelModeNotifier.value != mode) {
      navigationLabelModeNotifier.value = mode;
    }
    return mode;
  }

  Future<void> setNavigationLabelMode(AppNavigationLabelMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_navigationLabelModeKey, mode.name);
    if (navigationLabelModeNotifier.value != mode) {
      navigationLabelModeNotifier.value = mode;
    }
  }

  Future<bool> getReducedMotion() async {
    final preferences = await SharedPreferences.getInstance();
    final reduced = preferences.getBool(_reducedMotionKey) ?? false;
    if (reducedMotionNotifier.value != reduced) {
      reducedMotionNotifier.value = reduced;
    }
    return reduced;
  }

  Future<void> setReducedMotion(bool reduced) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_reducedMotionKey, reduced);
    if (reducedMotionNotifier.value != reduced) {
      reducedMotionNotifier.value = reduced;
    }
  }

  Future<Set<String>> getWantedMissingVolumeIds({String? userId}) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences
            .getStringList(
              _scopedPreferenceKey(_wantedMissingVolumesKey, userId),
            )
            ?.toSet() ??
        <String>{};
  }

  Future<void> setMissingVolumeWanted(
    String volumeId, {
    required bool wanted,
    String? userId,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final key = _scopedPreferenceKey(_wantedMissingVolumesKey, userId);
    final ids = preferences.getStringList(key)?.toSet() ?? <String>{};
    wanted ? ids.add(volumeId) : ids.remove(volumeId);
    await preferences.setStringList(key, ids.toList()..sort());
  }

  Future<Set<String>> getReleaseAlertSubSeriesIds({String? userId}) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences
            .getStringList(_scopedPreferenceKey(_releaseAlertsKey, userId))
            ?.toSet() ??
        <String>{};
  }

  Future<void> setReleaseAlert(
    String subSeriesId, {
    required bool enabled,
    String? userId,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final key = _scopedPreferenceKey(_releaseAlertsKey, userId);
    final ids = preferences.getStringList(key)?.toSet() ?? <String>{};
    enabled ? ids.add(subSeriesId) : ids.remove(subSeriesId);
    await preferences.setStringList(key, ids.toList()..sort());
  }
}
