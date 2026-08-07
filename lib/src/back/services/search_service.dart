import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mymangatheque/src/back/services/api/mobile_api_client.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/back/services/appwrite_client.dart';
import 'package:mymangatheque/src/back/services/models/api_record_model.dart';

class SearchService {
  SearchService._internal();

  static final SearchService _singleton = SearchService._internal();
  factory SearchService() => _singleton;

  static const String _apiBaseUrl = 'https://api.mymangatheque.com';
  static const Duration _realtimeTimeout = Duration(seconds: 15);

  final AppwriteClientService _appwrite = AppwriteClientService();
  final AppwriteConnector _connector = AppwriteConnector();
  final MobileApiClient _mobileApi = MobileApiClient();

  int _requestCounter = 0;
  http.Client? _currentClient;
  final Map<String, DateTime> _rateLimitRetryUntil = <String, DateTime>{};

  Future<void> _ensureInitialized() async {
    await _appwrite.init();
    await _mobileApi.init();
    await _connector.init();
  }

  String _normalizeResource(String resource) {
    switch (resource.trim()) {
      case 'sub_series':
      case 'subseries':
      case 'sub-series':
        return 'sub-series';
      case 'series':
      case 'volumes':
      case 'authors':
      case 'editors':
      case 'users':
        return resource.trim();
      default:
        return resource.trim();
    }
  }

  String _responseListKey(String resource) {
    switch (_normalizeResource(resource)) {
      case 'sub-series':
        return 'subSeries';
      default:
        return _normalizeResource(resource);
    }
  }

  String _collectionId(String resource) {
    switch (_normalizeResource(resource)) {
      case 'sub-series':
        return 'sub_series';
      default:
        return _normalizeResource(resource);
    }
  }

  String _resourcePath(String resource) => '/api/${_normalizeResource(resource)}';

  String _normalizeText(String input) {
    const accentMap = <String, String>{
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'å': 'a',
      'ç': 'c',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ñ': 'n',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ý': 'y',
      'ÿ': 'y',
      'œ': 'oe',
      'æ': 'ae',
    };

    var output = input.toLowerCase();
    accentMap.forEach((key, value) {
      output = output.replaceAll(key, value);
    });
    output = output.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    output = output.replaceAll(RegExp(r'\s+'), ' ').trim();
    return output;
  }

  Future<String?> _tryCreateJwt() async {
    try {
      final jwt = await _appwrite.createJwt();
      return jwt.jwt;
    } catch (e) {
      debugPrint('SearchService JWT creation failed: $e');
      return null;
    }
  }

  Future<String?> _getApiKey() async {
    try {
      return await _mobileApi.ensureApiKey();
    } catch (e) {
      debugPrint('SearchService API key bootstrap failed: $e');
      return null;
    }
  }

  Future<http.Response> _sendRealtimeRequest(
    Uri uri, {
    required String resource,
    required int attempt,
  }) async {
    final client = _currentClient ?? http.Client();
    _currentClient = client;

    final headers = <String, String>{'Accept': 'application/json'};
    if (resource == 'users') {
      final jwt = await _tryCreateJwt();
      if (jwt != null && jwt.isNotEmpty) {
        headers['Authorization'] = 'Bearer $jwt';
      }
    } else {
      final apiKey = await _getApiKey();
      if (apiKey != null && apiKey.isNotEmpty) {
        headers['x-api-key'] = apiKey;
      }
    }

    late final http.Response response;
    try {
      response = await client.get(uri, headers: headers).timeout(_realtimeTimeout);
    } on TimeoutException catch (e) {
      debugPrint('SearchService realtime timeout for $resource: $e');
      return http.Response('', HttpStatus.requestTimeout);
    } on http.ClientException catch (e) {
      debugPrint('SearchService realtime client closed for $resource: $e');
      return http.Response('', HttpStatus.requestTimeout);
    } on SocketException catch (e) {
      debugPrint('SearchService realtime socket error for $resource: $e');
      return http.Response('', HttpStatus.serviceUnavailable);
    } catch (e) {
      debugPrint('SearchService realtime request failed for $resource: $e');
      return http.Response('', HttpStatus.serviceUnavailable);
    }

    if (response.statusCode == 429) {
      final retryAfter = _rateLimitRetryUntil[resource];
      final now = DateTime.now().toUtc();
      if (retryAfter != null && now.isBefore(retryAfter)) {
        return response;
      }
      _rateLimitRetryUntil[resource] = now.add(Duration(milliseconds: 300 * (attempt + 1)));
      if (attempt < 2) {
        await Future<void>.delayed(Duration(milliseconds: 150 * (attempt + 1)));
        return _sendRealtimeRequest(uri, resource: resource, attempt: attempt + 1);
      }
    }

    if (response.statusCode >= 500 && attempt < 1) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      return _sendRealtimeRequest(uri, resource: resource, attempt: attempt + 1);
    }

    return response;
  }

  List<ApiRecordModel> _parseRealtimeRecords(String resource, dynamic decoded) {
    if (decoded is! Map<String, dynamic>) return <ApiRecordModel>[];

    final rawList = _extractResultRows(resource, decoded);
    if (rawList.isEmpty) return <ApiRecordModel>[];

    final normalizedResource = _collectionId(resource);
    final records = <ApiRecordModel>[];

    for (final item in rawList) {
      final id = (item[r'$id'] ?? item['id'] ?? '').toString();
      if (id.isEmpty) continue;
      records.add(
        ApiRecordModel(
          id: id,
          collectionId: normalizedResource,
          data: Map<String, dynamic>.from(item),
        ),
      );
    }

    return records;
  }

  List<ApiRecordModel> _sortByMatchScore(String resource, List<ApiRecordModel> records, dynamic decoded) {
    if (decoded is! Map<String, dynamic>) return records;
    final search = decoded['search'];
    if (search is! Map<String, dynamic>) return records;
    final matches = search['matches'];
    if (matches is! List) return records;

    final scoreById = <String, num>{};
    for (final match in matches.whereType<Map<String, dynamic>>()) {
      final id = (match['id'] ?? '').toString();
      final score = match['score'];
      if (id.isNotEmpty && score is num) {
        scoreById[id] = score;
      }
    }

    final sorted = List<ApiRecordModel>.from(records)
      ..sort((a, b) {
        final aScore = scoreById[a.id] ?? 0;
        final bScore = scoreById[b.id] ?? 0;
        final cmp = bScore.compareTo(aScore);
        if (cmp != 0) return cmp;
        return _normalizeText(_recordLabel(resource, a.data)).compareTo(_normalizeText(_recordLabel(resource, b.data)));
      });
    return sorted;
  }

  String _recordLabel(String resource, Map<String, dynamic> data) {
    switch (_normalizeResource(resource)) {
      case 'users':
        return (data['pseudo'] ?? data['username'] ?? data['name'] ?? data['email'] ?? '').toString();
      case 'authors':
      case 'editors':
        return (data['name'] ?? '').toString();
      default:
        return (data['title'] ?? data['titleFr'] ?? data['name'] ?? '').toString();
    }
  }

  Future<List<ApiRecordModel>> realtime(
    String resource, {
    String? q,
    String? query,
    int limit = 8,
  }) async {
    await _ensureInitialized();

    final resourceName = _normalizeResource(resource);
    final searchText = (q ?? query ?? '').trim();
    if (searchText.length < 2) {
      return <ApiRecordModel>[];
    }

    final safeLimit = limit.clamp(1, 20);
    final requestId = ++_requestCounter;

    try {
      _currentClient?.close();
    } catch (_) {}
    _currentClient = http.Client();

    final params = <String, String>{
      'limit': safeLimit.toString(),
      if ((query ?? '').trim().isNotEmpty) 'query': query!.trim(),
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
    };

    final uri = Uri.parse('$_apiBaseUrl${_resourcePath(resourceName)}/search/realtime').replace(queryParameters: params);

    final response = await _sendRealtimeRequest(
      uri,
      resource: resourceName,
      attempt: 0,
    );

    if (requestId != _requestCounter) {
      return <ApiRecordModel>[];
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return <ApiRecordModel>[];
    }

    final decoded = jsonDecode(response.body);
    final parsed = _parseRealtimeRecords(resourceName, decoded);
    return _sortByMatchScore(resourceName, parsed, decoded);
  }

  Future<RecordPage> searchPaged(
    String resource, {
    String? q,
    String? query,
    int page = 1,
    int limit = 30,
  }) async {
    await _ensureInitialized();

    final resourceName = _normalizeResource(resource);
    final searchText = (q ?? query ?? '').trim();
    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit < 1 ? 30 : limit;

    final response = await _mobileApi.get(
      '/api/$resourceName/search',
      query: <String, dynamic>{
        'page': safePage,
        'limit': safeLimit,
        if (searchText.isNotEmpty) 'q': searchText,
        if ((query ?? '').trim().isNotEmpty) 'query': query!.trim(),
      },
      requiresApiKey: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      final pageData = _extractPagedResults(resourceName, decoded, safePage, safeLimit);
      if (pageData != null) return pageData;
    }

    return _fallbackLocalPagedSearch(
      resourceName,
      searchText,
      page: safePage,
      limit: safeLimit,
    );
  }

  RecordPage? _extractPagedResults(String resource, dynamic decoded, int page, int limit) {
    if (decoded is! Map<String, dynamic>) return null;

    final list = _extractResultRows(resource, decoded);

    if (list.isEmpty) return null;

    final items = list
        .map(
          (item) => ApiRecordModel(
            id: (item[r'$id'] ?? item['id'] ?? '').toString(),
            collectionId: _collectionId(resource),
            data: Map<String, dynamic>.from(item),
          ),
        )
        .where((item) => item.id.isNotEmpty)
        .toList();

    final pagination = decoded['pagination'];
    final paginationMap = pagination is Map<String, dynamic> ? pagination : <String, dynamic>{};
    final paginationValue = paginationMap['totalItems'] ?? paginationMap['total'] ?? paginationMap['count'] ?? paginationMap['totalCount'];
    final totalItems = paginationValue is num ? paginationValue.toInt() : int.tryParse(paginationValue?.toString() ?? '0') ?? 0;
    final totalPagesValue = paginationMap['totalPages'] ?? paginationMap['pages'];
    final totalPages = totalPagesValue is num
        ? totalPagesValue.toInt()
        : int.tryParse(totalPagesValue?.toString() ?? '') ?? (items.length >= limit ? page + 1 : page);

    return RecordPage(items: items, page: page, totalPages: totalPages < 1 ? 1 : totalPages, totalItems: totalItems);
  }

  List<Map<String, dynamic>> _extractResultRows(String resource, Map<String, dynamic> decoded) {
    final listKey = _responseListKey(resource);
    final candidates = <dynamic>[];

    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      candidates.add(data[listKey]);
      candidates.add(data['results']);
      candidates.add(data['items']);
      candidates.add(data['rows']);
      final nested = data['results'];
      if (nested is Map<String, dynamic>) {
        candidates.add(nested[listKey]);
        candidates.add(nested['items']);
        candidates.add(nested['rows']);
        candidates.add(nested['results']);
      }
    }

    candidates.add(decoded[listKey]);
    candidates.add(decoded['results']);
    candidates.add(decoded['items']);
    candidates.add(decoded['rows']);

    for (final candidate in candidates) {
      if (candidate is List) {
        final rows = candidate.whereType<Map<String, dynamic>>().toList();
        if (rows.isNotEmpty) return rows;
      }
      if (candidate is Map<String, dynamic>) {
        final nested = candidate[listKey];
        if (nested is List) {
          final rows = nested.whereType<Map<String, dynamic>>().toList();
          if (rows.isNotEmpty) return rows;
        }
      }
    }

    return <Map<String, dynamic>>[];
  }

  Future<RecordPage> _fallbackLocalPagedSearch(
    String resource,
    String searchText, {
    required int page,
    required int limit,
  }) async {
    final collectionId = _collectionId(resource);
    final records = await _connector.getCollectionFullList(collectionId);
    final normalized = _normalizeText(searchText);

    final filtered = records.where((record) {
      final text = _recordSearchText(resource, record.data);
      if (normalized.isEmpty) return true;
      return text.contains(normalized);
    }).toList();

    filtered.sort((a, b) => _recordLabel(resource, a.data).compareTo(_recordLabel(resource, b.data)));

    final start = (page - 1) * limit;
    if (start >= filtered.length) {
      return RecordPage(items: <ApiRecordModel>[], page: page, totalPages: page, totalItems: filtered.length);
    }

    final end = (start + limit).clamp(0, filtered.length);
    final pageItems = filtered.sublist(start, end);
    final totalPages = (filtered.length / limit).ceil();

    return RecordPage(items: pageItems, page: page, totalPages: totalPages < 1 ? 1 : totalPages, totalItems: filtered.length);
  }

  String _recordSearchText(String resource, Map<String, dynamic> data) {
    final tokens = <String>[];

    void collect(dynamic value, {int depth = 0}) {
      if (depth > 3 || value == null) return;
      if (value is String) {
        final text = value.trim();
        if (text.isEmpty) return;
        if (text.startsWith('http://') || text.startsWith('https://')) return;
        tokens.add(text);
        return;
      }
      if (value is num || value is bool) {
        tokens.add(value.toString());
        return;
      }
      if (value is List) {
        for (final entry in value) {
          collect(entry, depth: depth + 1);
        }
        return;
      }
      if (value is Map) {
        for (final entry in value.entries) {
          final key = entry.key.toString();
          if (key == 'id' ||
              key == r'$id' ||
              key == 'created' ||
              key == 'updated' ||
              key == r'$createdAt' ||
              key == r'$updatedAt' ||
              key == 'image' ||
              key == 'coverUrl' ||
              key == 'logo') {
            continue;
          }
          collect(entry.value, depth: depth + 1);
        }
      }
    }

    switch (_normalizeResource(resource)) {
      case 'series':
        collect(data['titleFr'] ?? data['title']);
        collect(data['authors']);
        break;
      case 'sub-series':
        collect(data['titleFr'] ?? data['title']);
        collect(data['editors']);
        collect(data['series']);
        break;
      case 'volumes':
        collect(data['titleFr'] ?? data['title']);
        collect(data['sub_series']);
        collect(data['series']);
        collect(data['authors']);
        break;
      case 'authors':
      case 'editors':
        collect(data['name']);
        break;
      case 'users':
        collect(data['pseudo'] ?? data['username'] ?? data['name'] ?? data['email']);
        break;
      default:
        collect(data);
        break;
    }

    return _normalizeText(tokens.join(' '));
  }
}

Future<List<ApiRecordModel>> searchRealtime(
  String resource, {
  String? q,
  String? query,
  int limit = 8,
}) {
  return SearchService().realtime(resource, q: q, query: query, limit: limit);
}

Future<RecordPage> searchPaged(
  String resource, {
  String? q,
  String? query,
  int page = 1,
  int limit = 30,
}) {
  return SearchService().searchPaged(resource, q: q, query: query, page: page, limit: limit);
}
