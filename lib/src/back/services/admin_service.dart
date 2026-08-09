import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/api/mobile_api_client.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';

String _adminT(String en, String fr) =>
    RuntimeLocalization.text(en: en, fr: fr);

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
      throw AdminInputException(
        _adminT('$label is required.', '$label est obligatoire.'),
      );
    }
    if (normalized.length > maxLength) {
      throw AdminInputException(
        _adminT(
          '$label cannot exceed $maxLength characters.',
          '$label ne peut pas dépasser $maxLength caractères.',
        ),
      );
    }
    if (_hasControlCharacters(normalized)) {
      throw AdminInputException(
        _adminT(
          '$label contains forbidden characters.',
          '$label contient des caractères interdits.',
        ),
      );
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
        _adminT(
          '$label must be a valid HTTPS URL without embedded credentials.',
          '$label doit être une URL HTTPS valide, sans identifiants intégrés.',
        ),
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
      throw AdminInputException(
        _adminT(
          '$label is not a valid identifier.',
          '$label n’est pas un identifiant valide.',
        ),
      );
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
        _adminT(
          '$label cannot contain more than $maxItems items.',
          '$label ne peut pas contenir plus de $maxItems éléments.',
        ),
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
        _adminT(
          '$label cannot contain more than $maxItems items.',
          '$label ne peut pas contenir plus de $maxItems éléments.',
        ),
      );
    }
    return normalized;
  }

  static Map<String, String> metadata(Map<String, String> values) {
    if (values.length > 50) {
      throw AdminInputException(
        _adminT(
          'Additional information is limited to 50 entries.',
          'Les informations complémentaires sont limitées à 50 entrées.',
        ),
      );
    }
    final normalized = <String, String>{};
    for (final entry in values.entries) {
      final key = requiredText(
        entry.key,
        label: _adminT('The information key', 'La clé d’information'),
        maxLength: 80,
      );
      if (!RegExp(
        r'^[A-Za-z0-9À-ÖØ-öø-ÿ][A-Za-z0-9À-ÖØ-öø-ÿ _.-]*$',
      ).hasMatch(key)) {
        throw AdminInputException(
          _adminT(
            'An information key contains forbidden characters.',
            'Une clé d’information contient des caractères interdits.',
          ),
        );
      }
      normalized[key] = requiredText(
        entry.value,
        label: _adminT('The information value', 'La valeur d’information'),
        maxLength: 500,
      );
    }
    return normalized;
  }

  static num nonNegativeNumber(num value, {required String label}) {
    if (!value.isFinite || value < 0) {
      throw AdminInputException(
        _adminT(
          '$label must be a non-negative number.',
          '$label doit être un nombre positif ou nul.',
        ),
      );
    }
    return value;
  }

  static int moneyInMinorUnits(num value, {required String label}) {
    final normalized = nonNegativeNumber(value, label: label);
    final minorUnits = (normalized * 100).round();
    if ((minorUnits / 100 - normalized).abs() > 0.000001) {
      throw AdminInputException(
        _adminT(
          '$label cannot contain more than two decimal places.',
          '$label ne peut pas contenir plus de deux décimales.',
        ),
      );
    }
    return minorUnits;
  }

  static int ean13(int value) {
    final ean = value.toString().padLeft(13, '0');
    if (!RegExp(r'^\d{13}$').hasMatch(ean)) {
      throw AdminInputException(
        _adminT(
          'The EAN must contain exactly 13 digits.',
          'L’EAN doit contenir exactement 13 chiffres.',
        ),
      );
    }
    var sum = 0;
    for (var index = 0; index < 12; index++) {
      final digit = int.parse(ean[index]);
      sum += index.isEven ? digit : digit * 3;
    }
    final expectedCheckDigit = (10 - (sum % 10)) % 10;
    if (expectedCheckDigit != int.parse(ean[12])) {
      throw AdminInputException(
        _adminT(
          'The EAN-13 check digit is invalid.',
          'La clé de contrôle EAN-13 est invalide.',
        ),
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

enum AdminRelationResource {
  volumes('/api/volumes/search', 'volumes'),
  subSeries('/api/sub-series/search', 'subSeries'),
  series('/api/series/search', 'series'),
  authors('/api/authors/search', 'authors'),
  editors('/api/editors/search', 'editors'),
  genres('/api/genres/search', 'genres')
  ;

  const AdminRelationResource(this.searchPath, this.responseKey);

  final String searchPath;
  final String responseKey;
  String get label => localizedLabel(RuntimeLocalization.languageCode);

  String localizedLabel(String languageCode) {
    final french =
        RuntimeLocalization.normalizeLanguageCode(languageCode) == 'fr';
    return switch (this) {
      volumes => french ? 'Volume' : 'Volume',
      subSeries => french ? 'Sous-série' : 'Sub-series',
      series => french ? 'Série' : 'Series',
      authors => french ? 'Auteur' : 'Author',
      editors => french ? 'Éditeur' : 'Publisher',
      genres => french ? 'Genre' : 'Genre',
    };
  }
}

class AdminRelationOption {
  const AdminRelationOption({
    required this.id,
    required this.label,
    required this.detail,
    required this.resource,
  });

  factory AdminRelationOption.fromJson(
    AdminRelationResource resource,
    Map<String, dynamic> json,
  ) {
    final id = (json['id'] ?? json[r'$id'] ?? '').toString();
    final label = switch (resource) {
      AdminRelationResource.authors ||
      AdminRelationResource.editors ||
      AdminRelationResource.genres => _adminFirstText(<dynamic>[
        json['name'],
        json['titleFr'],
        id,
      ]),
      _ => _adminFirstText(<dynamic>[
        json['titleFr'],
        json['title'],
        json['titleEn'],
        json['titleJp'],
        id,
      ]),
    };

    final detailParts = <String>[];
    if (resource == AdminRelationResource.volumes) {
      final tomeNumber = _adminNum(
        json['tomeNumber'] ?? json['tome_number'],
      );
      if (tomeNumber != null) {
        detailParts.add('Tome ${_adminFormatNumber(tomeNumber)}');
      }
      final subSeries = _adminMap(json['subSeries'] ?? json['sub_series']);
      final subSeriesLabel = _adminFirstText(<dynamic>[
        json['subSeriesTitle'],
        subSeries?['titleFr'],
        subSeries?['title'],
      ]);
      if (subSeriesLabel.isNotEmpty) detailParts.add(subSeriesLabel);
      final resume = _adminFirstText(<dynamic>[
        json['resume'],
        json['summary'],
      ]);
      if (resume.isNotEmpty) {
        detailParts.add(
          resume.length > 90 ? '${resume.substring(0, 90)}…' : resume,
        );
      }
    } else if (resource == AdminRelationResource.subSeries) {
      final series = _adminMap(json['series']);
      final seriesLabel = _adminFirstText(<dynamic>[
        json['seriesTitle'],
        series?['titleFr'],
        series?['title'],
      ]);
      if (seriesLabel.isNotEmpty) detailParts.add(seriesLabel);
    }

    return AdminRelationOption(
      id: id,
      label: label,
      detail: detailParts.join(' · '),
      resource: resource,
    );
  }

  final String id;
  final String label;
  final String detail;
  final AdminRelationResource resource;
}

enum AdminUserOrderBy {
  createdAt(r'$createdAt', 'Creation date', 'Date de création'),
  updatedAt(r'$updatedAt', 'Last update', 'Dernière modification'),
  pseudo('pseudo', 'Username', 'Pseudo'),
  mail('mail', 'Email address', 'Adresse e-mail'),
  role('role', 'Role', 'Rôle')
  ;

  const AdminUserOrderBy(this.apiValue, this.englishLabel, this.frenchLabel);

  final String apiValue;
  final String englishLabel;
  final String frenchLabel;

  String get label => _adminT(englishLabel, frenchLabel);
}

enum AdminSortDirection {
  ascending('asc', 'Ascending', 'Croissant'),
  descending('desc', 'Descending', 'Décroissant')
  ;

  const AdminSortDirection(this.apiValue, this.englishLabel, this.frenchLabel);

  final String apiValue;
  final String englishLabel;
  final String frenchLabel;

  String get label => _adminT(englishLabel, frenchLabel);
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.pseudo,
    required this.email,
    required this.role,
    required this.coverUrl,
    required this.suspended,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: (json['id'] ?? json[r'$id'] ?? '').toString(),
      pseudo: _adminFirstText(<dynamic>[
        json['pseudo'],
        json['name'],
        'Utilisateur',
      ]),
      email: _adminFirstText(<dynamic>[json['mail'], json['email']]),
      role: _adminFirstText(<dynamic>[json['role'], 'user']),
      coverUrl: _adminFirstText(<dynamic>[
        json['coverURL'],
        json['coverUrl'],
        json['avatarUrl'],
      ]),
      suspended: _adminBool(
        json['suspended'] ?? json['isSuspended'] ?? json['disabled'],
        fallback: false,
      ),
      createdAt: _adminDate(json[r'$createdAt'] ?? json['createdAt']),
      updatedAt: _adminDate(json[r'$updatedAt'] ?? json['updatedAt']),
    );
  }

  final String id;
  final String pseudo;
  final String email;
  final String role;
  final String coverUrl;
  final bool suspended;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class AdminUserPage {
  const AdminUserPage({
    required this.users,
    required this.page,
    required this.totalPages,
    required this.totalItems,
  });

  factory AdminUserPage.fromJson(Map<String, dynamic> json) {
    final data = _adminMap(json['data']) ?? json;
    final rawUsers = data['users'] ?? json['users'];
    final users = rawUsers is List
        ? rawUsers
              .map(_adminMap)
              .whereType<Map<String, dynamic>>()
              .map(AdminUser.fromJson)
              .toList()
        : <AdminUser>[];
    final pagination =
        _adminMap(data['pagination']) ??
        _adminMap(json['pagination']) ??
        const <String, dynamic>{};

    return AdminUserPage(
      users: users,
      page: _adminInt(pagination['page'] ?? pagination['currentPage'], 1),
      totalPages: _adminInt(pagination['totalPages'], 1),
      totalItems: _adminInt(
        pagination['totalItems'] ?? pagination['total'] ?? json['results'],
        users.length,
      ),
    );
  }

  final List<AdminUser> users;
  final int page;
  final int totalPages;
  final int totalItems;
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

String _adminFirstText(Iterable<dynamic> values) {
  for (final value in values) {
    final normalized = value?.toString().trim() ?? '';
    if (normalized.isNotEmpty) return normalized;
  }
  return '';
}

String _adminFormatNumber(num value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
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
    if (!isLoggedIn()) return _adminT('No admin key', 'Aucune clé admin');
    final key = _adminApiKey!;
    if (key.length <= 8) return '••••••••';
    return '••••••••${key.substring(key.length - 4)}';
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

  Future<Map<String, dynamic>> getSummary({
    int days = 30,
    bool comparePrevious = true,
  }) async {
    await init();
    final response = await _request(
      'GET',
      '/api/analytics/summary',
      query: <String, dynamic>{
        'days': days.clamp(1, 365),
        'comparePrevious': comparePrevious,
      },
    );
    return _decodeMap(response.body);
  }

  Future<Map<String, dynamic>> getAnalyticsHealth() async {
    final response = await http
        .get(Uri.parse('$_apiBaseUrl/api/analytics/health'))
        .timeout(_requestTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AdminApiException(
        response.statusCode,
        _extractApiError(response),
      );
    }
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

  Future<Map<String, dynamic>> getMostWishlistedMangas({
    int days = 30,
    int limit = 10,
  }) async {
    await init();
    final response = await _request(
      'GET',
      '/api/analytics/most-added-mangas-wishlist',
      query: <String, dynamic>{'days': days, 'limit': limit},
    );
    return _decodeMap(response.body);
  }

  Future<Map<String, dynamic>> getProductAnalytics({
    int days = 30,
    bool comparePrevious = true,
  }) async {
    await init();
    final response = await _request(
      'GET',
      '/api/analytics/product',
      query: <String, dynamic>{
        'days': days.clamp(1, 365),
        'comparePrevious': comparePrevious,
      },
    );
    return _decodeMap(response.body);
  }

  Future<Map<String, dynamic>> getNotificationAnalytics({
    int days = 30,
    bool comparePrevious = true,
  }) async {
    await init();
    final response = await _request(
      'GET',
      '/api/analytics/notifications',
      query: <String, dynamic>{
        'days': days.clamp(1, 365),
        'comparePrevious': comparePrevious,
      },
    );
    return _decodeMap(response.body);
  }

  Future<Map<String, dynamic>> getSponsorshipDashboard({
    int days = 30,
    bool comparePrevious = true,
  }) async {
    await init();
    final response = await _request(
      'GET',
      '/api/admin/sponsorship',
      query: <String, dynamic>{
        'days': days.clamp(1, 365),
        'comparePrevious': comparePrevious,
      },
    );
    return _decodeMap(response.body);
  }

  Future<void> createSponsorshipCampaign({
    required String name,
    required String mangaId,
    required num budget,
    required DateTime startsAt,
    required DateTime endsAt,
    required String placement,
    required int frequencyCap,
    List<String> platforms = const <String>[],
    List<String> countries = const <String>[],
    List<String> languages = const <String>[],
    String currency = 'EUR',
  }) async {
    await init();
    final safeName = AdminInputValidator.requiredText(
      name,
      label: _adminT('Campaign name', 'Le nom de campagne'),
      maxLength: 120,
    );
    final safeMangaId = AdminInputValidator.relationId(
      mangaId,
      label: _adminT('Sponsored manga', 'Le manga sponsorisé'),
    );
    final safeBudget = AdminInputValidator.nonNegativeNumber(
      budget,
      label: _adminT('Budget', 'Le budget'),
    );
    if (safeBudget <= 0) {
      throw AdminInputException(
        _adminT(
          'The budget must be greater than zero.',
          'Le budget doit être supérieur à zéro.',
        ),
      );
    }
    if (!endsAt.isAfter(startsAt)) {
      throw AdminInputException(
        _adminT(
          'The campaign end must be after its start.',
          'La fin de campagne doit être postérieure à son début.',
        ),
      );
    }
    if (frequencyCap < 1 || frequencyCap > 10000) {
      throw AdminInputException(
        _adminT(
          'The frequency cap must be between 1 and 10,000 impressions.',
          'Le plafonnement doit être compris entre 1 et 10 000 impressions.',
        ),
      );
    }
    const allowedPlacements = <String>{'home', 'search', 'catalog', 'details'};
    if (!allowedPlacements.contains(placement)) {
      throw AdminInputException(
        _adminT(
          'Invalid campaign placement.',
          'Emplacement de campagne invalide.',
        ),
      );
    }
    final budgetInMinorUnits = AdminInputValidator.moneyInMinorUnits(
      safeBudget,
      label: _adminT('Budget', 'Le budget'),
    );
    await _request(
      'POST',
      '/api/admin/sponsorship/campaigns',
      body: <String, dynamic>{
        'name': safeName,
        'mangaId': safeMangaId,
        'budget': budgetInMinorUnits,
        'currency': AdminInputValidator.requiredText(
          currency,
          label: _adminT('Currency', 'La devise'),
          maxLength: 3,
        ).toUpperCase(),
        'startsAt': startsAt.toUtc().toIso8601String(),
        'endsAt': endsAt.toUtc().toIso8601String(),
        'placement': AdminInputValidator.requiredText(
          placement,
          label: _adminT('Placement', 'L’emplacement'),
          maxLength: 80,
        ),
        'targeting': <String, dynamic>{
          'platforms': AdminInputValidator.textList(
            platforms,
            label: _adminT('Target platforms', 'Les plateformes ciblées'),
            maxItems: 4,
            maxItemLength: 20,
          ),
          'countries': AdminInputValidator.textList(
            countries,
            label: _adminT('Target countries', 'Les pays ciblés'),
            maxItems: 50,
            maxItemLength: 2,
          ).map((value) => value.toUpperCase()).toList(),
          'languages': AdminInputValidator.textList(
            languages,
            label: _adminT('Target languages', 'Les langues ciblées'),
            maxItems: 50,
            maxItemLength: 16,
          ),
        },
        'frequencyCap': frequencyCap,
      },
    );
  }

  Future<void> updateSponsorshipCampaignStatus(
    String campaignId,
    String status,
  ) async {
    await init();
    final safeId = AdminInputValidator.relationId(
      campaignId,
      label: _adminT('Campaign', 'La campagne'),
    );
    const allowed = <String>{'draft', 'active', 'paused', 'completed'};
    if (!allowed.contains(status)) {
      throw AdminInputException(
        _adminT('Invalid campaign status.', 'Statut de campagne invalide.'),
      );
    }
    await _request(
      'PATCH',
      '/api/admin/sponsorship/campaigns/$safeId',
      body: <String, dynamic>{'status': status},
    );
  }

  Future<Map<String, dynamic>> getEditorialRecommendations() async {
    await init();
    final response = await _request(
      'GET',
      '/api/admin/editorial-recommendations',
    );
    return _decodeMap(response.body);
  }

  Future<void> createEditorialRecommendation({
    required String mangaId,
    required String placement,
    required int priority,
    required DateTime startsAt,
    required DateTime endsAt,
    String? note,
  }) async {
    await init();
    if (!endsAt.isAfter(startsAt)) {
      throw AdminInputException(
        _adminT(
          'The feature end must be after its start.',
          'La fin de mise en avant doit être postérieure à son début.',
        ),
      );
    }
    if (priority < 0 || priority > 100) {
      throw AdminInputException(
        _adminT(
          'Priority must be between 0 and 100.',
          'La priorité doit être comprise entre 0 et 100.',
        ),
      );
    }
    const allowedPlacements = <String>{'home', 'search', 'catalog', 'details'};
    if (!allowedPlacements.contains(placement)) {
      throw AdminInputException(
        _adminT(
          'Invalid editorial placement.',
          'Emplacement éditorial invalide.',
        ),
      );
    }
    await _request(
      'POST',
      '/api/admin/editorial-recommendations',
      body: <String, dynamic>{
        'mangaId': AdminInputValidator.relationId(
          mangaId,
          label: _adminT('Manga', 'Le manga'),
        ),
        'placement': AdminInputValidator.requiredText(
          placement,
          label: _adminT('Placement', 'L’emplacement'),
          maxLength: 80,
        ),
        'priority': priority,
        'startsAt': startsAt.toUtc().toIso8601String(),
        'endsAt': endsAt.toUtc().toIso8601String(),
        if (AdminInputValidator.optionalText(
              note,
              label: _adminT('Editorial note', 'La note éditoriale'),
              maxLength: 500,
            )
            case final safeNote?)
          'justification': safeNote,
      },
    );
  }

  Future<void> deleteEditorialRecommendation(String recommendationId) async {
    await init();
    final safeId = AdminInputValidator.relationId(
      recommendationId,
      label: _adminT('Recommendation', 'La recommandation'),
    );
    await _request('DELETE', '/api/admin/editorial-recommendations/$safeId');
  }

  Future<Map<String, dynamic>> getRevenueDashboard({
    int days = 30,
    bool comparePrevious = true,
  }) async {
    await init();
    final response = await _request(
      'GET',
      '/api/admin/revenue',
      query: <String, dynamic>{
        'days': days.clamp(1, 365),
        'comparePrevious': comparePrevious,
      },
    );
    return _decodeMap(response.body);
  }

  Future<void> updateSponsorInvoicePayment(
    String invoiceId, {
    required String status,
    String? reference,
  }) async {
    await init();
    final safeId = AdminInputValidator.relationId(
      invoiceId,
      label: _adminT('Invoice', 'La facture'),
    );
    const allowed = <String>{'pending', 'paid', 'overdue', 'cancelled'};
    if (!allowed.contains(status)) {
      throw AdminInputException(
        _adminT('Invalid payment status.', 'Statut de paiement invalide.'),
      );
    }
    await _request(
      'PATCH',
      '/api/admin/revenue/invoices/$safeId',
      body: <String, dynamic>{
        'status': status,
        if (AdminInputValidator.optionalText(
              reference,
              label: _adminT('Payment reference', 'La référence de paiement'),
              maxLength: 120,
            )
            case final safeReference?)
          'paymentReference': safeReference,
      },
    );
  }

  Future<Map<String, dynamic>> getCatalogQualityDashboard() async {
    await init();
    final response = await _request('GET', '/api/admin/catalog-quality');
    return _decodeMap(response.body);
  }

  Future<void> scanCatalogQuality() async {
    await init();
    await _request('POST', '/api/admin/catalog-quality/scan');
  }

  Future<void> resolveCatalogQualityIssue(
    String issueId, {
    String? note,
  }) async {
    await init();
    final safeId = AdminInputValidator.relationId(
      issueId,
      label: _adminT('Issue', 'L’anomalie'),
    );
    await _request(
      'POST',
      '/api/admin/catalog-quality/issues/$safeId/resolve',
      body: <String, dynamic>{
        if (AdminInputValidator.optionalText(
              note,
              label: _adminT('Note', 'La note'),
              maxLength: 1000,
            )
            case final safeNote?)
          'note': safeNote,
      },
    );
  }

  Future<Map<String, dynamic>> getModerationDashboard() async {
    await init();
    final response = await _request('GET', '/api/admin/moderation');
    return _decodeMap(response.body);
  }

  Future<void> updateUserRole(String userId, String role) async {
    await init();
    final safeId = AdminInputValidator.relationId(
      userId,
      label: _adminT('Account', 'Le compte'),
    );
    const allowed = <String>{'user', 'moderator', 'admin'};
    if (!allowed.contains(role)) {
      throw AdminInputException(
        _adminT('Invalid user role.', 'Rôle utilisateur invalide.'),
      );
    }
    await _request(
      'PATCH',
      '/api/admin/users/$safeId/role',
      body: <String, dynamic>{'role': role},
    );
  }

  Future<void> suspendUser(
    String userId, {
    required bool suspended,
    String? reason,
  }) async {
    await init();
    final safeId = AdminInputValidator.relationId(
      userId,
      label: _adminT('Account', 'Le compte'),
    );
    await _request(
      'PATCH',
      '/api/admin/users/$safeId/suspension',
      body: <String, dynamic>{
        'suspended': suspended,
        if (AdminInputValidator.optionalText(
              reason,
              label: _adminT('Reason', 'Le motif'),
              maxLength: 500,
            )
            case final safeReason?)
          'reason': safeReason,
      },
    );
  }

  Future<void> resolveModerationCase(
    String caseId, {
    required String resolution,
    String? note,
  }) async {
    await init();
    final safeId = AdminInputValidator.relationId(
      caseId,
      label: _adminT(
        'Report or GDPR request',
        'Le signalement ou la demande RGPD',
      ),
    );
    await _request(
      'POST',
      '/api/admin/moderation/cases/$safeId/resolve',
      body: <String, dynamic>{
        'resolution': AdminInputValidator.requiredText(
          resolution,
          label: _adminT('Resolution', 'La résolution'),
          maxLength: 80,
        ),
        if (AdminInputValidator.optionalText(
              note,
              label: _adminT('Note', 'La note'),
              maxLength: 1000,
            )
            case final safeNote?)
          'note': safeNote,
      },
    );
  }

  Future<Map<String, dynamic>> getOperationsDashboard() async {
    await init();
    final response = await _request('GET', '/api/admin/operations');
    return _decodeMap(response.body);
  }

  Future<void> updateFeatureFlag(String flagId, bool enabled) async {
    await init();
    final safeId = AdminInputValidator.relationId(
      flagId,
      label: _adminT('Feature flag', 'Le feature flag'),
    );
    await _request(
      'PATCH',
      '/api/admin/operations/feature-flags/$safeId',
      body: <String, dynamic>{'enabled': enabled},
    );
  }

  Future<void> retryQueueJob(String jobId) async {
    await init();
    final safeId = AdminInputValidator.relationId(
      jobId,
      label: _adminT('Job', 'La tâche'),
    );
    await _request('POST', '/api/admin/operations/jobs/$safeId/retry');
  }

  Future<void> invalidateCache(String namespace) async {
    await init();
    final safeNamespace = AdminInputValidator.relationId(
      namespace,
      label: _adminT('Cache', 'Le cache'),
    );
    await _request(
      'POST',
      '/api/admin/operations/cache/invalidate',
      body: <String, dynamic>{'namespace': safeNamespace},
    );
  }

  Future<Map<String, dynamic>> getAuditEvents({
    int page = 1,
    int limit = 50,
    String? action,
  }) async {
    await init();
    final response = await _request(
      'GET',
      '/api/admin/audit',
      query: <String, dynamic>{
        'page': page.clamp(1, 1000000),
        'limit': limit.clamp(1, 100),
        if (AdminInputValidator.optionalText(
              action,
              label: _adminT('Action filter', 'Le filtre d’action'),
              maxLength: 80,
            )
            case final safeAction?)
          'action': safeAction,
      },
    );
    return _decodeMap(response.body);
  }

  Future<Map<String, dynamic>> requestAdminExport({
    required String resource,
    String format = 'csv',
  }) async {
    await init();
    const allowedResources = <String>{
      'sponsorship',
      'revenue',
      'catalog-quality',
      'moderation',
      'operations',
      'audit',
      'editorial',
      'analytics-summary',
      'analytics-product',
      'analytics-notifications',
    };
    if (!allowedResources.contains(resource)) {
      throw AdminInputException(
        _adminT('Invalid export resource.', 'Ressource d’export invalide.'),
      );
    }
    if (!const <String>{'csv', 'json'}.contains(format)) {
      throw AdminInputException(
        _adminT('Invalid export format.', 'Format d’export invalide.'),
      );
    }
    final response = await _request(
      'POST',
      '/api/admin/exports',
      body: <String, dynamic>{'resource': resource, 'format': format},
    );
    return _decodeMap(response.body);
  }

  Future<AdminUserPage> getUsers({
    AdminUserOrderBy orderBy = AdminUserOrderBy.createdAt,
    AdminSortDirection direction = AdminSortDirection.descending,
    int page = 1,
    int limit = 50,
    String? query,
  }) async {
    await init();
    final response = await _request(
      'GET',
      '/api/admin/users',
      query: <String, dynamic>{
        'orderBy': orderBy.apiValue,
        'orderDirection': direction.apiValue,
        'page': page.clamp(1, 1000000),
        'limit': limit.clamp(1, 100),
        if (AdminInputValidator.optionalText(
              query,
              label: _adminT('User search', 'La recherche utilisateur'),
              maxLength: 200,
            )
            case final safeQuery?)
          'q': safeQuery,
      },
    );
    return AdminUserPage.fromJson(_decodeMap(response.body));
  }

  Future<List<AdminRelationOption>> searchRelations(
    AdminRelationResource resource,
    String query, {
    int limit = 20,
  }) async {
    await init();
    final safeQuery = AdminInputValidator.requiredText(
      query,
      label: _adminT('Search', 'La recherche'),
      maxLength: 200,
    );
    final response = await _request(
      'GET',
      resource.searchPath,
      query: <String, dynamic>{
        'q': safeQuery,
        'query': safeQuery,
        'limit': limit.clamp(1, 50),
      },
    );
    final decoded = _decodeMap(response.body);
    final data = _adminMap(decoded['data']) ?? decoded;
    final rawItems = data[resource.responseKey];
    if (rawItems is! List) return const <AdminRelationOption>[];
    return rawItems
        .map(_adminMap)
        .whereType<Map<String, dynamic>>()
        .map((item) => AdminRelationOption.fromJson(resource, item))
        .where((item) => item.id.isNotEmpty)
        .toList();
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
      '/api/admin/volume-quality/scan',
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
      label: _adminT('Issue', 'L’anomalie'),
    );
    final safeNote = AdminInputValidator.optionalText(
      note,
      label: _adminT('Resolution note', 'La note de résolution'),
      maxLength: 1000,
    );
    await _request(
      'PATCH',
      '/api/admin/volume-quality/issues/$safeIssueId/resolve',
      body: <String, dynamic>{
        if (safeNote != null) 'resolutionNote': safeNote,
      },
    );
  }

  Future<void> reopenVolumeQualityIssue(String issueId) async {
    await init();
    final safeIssueId = AdminInputValidator.relationId(
      issueId,
      label: _adminT('Issue', 'L’anomalie'),
    );
    await _request(
      'POST',
      '/api/admin/volume-quality/issues/$safeIssueId/reopen',
    );
  }

  Future<void> updateVolumeQualityData(
    String volumeId, {
    num? tomeNumber,
    String? subSeriesId,
  }) async {
    await init();
    final safeVolumeId = AdminInputValidator.relationId(
      volumeId,
      label: _adminT('Volume', 'Le volume'),
    );
    final body = <String, dynamic>{
      if (tomeNumber != null)
        'tomeNumber': AdminInputValidator.nonNegativeNumber(
          tomeNumber,
          label: _adminT('Volume number', 'Le numéro de tome'),
        ),
      if ((subSeriesId ?? '').trim().isNotEmpty)
        'subSeries': AdminInputValidator.relationId(
          subSeriesId!,
          label: _adminT('Sub-series', 'La sous-série'),
        ),
    };
    if (body.isEmpty) {
      throw AdminInputException(
        _adminT(
          'Change the volume number or the sub-series.',
          'Modifiez le numéro de tome ou la sous-série.',
        ),
      );
    }
    await _request('PATCH', '/api/volumes/$safeVolumeId', body: body);
  }

  Future<void> createAuthor({
    required String name,
    List<String> jobs = const <String>[],
    String? coverUrl,
  }) async {
    await init();

    final safeName = AdminInputValidator.requiredText(
      name,
      label: _adminT('Name', 'Le nom'),
    );
    final safeJobs = AdminInputValidator.textList(
      jobs,
      label: _adminT('Jobs', 'Les métiers'),
      maxItems: 20,
      maxItemLength: 80,
    );
    final safeCoverUrl = AdminInputValidator.httpsUrl(
      coverUrl,
      label: _adminT('Image', 'L’image'),
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
        'name': AdminInputValidator.requiredText(
          name,
          label: _adminT('Name', 'Le nom'),
        ),
      },
    );
  }

  Future<void> createEditor({required String name, String? coverUrl}) async {
    await init();
    final safeCoverUrl = AdminInputValidator.httpsUrl(
      coverUrl,
      label: _adminT('Logo', 'Le logo'),
    );
    await _request(
      'POST',
      '/api/editors',
      body: <String, dynamic>{
        'name': AdminInputValidator.requiredText(
          name,
          label: _adminT('Name', 'Le nom'),
        ),
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
              label: _adminT('Alternative titles', 'Les titres alternatifs'),
              maxItems: 30,
            ),
          if (authorIds.isNotEmpty)
            'authors': _safeRelationIds(
              authorIds,
              _adminT('Authors', 'Les auteurs'),
            ),
          if (editorIds.isNotEmpty)
            'editors': _safeRelationIds(
              editorIds,
              _adminT('Publishers', 'Les éditeurs'),
            ),
          if (genreIds.isNotEmpty)
            'genres': _safeRelationIds(
              genreIds,
              _adminT('Genres', 'Les genres'),
            ),
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
            label: _adminT('Parent series', 'La série parente'),
          ),
          if (authorIds.isNotEmpty)
            'authors': _safeRelationIds(
              authorIds,
              _adminT('Authors', 'Les auteurs'),
            ),
          if ((editorId ?? '').trim().isNotEmpty)
            'editors': AdminInputValidator.relationId(
              editorId!,
              label: _adminT('Publisher', 'L’éditeur'),
            ),
          if (genreIds.isNotEmpty)
            'genres': _safeRelationIds(
              genreIds,
              _adminT('Genres', 'Les genres'),
            ),
          'type': AdminInputValidator.requiredText(
            support,
            label: _adminT('Format', 'Le support'),
            maxLength: 40,
          ),
          'status': AdminInputValidator.requiredText(
            status,
            label: _adminT('Status', 'Le statut'),
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
      label: _adminT('French title', 'Le titre français'),
    );
    final safeTitleJp = AdminInputValidator.optionalText(
      titleJp,
      label: _adminT('Japanese title', 'Le titre japonais'),
    );
    final safeTitleEn = AdminInputValidator.optionalText(
      titleEn,
      label: _adminT('English title', 'Le titre anglais'),
    );
    final safeCoverUrl = AdminInputValidator.httpsUrl(
      coverUrl,
      label: _adminT('Cover', 'La couverture'),
    );
    final safeResume = AdminInputValidator.optionalText(
      resume,
      label: _adminT('Summary', 'Le résumé'),
      maxLength: 10000,
    );
    final safeGenderJp = AdminInputValidator.optionalText(
      genderJp,
      label: _adminT('Japanese demographic', 'Le public japonais'),
      maxLength: 80,
    );
    final body = <String, dynamic>{
      'titleFr': safeTitleFr,
      if (safeTitleJp != null) 'titleJp': safeTitleJp,
      if (safeTitleEn != null) 'titleEn': safeTitleEn,
      'tomeNumber': AdminInputValidator.nonNegativeNumber(
        tomeNumber,
        label: _adminT('Volume number', 'Le numéro de tome'),
      ),
      'price': AdminInputValidator.nonNegativeNumber(
        price,
        label: _adminT('Price', 'Le prix'),
      ),
      if (safeCoverUrl != null) 'coverUrl': safeCoverUrl,
      if (safeResume != null) 'resume': safeResume,
      if (publicationDate != null)
        'publicationDate': publicationDate.toUtc().toIso8601String(),
      'ean': AdminInputValidator.ean13(ean),
      'language': AdminInputValidator.requiredText(
        language,
        label: _adminT('Language', 'La langue'),
        maxLength: 40,
      ),
      'support': AdminInputValidator.requiredText(
        support,
        label: _adminT('Format', 'Le support'),
        maxLength: 40,
      ),
      if (safeGenderJp != null) 'genderJp': safeGenderJp,
      if ((subSeriesId ?? '').trim().isNotEmpty)
        'subSeries': AdminInputValidator.relationId(
          subSeriesId!,
          label: _adminT('Sub-series', 'La sous-série'),
        ),
      if (bookLinks.isNotEmpty)
        'bookLink': AdminInputValidator.httpsUrlList(
          bookLinks,
          label: _adminT('Purchase links', 'Les liens d’achat'),
        ),
      if (containsIds.isNotEmpty)
        'contain': _safeRelationIds(
          containsIds,
          _adminT('Included content', 'Les contenus inclus'),
        ),
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
      label: _adminT('Japanese title', 'Le titre japonais'),
    );
    final safeTitleEn = AdminInputValidator.optionalText(
      titleEn,
      label: _adminT('English title', 'Le titre anglais'),
    );
    final safeCoverUrl = AdminInputValidator.httpsUrl(
      coverUrl,
      label: _adminT('Cover', 'La couverture'),
    );
    return <String, dynamic>{
      'titleFr': AdminInputValidator.requiredText(
        titleFr,
        label: _adminT('French title', 'Le titre français'),
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
        _adminT(
          'Administrator not signed in. Enter an administrator API key.',
          'Admin non connecté. Veuillez saisir une clé API admin.',
        ),
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
    if (!isSafeApiPath(path)) {
      throw ArgumentError.value(
        path,
        'path',
        _adminT('Invalid API path.', 'Chemin API invalide.'),
      );
    }
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
        throw UnsupportedError(
          _adminT(
            'Unsupported HTTP method: $method',
            'Méthode HTTP non supportée : $method',
          ),
        );
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
      return _adminT(
        'API error (${response.statusCode}): service temporarily unavailable.',
        'Erreur API (${response.statusCode}) : service temporairement indisponible.',
      );
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message']?.toString();
        if (message != null && message.isNotEmpty) {
          final safeMessage = redactSensitiveText(
            message,
            maxLength: 300,
          ).trim();
          return _adminT(
            'API error (${response.statusCode}): $safeMessage',
            'Erreur API (${response.statusCode}) : $safeMessage',
          );
        }
      }
    } catch (_) {}

    return _adminT(
      'API error (${response.statusCode}): request rejected.',
      'Erreur API (${response.statusCode}) : requête refusée.',
    );
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
      RuntimeLocalization.debug(
        en: 'Secure storage read failed.',
        fr: 'La lecture du stockage sécurisé a échoué.',
      );
      return null;
    }
  }

  Future<void> _writeSecure(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      RuntimeLocalization.debug(
        en: 'Secure storage write failed.',
        fr: 'L’écriture dans le stockage sécurisé a échoué.',
      );
      throw StateError(
        _adminT(
          'Secure storage is unavailable. The administrator key was not saved.',
          'Le stockage sécurisé est indisponible. La clé admin n’a pas été conservée.',
        ),
      );
    }
  }

  Future<void> _deleteSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      RuntimeLocalization.debug(
        en: 'Secure storage deletion failed.',
        fr: 'La suppression dans le stockage sécurisé a échoué.',
      );
    }
  }
}
