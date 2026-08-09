import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:http/http.dart' as http;
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/analytics/reliability_monitor.dart';
import 'package:mymangatheque/src/back/services/api/mobile_api_key_manager.dart';
import 'package:mymangatheque/src/back/services/appwrite_client.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';

class MobileApiClient {
  MobileApiClient._internal();

  static final MobileApiClient _singleton = MobileApiClient._internal();

  factory MobileApiClient() => _singleton;

  static const String _apiBaseUrl = 'https://api.mymangatheque.com';
  static const Duration _requestTimeout = Duration(seconds: 20);

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
    if (current != null &&
        !current.willExpireWithin(const Duration(minutes: 5))) {
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
    final hasAuthenticatedSession = await _appwriteClient
        .hasAuthenticatedUserSession();

    if (hasAuthenticatedSession) {
      jwt = await _tryCreateJwt();
    } else {
      // Optional guest path: backend can now issue API keys without Bearer.
      await _appwriteClient.ensureGuestSession();
      jwt = await _tryCreateJwt(silentUnauthorized: true);
    }

    final candidate = _keyManager.generateCandidate();
    final response = await _requestMobileKey(
      authorizationBearer: jwt,
      keyHash: candidate.keyHash,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        RuntimeLocalization.text(
          en: 'Unable to obtain the mobile API key (status ${response.statusCode}): ${redactSensitiveText(response.body)}',
          fr: 'Impossible d’obtenir la clé API mobile (statut ${response.statusCode}) : ${redactSensitiveText(response.body)}',
        ),
      );
    }

    final parsed = _keyManager.parseKeyFromResponseBody(
      response.body,
      clientGeneratedKey: candidate.value,
    );
    await _keyManager.saveKey(parsed);
    return parsed.value;
  }

  Future<String?> _tryCreateJwt({bool silentUnauthorized = false}) {
    return _currentJwtOrNull(silentUnauthorized: silentUnauthorized);
  }

  Future<http.Response> _requestMobileKey({
    required String keyHash,
    String? authorizationBearer,
  }) {
    return http
        .post(
          Uri.parse('$_apiBaseUrl/api/auth/keys/mobile'),
          headers: <String, String>{
            if (authorizationBearer != null && authorizationBearer.isNotEmpty)
              'Authorization': 'Bearer $authorizationBearer',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{'keyHash': keyHash}),
        )
        .timeout(_requestTimeout);
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
      final unauthorized =
          e.code == 401 || e.type == 'general_unauthorized_scope';
      if (unauthorized) {
        if (!silentUnauthorized) {
          RuntimeLocalization.debug(
            en: 'JWT generation failed because the session is unauthorized: $e',
            fr: 'La génération du JWT a échoué car la session n’est pas autorisée : $e',
          );
        }
        _clearJwtCache();
        return null;
      }

      final rateLimited =
          e.code == 429 || e.type == 'general_rate_limit_exceeded';
      if (rateLimited) {
        _jwtRateLimitedUntilUtc = DateTime.now().toUtc().add(
          const Duration(seconds: 45),
        );
        RuntimeLocalization.debug(
          en: 'JWT generation is rate-limited. Reusing the cached JWT when available.',
          fr: 'La génération du JWT est limitée. Réutilisation du JWT en cache si disponible.',
        );
        return _cachedJwt;
      }

      RuntimeLocalization.debug(
        en: 'JWT generation failed: $e',
        fr: 'La génération du JWT a échoué : $e',
      );
      return _cachedJwt;
    } catch (e) {
      RuntimeLocalization.debug(
        en: 'JWT generation failed: $e',
        fr: 'La génération du JWT a échoué : $e',
      );
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

    if (!isSafeApiPath(path)) {
      throw ArgumentError(
        RuntimeLocalization.text(
          en: 'Invalid API path.',
          fr: 'Chemin API invalide.',
        ),
      );
    }

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
      final hasAuthenticatedSession = await _appwriteClient
          .hasAuthenticatedUserSession();
      if (!hasAuthenticatedSession) {
        RuntimeLocalization.debug(
          en: 'A Bearer JWT was requested for $path without an authenticated session.',
          fr: 'Un JWT Bearer a été demandé pour $path sans session authentifiée.',
        );
        return http.Response(
          jsonEncode(<String, dynamic>{
            'status': 'fail',
            'message': RuntimeLocalization.text(
              en: 'Missing authenticated user session for Bearer request',
              fr: 'Session utilisateur authentifiée absente pour la requête Bearer',
            ),
          }),
          401,
          headers: const <String, String>{'content-type': 'application/json'},
        );
      }

      final jwt = await _currentJwtOrNull();
      if (jwt == null || jwt.isEmpty) {
        RuntimeLocalization.debug(
          en: 'Bearer JWT unavailable for $path. Returning 401.',
          fr: 'JWT Bearer indisponible pour $path. Retour du statut 401.',
        );
        return http.Response(
          jsonEncode(<String, dynamic>{
            'status': 'fail',
            'message': RuntimeLocalization.text(
              en: 'Missing authenticated user session for Bearer request',
              fr: 'Session utilisateur authentifiée absente pour la requête Bearer',
            ),
          }),
          401,
          headers: const <String, String>{'content-type': 'application/json'},
        );
      }
      headers['Authorization'] = 'Bearer $jwt';
    }

    final payload = body == null ? null : jsonEncode(body);

    late final http.Response response;
    final stopwatch = Stopwatch()..start();
    try {
      switch (method) {
        case 'GET':
          response = await http
              .get(uri, headers: headers)
              .timeout(_requestTimeout);
          break;
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: payload)
              .timeout(_requestTimeout);
          break;
        case 'PATCH':
          response = await http
              .patch(uri, headers: headers, body: payload)
              .timeout(_requestTimeout);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: headers, body: payload)
              .timeout(_requestTimeout);
          break;
        default:
          throw UnsupportedError(
            RuntimeLocalization.text(
              en: 'HTTP method not supported: $method',
              fr: 'Méthode HTTP non prise en charge : $method',
            ),
          );
      }
      stopwatch.stop();
      ReliabilityMonitor.instance.record(
        method: method,
        path: path,
        duration: stopwatch.elapsed,
        statusCode: response.statusCode,
      );
    } on Object catch (error) {
      stopwatch.stop();
      ReliabilityMonitor.instance.record(
        method: method,
        path: path,
        duration: stopwatch.elapsed,
        failureType: error is TimeoutException ? 'timeout' : 'network',
      );
      rethrow;
    }

    if (requiresApiKey &&
        !retryingAfterKeyRefresh &&
        (response.statusCode == 401 || response.statusCode == 403)) {
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
