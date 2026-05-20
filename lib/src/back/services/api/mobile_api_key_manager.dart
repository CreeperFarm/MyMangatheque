import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MobileApiKey {
  const MobileApiKey({required this.value, required this.expiresAt});

  final String value;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool willExpireWithin(Duration duration) {
    return DateTime.now().add(duration).isAfter(expiresAt);
  }
}

class MobileApiKeyManager {
  MobileApiKeyManager._internal();

  static final MobileApiKeyManager _singleton = MobileApiKeyManager._internal();

  factory MobileApiKeyManager() => _singleton;

  static const String _keyStorageKey = 'mmt_api_key_value';
  static const String _keyExpiryStorageKey = 'mmt_api_key_expiry';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  MobileApiKey? _cached;

  Future<void> init() async {
    if (_cached != null) return;
    _cached = await _readFromStorage();
  }

  Future<MobileApiKey?> getKey() async {
    await init();
    if (_cached != null) return _cached;
    _cached = await _readFromStorage();
    return _cached;
  }

  Future<void> saveKey(MobileApiKey key) async {
    _cached = key;
    await _writeSecure(_keyStorageKey, key.value);
    await _writeSecure(_keyExpiryStorageKey, key.expiresAt.toIso8601String());
  }

  Future<void> clear() async {
    _cached = null;
    await _deleteSecure(_keyStorageKey);
    await _deleteSecure(_keyExpiryStorageKey);
  }

  Future<MobileApiKey?> _readFromStorage() async {
    final key = await _readSecure(_keyStorageKey);
    final expiry = await _readSecure(_keyExpiryStorageKey);

    if (key == null || key.isEmpty || expiry == null || expiry.isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(expiry);
    if (parsed == null) {
      return null;
    }

    return MobileApiKey(value: key, expiresAt: parsed.toUtc());
  }

  Future<String?> _readSecure(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      debugPrint('Secure storage read failed for $key: $e');
      return _readFallback(key);
    }
  }

  Future<void> _writeSecure(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return;
    } catch (e) {
      debugPrint('Secure storage write failed for $key: $e');
      await _writeFallback(key, value);
    }
  }

  Future<void> _deleteSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
      return;
    } catch (e) {
      debugPrint('Secure storage delete failed for $key: $e');
      await _deleteFallback(key);
    }
  }

  Future<String?> _readFallback(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _writeFallback(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _deleteFallback(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  MobileApiKey parseKeyFromResponseBody(String responseBody) {
    dynamic decoded;
    try {
      decoded = jsonDecode(responseBody);
    } catch (_) {
      decoded = responseBody;
    }

    String? key;
    String? expiresAtRaw;

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      key =
          decoded['key']?.toString() ??
          decoded['apiKey']?.toString() ??
          (data is Map<String, dynamic>
              ? data['key']?.toString() ?? data['apiKey']?.toString()
              : null);
      expiresAtRaw =
          decoded['expiresAt']?.toString() ??
          decoded['expires_at']?.toString() ??
          (data is Map<String, dynamic>
              ? data['expiresAt']?.toString() ?? data['expires_at']?.toString()
              : null);
    } else if (decoded is String && decoded.trim().isNotEmpty) {
      key = decoded.trim();
    }

    if (key == null || key.isEmpty) {
      throw StateError('No API key returned by /api/auth/keys/mobile');
    }

    final expiresAt =
        DateTime.tryParse(expiresAtRaw ?? '')?.toUtc() ??
        DateTime.now().toUtc().add(const Duration(hours: 2));

    return MobileApiKey(value: key, expiresAt: expiresAt);
  }
}
