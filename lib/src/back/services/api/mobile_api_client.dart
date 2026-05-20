import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mymangatheque/src/back/services/api/mobile_api_key_manager.dart';
import 'package:mymangatheque/src/back/services/appwrite_client.dart';

class MobileApiClient {
  MobileApiClient._internal();

  static final MobileApiClient _singleton = MobileApiClient._internal();

  factory MobileApiClient() => _singleton;

  static const String _apiBaseUrl = 'https://api.mymangatheque.com';

  final MobileApiKeyManager _keyManager = MobileApiKeyManager();
  final AppwriteClientService _appwriteClient = AppwriteClientService();
  String? _cachedJwt;
  DateTime? _cachedJwtExpiresAtUtc;
  DateTime? _jwtRateLimitedUntilUtc;
  Future<String?>? _jwtRefreshFuture;

  Future<void> init() async {
    await _appwriteClient.init();
    await _keyManager.init();
  }

  Future<void> invalidateApiKey() async {
    await _keyManager.clear();
    _clearJwtCache();
  }

  Future<String> ensureApiKey() async {
    await init();

    final current = await _keyManager.getKey();
    if (current != null && !current.willExpireWithin(const Duration(minutes: 5))) {
      return current.value;
    }

    return _refreshApiKey();
  }

  Future<String> forceRefreshApiKey() async {
    await init();
    return _refreshApiKey();
  }

  Future<String> _refreshApiKey() async {
    String? jwt;
    final hasAuthenticatedSession = await _appwriteClient.hasAuthenticatedUserSession();

    if (hasAuthenticatedSession) {
      jwt = await _tryCreateJwt();
    } else {
      // Optional guest path: backend can now issue API keys without Bearer.
      await _appwriteClient.ensureGuestSession();
      jwt = await _tryCreateJwt(silentUnauthorized: true);
    }

    final response = await _requestMobileKey(authorizationBearer: jwt);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Unable to obtain mobile API key (status ${response.statusCode}): ${response.body}',
      );
    }

    final parsed = _keyManager.parseKeyFromResponseBody(response.body);
    await _keyManager.saveKey(parsed);
    return parsed.value;
  }

  Future<String?> _tryCreateJwt({bool silentUnauthorized = false}) {
    return _currentJwtOrNull(silentUnauthorized: silentUnauthorized);
  }

  Future<http.Response> _requestMobileKey({String? authorizationBearer}) {
    return http.post(
      Uri.parse('$_apiBaseUrl/api/auth/keys/mobile'),
      headers: <String, String>{
        if (authorizationBearer != null && authorizationBearer.isNotEmpty) 'Authorization': 'Bearer $authorizationBearer',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{}),
    );
  }

  bool _hasValidCachedJwt() {
    final token = _cachedJwt;
    final expiry = _cachedJwtExpiresAtUtc;
    if (token == null || token.isEmpty || expiry == null) return false;
    return DateTime.now().toUtc().isBefore(
      expiry.subtract(const Duration(seconds: 30)),
    );
  }

  void _clearJwtCache() {
    _cachedJwt = null;
    _cachedJwtExpiresAtUtc = null;
    _jwtRateLimitedUntilUtc = null;
  }

  Future<String?> _currentJwtOrNull({bool silentUnauthorized = false}) async {
    await init();

    if (_hasValidCachedJwt()) {
      return _cachedJwt;
    }

    final now = DateTime.now().toUtc();
    final rateLimitedUntil = _jwtRateLimitedUntilUtc;
    if (rateLimitedUntil != null && now.isBefore(rateLimitedUntil)) {
      return _cachedJwt;
    }

    final inFlight = _jwtRefreshFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _refreshJwt(silentUnauthorized: silentUnauthorized);
    _jwtRefreshFuture = future;
    try {
      return await future;
    } finally {
      if (identical(_jwtRefreshFuture, future)) {
        _jwtRefreshFuture = null;
      }
    }
  }

  Future<String?> _refreshJwt({bool silentUnauthorized = false}) async {
    try {
      final jwt = await _appwriteClient.createJwt();
      _cachedJwt = jwt.jwt;
      _cachedJwtExpiresAtUtc = DateTime.now().toUtc().add(
        const Duration(minutes: 14),
      );
      _jwtRateLimitedUntilUtc = null;
      return _cachedJwt;
    } on AppwriteException catch (e) {
      final unauthorized = e.code == 401 || e.type == 'general_unauthorized_scope';
      if (unauthorized) {
        if (!silentUnauthorized) {
          debugPrint('JWT generation failed (unauthorized): $e');
        }
        _clearJwtCache();
        return null;
      }

      final rateLimited = e.code == 429 || e.type == 'general_rate_limit_exceeded';
      if (rateLimited) {
        _jwtRateLimitedUntilUtc = DateTime.now().toUtc().add(
          const Duration(seconds: 45),
        );
        debugPrint(
          'JWT generation rate-limited. Reusing cached JWT if available.',
        );
        return _cachedJwt;
      }

      debugPrint('JWT generation failed: $e');
      return _cachedJwt;
    } catch (e) {
      debugPrint('JWT generation failed: $e');
      return _cachedJwt;
    }
  }

  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? query,
    bool requiresApiKey = true,
    bool requiresBearer = false,
  }) {
    return _request(
      'GET',
      path,
      query: query,
      requiresApiKey: requiresApiKey,
      requiresBearer: requiresBearer,
    );
  }

  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    bool requiresApiKey = true,
    bool requiresBearer = false,
  }) {
    return _request(
      'POST',
      path,
      query: query,
      body: body,
      requiresApiKey: requiresApiKey,
      requiresBearer: requiresBearer,
    );
  }

  Future<http.Response> patch(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    bool requiresApiKey = true,
    bool requiresBearer = false,
  }) {
    return _request(
      'PATCH',
      path,
      query: query,
      body: body,
      requiresApiKey: requiresApiKey,
      requiresBearer: requiresBearer,
    );
  }

  Future<http.Response> delete(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    bool requiresApiKey = true,
    bool requiresBearer = false,
  }) {
    return _request(
      'DELETE',
      path,
      query: query,
      body: body,
      requiresApiKey: requiresApiKey,
      requiresBearer: requiresBearer,
    );
  }

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    bool requiresApiKey = true,
    bool requiresBearer = false,
    bool retryingAfterKeyRefresh = false,
  }) async {
    await init();

    final uri = Uri.parse('$_apiBaseUrl$path').replace(
      queryParameters: query?.map(
        (key, value) => MapEntry(key, value?.toString()),
      ),
    );

    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };

    if (requiresApiKey) {
      headers['x-api-key'] = await ensureApiKey();
    }

    if (requiresBearer) {
      final hasAuthenticatedSession = await _appwriteClient.hasAuthenticatedUserSession();
      if (!hasAuthenticatedSession) {
        debugPrint(
          'Bearer JWT requested for $path but no authenticated session is active.',
        );
        return http.Response(
          jsonEncode(<String, dynamic>{
            'status': 'fail',
            'message': 'Missing authenticated user session for Bearer request',
          }),
          401,
          headers: const <String, String>{'content-type': 'application/json'},
        );
      }

      final jwt = await _currentJwtOrNull();
      if (jwt == null || jwt.isEmpty) {
        debugPrint('Bearer JWT unavailable for $path. Returning 401.');
        return http.Response(
          jsonEncode(<String, dynamic>{
            'status': 'fail',
            'message': 'Missing authenticated user session for Bearer request',
          }),
          401,
          headers: const <String, String>{'content-type': 'application/json'},
        );
      }
      headers['Authorization'] = 'Bearer $jwt';
    }

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
        throw UnsupportedError('HTTP method not supported: $method');
    }

    if (requiresApiKey && !retryingAfterKeyRefresh && (response.statusCode == 401 || response.statusCode == 403)) {
      await forceRefreshApiKey();
      return _request(
        method,
        path,
        query: query,
        body: body,
        requiresApiKey: requiresApiKey,
        requiresBearer: requiresBearer,
        retryingAfterKeyRefresh: true,
      );
    }

    return response;
  }

  dynamic decodeBody(http.Response response) {
    final body = response.body;
    if (body.isEmpty) return null;

    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  Future<List<dynamic>> fetchAllPages({
    required String path,
    required String listKey,
    Map<String, dynamic>? baseQuery,
    bool requiresApiKey = true,
    bool requiresBearer = false,
  }) async {
    final all = <dynamic>[];
    var page = 1;
    var totalPages = 1;

    do {
      final query = <String, dynamic>{
        'page': page,
        'limit': 100,
        ...?baseQuery,
      };

      final response = await get(
        path,
        query: query,
        requiresApiKey: requiresApiKey,
        requiresBearer: requiresBearer,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'API pagination request failed for $path (status ${response.statusCode}): ${response.body}',
        );
      }

      final decoded = decodeBody(response);
      final pageData = _extractList(decoded, listKey);
      all.addAll(pageData);

      final pagination = _extractPagination(decoded);
      totalPages = pagination['totalPages'] as int? ?? 1;
      page += 1;
    } while (page <= totalPages);

    return all;
  }

  List<dynamic> _extractList(dynamic decoded, String listKey) {
    if (decoded is List<dynamic>) return decoded;
    if (decoded is! Map<String, dynamic>) return const <dynamic>[];

    final direct = decoded[listKey];
    if (direct is List<dynamic>) return direct;

    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      final nested = data[listKey];
      if (nested is List<dynamic>) return nested;
    }

    return const <dynamic>[];
  }

  Map<String, dynamic> _extractPagination(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) return const <String, dynamic>{};
    final pagination = decoded['pagination'];
    if (pagination is Map<String, dynamic>) return pagination;
    return const <String, dynamic>{};
  }
}
