import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This implementation uses shared_preferences, which is NOT secure.
/// Consider using flutter_secure_storage instead. The reason I didn't
/// use it in the tutorial is because it requires a developer account
/// for Apple.
class LocalStorage {
  static const _tokenKey = 'token';
  static const _ownedSubSerieKey = 'ownedSubSerie';

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
  }

  Future<Set<SubSerieForCollection>?> getOwnedSubSerie() async {
    debugPrint("Retrieving owned sub series from local storage");
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_ownedSubSerieKey); // Get JSON String

    if (jsonString == null) return null; // Return null if no data

    return (json.decode(jsonString) as List).map((e) => SubSerieForCollection.fromJson(e)).toSet();
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
  }
}
