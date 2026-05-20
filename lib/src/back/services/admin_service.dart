import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mymangatheque/src/back/services/api/mobile_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminConnector {
  AdminConnector._internal();

  static final AdminConnector _singleton = AdminConnector._internal();

  factory AdminConnector() => _singleton;

  static const String _apiBaseUrl = 'https://api.mymangatheque.com';
  static const String _storageKey = 'mmt_admin_api_key';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final MobileApiClient _mobileApiClient = MobileApiClient();

  String? _adminApiKey;

  Future<void> init() async {
    _adminApiKey ??= await _readSecure(_storageKey);
    if (_adminApiKey == null || _adminApiKey!.isEmpty) {
      _adminApiKey = null;
    }
  }

  bool isLoggedIn() => _adminApiKey != null && _adminApiKey!.isNotEmpty;

  String get maskedKey {
    if (!isLoggedIn()) return 'Aucune clé admin';
    final key = _adminApiKey!;
    if (key.length <= 8) return key;
    return '${key.substring(0, 4)}••••${key.substring(key.length - 4)}';
  }

  Future<bool> loginAsAdmin(String apiKey) async {
    await init();
    final sanitized = apiKey.trim();
    if (sanitized.isEmpty) return false;

    final verified = await _canUseAsAdmin(sanitized);
    if (!verified) return false;

    _adminApiKey = sanitized;
    await _writeSecure(_storageKey, sanitized);
    return true;
  }

  Future<bool> loginWithCurrentSessionKey() async {
    await init();
    final sessionKey = await _mobileApiClient.ensureApiKey();
    final verified = await _canUseAsAdmin(sessionKey);
    if (!verified) return false;

    _adminApiKey = sessionKey;
    await _writeSecure(_storageKey, sessionKey);
    return true;
  }

  Future<void> logout() async {
    _adminApiKey = null;
    await _deleteSecure(_storageKey);
  }

  Future<Map<String, dynamic>> getSummary() async {
    await init();
    final response = await _request('GET', '/api/analytics/summary');
    return _decodeMap(response.body);
  }

  Future<Map<String, dynamic>> getMostAddedVolumes({
    int days = 30,
    int limit = 10,
  }) async {
    await init();
    final response = await _request(
      'GET',
      '/api/analytics/most-added-volumes',
      query: <String, dynamic>{'days': days, 'limit': limit},
    );
    return _decodeMap(response.body);
  }

  Future<void> createAuthor({
    required String name,
    List<String> jobs = const <String>[],
    String? coverUrl,
  }) async {
    await init();

    final body = <String, dynamic>{
      'name': name.trim(),
      if (jobs.isNotEmpty) 'jobs': jobs,
      if ((coverUrl ?? '').trim().isNotEmpty) 'coverUrl': coverUrl!.trim(),
    };

    await _request('POST', '/api/authors', body: body);
  }

  Future<void> createGenre({required String name}) async {
    await init();
    await _request(
      'POST',
      '/api/genres',
      body: <String, dynamic>{'name': name.trim()},
    );
  }

  Future<void> createVolume({
    required String titleFr,
    String? titleJp,
    String? titleEn,
    required num tomeNumber,
    required num price,
    String? coverUrl,
    String? resume,
    DateTime? publicationDate,
    required int ean,
    required String language,
    required String support,
    String? genderJp,
    String? subSeriesId,
    bool over18 = false,
  }) async {
    await init();

    final body = <String, dynamic>{
      'titleFr': titleFr.trim(),
      if ((titleJp ?? '').trim().isNotEmpty) 'titleJp': titleJp!.trim(),
      if ((titleEn ?? '').trim().isNotEmpty) 'titleEn': titleEn!.trim(),
      'tomeNumber': tomeNumber,
      'price': price,
      if ((coverUrl ?? '').trim().isNotEmpty) 'coverUrl': coverUrl!.trim(),
      if ((resume ?? '').trim().isNotEmpty) 'resume': resume!.trim(),
      if (publicationDate != null)
        'publicationDate': publicationDate.toUtc().toIso8601String(),
      'ean': ean,
      'language': language,
      'support': support,
      if ((genderJp ?? '').trim().isNotEmpty) 'genderJp': genderJp!.trim(),
      if ((subSeriesId ?? '').trim().isNotEmpty)
        'subSeries': subSeriesId!.trim(),
      'over18': over18,
    };

    await _request('POST', '/api/volumes', body: body);
  }

  Future<bool> _canUseAsAdmin(String apiKey) async {
    try {
      final response = await _rawRequest(
        'GET',
        '/api/auth/keys',
        apiKey: apiKey,
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    if (!isLoggedIn()) {
      throw StateError(
        'Admin non connecté. Veuillez saisir une clé API admin.',
      );
    }
    return _rawRequest(
      method,
      path,
      apiKey: _adminApiKey!,
      query: query,
      body: body,
    );
  }

  Future<http.Response> _rawRequest(
    String method,
    String path, {
    required String apiKey,
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl$path').replace(
      queryParameters: query?.map(
        (key, value) => MapEntry(key, value?.toString()),
      ),
    );

    final headers = <String, String>{
      'Accept': 'application/json',
      'x-api-key': apiKey,
      if (body != null) 'Content-Type': 'application/json',
    };

    final payload = body == null ? null : jsonEncode(body);
    late final http.Response response;

    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers, body: payload);
        break;
      case 'PATCH':
        response = await http.patch(uri, headers: headers, body: payload);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers, body: payload);
        break;
      default:
        throw UnsupportedError('Méthode HTTP non supportée: $method');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractApiError(response));
    }
    return response;
  }

  String _extractApiError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return 'Erreur API (${response.statusCode}): $message';
        }
      }
    } catch (_) {}

    return 'Erreur API (${response.statusCode}): ${response.body}';
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{};
  }

  Future<String?> _readSecure(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      debugPrint('Secure storage read failed for $key: $e');
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
  }

  Future<void> _writeSecure(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      debugPrint('Secure storage write failed for $key: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }

  Future<void> _deleteSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      debugPrint('Secure storage delete failed for $key: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    }
  }
}
