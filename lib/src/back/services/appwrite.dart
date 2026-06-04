import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:mymangatheque/environment.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/api/mobile_api_client.dart';
import 'package:mymangatheque/src/back/services/appwrite_client.dart';
import 'package:mymangatheque/src/back/services/models/api_record_model.dart';
import 'package:mymangatheque/src/back/services/notifications/notification_service.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:mymangatheque/src/models/user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';

export 'package:mymangatheque/src/models/file.dart';
export 'package:mymangatheque/src/models/user.dart';

// Compatibility aliases for legacy record usages in the UI.
typedef RecordModel = ApiRecordModel;
typedef RecordSubscriptionEvent = ApiRecordSubscriptionEvent;

class RecordPage {
  const RecordPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalItems,
  });

  final List<RecordModel> items;
  final int page;
  final int totalPages;
  final int totalItems;

  bool get hasMore => page < totalPages;
}

class _RecordListCacheEntry {
  const _RecordListCacheEntry(this.records, this.cachedAt);

  final List<RecordModel> records;
  final DateTime cachedAt;
}

class _RelationSpec {
  const _RelationSpec({
    required this.collectionId,
    required this.sourceKeys,
    required this.expandKeys,
    required this.many,
  });

  final String collectionId;
  final List<String> sourceKeys;
  final List<String> expandKeys;
  final bool many;
}

class AppwriteConnector {
  static const String _mangaDatabaseId = 'manga-db';
  static const String _reviewsCollectionId = 'reviews';
  static const Duration _fullListCacheTtl = Duration(seconds: 25);

  AppwriteConnector._internal();

  static final AppwriteConnector _singleton = AppwriteConnector._internal();

  factory AppwriteConnector() => _singleton;

  final AppwriteClientService _appwrite = AppwriteClientService();
  final MobileApiClient _api = MobileApiClient();
  final NotificationService _notifications = NotificationService();

  final BehaviorSubject<User?> _connectedUser = BehaviorSubject<User?>();
  final Map<String, _RecordListCacheEntry> _fullListCache = <String, _RecordListCacheEntry>{};
  final Map<String, Future<List<RecordModel>>> _fullListInFlight = <String, Future<List<RecordModel>>>{};
  Set<String>? _ownedVolumeIdsIndex;
  Map<String, bool>? _ownedReadStateIndex;
  Set<String>? _followedSubSeriesIdsIndex;

  bool _initialized = false;
  int alreadyClick = 0;

  Future<void> init() async {
    if (_initialized) return;

    await _appwrite.init();
    await _appwrite.ensureGuestSession();
    await _api.init();
    await _notifications.init();
    _notifications.startFallbackPolling();

    try {
      await _api.ensureApiKey();
    } catch (e) {
      debugPrint('Mobile API key bootstrap failed: $e');
    }

    await _syncConnectedUser();
    _initialized = true;
  }

  Future<void> refresh() async {
    await _syncConnectedUser();
  }

  Future<void> refreshSession() async {
    await _appwrite.ensureGuestSession();
    await _api.invalidateApiKey();
    await _api.ensureApiKey();
    await _syncConnectedUser();
  }

  bool isLoggedIn() {
    return _connectedUser.valueOrNull != null;
  }

  Stream<User?> listenToUserChanges() => _connectedUser.stream;

  User? getConnectedUser() => _connectedUser.valueOrNull;

  Stream<List<InAppNotification>> listenToNotifications() {
    return _notifications.stream;
  }

  Future<void> _syncConnectedUser() async {
    final previousUserId = _connectedUser.valueOrNull?.id;
    final hasUserSession = await _appwrite.hasAuthenticatedUserSession();
    if (!hasUserSession) {
      if (previousUserId != null) {
        _clearCollectionCaches();
      }
      _connectedUser.add(null);
      return;
    }

    final profile = await _loadCurrentUserProfile();
    if (profile != null) {
      if (previousUserId != null && previousUserId != profile.id) {
        _clearCollectionCaches();
      }
      _connectedUser.add(profile);
      return;
    }

    final fallbackUser = await _loadCurrentUserFromAppwriteAccount();
    if (previousUserId != null && previousUserId != fallbackUser?.id) {
      _clearCollectionCaches();
    }
    _connectedUser.add(fallbackUser);
  }

  Future getOwned(String userId, expand, {bool forceRefresh = false}) async {
    final record = await _api.get(
      '/api/users/me/owned',
      requiresApiKey: true,
      requiresBearer: true,
      query: <String, dynamic>{'expand': expand},
    );

    debugPrint(record.body);
  }

  Future<User?> _loadCurrentUserProfile() async {
    try {
      final response = await _api.get(
        '/api/users/me',
        requiresApiKey: true,
        requiresBearer: true,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final decoded = _api.decodeBody(response);
      if (decoded is! Map<String, dynamic>) return null;

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) return null;

      final user = data['user'];
      if (user is! Map<String, dynamic>) return null;

      return User.fromApiJson(user);
    } catch (e) {
      debugPrint('Unable to fetch current user profile: $e');
      return null;
    }
  }

  Future<User?> _loadCurrentUserFromAppwriteAccount() async {
    try {
      final accountUser = await _appwrite.tryGetCurrentUser();
      if (accountUser == null) return null;
      final now = DateTime.now().toUtc();
      return User(
        id: accountUser.$id,
        username: accountUser.name.isNotEmpty ? accountUser.name : accountUser.email.split('@').first,
        email: accountUser.email,
        gender: 'other',
        avatar: null,
        birthday: now,
        created: DateTime.tryParse(accountUser.$createdAt)?.toUtc() ?? now,
        updated: DateTime.tryParse(accountUser.$updatedAt)?.toUtc() ?? now,
      );
    } catch (e) {
      debugPrint('Unable to fetch fallback Appwrite account profile: $e');
      return null;
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    if (alreadyClick != 0) {
      showMessage(AppLocalizations.of(context)!.pleaseWait, context);
      return;
    }

    alreadyClick = 1;
    try {
      await _appwrite.loginWithGoogle();
      await _api.invalidateApiKey();
      await _syncConnectedUser();
      await _api.ensureApiKey();
      if (context.mounted) {
        pushOrGo(context, '/profile');
      }
    } catch (e) {
      final cancelled = e.toString().contains('PlatformException(CANCELED');
      if (cancelled) {
        debugPrint('Google sign-in cancelled by user/session: $e');
        return;
      }
      if (context.mounted) {
        showMessage(AppLocalizations.of(context)!.errorOccurred, context);
      }
      debugPrint('Google sign-in failed: $e');
    } finally {
      alreadyClick = 0;
    }
  }

  Future<User?> loginWithEmail(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      await _appwrite.loginWithEmailPassword(
        email: email.toLowerCase(),
        password: password,
      );

      await _api.invalidateApiKey();
      await _syncConnectedUser();
      await _api.ensureApiKey();

      if (context.mounted) {
        showMessage(AppLocalizations.of(context)!.userLoginSuccess, context);
      }
      return _connectedUser.valueOrNull;
    } catch (e) {
      if (context.mounted) {
        showMessage(AppLocalizations.of(context)!.errorOccurred, context);
      }
      debugPrint('Email login failed: $e');
      return null;
    }
  }

  Future<User?> updateUserData(String email) async {
    final user = await _loadCurrentUserProfile();
    _connectedUser.add(user);
    return user;
  }

  Future<String> createUser(
    String username,
    String email,
    String password,
    String passwordVerifier,
    String gender,
    String birthday,
    BuildContext context,
  ) async {
    assert(username.isNotEmpty);
    assert(email.isNotEmpty);
    assert(password.isNotEmpty);
    assert(passwordVerifier.isNotEmpty);
    assert(gender.isNotEmpty);
    assert(birthday.isNotEmpty);

    if (password != passwordVerifier) {
      throw Exception('Password and confirmation do not match');
    }

    final created = await _appwrite.createAccount(
      email: email.toLowerCase(),
      password: password,
      name: username,
    );

    if (!context.mounted) {
      return created.$id;
    }
    await loginWithEmail(email, password, context);

    try {
      await _api.patch(
        '/api/users/me',
        requiresApiKey: true,
        requiresBearer: true,
        body: <String, dynamic>{
          'pseudo': username,
          'gender': gender,
          'birthday': DateTime.tryParse(birthday)?.toUtc().toIso8601String(),
        },
      );
      await _syncConnectedUser();
    } catch (e) {
      debugPrint('Unable to enrich profile after signup: $e');
    }

    await sendVerification(email);

    return created.$id;
  }

  Future<void> sendVerification(String email) async {
    try {
      await _appwrite.sendEmailVerification();
    } catch (e) {
      debugPrint('Email verification request failed: $e');
    }
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _appwrite.createRecoveryEmail(email);
      if (context.mounted) {
        Navigator.pop(context);
        showMessage(AppLocalizations.of(context)!.emailResetSent, context);
      }
    } catch (e) {
      if (context.mounted) {
        showMessage(AppLocalizations.of(context)!.errorOccurred, context);
      }
      rethrow;
    }
  }

  Future<void> completePasswordRecovery({
    required String userId,
    required String secret,
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      await _appwrite.completeRecovery(
        userId: userId,
        secret: secret,
        newPassword: newPassword,
      );

      if (context.mounted) {
        showMessage(
          AppLocalizations.of(context)!.modifyPasswordSuccess,
          context,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showMessage(AppLocalizations.of(context)!.errorOccurred, context);
      }
      rethrow;
    }
  }

  Future<void> modifyPassword(
    String email,
    String oldPassword,
    String newPassword,
    BuildContext context,
  ) async {
    try {
      await _appwrite.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      if (context.mounted) {
        showMessage(
          AppLocalizations.of(context)!.modifyPasswordSuccess,
          context,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showMessage(AppLocalizations.of(context)!.errorOccurred, context);
      }
      rethrow;
    }
  }

  Future<void> deleteUser(String recordId) async {
    await _appwrite.blockCurrentAccount();
    logOut();
  }

  void logOut() {
    _connectedUser.add(null);
    _clearCollectionCaches();
    _api.invalidateApiKey();
    _appwrite.logoutCurrentSession();

    LocalStorage().deleteToken();
    LocalStorage().deleteOwnedSubSerie();
  }

  void _invalidateCollectionCache(String collectionId) {
    final normalized = _normalizeCollectionId(collectionId);
    _fullListCache.remove(normalized);
    _fullListInFlight.remove(normalized);
    if (normalized == 'owned') {
      _ownedVolumeIdsIndex = null;
      _ownedReadStateIndex = null;
    } else if (normalized == 'followed') {
      _followedSubSeriesIdsIndex = null;
    }
  }

  void _clearCollectionCaches() {
    _fullListCache.clear();
    _fullListInFlight.clear();
    _ownedVolumeIdsIndex = null;
    _ownedReadStateIndex = null;
    _followedSubSeriesIdsIndex = null;
  }

  bool _isCacheEntryFresh(_RecordListCacheEntry? entry) {
    if (entry == null) return false;
    return DateTime.now().difference(entry.cachedAt) <= _fullListCacheTtl;
  }

  List<RecordModel> _cloneRecords(List<RecordModel> records) {
    return records
        .map(
          (record) => RecordModel(
            id: record.id,
            collectionId: record.collectionId,
            data: Map<String, dynamic>.from(record.data),
          ),
        )
        .toList();
  }

  Future<User?> findUser(String email) async {
    final user = await _loadCurrentUserProfile();
    if (user == null) return null;
    if (user.email.toLowerCase() != email.toLowerCase()) return null;
    return user;
  }

  Future<bool> updateAvatar(
    String collectionId,
    String userId,
    String fileName,
    List<int>? fileBytes,
    BuildContext context,
  ) async {
    if (fileBytes == null || fileName.isEmpty) {
      return false;
    }

    final hasAuthenticatedSession = await _appwrite.hasAuthenticatedUserSession();
    if (!hasAuthenticatedSession) {
      debugPrint('Avatar upload skipped: no authenticated Appwrite session.');
      if (context.mounted) {
        showMessage(AppLocalizations.of(context)!.errorOccurred, context);
      }
      return false;
    }

    final fileId = ID.unique();
    var uploadSucceeded = false;
    try {
      await _appwrite.storage.createFile(
        bucketId: 'user-bucket',
        fileId: fileId,
        file: InputFile.fromBytes(bytes: fileBytes, filename: fileName),
      );
      uploadSucceeded = true;
    } on AppwriteException catch (e) {
      debugPrint('Avatar update failed: $e');
      debugPrint(
        'Verify Appwrite storage permissions for bucket "user-bucket" (create/write for authenticated users).',
      );
      if (context.mounted) {
        showMessage(AppLocalizations.of(context)!.errorOccurred, context);
      }
      return false;
    } catch (e) {
      final parsingBug = e.toString().contains(
        "type 'Null' is not a subtype of type 'bool'",
      );
      if (parsingBug) {
        // Appwrite Dart SDK may fail to parse `File.encryption` when null.
        // Upload can still be successful because the request already completed.
        uploadSucceeded = true;
        debugPrint(
          'Avatar file upload response parsing failed; continuing with known fileId: $fileId',
        );
      } else {
        debugPrint('Avatar update failed: $e');
        if (context.mounted) {
          showMessage(AppLocalizations.of(context)!.errorOccurred, context);
        }
        return false;
      }
    }

    if (!uploadSucceeded) {
      return false;
    }

    try {
      final coverUrl =
          '${Environment.appwritePublicEndpoint}/storage/buckets/user-bucket/files/$fileId/view?project=${Environment.appwriteProjectId}';

      await _api.patch(
        '/api/users/me',
        requiresApiKey: true,
        requiresBearer: true,
        body: <String, dynamic>{'coverURL': coverUrl},
      );

      await _syncConnectedUser();
      return true;
    } catch (e) {
      debugPrint('Avatar profile patch failed after upload: $e');
      if (context.mounted) {
        showMessage(AppLocalizations.of(context)!.errorOccurred, context);
      }
      return false;
    }
  }

  Future<void> removeEntry(String collectionId, String entryId) async {
    final normalized = _normalizeCollectionId(collectionId);

    switch (normalized) {
      case 'volumes':
        await _api.delete('/api/volumes/$entryId');
        _invalidateCollectionCache('volumes');
        return;
      case 'sub_series':
        await _api.delete('/api/sub-series/$entryId');
        _invalidateCollectionCache('sub_series');
        return;
      case 'series':
        await _api.delete('/api/series/$entryId');
        _invalidateCollectionCache('series');
        return;
      case 'authors':
        await _api.delete('/api/authors/$entryId');
        _invalidateCollectionCache('authors');
        return;
      case 'editors':
        await _api.delete('/api/editors/$entryId');
        _invalidateCollectionCache('editors');
        return;
      case 'genres':
        await _api.delete('/api/genres/$entryId');
        _invalidateCollectionCache('genres');
        return;
      case 'owned':
        await _api.delete(
          '/api/users/me/owned/$entryId',
          requiresApiKey: true,
          requiresBearer: true,
        );
        _invalidateCollectionCache('owned');
        return;
      case 'followed':
        await _api.delete(
          '/api/users/me/followed/$entryId',
          requiresApiKey: true,
          requiresBearer: true,
        );
        _invalidateCollectionCache('followed');
        return;
      default:
        throw UnsupportedError(
          'Unsupported collection for delete: $collectionId',
        );
    }
  }

  Future<List<RecordModel>> getOne(String collectionId, String recordId) async {
    final normalized = _normalizeCollectionId(collectionId);
    final map = await _fetchOneNormalized(normalized, recordId);
    return <RecordModel>[
      RecordModel(
        id: map['id'].toString(),
        collectionId: normalized,
        data: map,
      ),
    ];
  }

  Future<List<RecordModel>> getOneOrder(
    String collectionId,
    String recordId,
    dynamic order,
  ) {
    return getOne(collectionId, recordId);
  }

  Future<List<RecordModel>> getOneExpand(
    String collectionId,
    String recordId,
    String? expand,
  ) async {
    final normalized = _normalizeCollectionId(collectionId);
    final map = await _fetchOneNormalized(normalized, recordId, expand: expand);
    return <RecordModel>[
      RecordModel(
        id: map['id'].toString(),
        collectionId: normalized,
        data: map,
      ),
    ];
  }

  Future<List<RecordModel>> getCollectionData(
    String collectionId, {
    String? expand,
  }) async {
    final normalized = _normalizeCollectionId(collectionId);
    final list = await _fetchCollectionNormalized(
      normalized,
      fullList: false,
      expand: expand,
    );
    return list
        .map(
          (item) => RecordModel(
            id: item['id'].toString(),
            collectionId: normalized,
            data: item,
          ),
        )
        .toList();
  }

  Future<RecordPage> getVolumesPage({int page = 1, int limit = 30}) async {
    return _fetchRecordPage(
      path: '/api/volumes',
      listKey: 'volumes',
      collectionId: 'volumes',
      normalize: _normalizeVolume,
      page: page,
      limit: limit,
      requiresApiKey: true,
    );
  }

  Future<RecordPage> getHomeRecommendationsPage({
    int page = 1,
    int limit = 30,
    int untilDays = 7,
  }) async {
    final normalizedUntilDays = untilDays.clamp(0, 365);

    // Prefer personalized recommendations when a user session exists.
    if (await _appwrite.hasAuthenticatedUserSession()) {
      try {
        return await _fetchRecordPage(
          path: '/api/recommendations/me',
          listKey: 'volumes',
          collectionId: 'volumes',
          normalize: _normalizeVolume,
          page: page,
          limit: limit,
          query: <String, dynamic>{'untilDays': normalizedUntilDays},
          requiresApiKey: true,
          requiresBearer: true,
        );
      } catch (e) {
        debugPrint(
          'Personalized recommendations unavailable, fallback to public home recommendations: $e',
        );
      }
    }

    return _fetchRecordPage(
      path: '/api/recommendations/home',
      listKey: 'volumes',
      collectionId: 'volumes',
      normalize: _normalizeVolume,
      page: page,
      limit: limit,
      query: <String, dynamic>{'untilDays': normalizedUntilDays},
      requiresApiKey: true,
    );
  }

  Future<RecordPage> getCollectionPage(
    String collectionId, {
    int page = 1,
    int limit = 30,
  }) async {
    final normalized = _normalizeCollectionId(collectionId);
    switch (normalized) {
      case 'volumes':
        return getVolumesPage(page: page, limit: limit);
      case 'series':
        return _fetchRecordPage(
          path: '/api/series',
          listKey: 'series',
          collectionId: 'series',
          normalize: _normalizeSeries,
          page: page,
          limit: limit,
          requiresApiKey: true,
        );
      case 'authors':
        return _fetchRecordPage(
          path: '/api/authors',
          listKey: 'authors',
          collectionId: 'authors',
          normalize: _normalizeAuthor,
          page: page,
          limit: limit,
          requiresApiKey: true,
        );
      case 'editors':
        return _fetchRecordPage(
          path: '/api/editors',
          listKey: 'editors',
          collectionId: 'editors',
          normalize: _normalizeEditor,
          page: page,
          limit: limit,
          requiresApiKey: true,
        );
      default:
        throw UnsupportedError(
          'Unsupported collection for paginated request: $collectionId',
        );
    }
  }

  /// Server-side paged search for a collection. Uses the backend endpoint
  /// /api/{resource}/search with q and pagination parameters.
  Future<RecordPage> searchCollectionPage(
    String collectionId, {
    String? query,
    int page = 1,
    int limit = 30,
  }) async {
    final normalized = _normalizeCollectionId(collectionId);
    switch (normalized) {
      case 'series':
        return _fetchRecordPage(
          path: '/api/series/search',
          listKey: 'series',
          collectionId: 'series',
          normalize: _normalizeSeries,
          page: page,
          limit: limit,
          query: <String, dynamic>{'q': query ?? ''},
          requiresApiKey: true,
        );
      case 'sub_series':
        return _fetchRecordPage(
          path: '/api/sub-series/search',
          listKey: 'subSeries',
          collectionId: 'sub_series',
          normalize: _normalizeSubSeries,
          page: page,
          limit: limit,
          query: <String, dynamic>{'q': query ?? ''},
          requiresApiKey: true,
        );
      case 'volumes':
        return _fetchRecordPage(
          path: '/api/volumes/search',
          listKey: 'volumes',
          collectionId: 'volumes',
          normalize: _normalizeVolume,
          page: page,
          limit: limit,
          query: <String, dynamic>{'q': query ?? ''},
          requiresApiKey: true,
        );
      case 'authors':
        return _fetchRecordPage(
          path: '/api/authors/search',
          listKey: 'authors',
          collectionId: 'authors',
          normalize: _normalizeAuthor,
          page: page,
          limit: limit,
          query: <String, dynamic>{'q': query ?? ''},
          requiresApiKey: true,
        );
      case 'editors':
        return _fetchRecordPage(
          path: '/api/editors/search',
          listKey: 'editors',
          collectionId: 'editors',
          normalize: _normalizeEditor,
          page: page,
          limit: limit,
          query: <String, dynamic>{'q': query ?? ''},
          requiresApiKey: true,
        );
      default:
        throw UnsupportedError(
          'Unsupported collection for search request: $collectionId',
        );
    }
  }

  Future<RecordPage> _fetchRecordPage({
    required String path,
    required String listKey,
    required String collectionId,
    required Map<String, dynamic> Function(Map<String, dynamic>) normalize,
    required int page,
    required int limit,
    Map<String, dynamic>? query,
    bool requiresApiKey = true,
    bool requiresBearer = false,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit < 1 ? 30 : limit;
    final requestQuery = <String, dynamic>{
      'page': safePage,
      'limit': safeLimit,
      ...?query,
    };

    final response = await _api.get(
      path,
      query: requestQuery,
      requiresApiKey: requiresApiKey,
      requiresBearer: requiresBearer,
    );

    final decoded = _api.decodeBody(response);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected payload for $path: $decoded');
    }

    final data = decoded['data'];
    final dataMap = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final rows = dataMap[listKey] ?? decoded[listKey] ?? (dataMap.length == 1 ? dataMap.values.first : null);
    final rawList = rows is List<dynamic> ? rows : const <dynamic>[];

    final records = rawList
        .whereType<Map<String, dynamic>>()
        .map(normalize)
        .map(
          (item) => RecordModel(
            id: item['id'].toString(),
            collectionId: collectionId,
            data: item,
          ),
        )
        .toList();

    final paginationRaw = decoded['pagination'];
    final pagination = paginationRaw is Map<String, dynamic> ? paginationRaw : <String, dynamic>{};

    final totalItemsFromPagination = _toIntOrDefault(
      pagination['totalItems'] ?? pagination['total'] ?? pagination['count'] ?? pagination['totalCount'],
      0,
    );
    final currentPage = _toIntOrDefault(
      pagination['currentPage'] ?? pagination['page'],
      safePage,
    );
    final inferredTotalPages = totalItemsFromPagination > 0
        ? (totalItemsFromPagination / safeLimit).ceil()
        : (rawList.length >= safeLimit ? currentPage + 1 : currentPage);
    final totalPages = _toIntOrDefault(
      pagination['totalPages'] ?? pagination['pages'],
      inferredTotalPages,
    );
    final totalItems = totalItemsFromPagination;

    return RecordPage(
      items: records,
      page: currentPage,
      totalPages: totalPages < 1 ? 1 : totalPages,
      totalItems: totalItems,
    );
  }

  Future<List<RecordModel>> getCollectionFullList(
    String collectionId, {
    String? expand,
  }) async {
    final normalized = _normalizeCollectionId(collectionId);
    if (expand != null && expand.trim().isNotEmpty) {
      final list = await _fetchCollectionNormalized(
        normalized,
        fullList: true,
        expand: expand,
      );
      return list
          .map(
            (item) => RecordModel(
              id: item['id'].toString(),
              collectionId: normalized,
              data: item,
            ),
          )
          .toList();
    }

    final cached = _fullListCache[normalized];
    if (_isCacheEntryFresh(cached)) {
      return _cloneRecords(cached!.records);
    }

    final inFlight = _fullListInFlight[normalized];
    if (inFlight != null) {
      return _cloneRecords(await inFlight);
    }

    final future = () async {
      final list = await _fetchCollectionNormalized(normalized, fullList: true);
      final records = list
          .map(
            (item) => RecordModel(
              id: item['id'].toString(),
              collectionId: normalized,
              data: item,
            ),
          )
          .toList();
      final shouldCacheEmpty = normalized == 'owned' || normalized == 'followed';
      if (records.isNotEmpty || shouldCacheEmpty) {
        _fullListCache[normalized] = _RecordListCacheEntry(
          _cloneRecords(records),
          DateTime.now(),
        );
      } else {
        _fullListCache.remove(normalized);
      }
      return records;
    }();

    _fullListInFlight[normalized] = future;
    try {
      return _cloneRecords(await future);
    } finally {
      _fullListInFlight.remove(normalized);
    }
  }

  Future<List<RecordModel>> getCollectionFullListOrder(
    String collectionId,
    String order,
  ) async {
    final list = await getCollectionFullList(collectionId);
    return _sortRecords(list, order);
  }

  Future<List<RecordModel>> getCollectionFullListOrderExpanded(
    String collectionId,
    String order,
    String expand,
  ) async {
    return _sortRecords(
      await getCollectionFullList(collectionId, expand: expand),
      order,
    );
  }

  Future<List<RecordModel>> getCollectionDataWithFilter(
    String collectionId,
    String query,
  ) async {
    final normalized = _normalizeCollectionId(collectionId);
    final list = await _fetchCollectionNormalized(
      normalized,
      fullList: false,
      filterQuery: query,
    );
    return list
        .map(
          (item) => RecordModel(
            id: item['id'].toString(),
            collectionId: normalized,
            data: item,
          ),
        )
        .toList();
  }

  Future<List<RecordModel>> getCollectionFullDataWithFilter(
    String collectionId,
    String query,
  ) async {
    final normalized = _normalizeCollectionId(collectionId);
    final list = await _fetchCollectionNormalized(
      normalized,
      fullList: true,
      filterQuery: query,
    );
    return list
        .map(
          (item) => RecordModel(
            id: item['id'].toString(),
            collectionId: normalized,
            data: item,
          ),
        )
        .toList();
  }

  Future<List<RecordModel>> getCollectionDataWithFilterExpand(
    String collectionId,
    String query,
    String expand,
  ) async {
    final normalized = _normalizeCollectionId(collectionId);
    final list = await _fetchCollectionNormalized(
      normalized,
      fullList: false,
      expand: expand,
      filterQuery: query,
    );
    return list
        .map(
          (item) => RecordModel(
            id: item['id'].toString(),
            collectionId: normalized,
            data: item,
          ),
        )
        .toList();
  }

  Future<List<RecordModel>> getCollectionFullDataWithFilterExpand(
    String collectionId,
    String query,
    String expand,
  ) async {
    final list = await _fetchCollectionNormalized(
      collectionId,
      fullList: true,
      expand: expand,
      filterQuery: query,
    );
    debugPrint(list.toString());
    return list
        .map(
          (item) => RecordModel(
            id: item['id'].toString(),
            collectionId: collectionId,
            data: item,
          ),
        )
        .toList();
  }

  Stream<List<RecordModel>> getCollectionDataListener(String collectionId) {
    final subject = PublishSubject<List<RecordModel>>();

    final subscription = listenToCollectionEvents(collectionId).listen((
      _,
    ) async {
      subject.add(await getCollectionData(collectionId));
    });

    subject.onListen = () async {
      subject.add(await getCollectionData(collectionId));
    };

    subject.onCancel = subscription.cancel;

    return subject.stream;
  }

  Stream<RecordSubscriptionEvent> listenToCollectionEvents(
    String collectionId,
  ) {
    final controller = StreamController<RecordSubscriptionEvent>();
    Timer? timer;

    timer = Timer.periodic(const Duration(seconds: 15), (_) {
      controller.add(
        RecordSubscriptionEvent(
          collectionId: _normalizeCollectionId(collectionId),
          action: 'poll',
        ),
      );
    });

    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }

  Future<int> getNewRegisterLast24h() async {
    try {
      final response = await _api.get(
        '/api/analytics/summary',
        requiresApiKey: true,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return 0;
      }

      final decoded = _api.decodeBody(response);
      if (decoded is! Map<String, dynamic>) return 0;

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) return 0;

      final value = data['users_last_24h'] ?? data['users24h'] ?? data['users'];
      return int.tryParse(value.toString()) ?? 0;
    } catch (e) {
      debugPrint('Unable to load analytics summary: $e');
      return 0;
    }
  }

  Future<String> getNewRegisterLastMonth() async {
    try {
      final response = await _api.get(
        '/api/analytics/most-added-volumes',
        query: <String, dynamic>{'days': 30, 'limit': 30},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return '{}';
      }
      return response.body;
    } catch (e) {
      debugPrint('Unable to load monthly analytics: $e');
      return '{}';
    }
  }

  Future<int> getNumberOwnedManga(String id) async {
    final list = await getCollectionFullList('owned');
    return list.length;
  }

  Future<int> getNumberFavSerie(String id) async {
    final list = await getCollectionFullList('followed');
    return list.length;
  }

  Future<String> getAuthorName(String authorId) async {
    final author = await getOne('authors', authorId);
    return author.first.data['name']?.toString() ?? '';
  }

  Future<String> getEditorName(String editorId) async {
    final editor = await getOne('editors', editorId);
    return editor.first.data['name']?.toString() ?? '';
  }

  Future<String> getVolumeImage(String volumeId) async {
    final volume = await getOne('volumes', volumeId);
    return volume.first.data['image']?.toString() ?? '';
  }

  Future<Map<String, dynamic>> getSubSerie(String id) async {
    final sub = await getOne('sub_series', id);
    return sub.first.data;
  }

  Future<List<String>> getSubSerieVolumesImages(String id) async {
    final subSeries = await getOneExpand('sub_series', id, 'volumes');
    final volumes = (subSeries.first.data['expand']?['volumes'] as List?) ?? const <dynamic>[];

    final sorted =
        List<Map<String, dynamic>>.from(
          volumes.whereType<Map<String, dynamic>>(),
        )..sort((a, b) {
          final aTome = (a['tome_number'] as num?) ?? 0;
          final bTome = (b['tome_number'] as num?) ?? 0;
          return aTome.compareTo(bTome);
        });

    return sorted.map((volume) => volume['image']?.toString() ?? '').where((url) => url.isNotEmpty).toList();
  }

  Future<void> _ensureOwnedIndexes() async {
    if (_ownedVolumeIdsIndex != null && _ownedReadStateIndex != null && _isCacheEntryFresh(_fullListCache['owned'])) {
      return;
    }

    final entries = await getCollectionFullList('owned');
    final ids = <String>{};
    final readState = <String, bool>{};

    for (final entry in entries) {
      final volumeId = entry.data['volume']?.toString() ?? entry.data['volumeId']?.toString() ?? entry.data['volumes']?.toString() ?? '';
      if (volumeId.isEmpty) continue;
      ids.add(volumeId);
      readState[volumeId] = entry.data['readed'] == true;
    }

    _ownedVolumeIdsIndex = ids;
    _ownedReadStateIndex = readState;
  }

  Future<void> _ensureFollowedIndex() async {
    if (_followedSubSeriesIdsIndex != null && _isCacheEntryFresh(_fullListCache['followed'])) {
      return;
    }
    final entries = await getCollectionFullList('followed');
    _followedSubSeriesIdsIndex = entries
        .map(
          (entry) =>
              entry.data['sub_serie']?.toString() ??
              entry.data['sub_series']?.toString() ??
              entry.data['subSeries']?.toString() ??
              entry.data['subSeriesId']?.toString() ??
              '',
        )
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<void> addVolumeToOwned(
    String userId,
    String volumeId,
    bool readState,
  ) async {
    await _api.post(
      '/api/users/me/owned',
      requiresApiKey: true,
      requiresBearer: true,
      body: <String, dynamic>{'volumeId': volumeId, 'readed': readState},
    );
    _invalidateCollectionCache('owned');
  }

  Future<void> removeVolumeFromOwned(String userId, String volumeId) async {
    await _api.delete(
      '/api/users/me/owned/$volumeId',
      requiresApiKey: true,
      requiresBearer: true,
    );
    _invalidateCollectionCache('owned');
  }

  Future<bool> isVolumeOwned(String userId, String volumeId) async {
    await _ensureOwnedIndexes();
    return _ownedVolumeIdsIndex?.contains(volumeId) == true;
  }

  Future<void> changeReadState(
    String userId,
    String volumeId,
    bool readState,
  ) async {
    await _api.patch(
      '/api/users/me/owned/$volumeId',
      requiresApiKey: true,
      requiresBearer: true,
      body: <String, dynamic>{'readed': readState},
    );
    _invalidateCollectionCache('owned');
  }

  Future<bool> isVolumeReaded(String userId, String volumeId) async {
    await _ensureOwnedIndexes();
    return _ownedReadStateIndex?[volumeId] == true;
  }

  Future<Map<String, dynamic>?> getMyVolumeReview(String volumeId) async {
    await init();
    final userId = getConnectedUser()?.id;
    if (userId == null || userId.isEmpty) return null;

    try {
      final tables = TablesDB(_appwrite.client);
      final response = await tables.listRows(
        databaseId: _mangaDatabaseId,
        tableId: _reviewsCollectionId,
        queries: <String>[
          Query.equal('users', userId),
          Query.equal('volumes', volumeId),
          Query.limit(1),
        ],
      );

      if (response.rows.isEmpty) return null;
      return _normalizeReviewDocument(response.rows.first);
    } catch (e) {
      debugPrint(
        'Unable to fetch current user review for volume $volumeId: $e',
      );
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getVolumeReviews(
    String volumeId, {
    String? includePendingForUserId,
  }) async {
    await init();
    try {
      final tables = TablesDB(_appwrite.client);
      final response = await tables.listRows(
        databaseId: _mangaDatabaseId,
        tableId: _reviewsCollectionId,
        queries: <String>[
          Query.equal('volumes', volumeId),
          Query.orderDesc(r'$createdAt'),
          Query.limit(100),
        ],
      );

      final includePendingUser = includePendingForUserId ?? '';
      final reviews = response.rows.map<Map<String, dynamic>>((doc) => _normalizeReviewDocument(doc)).where((review) {
        final checked = review['commentChecked'] == true;
        final isPendingForUser = includePendingUser.isNotEmpty && review['userId']?.toString() == includePendingUser;
        return checked || isPendingForUser;
      }).toList();

      return reviews;
    } catch (e) {
      debugPrint('Unable to fetch volume reviews for $volumeId: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> upsertVolumeReview({
    required String volumeId,
    required int stars,
    String comment = '',
    List<String> favCharacters = const <String>[],
  }) async {
    await init();
    final userId = getConnectedUser()?.id;
    if (userId == null || userId.isEmpty) {
      throw Exception('User must be logged in to submit a review');
    }

    final normalizedStars = stars.clamp(1, 5);
    final cleanedComment = comment.trim();
    final cleanedFavCharacters = favCharacters.map((item) => item.trim()).where((item) => item.isNotEmpty).toSet().toList();

    final payload = <String, dynamic>{
      'users': userId,
      'volumes': volumeId,
      'stars': normalizedStars,
      'comment': cleanedComment,
      'fav_characters': cleanedFavCharacters,
      // keep moderation workflow: edited comments return to unchecked
      'commentChecked': false,
    };

    final tables = TablesDB(_appwrite.client);
    final existingReview = await getMyVolumeReview(volumeId);
    if (existingReview != null) {
      await tables.updateRow(
        databaseId: _mangaDatabaseId,
        tableId: _reviewsCollectionId,
        rowId: existingReview['id']?.toString() ?? '',
        data: payload,
      );
      return;
    }

    await tables.createRow(
      databaseId: _mangaDatabaseId,
      tableId: _reviewsCollectionId,
      rowId: ID.unique(),
      data: payload,
      permissions: <String>[
        Permission.read(Role.any()),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );
  }

  Future<void> addSubSeriesToFollowed(String userId, String subSeriesId) async {
    await _api.post(
      '/api/users/me/followed',
      requiresApiKey: true,
      requiresBearer: true,
      body: <String, dynamic>{'subSeriesId': subSeriesId},
    );
    _invalidateCollectionCache('followed');
  }

  Future<void> removeSubSeriesToFollowed(
    String userId,
    String subSeriesId,
  ) async {
    await _api.delete(
      '/api/users/me/followed/$subSeriesId',
      requiresApiKey: true,
      requiresBearer: true,
    );
    _invalidateCollectionCache('followed');
  }

  Future<bool> isSubSeriesFollowed(String userId, String subSeriesId) async {
    await _ensureFollowedIndex();
    return _followedSubSeriesIdsIndex?.contains(subSeriesId) == true;
  }

  Future<String> getAppVersion() async {
    return (await PackageInfo.fromPlatform()).version;
  }

  Future<String> get appVersion async => (await PackageInfo.fromPlatform()).version;

  Future<String> get buildVersion async => (await PackageInfo.fromPlatform()).buildNumber;

  String get serverUrl => 'https://api.mymangatheque.com';

  AppwriteCompatClient connector() => AppwriteCompatClient();

  Future<void> registerPushTarget({
    required String deviceToken,
    required String targetId,
  }) {
    return _notifications.registerPushTarget(
      deviceToken: deviceToken,
      targetId: targetId,
    );
  }

  // ----- Internal mapping and compatibility helpers -----

  List<RecordModel> _sortRecords(List<RecordModel> records, String order) {
    if (order.isEmpty) return records;

    final desc = order.startsWith('-');
    final key = order.replaceFirst(RegExp(r'^[+-]'), '');

    final sorted = List<RecordModel>.from(records)
      ..sort((a, b) {
        final av = a.data[key];
        final bv = b.data[key];

        int cmp;
        if (av is num && bv is num) {
          cmp = av.compareTo(bv);
        } else {
          final ad = DateTime.tryParse(av?.toString() ?? '');
          final bd = DateTime.tryParse(bv?.toString() ?? '');
          if (ad != null && bd != null) {
            cmp = ad.compareTo(bd);
          } else {
            cmp = (av?.toString() ?? '').compareTo(bv?.toString() ?? '');
          }
        }

        return desc ? -cmp : cmp;
      });

    return sorted;
  }

  Map<String, dynamic> _normalizeReviewDocument(dynamic doc) {
    final data = Map<String, dynamic>.from(doc.data);
    return <String, dynamic>{
      'id': doc.$id,
      'userId': _relationId(data['users']) ?? '',
      'volumeId': _relationId(data['volumes']) ?? '',
      'stars': _toIntOrDefault(data['stars'], 0),
      'comment': data['comment']?.toString() ?? '',
      'commentChecked': data['commentChecked'] == true,
      'favCharacters': _toStringList(data['fav_characters']),
      'createdAt': doc.$createdAt,
      'updatedAt': doc.$updatedAt,
    };
  }

  String _normalizeCollectionId(String collectionId) {
    switch (collectionId) {
      case 'sub-series':
      case 'subseries':
      case 'sub_serie':
      case 'sub_series':
        return 'subSeries';
      default:
        return collectionId;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCollectionNormalized(
    String collectionId, {
    required bool fullList,
    String? expand,
    String? filterQuery,
  }) async {
    final records = switch (collectionId) {
      'series' => await _fetchPaginatedCollection(
        '/api/series',
        'series',
        normalize: _normalizeSeries,
        fullList: fullList,
        requiresApiKey: true,
        expand: expand,
        filterQuery: filterQuery,
      ),
      'sub_series' => await _fetchPaginatedCollection(
        '/api/sub-series',
        'subSeries',
        normalize: _normalizeSubSeries,
        fullList: fullList,
        requiresApiKey: true,
        expand: expand,
        filterQuery: filterQuery,
      ),
      'volumes' => await _fetchPaginatedCollection(
        '/api/volumes',
        'volumes',
        normalize: _normalizeVolume,
        fullList: fullList,
        requiresApiKey: true,
        expand: expand,
        filterQuery: filterQuery,
      ),
      'authors' => await _fetchPaginatedCollection(
        '/api/authors',
        'authors',
        normalize: _normalizeAuthor,
        fullList: fullList,
        requiresApiKey: true,
        expand: expand,
        filterQuery: filterQuery,
      ),
      'editors' => await _fetchPaginatedCollection(
        '/api/editors',
        'editors',
        normalize: _normalizeEditor,
        fullList: fullList,
        requiresApiKey: true,
        expand: expand,
        filterQuery: filterQuery,
      ),
      'genres' => await _fetchPaginatedCollection(
        '/api/genres',
        'genres',
        normalize: _normalizeGenre,
        fullList: fullList,
        requiresApiKey: true,
        expand: expand,
        filterQuery: filterQuery,
      ),
      'owned' => await _fetchUserCollection(
        '/api/users/me/owned',
        'ownedVolumes',
        normalize: _normalizeOwnedEntry,
        expand: expand,
      ),
      'followed' => await _fetchUserCollection(
        '/api/users/me/followed',
        'followedSubSeries',
        normalize: _normalizeFollowedEntry,
        expand: expand,
      ),
      _ => throw UnsupportedError('Unsupported collection: $collectionId'),
    };

    final requestedExpand = expand?.trim() ?? '';
    if (requestedExpand.isEmpty || records.isEmpty) {
      return records;
    }

    return Future.wait(
      records.map(
        (record) => _appendExpand(collectionId, record, requestedExpand),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchOneNormalized(
    String collectionId,
    String id, {
    String? expand,
  }) async {
    final record = switch (collectionId) {
      'series' => await _fetchOne(
        '/api/series/$id',
        _normalizeSeries,
        requiresApiKey: true,
        expand: expand,
      ),
      'sub_series' => await _fetchOne(
        '/api/sub-series/$id',
        _normalizeSubSeries,
        requiresApiKey: true,
        expand: expand,
      ),
      'volumes' => await _fetchOne(
        '/api/volumes/$id',
        _normalizeVolume,
        requiresApiKey: true,
        expand: expand,
      ),
      'authors' => await _fetchOne(
        '/api/authors/$id',
        _normalizeAuthor,
        requiresApiKey: true,
        expand: expand,
      ),
      'editors' => await _fetchOne(
        '/api/editors/$id',
        _normalizeEditor,
        requiresApiKey: true,
        expand: expand,
      ),
      'genres' => await _fetchOne(
        '/api/genres/$id',
        _normalizeGenre,
        requiresApiKey: true,
        expand: expand,
      ),
      'owned' =>
        (await _fetchCollectionNormalized(
          'owned',
          fullList: true,
          expand: expand,
        )).firstWhere(
          (entry) => entry['volume']?.toString() == id || entry['id']?.toString() == id,
          orElse: () => <String, dynamic>{'id': id},
        ),
      'followed' =>
        (await _fetchCollectionNormalized(
          'followed',
          fullList: true,
          expand: expand,
        )).firstWhere(
          (entry) => entry['sub_serie']?.toString() == id || entry['id']?.toString() == id,
          orElse: () => <String, dynamic>{'id': id},
        ),
      _ => throw UnsupportedError('Unsupported collection: $collectionId'),
    };

    final requestedExpand = expand?.trim() ?? '';
    if (requestedExpand.isEmpty) {
      return record;
    }

    return _appendExpand(collectionId, record, requestedExpand);
  }

  Future<Map<String, dynamic>> _fetchOne(
    String path,
    Map<String, dynamic> Function(Map<String, dynamic>) normalize, {
    bool requiresApiKey = true,
    String? expand,
  }) async {
    final response = await _api.get(
      path,
      query: expand == null || expand.trim().isEmpty ? null : <String, dynamic>{'expand': expand},
      requiresApiKey: requiresApiKey,
    );

    final decoded = _api.decodeBody(response);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected payload for $path: $decoded');
    }

    final payload = _extractSingleRecordPayload(decoded, path);
    final payloadWithExpand = _mergeTopLevelExpandIntoPayload(
      payload,
      decoded['expand'],
    );
    return normalize(payloadWithExpand);
  }

  Map<String, dynamic> _mergeTopLevelExpandIntoPayload(
    Map<String, dynamic> payload,
    dynamic topLevelExpand,
  ) {
    final normalizedTopLevelExpand = _normalizeTopLevelExpand(topLevelExpand);
    if (normalizedTopLevelExpand == null) {
      return payload;
    }

    final mergedExpand = _mergeExpandValue(
      payload['expand'],
      normalizedTopLevelExpand,
    );
    return <String, dynamic>{...payload, 'expand': mergedExpand};
  }

  dynamic _normalizeTopLevelExpand(dynamic rawExpand) {
    if (rawExpand == null) return null;
    if (rawExpand is Map<String, dynamic>) return _cloneExpandValue(rawExpand);
    if (rawExpand is Map) return _cloneExpandValue(Map<String, dynamic>.from(rawExpand));

    if (rawExpand is List) {
      final merged = <String, dynamic>{};
      for (final item in rawExpand) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        map.forEach((key, value) {
          if (!merged.containsKey(key)) {
            merged[key] = _cloneExpandValue(value);
          } else {
            merged[key] = _mergeExpandValue(merged[key], value);
          }
        });
      }

      if (merged.isNotEmpty) {
        return merged;
      }
    }

    return _cloneExpandValue(rawExpand);
  }

  dynamic _mergeExpandValue(dynamic current, dynamic incoming) {
    if (current == null) return _cloneExpandValue(incoming);
    if (incoming == null) return _cloneExpandValue(current);

    if (current is Map && incoming is Map) {
      final merged = <String, dynamic>{...Map<String, dynamic>.from(current)};
      for (final entry in incoming.entries) {
        final key = entry.key.toString();
        if (!merged.containsKey(key)) {
          merged[key] = _cloneExpandValue(entry.value);
        } else {
          merged[key] = _mergeExpandValue(merged[key], entry.value);
        }
      }
      return merged;
    }

    if (current is List && incoming is List) {
      return <dynamic>[
        ...current.map(_cloneExpandValue),
        ...incoming.map(_cloneExpandValue),
      ];
    }

    return _cloneExpandValue(current);
  }

  Map<String, dynamic> _extractSingleRecordPayload(
    Map<String, dynamic> decoded,
    String path,
  ) {
    if (_looksLikeSingleRecord(decoded)) {
      return decoded;
    }

    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      final nestedRecord = _pickNestedRecord(data);
      if (nestedRecord != null) {
        return nestedRecord;
      }
    }

    final topLevelRecord = _pickNestedRecord(
      decoded,
      skipKeys: <String>{
        'status',
        'message',
        'pagination',
        'results',
        'meta',
        'errors',
      },
    );
    if (topLevelRecord != null) {
      return topLevelRecord;
    }

    throw Exception('Unexpected single-item payload for $path: $decoded');
  }

  Map<String, dynamic>? _pickNestedRecord(
    Map<String, dynamic> source, {
    Set<String> skipKeys = const <String>{},
  }) {
    for (final entry in source.entries) {
      if (skipKeys.contains(entry.key)) continue;
      final value = entry.value;
      if (value is Map<String, dynamic> && _looksLikeSingleRecord(value)) {
        return value;
      }
    }

    if (source.length == 1) {
      final only = source.values.first;
      if (only is Map<String, dynamic>) {
        return only;
      }
    }

    return null;
  }

  bool _looksLikeSingleRecord(Map<String, dynamic> data) {
    return data.containsKey(r'$id') ||
        data.containsKey('id') ||
        data.containsKey('titleFr') ||
        data.containsKey('name') ||
        data.containsKey('tomeNumber') ||
        data.containsKey('tome_number');
  }

  Future<List<Map<String, dynamic>>> _fetchPaginatedCollection(
    String path,
    String listKey, {
    required Map<String, dynamic> Function(Map<String, dynamic>) normalize,
    required bool fullList,
    bool requiresApiKey = true,
    String? expand,
    String? filterQuery,
  }) async {
    late final List<dynamic> rows;
    try {
      rows = fullList
          ? await _api.fetchAllPages(
              path: path,
              listKey: listKey,
              baseQuery: <String, dynamic>{
                if (expand != null && expand.trim().isNotEmpty) 'expand': expand,
                if (filterQuery != null && filterQuery.trim().isNotEmpty) 'filter': filterQuery,
              },
              requiresApiKey: requiresApiKey,
            )
          : await () async {
              final response = await _api.get(
                path,
                query: <String, dynamic>{
                  'page': 1,
                  'limit': 20,
                  if (expand != null && expand.trim().isNotEmpty) 'expand': expand,
                  if (filterQuery != null && filterQuery.trim().isNotEmpty) 'filter': filterQuery,
                },
                requiresApiKey: requiresApiKey,
              );
              if (response.statusCode < 200 || response.statusCode >= 300) {
                return const <dynamic>[];
              }
              final decoded = _api.decodeBody(response);
              if (decoded is! Map<String, dynamic>) return const <dynamic>[];
              final data = decoded['data'];
              if (data is! Map<String, dynamic>) return const <dynamic>[];
              final list = data[listKey];
              if (list is! List<dynamic>) return const <dynamic>[];
              return list;
            }();
    } catch (e) {
      final message = e.toString();
      final isMissingApiKey =
          message.contains('No API Key provided') ||
          message.contains('authenticated Appwrite JWT required') ||
          message.contains(
            'Authorization: Bearer <appwrite-jwt> is required',
          ) ||
          message.contains(
            'Missing authenticated user session for Bearer request',
          ) ||
          message.contains('general_rate_limit_exceeded');
      if (isMissingApiKey) {
        debugPrint('Skipping $path while mobile API key is unavailable.');
        return <Map<String, dynamic>>[];
      }
      rethrow;
    }

    return rows.whereType<Map<String, dynamic>>().map((raw) => normalize(raw)).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchUserCollection(
    String path,
    String listKey, {
    required Map<String, dynamic> Function(Map<String, dynamic>) normalize,
    String? expand,
  }) async {
    late final dynamic response;
    try {
      response = await _api.get(
        path,
        query: expand == null || expand.trim().isEmpty ? null : <String, dynamic>{'expand': expand},
        requiresApiKey: true,
        requiresBearer: true,
      );
    } catch (e) {
      debugPrint('Skipping user collection $path: $e');
      return <Map<String, dynamic>>[];
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return <Map<String, dynamic>>[];
    }

    final decoded = _api.decodeBody(response);
    final list = _extractUserCollectionList(decoded, listKey);
    if (list.isEmpty) return <Map<String, dynamic>>[];

    return list.whereType<Map<String, dynamic>>().map((raw) => normalize(raw)).toList();
  }

  List<dynamic> _extractUserCollectionList(dynamic decoded, String listKey) {
    if (decoded is List<dynamic>) return decoded;
    if (decoded is! Map<String, dynamic>) return const <dynamic>[];

    final direct = decoded[listKey];
    if (direct is List<dynamic>) return direct;

    final alternateKeys = <String>[
      if (listKey == 'ownedVolumes') ...<String>['owned', 'ownedVolumes'],
      if (listKey == 'followedSubSeries') ...<String>['followed', 'followedSubSeries'],
      'items',
      'results',
      'data',
    ];
    for (final key in alternateKeys) {
      final candidate = decoded[key];
      if (candidate is List<dynamic>) return candidate;
      if (candidate is Map<String, dynamic>) {
        final nested = candidate[listKey];
        if (nested is List<dynamic>) return nested;
        for (final nestedValue in candidate.values) {
          if (nestedValue is List<dynamic>) return nestedValue;
        }
      }
    }

    final data = decoded['data'];
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic>) {
      final nested = data[listKey];
      if (nested is List<dynamic>) return nested;

      for (final value in data.values) {
        if (value is List<dynamic>) return value;
      }
    }

    for (final value in decoded.values) {
      if (value is List<dynamic>) return value;
    }

    return const <dynamic>[];
  }

  Future<Map<String, dynamic>> _appendExpand(
    String collectionId,
    Map<String, dynamic> record,
    String expand,
  ) async {
    final expandedRecord = Map<String, dynamic>.from(record);
    final paths = expand
        .split(',')
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .map(
          (path) => path.split('.').map((part) => part.trim()).where((part) => part.isNotEmpty).toList(),
        )
        .where((parts) => parts.isNotEmpty);

    for (final path in paths) {
      await _appendExpandPath(collectionId, expandedRecord, path);
    }

    return expandedRecord;
  }

  Future<void> _appendExpandPath(
    String collectionId,
    Map<String, dynamic> record,
    List<String> path,
  ) async {
    if (path.isEmpty) return;

    final spec = _relationSpec(collectionId, path.first);
    if (spec == null) return;

    final expand = _ensureExpandMap(record);
    var expandedValue = _findExpandedValue(expand, spec.expandKeys);

    if (_hasExpandedRecords(expandedValue)) {
      expandedValue = _normalizeExpandedValue(spec, expandedValue);
    } else {
      expandedValue = await _loadExpandedRelation(record, spec);
    }

    if (!_hasExpandedRecords(expandedValue)) return;

    _storeExpandedValue(expand, spec.expandKeys, expandedValue);

    final nestedPath = path.sublist(1);
    if (nestedPath.isEmpty) return;

    for (final nestedRecord in _expandedRecordMaps(expandedValue)) {
      await _appendExpandPath(spec.collectionId, nestedRecord, nestedPath);
    }
  }

  Map<String, dynamic> _ensureExpandMap(Map<String, dynamic> record) {
    final expand = _cloneExpandMap(record['expand']);
    record['expand'] = expand;
    return expand;
  }

  dynamic _findExpandedValue(Map<String, dynamic> expand, List<String> keys) {
    for (final key in keys) {
      final value = expand[key];
      if (_hasExpandedRecords(value)) {
        return value;
      }
    }
    return null;
  }

  bool _hasExpandedRecords(dynamic value) {
    if (value is Map) return value.isNotEmpty;
    if (value is List) {
      return value.any((item) => item is Map && item.isNotEmpty);
    }
    return false;
  }

  List<Map<String, dynamic>> _expandedRecordMaps(dynamic value) {
    if (value is Map<String, dynamic>) return <Map<String, dynamic>>[value];
    if (value is Map) return <Map<String, dynamic>>[Map<String, dynamic>.from(value)];
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) => item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item),
          )
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  dynamic _normalizeExpandedValue(_RelationSpec spec, dynamic value) {
    final records = _expandedRecordMaps(value).map((item) => _normalizeRecordForCollection(spec.collectionId, item)).toList();
    if (spec.many) return records;
    return records.isNotEmpty ? records.first : <String, dynamic>{};
  }

  Future<dynamic> _loadExpandedRelation(
    Map<String, dynamic> record,
    _RelationSpec spec,
  ) async {
    final ids = <String>{};
    for (final key in spec.sourceKeys) {
      ids.addAll(_relationIds(record[key]));
    }

    if (ids.isEmpty) {
      return spec.many ? <Map<String, dynamic>>[] : <String, dynamic>{};
    }

    final records = <Map<String, dynamic>>[];
    for (final id in ids) {
      try {
        records.add(await _fetchOneNormalized(spec.collectionId, id));
      } catch (e) {
        debugPrint('Unable to expand ${spec.collectionId}/$id: $e');
      }
    }

    if (spec.many) return records;
    return records.isNotEmpty ? records.first : <String, dynamic>{};
  }

  void _storeExpandedValue(
    Map<String, dynamic> expand,
    List<String> keys,
    dynamic value,
  ) {
    for (final key in keys) {
      expand[key] = value;
    }
  }

  Map<String, dynamic> _normalizeRecordForCollection(
    String collectionId,
    Map<String, dynamic> raw,
  ) {
    return switch (_normalizeCollectionId(collectionId)) {
      'series' => _normalizeSeries(raw),
      'sub_series' => _normalizeSubSeries(raw),
      'volumes' => _normalizeVolume(raw),
      'authors' => _normalizeAuthor(raw),
      'editors' => _normalizeEditor(raw),
      'genres' => _normalizeGenre(raw),
      'owned' => _normalizeOwnedEntry(raw),
      'followed' => _normalizeFollowedEntry(raw),
      _ => Map<String, dynamic>.from(raw),
    };
  }

  _RelationSpec? _relationSpec(String collectionId, String relation) {
    final normalizedCollection = _normalizeCollectionId(collectionId);
    final normalizedRelation = _normalizeRelationName(relation);

    switch (normalizedCollection) {
      case 'owned':
        if (normalizedRelation == 'volume') {
          return const _RelationSpec(
            collectionId: 'volumes',
            sourceKeys: <String>['volume', 'volumes', 'volumeId'],
            expandKeys: <String>['volume', 'volumes'],
            many: false,
          );
        }
        break;
      case 'followed':
        if (normalizedRelation == 'sub_series') {
          return const _RelationSpec(
            collectionId: 'sub_series',
            sourceKeys: <String>[
              'sub_serie',
              'sub_series',
              'subSeries',
              'subSeriesId',
            ],
            expandKeys: <String>['sub_serie', 'sub_series', 'subSeries'],
            many: false,
          );
        }
        break;
      case 'series':
        if (normalizedRelation == 'sub_series') {
          return const _RelationSpec(
            collectionId: 'sub_series',
            sourceKeys: <String>['subSeries', 'sub_series'],
            expandKeys: <String>['subSeries', 'sub_series'],
            many: true,
          );
        }
        if (normalizedRelation == 'authors') {
          return const _RelationSpec(
            collectionId: 'authors',
            sourceKeys: <String>['authors'],
            expandKeys: <String>['authors'],
            many: true,
          );
        }
        if (normalizedRelation == 'genres') {
          return const _RelationSpec(
            collectionId: 'genres',
            sourceKeys: <String>['genres'],
            expandKeys: <String>['genres'],
            many: true,
          );
        }
        if (normalizedRelation == 'editors') {
          return const _RelationSpec(
            collectionId: 'editors',
            sourceKeys: <String>['editors', 'editor'],
            expandKeys: <String>['editors', 'editor'],
            many: true,
          );
        }
        break;
      case 'sub_series':
        if (normalizedRelation == 'volumes') {
          return const _RelationSpec(
            collectionId: 'volumes',
            sourceKeys: <String>['volumes'],
            expandKeys: <String>['volumes'],
            many: true,
          );
        }
        if (normalizedRelation == 'authors') {
          return const _RelationSpec(
            collectionId: 'authors',
            sourceKeys: <String>['authors'],
            expandKeys: <String>['authors'],
            many: true,
          );
        }
        if (normalizedRelation == 'editors') {
          return const _RelationSpec(
            collectionId: 'editors',
            sourceKeys: <String>['editors', 'editor'],
            expandKeys: <String>['editors', 'editor'],
            many: false,
          );
        }
        if (normalizedRelation == 'series') {
          return const _RelationSpec(
            collectionId: 'series',
            sourceKeys: <String>['series', 'serie'],
            expandKeys: <String>['series', 'serie'],
            many: false,
          );
        }
        break;
      case 'volumes':
        if (normalizedRelation == 'sub_series') {
          return const _RelationSpec(
            collectionId: 'sub_series',
            sourceKeys: <String>['subSeries', 'sub_series', 'sub_series_id'],
            expandKeys: <String>['subSeries', 'sub_series', 'sub_serie'],
            many: false,
          );
        }
        if (normalizedRelation == 'series') {
          return const _RelationSpec(
            collectionId: 'series',
            sourceKeys: <String>['series', 'serie'],
            expandKeys: <String>['series', 'serie'],
            many: false,
          );
        }
        if (normalizedRelation == 'editors') {
          return const _RelationSpec(
            collectionId: 'editors',
            sourceKeys: <String>['editors', 'editor'],
            expandKeys: <String>['editors', 'editor'],
            many: false,
          );
        }
        if (normalizedRelation == 'authors') {
          return const _RelationSpec(
            collectionId: 'authors',
            sourceKeys: <String>['authors'],
            expandKeys: <String>['authors'],
            many: true,
          );
        }
        break;
      case 'authors':
        if (normalizedRelation == 'series') {
          return const _RelationSpec(
            collectionId: 'series',
            sourceKeys: <String>['series'],
            expandKeys: <String>['series'],
            many: true,
          );
        }
        if (normalizedRelation == 'sub_series') {
          return const _RelationSpec(
            collectionId: 'sub_series',
            sourceKeys: <String>['subSeries', 'sub_series'],
            expandKeys: <String>['subSeries', 'sub_series'],
            many: true,
          );
        }
        break;
      case 'editors':
        if (normalizedRelation == 'series') {
          return const _RelationSpec(
            collectionId: 'series',
            sourceKeys: <String>['series'],
            expandKeys: <String>['series'],
            many: true,
          );
        }
        if (normalizedRelation == 'sub_series') {
          return const _RelationSpec(
            collectionId: 'sub_series',
            sourceKeys: <String>['subSeries', 'sub_series'],
            expandKeys: <String>['subSeries', 'sub_series'],
            many: true,
          );
        }
        break;
    }

    return null;
  }

  String _normalizeRelationName(String relation) {
    switch (relation) {
      case 'sub-series':
      case 'subseries':
      case 'subSerie':
      case 'sub_serie':
      case 'sub_series':
      case 'subSeries':
        return 'sub_series';
      case 'serie':
      case 'series':
        return 'series';
      case 'editor':
      case 'editors':
        return 'editors';
      case 'volume':
        return 'volume';
      case 'volumes':
        return 'volumes';
      default:
        return relation;
    }
  }

  Map<String, dynamic> _normalizeSeries(Map<String, dynamic> raw) {
    final id = _extractId(raw);
    final subSeries = _relationIds(raw['subSeries'] ?? raw['sub_series']);
    final expand = _cloneExpandMap(raw['expand']);

    return <String, dynamic>{
      'id': id,
      'title': raw['title'] ?? raw['titleFr'] ?? '',
      'titleFr': raw['titleFr'] ?? raw['title'] ?? '',
      'titleJp': raw['titleJp'] ?? '',
      'titleEn': raw['titleEn'] ?? '',
      'slug': raw['slug']?.toString() ?? '',
      'altTitles': _toStringList(
        raw['altTitles'] ?? raw['alternativeTitles'] ?? raw['aliases'],
      ),
      'image': _normalizeImageUrl(raw['coverUrl'] ?? raw['image']),
      'coverUrl': _normalizeImageUrl(raw['coverUrl'] ?? raw['image']),
      'sub_series': subSeries,
      'subSeries': subSeries,
      'authors': _relationIds(raw['authors']),
      'genres': _relationIds(raw['genres']),
      'editors': _relationIds(raw['editors']),
      if (expand.isNotEmpty) 'expand': expand,
      'over18': _toBool(raw['over18']),
      'firstPublication': _toIsoDate(raw['firstPublicationDate']),
      'created': raw[r'$createdAt'] ?? raw['created'],
      'updated': raw[r'$updatedAt'] ?? raw['updated'],
    };
  }

  Map<String, dynamic> _normalizeSubSeries(Map<String, dynamic> raw) {
    final id = _extractId(raw);
    final expand = _cloneExpandMap(raw['expand']);
    return <String, dynamic>{
      'id': id,
      'title': raw['title'] ?? raw['titleFr'] ?? '',
      'titleFr': raw['titleFr'] ?? raw['title'] ?? '',
      'titleJp': raw['titleJp'] ?? '',
      'titleEn': raw['titleEn'] ?? '',
      'image': _normalizeImageUrl(raw['coverUrl'] ?? raw['image']),
      'coverUrl': _normalizeImageUrl(raw['coverUrl'] ?? raw['image']),
      'volumes': _relationIds(raw['volumes']),
      'authors': _relationIds(raw['authors']),
      'editor': _relationId(raw['editors'] ?? raw['editor']) ?? '',
      'editors': _relationId(raw['editors'] ?? raw['editor']) ?? '',
      'serie': _relationId(raw['series'] ?? raw['serie']) ?? '',
      'series': _relationId(raw['series'] ?? raw['serie']) ?? '',
      'genres': _relationIds(raw['genres']),
      'support': raw['type'] ?? raw['support'] ?? 'manga',
      if (expand.isNotEmpty) 'expand': expand,
      'status': raw['status'] ?? 'Unknown',
      'over18': _toBool(raw['over18']),
      'firstPublication': _toIsoDate(raw['firstPublicationDate']),
      'created': raw[r'$createdAt'] ?? raw['created'],
      'updated': raw[r'$updatedAt'] ?? raw['updated'],
    };
  }

  Map<String, dynamic> _normalizeVolume(Map<String, dynamic> raw) {
    final id = _extractId(raw);
    final expand = _cloneExpandMap(raw['expand']);

    final parsedInfo = _parseJsonObject(raw['infoVolume'] ?? raw['info']);
    final parsedLinks = _parseJsonList(raw['bookLink'] ?? raw['book_link']);
    final contains = _toStringList(raw['contain'] ?? raw['contains']);

    return <String, dynamic>{
      'id': id,
      'title': raw['title'] ?? raw['titleFr'] ?? '',
      'titleFr': raw['titleFr'] ?? raw['title'] ?? '',
      'titleJp': raw['titleJp'] ?? '',
      'titleEn': raw['titleEn'] ?? '',
      'tome_number': raw['tomeNumber'] ?? raw['tome_number'],
      'price': raw['price'] ?? -1,
      'image': _normalizeImageUrl(raw['coverUrl'] ?? raw['image']),
      'coverUrl': _normalizeImageUrl(raw['coverUrl'] ?? raw['image']),
      'over18': _toBool(raw['over18']),
      'resume': raw['resume'] ?? '',
      'release': _toIsoDate(raw['publicationDate'] ?? raw['release']),
      'publicationDate': _toIsoDate(raw['publicationDate'] ?? raw['release']),
      'ean': raw['ean'],
      'language': raw['language']?.toString() ?? 'french',
      'sub_series': _relationId(raw['subSeries'] ?? raw['sub_series']) ?? '',
      'sub_series_id': _relationId(raw['subSeries'] ?? raw['sub_series']) ?? '',
      'series': _relationId(raw['series'] ?? raw['serie']) ?? '',
      'serie': _relationId(raw['series'] ?? raw['serie']) ?? '',
      'editor': _relationId(raw['editor'] ?? raw['editors']) ?? '',
      'editors': _relationId(raw['editor'] ?? raw['editors']) ?? '',
      'authors': _relationIds(raw['authors']),
      'contains': contains,
      'contain': contains,
      if (expand.isNotEmpty) 'expand': expand,
      'info': parsedInfo,
      'book_link': parsedLinks,
      'support': raw['support']?.toString() ?? raw['type']?.toString() ?? 'manga',
      'genre_jap': raw['genderJp'] ?? raw['genre_jap'],
      'created': raw[r'$createdAt'] ?? raw['created'],
      'updated': raw[r'$updatedAt'] ?? raw['updated'],
    };
  }

  Map<String, dynamic> _normalizeAuthor(Map<String, dynamic> raw) {
    final id = _extractId(raw);
    final jobs = raw['jobs'];
    final jobValue = jobs is List ? jobs.map((e) => e.toString()).join(', ') : raw['job']?.toString() ?? '';
    final subSeries = _relationIds(raw['subSeries'] ?? raw['sub_series']);
    final expand = _cloneExpandMap(raw['expand']);

    return <String, dynamic>{
      'id': id,
      'name': raw['name'] ?? '',
      'image': _normalizeImageUrl(raw['coverUrl'] ?? raw['image']),
      'coverUrl': _normalizeImageUrl(raw['coverUrl'] ?? raw['image']),
      'series': _relationIds(raw['series']),
      'sub_series': subSeries,
      'subSeries': subSeries,
      if (expand.isNotEmpty) 'expand': expand,
      'job': jobValue,
      'created': raw[r'$createdAt'] ?? raw['created'],
      'updated': raw[r'$updatedAt'] ?? raw['updated'],
    };
  }

  Map<String, dynamic> _normalizeEditor(Map<String, dynamic> raw) {
    final id = _extractId(raw);
    final subSeries = _relationIds(raw['subSeries'] ?? raw['sub_series']);
    final expand = _cloneExpandMap(raw['expand']);

    return <String, dynamic>{
      'id': id,
      'name': raw['name'] ?? '',
      'image': _normalizeImageUrl(raw['coverUrl'] ?? raw['image']),
      'logo': _normalizeImageUrl(
        raw['coverUrl'] ?? raw['logo'] ?? raw['image'],
      ),
      'coverUrl': _normalizeImageUrl(
        raw['coverUrl'] ?? raw['image'] ?? raw['logo'],
      ),
      'series': _relationIds(raw['series']),
      'sub_series': subSeries,
      'subSeries': subSeries,
      if (expand.isNotEmpty) 'expand': expand,
      'created': raw[r'$createdAt'] ?? raw['created'],
      'updated': raw[r'$updatedAt'] ?? raw['updated'],
    };
  }

  Map<String, dynamic> _normalizeGenre(Map<String, dynamic> raw) {
    final id = _extractId(raw);
    final expand = _cloneExpandMap(raw['expand']);
    return <String, dynamic>{
      'id': id,
      'name': raw['name'] ?? '',
      'series': _relationIds(raw['series']),
      if (expand.isNotEmpty) 'expand': expand,
      'created': raw[r'$createdAt'] ?? raw['created'],
      'updated': raw[r'$updatedAt'] ?? raw['updated'],
    };
  }

  Map<String, dynamic> _normalizeOwnedEntry(Map<String, dynamic> raw) {
    final id = _extractId(raw);
    final volumeId = raw['volumeId']?.toString() ?? _relationId(raw['volume'] ?? raw['volumes']) ?? '';
    final expand = _cloneExpandMap(raw['expand']);

    final data = <String, dynamic>{
      'id': id,
      'user': _connectedUser.valueOrNull?.id ?? '',
      'volume': volumeId,
      'readed': raw['readed'] ?? false,
      'lended': raw['lended'] ?? false,
      'lendedLabel': raw['lendedLabel'],
      'created': raw[r'$createdAt'] ?? raw['created'],
      'updated': raw[r'$updatedAt'] ?? raw['updated'],
    };

    final expandedVolume = raw['volume'] ?? raw['volumes'] ?? expand['volume'] ?? expand['volumes'];
    if (expandedVolume is Map<String, dynamic>) {
      expand['volume'] = _normalizeVolume(expandedVolume);
    }
    if (expand.isNotEmpty) {
      data['expand'] = expand;
    }

    return data;
  }

  Map<String, dynamic> _normalizeFollowedEntry(Map<String, dynamic> raw) {
    final id = _extractId(raw);
    final subSeriesId =
        raw['subSeriesId']?.toString() ??
        _relationId(
          raw['subSeries'] ?? raw['sub_series'] ?? raw['sub_serie'],
        ) ??
        '';
    final expand = _cloneExpandMap(raw['expand']);

    final data = <String, dynamic>{
      'id': id,
      'user': _connectedUser.valueOrNull?.id ?? '',
      'sub_serie': subSeriesId,
      'created': raw[r'$createdAt'] ?? raw['created'],
      'updated': raw[r'$updatedAt'] ?? raw['updated'],
    };

    final expandedSubSeries = raw['subSeries'] ?? expand['subSeries'] ?? expand['sub_series'] ?? expand['sub_serie'];
    if (expandedSubSeries is Map<String, dynamic>) {
      final sub = _normalizeSubSeries(expandedSubSeries);
      expand['sub_serie'] = sub;
      expand['sub_series'] = sub;
    }
    if (expand.isNotEmpty) {
      data['expand'] = expand;
    }

    return data;
  }

  String _extractId(Map<String, dynamic> raw) {
    return (raw[r'$id'] ?? raw['id'] ?? '').toString();
  }

  List<String> _relationIds(dynamic value) {
    if (value == null) return <String>[];

    if (value is List) {
      final ids = <String>[];
      for (final item in value) {
        final id = _relationId(item);
        if (id != null && id.isNotEmpty) {
          ids.add(id);
        }
      }
      return ids;
    }

    final single = _relationId(value);
    if (single == null || single.isEmpty) return <String>[];
    return <String>[single];
  }

  String? _relationId(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final normalized = value.trim();
      if (normalized.isEmpty || normalized == 'null' || normalized == 'undefined') {
        return null;
      }
      return normalized;
    }
    if (value is num) return value.toString();
    if (value is List) {
      for (final item in value) {
        final id = _relationId(item);
        if (id != null && id.isNotEmpty) {
          return id;
        }
      }
      return null;
    }
    if (value is Map<String, dynamic>) {
      final id = value[r'$id'] ?? value['id'];
      if (id != null && id.toString().trim().isNotEmpty) {
        return id.toString();
      }
      final nestedKeys = <String>['value', 'record', 'document'];
      for (final key in nestedKeys) {
        final nested = _relationId(value[key]);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
      return null;
    }
    if (value is Map) {
      return _relationId(Map<String, dynamic>.from(value));
    }
    return value.toString();
  }

  List<String> _toStringList(dynamic value) {
    if (value == null) return <String>[];
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return <String>[];
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
        }
      } catch (_) {
        // Keep plain string fallback.
      }
      return <String>[trimmed];
    }
    return <String>[value.toString()];
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }

  String? _toIsoDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toUtc().toIso8601String();
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return null;
    return parsed.toUtc().toIso8601String();
  }

  int _toIntOrDefault(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  String _normalizeImageUrl(dynamic raw) {
    final value = raw?.toString().trim() ?? '';
    if (value.isEmpty) return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('//')) {
      return 'https:$value';
    }

    if (value.startsWith('/')) {
      return '$serverUrl$value';
    }

    return value;
  }

  Map<String, dynamic>? _parseJsonObject(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return <String, dynamic>{'raw': value};
      }
    }
    return null;
  }

  dynamic _cloneExpandValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value.map(
        (key, nested) => MapEntry(key, _cloneExpandValue(nested)),
      );
    }
    if (value is Map) {
      return value.map(
        (key, nested) => MapEntry(key.toString(), _cloneExpandValue(nested)),
      );
    }
    if (value is List) {
      return value.map(_cloneExpandValue).toList();
    }
    return value;
  }

  Map<String, dynamic> _cloneExpandMap(dynamic value) {
    final cloned = _cloneExpandValue(value);
    if (cloned is Map<String, dynamic>) return cloned;
    if (cloned is Map) return Map<String, dynamic>.from(cloned);
    return <String, dynamic>{};
  }

  List<dynamic> _parseJsonList(dynamic value) {
    if (value == null) return <dynamic>[];
    if (value is List) return value;
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded;
        }
      } catch (_) {
        return <dynamic>[value];
      }
    }
    return <dynamic>[value];
  }
}

class AppwriteCompatClient {
  AppwriteCompatClient();

  AppwriteCompatCollection collection(String collectionId) {
    return AppwriteCompatCollection(collectionId);
  }
}

class AppwriteCompatCollection {
  AppwriteCompatCollection(this._collectionId);

  final String _collectionId;

  CompatSubscription subscribe(String topic, Function(dynamic) callback) {
    Timer? timer;

    timer = Timer.periodic(const Duration(seconds: 15), (_) async {
      callback(
        RecordSubscriptionEvent(collectionId: _collectionId, action: 'poll'),
      );
    });

    return CompatSubscription(() {
      timer?.cancel();
    });
  }
}
