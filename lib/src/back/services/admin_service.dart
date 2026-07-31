import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mymangatheque/src/back/services/api/mobile_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AdminVolumeIssueType {
  zeroTomeNumber('zero_tome_number'),
  duplicateTomeNumber('duplicate_tome_number'),
  unknown('unknown')
  ;

  const AdminVolumeIssueType(this.apiValue);

  final String apiValue;

  static AdminVolumeIssueType fromApi(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return switch (normalized) {
      'zero_tome_number' ||
      'zero_tome' ||
      'tome_number_zero' => AdminVolumeIssueType.zeroTomeNumber,
      'duplicate_tome_number' ||
      'duplicate_tome' ||
      'duplicate' => AdminVolumeIssueType.duplicateTomeNumber,
      _ => AdminVolumeIssueType.unknown,
    };
  }
}

enum AdminVolumeIssueStatus {
  open('open'),
  resolved('resolved')
  ;

  const AdminVolumeIssueStatus(this.apiValue);

  final String apiValue;

  static AdminVolumeIssueStatus fromApi(dynamic value) {
    return value?.toString().trim().toLowerCase() == 'resolved'
        ? AdminVolumeIssueStatus.resolved
        : AdminVolumeIssueStatus.open;
  }
}

class AdminIssueVolume {
  const AdminIssueVolume({
    required this.id,
    required this.title,
    required this.tomeNumber,
    required this.ean,
    required this.coverUrl,
  });

  factory AdminIssueVolume.fromJson(Map<String, dynamic> json) {
    return AdminIssueVolume(
      id: (json['id'] ?? json[r'$id'] ?? '').toString(),
      title: (json['titleFr'] ?? json['title'] ?? '').toString(),
      tomeNumber: _adminNum(json['tomeNumber'] ?? json['tome_number']),
      ean: json['ean']?.toString() ?? '',
      coverUrl: (json['coverUrl'] ?? json['image'] ?? '').toString(),
    );
  }

  final String id;
  final String title;
  final num? tomeNumber;
  final String ean;
  final String coverUrl;
}

class AdminVolumeIssue {
  const AdminVolumeIssue({
    required this.id,
    required this.type,
    required this.status,
    required this.fingerprint,
    required this.subSeriesId,
    required this.subSeriesTitle,
    required this.tomeNumber,
    required this.volumes,
    required this.isCurrentlyPresent,
    this.firstDetectedAt,
    this.lastDetectedAt,
    this.resolvedAt,
    this.resolvedBy,
    this.resolutionNote,
  });

  factory AdminVolumeIssue.fromJson(Map<String, dynamic> json) {
    final subSeries = _adminMap(json['subSeries'] ?? json['sub_series']);
    final rawVolumes = json['volumes'] ?? json['volume'];
    final volumeMaps = rawVolumes is List
        ? rawVolumes.map(_adminMap).whereType<Map<String, dynamic>>()
        : <Map<String, dynamic>>[
            if (_adminMap(rawVolumes) case final volume?) volume,
          ];
    final volumes = volumeMaps.map(AdminIssueVolume.fromJson).toList();

    if (volumes.isEmpty && json['volumeIds'] is List) {
      volumes.addAll(
        (json['volumeIds'] as List).map(
          (id) => AdminIssueVolume(
            id: id.toString(),
            title: '',
            tomeNumber: _adminNum(json['tomeNumber'] ?? json['tome_number']),
            ean: '',
            coverUrl: '',
          ),
        ),
      );
    }

    return AdminVolumeIssue(
      id: (json['id'] ?? json[r'$id'] ?? '').toString(),
      type: AdminVolumeIssueType.fromApi(json['issueType'] ?? json['type']),
      status: AdminVolumeIssueStatus.fromApi(json['status']),
      fingerprint: json['fingerprint']?.toString() ?? '',
      subSeriesId:
          (json['subSeriesId'] ?? subSeries?['id'] ?? subSeries?[r'$id'] ?? '')
              .toString(),
      subSeriesTitle:
          (json['subSeriesTitle'] ??
                  subSeries?['titleFr'] ??
                  subSeries?['title'] ??
                  '')
              .toString(),
      tomeNumber: _adminNum(json['tomeNumber'] ?? json['tome_number']),
      volumes: volumes,
      isCurrentlyPresent: _adminBool(
        json['isCurrentlyPresent'],
        fallback: true,
      ),
      firstDetectedAt: _adminDate(json['firstDetectedAt']),
      lastDetectedAt: _adminDate(json['lastDetectedAt']),
      resolvedAt: _adminDate(json['resolvedAt']),
      resolvedBy: json['resolvedBy']?.toString(),
      resolutionNote: json['resolutionNote']?.toString(),
    );
  }

  final String id;
  final AdminVolumeIssueType type;
  final AdminVolumeIssueStatus status;
  final String fingerprint;
  final String subSeriesId;
  final String subSeriesTitle;
  final num? tomeNumber;
  final List<AdminIssueVolume> volumes;
  final bool isCurrentlyPresent;
  final DateTime? firstDetectedAt;
  final DateTime? lastDetectedAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? resolutionNote;
}

class AdminVolumeIssuePage {
  const AdminVolumeIssuePage({
    required this.issues,
    required this.page,
    required this.totalPages,
    required this.totalItems,
  });

  factory AdminVolumeIssuePage.fromJson(Map<String, dynamic> json) {
    final data = _adminMap(json['data']) ?? json;
    final rawIssues = data['issues'] ?? json['issues'];
    final issues = rawIssues is List
        ? rawIssues
              .map(_adminMap)
              .whereType<Map<String, dynamic>>()
              .map(AdminVolumeIssue.fromJson)
              .toList()
        : <AdminVolumeIssue>[];
    final pagination =
        _adminMap(data['pagination']) ??
        _adminMap(json['pagination']) ??
        const <String, dynamic>{};

    return AdminVolumeIssuePage(
      issues: issues,
      page: _adminInt(pagination['page'] ?? pagination['currentPage'], 1),
      totalPages: _adminInt(pagination['totalPages'], 1),
      totalItems: _adminInt(
        pagination['totalItems'] ?? pagination['total'],
        issues.length,
      ),
    );
  }

  final List<AdminVolumeIssue> issues;
  final int page;
  final int totalPages;
  final int totalItems;
}

class AdminApiException implements Exception {
  const AdminApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

Map<String, dynamic>? _adminMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

num? _adminNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString().replaceAll(',', '.') ?? '');
}

int _adminInt(dynamic value, int fallback) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _adminBool(dynamic value, {required bool fallback}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }
  return fallback;
}

DateTime? _adminDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

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

  Future<AdminVolumeIssuePage> getVolumeQualityIssues({
    AdminVolumeIssueType? type,
    AdminVolumeIssueStatus status = AdminVolumeIssueStatus.open,
    int page = 1,
    int limit = 50,
  }) async {
    await init();
    final response = await _request(
      'GET',
      '/api/admin/volume-quality/issues',
      query: <String, dynamic>{
        'status': status.apiValue,
        if (type != null && type != AdminVolumeIssueType.unknown)
          'type': type.apiValue,
        'page': page,
        'limit': limit,
      },
    );
    return AdminVolumeIssuePage.fromJson(_decodeMap(response.body));
  }

  Future<int> scanVolumeQualityIssues() async {
    await init();
    final response = await _request(
      'POST',
      '/api/admin/volume-quality/issues/scan',
    );
    final decoded = _decodeMap(response.body);
    final data = _adminMap(decoded['data']) ?? decoded;
    return _adminInt(
      data['openIssues'] ?? data['detectedIssues'] ?? data['count'],
      0,
    );
  }

  Future<void> resolveVolumeQualityIssue(
    String issueId, {
    String? note,
  }) async {
    await init();
    await _request(
      'POST',
      '/api/admin/volume-quality/issues/$issueId/resolve',
      body: <String, dynamic>{
        if ((note ?? '').trim().isNotEmpty) 'note': note!.trim(),
      },
    );
  }

  Future<void> reopenVolumeQualityIssue(String issueId) async {
    await init();
    await _request(
      'POST',
      '/api/admin/volume-quality/issues/$issueId/reopen',
    );
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
      await _rawRequest(
        'GET',
        '/api/auth/keys',
        apiKey: apiKey,
      );
      return true;
    } catch (_) {}

    try {
      await _rawRequest(
        'GET',
        '/api/admin/volume-quality/issues',
        apiKey: apiKey,
        query: const <String, dynamic>{'status': 'open', 'page': 1, 'limit': 1},
      );
      return true;
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
      throw AdminApiException(
        response.statusCode,
        _extractApiError(response),
      );
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
