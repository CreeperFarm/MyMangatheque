import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mymangatheque/src/back/services/api/mobile_api_client.dart';

class AdminInputException implements Exception {
  const AdminInputException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Validation is repeated in the connector so a future caller cannot bypass
/// the form-level checks and send an unsafe or unexpectedly large payload.
class AdminInputValidator {
  const AdminInputValidator._();

  static String requiredText(
    String value, {
    required String label,
    int maxLength = 200,
  }) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw AdminInputException('$label est obligatoire.');
    }
    if (normalized.length > maxLength) {
      throw AdminInputException(
        '$label ne peut pas dépasser $maxLength caractères.',
      );
    }
    if (_hasControlCharacters(normalized)) {
      throw AdminInputException('$label contient des caractères interdits.');
    }
    return normalized;
  }

  static String? optionalText(
    String? value, {
    required String label,
    int maxLength = 2000,
  }) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return null;
    return requiredText(normalized, label: label, maxLength: maxLength);
  }

  static String? httpsUrl(String? value, {required String label}) {
    final normalized = optionalText(
      value,
      label: label,
      maxLength: 2048,
    );
    if (normalized == null) return null;
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        uri.scheme.toLowerCase() != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw AdminInputException(
        '$label doit être une URL HTTPS valide, sans identifiants intégrés.',
      );
    }
    return uri.toString();
  }

  static String relationId(String value, {required String label}) {
    final normalized = requiredText(
      value,
      label: label,
      maxLength: 128,
    );
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$').hasMatch(normalized)) {
      throw AdminInputException('$label n’est pas un identifiant valide.');
    }
    return normalized;
  }

  static List<String> textList(
    Iterable<String> values, {
    required String label,
    int maxItems = 50,
    int maxItemLength = 200,
    bool relationIds = false,
  }) {
    final normalized = <String>[];
    for (final raw in values) {
      final item = raw.trim();
      if (item.isEmpty) continue;
      final checked = relationIds
          ? relationId(item, label: label)
          : requiredText(item, label: label, maxLength: maxItemLength);
      if (!normalized.contains(checked)) normalized.add(checked);
    }
    if (normalized.length > maxItems) {
      throw AdminInputException(
        '$label ne peut pas contenir plus de $maxItems éléments.',
      );
    }
    return normalized;
  }

  static List<String> httpsUrlList(
    Iterable<String> values, {
    required String label,
    int maxItems = 20,
  }) {
    final normalized = <String>[];
    for (final value in values) {
      final checked = httpsUrl(value, label: label);
      if (checked != null && !normalized.contains(checked)) {
        normalized.add(checked);
      }
    }
    if (normalized.length > maxItems) {
      throw AdminInputException(
        '$label ne peut pas contenir plus de $maxItems éléments.',
      );
    }
    return normalized;
  }

  static Map<String, String> metadata(Map<String, String> values) {
    if (values.length > 50) {
      throw const AdminInputException(
        'Les informations complémentaires sont limitées à 50 entrées.',
      );
    }
    final normalized = <String, String>{};
    for (final entry in values.entries) {
      final key = requiredText(
        entry.key,
        label: 'La clé d’information',
        maxLength: 80,
      );
      if (!RegExp(
        r'^[A-Za-z0-9À-ÖØ-öø-ÿ][A-Za-z0-9À-ÖØ-öø-ÿ _.-]*$',
      ).hasMatch(key)) {
        throw const AdminInputException(
          'Une clé d’information contient des caractères interdits.',
        );
      }
      normalized[key] = requiredText(
        entry.value,
        label: 'La valeur d’information',
        maxLength: 500,
      );
    }
    return normalized;
  }

  static num nonNegativeNumber(num value, {required String label}) {
    if (!value.isFinite || value < 0) {
      throw AdminInputException('$label doit être un nombre positif ou nul.');
    }
    return value;
  }

  static int ean13(int value) {
    final ean = value.toString().padLeft(13, '0');
    if (!RegExp(r'^\d{13}$').hasMatch(ean)) {
      throw const AdminInputException(
        'L’EAN doit contenir exactement 13 chiffres.',
      );
    }
    var sum = 0;
    for (var index = 0; index < 12; index++) {
      final digit = int.parse(ean[index]);
      sum += index.isEven ? digit : digit * 3;
    }
    final expectedCheckDigit = (10 - (sum % 10)) % 10;
    if (expectedCheckDigit != int.parse(ean[12])) {
      throw const AdminInputException(
        'La clé de contrôle EAN-13 est invalide.',
      );
    }
    return value;
  }

  static bool _hasControlCharacters(String value) {
    return value.runes.any(
      (codePoint) => codePoint < 32 && codePoint != 9 && codePoint != 10,
    );
  }
}

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
  static const Duration _requestTimeout = Duration(seconds: 20);

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

    await _writeSecure(_storageKey, sanitized);
    _adminApiKey = sanitized;
    return true;
  }

  Future<bool> loginWithCurrentSessionKey() async {
    await init();
    final sessionKey = await _mobileApiClient.ensureApiKey();
    final verified = await _canUseAsAdmin(sessionKey);
    if (!verified) return false;

    await _writeSecure(_storageKey, sessionKey);
    _adminApiKey = sessionKey;
    return true;
  }

  Future<void> logout() async {
    _adminApiKey = null;
    await _deleteSecure(_storageKey);
  }

  Future<Map<String, dynamic>> getSummary({int days = 30}) async {
    await init();
    final response = await _request(
      'GET',
      '/api/analytics/summary',
      query: <String, dynamic>{'days': days},
    );
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
    final safeIssueId = AdminInputValidator.relationId(
      issueId,
      label: 'L’anomalie',
    );
    final safeNote = AdminInputValidator.optionalText(
      note,
      label: 'La note de résolution',
      maxLength: 1000,
    );
    await _request(
      'POST',
      '/api/admin/volume-quality/issues/$safeIssueId/resolve',
      body: <String, dynamic>{
        if (safeNote != null) 'note': safeNote,
      },
    );
  }

  Future<void> reopenVolumeQualityIssue(String issueId) async {
    await init();
    final safeIssueId = AdminInputValidator.relationId(
      issueId,
      label: 'L’anomalie',
    );
    await _request(
      'POST',
      '/api/admin/volume-quality/issues/$safeIssueId/reopen',
    );
  }

  Future<void> createAuthor({
    required String name,
    List<String> jobs = const <String>[],
    String? coverUrl,
  }) async {
    await init();

    final safeName = AdminInputValidator.requiredText(name, label: 'Le nom');
    final safeJobs = AdminInputValidator.textList(
      jobs,
      label: 'Les métiers',
      maxItems: 20,
      maxItemLength: 80,
    );
    final safeCoverUrl = AdminInputValidator.httpsUrl(
      coverUrl,
      label: 'L’image',
    );
    final body = <String, dynamic>{
      'name': safeName,
      if (safeJobs.isNotEmpty) 'jobs': safeJobs,
      if (safeCoverUrl != null) 'coverUrl': safeCoverUrl,
    };

    await _request('POST', '/api/authors', body: body);
  }

  Future<void> createGenre({required String name}) async {
    await init();
    await _request(
      'POST',
      '/api/genres',
      body: <String, dynamic>{
        'name': AdminInputValidator.requiredText(name, label: 'Le nom'),
      },
    );
  }

  Future<void> createEditor({required String name, String? coverUrl}) async {
    await init();
    final safeCoverUrl = AdminInputValidator.httpsUrl(
      coverUrl,
      label: 'Le logo',
    );
    await _request(
      'POST',
      '/api/editors',
      body: <String, dynamic>{
        'name': AdminInputValidator.requiredText(name, label: 'Le nom'),
        if (safeCoverUrl != null) 'coverUrl': safeCoverUrl,
      },
    );
  }

  Future<void> createSeries({
    required String titleFr,
    String? titleJp,
    String? titleEn,
    List<String> altTitles = const <String>[],
    String? coverUrl,
    List<String> authorIds = const <String>[],
    List<String> editorIds = const <String>[],
    List<String> genreIds = const <String>[],
    DateTime? firstPublicationDate,
    bool over18 = false,
  }) async {
    await init();
    final body =
        _catalogTitlePayload(
          titleFr: titleFr,
          titleJp: titleJp,
          titleEn: titleEn,
          coverUrl: coverUrl,
        )..addAll(<String, dynamic>{
          if (altTitles.isNotEmpty)
            'altTitles': AdminInputValidator.textList(
              altTitles,
              label: 'Les titres alternatifs',
              maxItems: 30,
            ),
          if (authorIds.isNotEmpty)
            'authors': _safeRelationIds(authorIds, 'Les auteurs'),
          if (editorIds.isNotEmpty)
            'editors': _safeRelationIds(editorIds, 'Les éditeurs'),
          if (genreIds.isNotEmpty)
            'genres': _safeRelationIds(genreIds, 'Les genres'),
          if (firstPublicationDate != null)
            'firstPublicationDate': firstPublicationDate
                .toUtc()
                .toIso8601String(),
          'over18': over18,
        });
    await _request('POST', '/api/series', body: body);
  }

  Future<void> createSubSeries({
    required String titleFr,
    String? titleJp,
    String? titleEn,
    String? coverUrl,
    required String seriesId,
    List<String> authorIds = const <String>[],
    String? editorId,
    List<String> genreIds = const <String>[],
    required String support,
    required String status,
    DateTime? firstPublicationDate,
    bool over18 = false,
  }) async {
    await init();
    final body =
        _catalogTitlePayload(
          titleFr: titleFr,
          titleJp: titleJp,
          titleEn: titleEn,
          coverUrl: coverUrl,
        )..addAll(<String, dynamic>{
          'series': AdminInputValidator.relationId(
            seriesId,
            label: 'La série parente',
          ),
          if (authorIds.isNotEmpty)
            'authors': _safeRelationIds(authorIds, 'Les auteurs'),
          if ((editorId ?? '').trim().isNotEmpty)
            'editors': AdminInputValidator.relationId(
              editorId!,
              label: 'L’éditeur',
            ),
          if (genreIds.isNotEmpty)
            'genres': _safeRelationIds(genreIds, 'Les genres'),
          'type': AdminInputValidator.requiredText(
            support,
            label: 'Le support',
            maxLength: 40,
          ),
          'status': AdminInputValidator.requiredText(
            status,
            label: 'Le statut',
            maxLength: 40,
          ),
          if (firstPublicationDate != null)
            'firstPublicationDate': firstPublicationDate
                .toUtc()
                .toIso8601String(),
          'over18': over18,
        });
    await _request('POST', '/api/sub-series', body: body);
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
    List<String> bookLinks = const <String>[],
    List<String> containsIds = const <String>[],
    Map<String, String> info = const <String, String>{},
    bool over18 = false,
  }) async {
    await init();
    final safeTitleFr = AdminInputValidator.requiredText(
      titleFr,
      label: 'Le titre français',
    );
    final safeTitleJp = AdminInputValidator.optionalText(
      titleJp,
      label: 'Le titre japonais',
    );
    final safeTitleEn = AdminInputValidator.optionalText(
      titleEn,
      label: 'Le titre anglais',
    );
    final safeCoverUrl = AdminInputValidator.httpsUrl(
      coverUrl,
      label: 'La couverture',
    );
    final safeResume = AdminInputValidator.optionalText(
      resume,
      label: 'Le résumé',
      maxLength: 10000,
    );
    final safeGenderJp = AdminInputValidator.optionalText(
      genderJp,
      label: 'Le public japonais',
      maxLength: 80,
    );
    final body = <String, dynamic>{
      'titleFr': safeTitleFr,
      if (safeTitleJp != null) 'titleJp': safeTitleJp,
      if (safeTitleEn != null) 'titleEn': safeTitleEn,
      'tomeNumber': AdminInputValidator.nonNegativeNumber(
        tomeNumber,
        label: 'Le numéro de tome',
      ),
      'price': AdminInputValidator.nonNegativeNumber(price, label: 'Le prix'),
      if (safeCoverUrl != null) 'coverUrl': safeCoverUrl,
      if (safeResume != null) 'resume': safeResume,
      if (publicationDate != null)
        'publicationDate': publicationDate.toUtc().toIso8601String(),
      'ean': AdminInputValidator.ean13(ean),
      'language': AdminInputValidator.requiredText(
        language,
        label: 'La langue',
        maxLength: 40,
      ),
      'support': AdminInputValidator.requiredText(
        support,
        label: 'Le support',
        maxLength: 40,
      ),
      if (safeGenderJp != null) 'genderJp': safeGenderJp,
      if ((subSeriesId ?? '').trim().isNotEmpty)
        'subSeries': AdminInputValidator.relationId(
          subSeriesId!,
          label: 'La sous-série',
        ),
      if (bookLinks.isNotEmpty)
        'bookLink': AdminInputValidator.httpsUrlList(
          bookLinks,
          label: 'Les liens d’achat',
        ),
      if (containsIds.isNotEmpty)
        'contain': _safeRelationIds(containsIds, 'Les contenus inclus'),
      if (info.isNotEmpty) 'infoVolume': AdminInputValidator.metadata(info),
      'over18': over18,
    };

    await _request('POST', '/api/volumes', body: body);
  }

  Map<String, dynamic> _catalogTitlePayload({
    required String titleFr,
    String? titleJp,
    String? titleEn,
    String? coverUrl,
  }) {
    final safeTitleJp = AdminInputValidator.optionalText(
      titleJp,
      label: 'Le titre japonais',
    );
    final safeTitleEn = AdminInputValidator.optionalText(
      titleEn,
      label: 'Le titre anglais',
    );
    final safeCoverUrl = AdminInputValidator.httpsUrl(
      coverUrl,
      label: 'La couverture',
    );
    return <String, dynamic>{
      'titleFr': AdminInputValidator.requiredText(
        titleFr,
        label: 'Le titre français',
      ),
      if (safeTitleJp != null) 'titleJp': safeTitleJp,
      if (safeTitleEn != null) 'titleEn': safeTitleEn,
      if (safeCoverUrl != null) 'coverUrl': safeCoverUrl,
    };
  }

  List<String> _safeRelationIds(Iterable<String> ids, String label) {
    return AdminInputValidator.textList(
      ids,
      label: label,
      maxItems: 100,
      maxItemLength: 128,
      relationIds: true,
    );
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
    if (response.statusCode >= 500) {
      return 'Erreur API (${response.statusCode}): service temporairement indisponible.';
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message']?.toString();
        if (message != null && message.isNotEmpty) {
          final safeMessage = message
              .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ')
              .trim();
          final truncated = safeMessage.length > 300
              ? safeMessage.substring(0, 300)
              : safeMessage;
          return 'Erreur API (${response.statusCode}): $truncated';
        }
      }
    } catch (_) {}

    return 'Erreur API (${response.statusCode}): requête refusée.';
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
      return null;
    }
  }

  Future<void> _writeSecure(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      debugPrint('Secure storage write failed for $key: $e');
      throw StateError(
        'Le stockage sécurisé est indisponible. La clé admin n’a pas été conservée.',
      );
    }
  }

  Future<void> _deleteSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      debugPrint('Secure storage delete failed for $key: $e');
    }
  }
}
