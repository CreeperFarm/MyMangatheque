import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mymangatheque/src/models/manga/author.dart';
import 'package:mymangatheque/src/models/manga/editor.dart';
import 'package:mymangatheque/src/models/manga/serie.dart';
import 'package:mymangatheque/src/models/manga/sub_serie.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This implementation uses shared_preferences, which is NOT secure.
/// Consider using flutter_secure_storage instead. The reason I didn't
/// use it is because it requires a developer account for Apple.
class LocalStorage {
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

  // * Token ----------------------------------------------------------------------------------------------------------
  Future<String?> getToken() async {
    debugPrint("Retrieving user's token from local storage");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token;
  }

  Future<void> setToken(String token) async {
    debugPrint("Saving user's token from local storage");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_tokenKey);
    debugPrint("The token from local storage as been deleted.");
  }

  // * End of token ----------------------------------------------------------------------------------------------------

  // * Language Code ---------------------------------------------------------------------------------------------------
  Future<String?> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString(_cacheLanguageKey);
    debugPrint("Retrieving user's language from local storage ($language)");
    return language;
  }

  Future<void> setLanguageCode(String language) async {
    debugPrint("Saving user's language from local storage ($language)");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheLanguageKey, language);
  }

  Future<void> deleteLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('language');
    debugPrint("The language from local storage as been deleted.");
  }

  // * End of language ------------------------------------------------------------------------------------------------

  // * Owned sub series ------------------------------------------------------------------------------------------------
  Future<Set<SubSerieForCollection>?> getOwnedSubSerie() async {
    debugPrint("Retrieving owned sub series from local storage");
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_ownedSubSerieKey); // Get JSON String

    if (jsonString == null) return null; // Return null if no data
    return (json.decode(jsonString) as List)
        .map((e) => SubSerieForCollection.fromJson(e))
        .toSet();
  }

  Future<void> saveOwnedSubSerie(Set<SubSerieForCollection> subSerie) async {
    debugPrint("Saving owned sub series from local storage");
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(subSerie.toList()); // Convert to JSON String
    await prefs.setString(_ownedSubSerieKey, jsonString);
  }

  Future<void> deleteOwnedSubSerie() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_ownedSubSerieKey);
    debugPrint("Owned sub series from local storage as been deleted.");
  }

  // * End of owned sub series ----------------------------------------------------------------------------------------

  // * Cache series ---------------------------------------------------------------------------------------------------
  Future<Set<Serie>?> getCacheSeries() async {
    debugPrint("Retrieving cache series from local storage");
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheSeriesKey); // Get JSON String

    if (jsonString == null) return null; // Return null if no data

    return (json.decode(jsonString) as List)
        .map((e) => Serie.fromJson(e))
        .toSet();
  }

  Future<void> saveCacheSeries(Set<Serie> series) async {
    debugPrint("Saving cache series from local storage");
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(series.toList()); // Convert to JSON String
    await prefs.setString(_cacheSeriesKey, jsonString);
  }

  Future<void> deleteCacheSeries() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_cacheSeriesKey);
    debugPrint("Cache of series from local storage as been deleted.");
  }

  // * End of cache series ------------------------------------------------------------------------------------------

  // * Cache sub series ----------------------------------------------------------------------------------------------
  Future<Set<SubSerie>?> getCacheSubSeries() async {
    debugPrint("Retrieving cache sub series from local storage");
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheSubSeriesKey); // Get JSON String

    if (jsonString == null) return null; // Return null if no data

    return (json.decode(jsonString) as List)
        .map((e) => SubSerie.fromJson(e))
        .toSet();
  }

  Future<void> saveCacheSubSeries(Set<SubSerie> subSeries) async {
    debugPrint("Saving cache sub series from local storage");
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(
      subSeries.toList(),
    ); // Convert to JSON String
    await prefs.setString(_cacheSubSeriesKey, jsonString);
  }

  Future<void> deleteCacheSubSeries() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_cacheSubSeriesKey);
    debugPrint("Cache of sub series from local storage as been deleted.");
  }

  // * End of cache sub series ----------------------------------------------------------------------------------------

  // * Cache volumes -------------------------------------------------------------------------------------------------
  Future<Set<Volume>?> getCacheVolumes() async {
    debugPrint("Retrieving cache volumes from local storage");
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheVolumesKey); // Get JSON String

    if (jsonString == null) return null; // Return null if no data

    return (json.decode(jsonString) as List)
        .map((e) => Volume.fromJson(e))
        .toSet();
  }

  Future<void> saveCacheVolumes(Set<Volume> volumes) async {
    debugPrint("Saving cache volumes from local storage");
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(volumes.toList()); // Convert to JSON String
    await prefs.setString(_cacheVolumesKey, jsonString);
  }

  Future<void> deleteCacheVolumes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_cacheVolumesKey);
    debugPrint("Cache of volumes from local storage as been deleted.");
  }

  // * End of cache volumes -------------------------------------------------------------------------------------------

  // * Cache authors -------------------------------------------------------------------------------------------------
  Future<Set<Author>?> getCacheAuthors() async {
    debugPrint("Retrieving cache authors from local storage");
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheAuthorsKey); // Get JSON String

    if (jsonString == null) return null; // Return null if no data

    return (json.decode(jsonString) as List)
        .map((e) => Author.fromJson(e))
        .toSet();
  }

  Future<void> saveCacheAuthors(Set<Author> authors) async {
    debugPrint("Saving cache authors from local storage");
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(authors.toList()); // Convert to JSON String
    await prefs.setString(_cacheAuthorsKey, jsonString);
  }

  Future<void> deleteCacheAuthors() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_cacheAuthorsKey);
    debugPrint("Cache of authors from local storage as been deleted.");
  }

  // * End of cache authors -------------------------------------------------------------------------------------------

  // * Cache editors -------------------------------------------------------------------------------------------------
  Future<Set<Editor>?> getCacheEditors() async {
    debugPrint("Retrieving cache editors from local storage");
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheEditorsKey); // Get JSON String

    if (jsonString == null) return null; // Return null if no data

    return (json.decode(jsonString) as List)
        .map((e) => Editor.fromJson(e))
        .toSet();
  }

  Future<void> saveCacheEditors(Set<Editor> editors) async {
    debugPrint("Saving cache editors from local storage");
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(editors.toList()); // Convert to JSON String
    await prefs.setString(_cacheEditorsKey, jsonString);
  }

  Future<void> deleteCacheEditors() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_cacheEditorsKey);
    debugPrint("Cache of editors from local storage as been deleted.");
  }

  // * End of cache editors -------------------------------------------------------------------------------------------

  // * Clear all cache ------------------------------------------------------------------------------------------------
  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_cacheSeriesKey);
    prefs.remove(_cacheSubSeriesKey);
    prefs.remove(_cacheVolumesKey);
    prefs.remove(_cacheAuthorsKey);
    prefs.remove(_cacheEditorsKey);
    debugPrint("The whole cache from local storage as been deleted.");
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
}
