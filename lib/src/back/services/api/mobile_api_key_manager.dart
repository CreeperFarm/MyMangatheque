import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MobileApiKey {
  const MobileApiKey({required this.value, required this.expiresAt});

  final String value;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool willExpireWithin(Duration duration) {
    return DateTime.now().add(duration).isAfter(expiresAt);
  }
}

class MobileApiKeyCandidate {
  const MobileApiKeyCandidate({required this.value, required this.keyHash});

  final String value;
  final String keyHash;
}

class MobileApiKeyManager {
  MobileApiKeyManager._internal();

  static final MobileApiKeyManager _singleton = MobileApiKeyManager._internal();

  factory MobileApiKeyManager() => _singleton;

  static const String _keyStorageKey = 'mmt_api_key_value';
  static const String _keyExpiryStorageKey = 'mmt_api_key_expiry';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Random _secureRandom = Random.secure();
  MobileApiKey? _cached;

  MobileApiKeyCandidate generateCandidate() {
    final bytes = List<int>.generate(
      32,
      (_) => _secureRandom.nextInt(256),
      growable: false,
    );
    final value = base64UrlEncode(bytes).replaceAll('=', '');
    final keyHash = sha256.convert(utf8.encode(value)).toString();
    return MobileApiKeyCandidate(value: value, keyHash: keyHash);
  }

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
    await _writeSecure(_keyStorageKey, key.value);
    await _writeSecure(_keyExpiryStorageKey, key.expiresAt.toIso8601String());
    _cached = key;
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
      return null;
    }
  }

  Future<void> _writeSecure(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return;
    } catch (e) {
      debugPrint('Secure storage write failed for $key: $e');
      throw StateError('Secure storage is unavailable for the mobile API key.');
    }
  }

  Future<void> _deleteSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
      return;
    } catch (e) {
      debugPrint('Secure storage delete failed for $key: $e');
    }
  }

  MobileApiKey parseKeyFromResponseBody(
    String responseBody, {
    String? clientGeneratedKey,
  }) {
    dynamic decoded;
    try {
      decoded = jsonDecode(responseBody);
    } catch (_) {
      decoded = responseBody;
    }

    String? key = clientGeneratedKey;
    String? expiresAtRaw;

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      key ??=
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
    } else if (key == null && decoded is String && decoded.trim().isNotEmpty) {
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
