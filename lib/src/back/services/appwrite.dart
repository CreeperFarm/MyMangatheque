import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:mymangatheque/environment.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/api/mobile_api_client.dart';
import 'package:mymangatheque/src/back/services/analytics/promotion_tracking_service.dart';
import 'package:mymangatheque/src/back/services/appwrite_client.dart';
import 'package:mymangatheque/src/back/services/cache/persistent_cache_store.dart';
import 'package:mymangatheque/src/back/services/models/api_record_model.dart';
import 'package:mymangatheque/src/back/services/notifications/notification_service.dart';
import 'package:mymangatheque/src/back/services/sync/realtime_sync_service.dart';
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

void _appLog({required String en, required String fr}) {
  RuntimeLocalization.debug(en: en, fr: fr);
}

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

class AddVolumeToOwnedResult {
  const AddVolumeToOwnedResult({
    required this.wasAlreadyOwned,
    required this.subSeriesFollowed,
    this.followError,
  });

  final bool wasAlreadyOwned;
  final bool subSeriesFollowed;
  final Object? followError;
}

class _RecordListCacheEntry {
  const _RecordListCacheEntry(this.records, this.cachedAt);

  final List<RecordModel> records;
  final DateTime cachedAt;
}

class _RecordCacheEntry {
  const _RecordCacheEntry(this.data, this.cachedAt);

  final Map<String, dynamic> data;
  final DateTime cachedAt;
}

class _RecordPageCacheEntry {
  const _RecordPageCacheEntry(this.page, this.cachedAt);

  final RecordPage page;
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
  static const Duration _recordCacheTtl = Duration(minutes: 2);
  static const Duration _homePersistentCacheTtl = Duration(minutes: 30);

  AppwriteConnector._internal();

  static final AppwriteConnector _singleton = AppwriteConnector._internal();

  factory AppwriteConnector() => _singleton;

  final AppwriteClientService _appwrite = AppwriteClientService();
  final MobileApiClient _api = MobileApiClient();
  final NotificationService _notifications = NotificationService();
  final PersistentCacheStore _persistentCache = PersistentCacheStore();
  final RealtimeSyncService _realtimeSync = RealtimeSyncService();

  final BehaviorSubject<User?> _connectedUser = BehaviorSubject<User?>();
  final Map<String, _RecordListCacheEntry> _fullListCache =
      <String, _RecordListCacheEntry>{};
  final Map<String, Future<List<RecordModel>>> _fullListInFlight =
      <String, Future<List<RecordModel>>>{};
  final Map<String, _RecordCacheEntry> _recordCache =
      <String, _RecordCacheEntry>{};
  final Map<String, Future<Map<String, dynamic>>> _recordInFlight =
      <String, Future<Map<String, dynamic>>>{};
  final Map<String, _RecordPageCacheEntry> _recordPageCache =
      <String, _RecordPageCacheEntry>{};
  final Map<String, Future<RecordPage>> _recordPageInFlight =
      <String, Future<RecordPage>>{};
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
      _appLog(
        en: 'Mobile API key initialization failed: $e',
        fr: 'L’initialisation de la clé API mobile a échoué : $e',
      );
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
    await _notifications.synchronizePushTargetIfEnabled();
  }

  bool isLoggedIn() {
    return _connectedUser.valueOrNull != null;
  }

  Stream<User?> listenToUserChanges() => _connectedUser.stream;

  User? getConnectedUser() => _connectedUser.valueOrNull;

  Stream<List<InAppNotification>> listenToNotifications() {
    return _notifications.stream;
  }

  List<InAppNotification> get notifications => _notifications.notifications;

  int get unreadNotificationCount => _notifications.unreadCount;

  void markAllNotificationsOpened() => _notifications.markAllOpened();

  void clearNotifications() => _notifications.clearInApp();

  void openNotification(String notificationId) {
    _notifications.openNotification(notificationId);
  }

  void markNotificationOpened(String notificationId) {
    _notifications.markOpened(notificationId);
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

  Future<List<RecordModel>> getOwned(
    String userId,
    String expand, {
    bool forceRefresh = false,
  }) async {
    final requestedExpand = expand.trim();
    final cacheKey = _fullListCacheKey(
      'owned',
      expand: requestedExpand,
      scope: userId,
    );

    if (forceRefresh) {
      _invalidateCollectionCache('owned');
    }

    final cached = _fullListCache[cacheKey];
    if (!forceRefresh && _isCacheEntryFresh(cached)) {
      return _cloneRecords(cached!.records);
    }

    final inFlight = _fullListInFlight[cacheKey];
    if (!forceRefresh && inFlight != null) {
      return _cloneRecords(await inFlight);
    }

    final future = () async {
      dynamic response;
      try {
        response = await _getOwnedResponse(requestedExpand);
      } catch (e) {
        _appLog(
          en: 'Unable to load the owned collection: $e',
          fr: 'Impossible de charger la collection possédée : $e',
        );
        return <RecordModel>[];
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _appLog(
          en: 'Owned collection request failed with HTTP ${response.statusCode}.',
          fr: 'La requête de collection possédée a échoué avec le statut HTTP ${response.statusCode}.',
        );
        if (requestedExpand.isEmpty) return <RecordModel>[];

        try {
          response = await _getOwnedResponse('');
        } catch (e) {
          _appLog(
            en: 'Owned collection retry without relationships failed: $e',
            fr: 'La nouvelle tentative sans relations de la collection possédée a échoué : $e',
          );
          return <RecordModel>[];
        }

        if (response.statusCode < 200 || response.statusCode >= 300) {
          _appLog(
            en: 'Owned collection retry failed with HTTP ${response.statusCode}.',
            fr: 'La nouvelle tentative de collection possédée a échoué avec le statut HTTP ${response.statusCode}.',
          );
          return <RecordModel>[];
        }
      }

      final decoded = _api.decodeBody(response);
      final list = _extractUserCollectionList(decoded, 'ownedVolumes');

      if (list.isEmpty) {
        _appLog(
          en: 'The owned collection response contains no items.',
          fr: 'La réponse de collection possédée ne contient aucun élément.',
        );
        return <RecordModel>[];
      }

      final records = <RecordModel>[];
      for (final raw
          in list.map(_asRecordMap).whereType<Map<String, dynamic>>()) {
        var normalized = _normalizeOwnedEntry(raw);
        if (requestedExpand.isNotEmpty) {
          normalized = await _appendExpand(
            'owned',
            normalized,
            requestedExpand,
          );
        }

        final id =
            (raw[r'$id'] ??
                    raw['id'] ??
                    normalized['id'] ??
                    normalized['volume'] ??
                    '')
                .toString();
        if (id.isEmpty) continue;

        records.add(
          RecordModel(
            id: id,
            collectionId: 'owned',
            data: normalized,
          ),
        );
      }

      _fullListCache[cacheKey] = _RecordListCacheEntry(
        _cloneRecords(records),
        DateTime.now(),
      );
      return records;
    }();

    _fullListInFlight[cacheKey] = future;
    try {
      return _cloneRecords(await future);
    } finally {
      _fullListInFlight.remove(cacheKey);
    }
  }

  Future<dynamic> _getOwnedResponse(String expand) {
    return _api.get(
      '/api/users/me/owned',
      requiresApiKey: true,
      requiresBearer: true,
      query: <String, dynamic>{
        if (expand.trim().isNotEmpty) 'expand': expand,
      },
    );
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
      _appLog(
        en: 'Unable to fetch the current user profile: $e',
        fr: 'Impossible de récupérer le profil utilisateur actuel : $e',
      );
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
        username: accountUser.name.isNotEmpty
            ? accountUser.name
            : accountUser.email.split('@').first,
        email: accountUser.email,
        gender: 'other',
        avatar: null,
        birthday: now,
        created: DateTime.tryParse(accountUser.$createdAt)?.toUtc() ?? now,
        updated: DateTime.tryParse(accountUser.$updatedAt)?.toUtc() ?? now,
      );
    } catch (e) {
      _appLog(
        en: 'Unable to fetch the fallback account profile: $e',
        fr: 'Impossible de récupérer le profil de compte de secours : $e',
      );
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
      final webRedirectStarted = await _appwrite.loginWithGoogle();
      if (webRedirectStarted) return;
      await _api.invalidateApiKey();
      await _syncConnectedUser();
      await _api.ensureApiKey();
      await _notifications.synchronizePushTargetIfEnabled();
      if (context.mounted) {
        pushOrGo(context, '/profile');
      }
    } catch (e) {
      final cancelled = e.toString().contains('PlatformException(CANCELED');
      if (cancelled) {
        _appLog(
          en: 'Google sign-in was cancelled.',
          fr: 'La connexion Google a été annulée.',
        );
        return;
      }
      if (context.mounted) {
        showMessage(AppLocalizations.of(context)!.errorOccurred, context);
      }
      _appLog(
        en: 'Google sign-in failed: $e',
        fr: 'La connexion Google a échoué : $e',
      );
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
      await _notifications.synchronizePushTargetIfEnabled();

      if (context.mounted) {
        showMessage(AppLocalizations.of(context)!.userLoginSuccess, context);
      }
      return _connectedUser.valueOrNull;
    } catch (e) {
      if (context.mounted) {
        showMessage(AppLocalizations.of(context)!.errorOccurred, context);
      }
      _appLog(
        en: 'Email sign-in failed: $e',
        fr: 'La connexion par e-mail a échoué : $e',
      );
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
      throw Exception(
        RuntimeLocalization.text(
          en: 'Password and confirmation do not match.',
          fr: 'Le mot de passe et sa confirmation ne correspondent pas.',
        ),
      );
    }

    final created = await _appwrite.createAccount(
      email: email.toLowerCase(),
      password: password,
      name: username,
    );

    if (!context.mounted) {
      return created.$id;
    }
    final loggedInUser = await loginWithEmail(email, password, context);
    if (loggedInUser == null) {
      throw StateError(
        RuntimeLocalization.text(
          en: 'The account was created but sign-in did not complete.',
          fr: 'Le compte a été créé, mais la connexion n’a pas abouti.',
        ),
      );
    }

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
      _appLog(
        en: 'Unable to complete the profile after sign-up: $e',
        fr: 'Impossible de compléter le profil après l’inscription : $e',
      );
    }

    await sendVerification(email);

    return created.$id;
  }

  Future<void> sendVerification(String email) async {
    try {
      await _appwrite.sendEmailVerification();
    } catch (e) {
      _appLog(
        en: 'Email verification request failed: $e',
        fr: 'La demande de vérification de l’e-mail a échoué : $e',
      );
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
    await logOut();
  }

  Future<void> logOut() async {
    final signedOutUserId = _connectedUser.valueOrNull?.id;
    _connectedUser.add(null);
    _clearCollectionCaches();
    if (signedOutUserId != null) {
      unawaited(_persistentCache.clear(scope: signedOutUserId));
    }
    unawaited(_persistentCache.clear(scope: 'authenticated'));
    await _api.invalidateApiKey();
    await _notifications.unregisterPushTarget();
    await _appwrite.logoutCurrentSession();

    final localStorage = LocalStorage();
    await localStorage.deleteToken();
    await localStorage.deleteOwnedSubSerie(userId: signedOutUserId);
    // Remove the former unscoped cache left by older application versions.
    await localStorage.deleteOwnedSubSerie();
  }

  void _invalidateCollectionCache(String collectionId) {
    final normalized = _normalizeCollectionId(collectionId);
    unawaited(_persistentCache.clearNamespace('catalogue.$normalized'));
    _fullListCache.removeWhere(
      (key, _) => key == normalized || key.startsWith('$normalized|'),
    );
    _fullListInFlight.removeWhere(
      (key, _) => key == normalized || key.startsWith('$normalized|'),
    );
    _recordCache.removeWhere((key, _) => key.startsWith('$normalized:'));
    _recordInFlight.removeWhere((key, _) => key.startsWith('$normalized:'));
    _recordPageCache.clear();
    _recordPageInFlight.clear();
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
    _recordCache.clear();
    _recordInFlight.clear();
    _recordPageCache.clear();
    _recordPageInFlight.clear();
    _ownedVolumeIdsIndex = null;
    _ownedReadStateIndex = null;
    _followedSubSeriesIdsIndex = null;
  }

  bool _isCacheEntryFresh(_RecordListCacheEntry? entry) {
    if (entry == null) return false;
    return DateTime.now().difference(entry.cachedAt) <= _fullListCacheTtl;
  }

  String _fullListCacheKey(
    String collectionId, {
    String? expand,
    String? scope,
  }) {
    final normalized = _normalizeCollectionId(collectionId);
    final normalizedExpand = expand?.trim() ?? '';
    final normalizedScope = scope?.trim() ?? '';
    if (normalizedExpand.isEmpty && normalizedScope.isEmpty) return normalized;

    final parts = <String>[
      normalized,
      if (normalizedScope.isNotEmpty) 'scope:$normalizedScope',
      if (normalizedExpand.isNotEmpty) 'expand:$normalizedExpand',
    ];
    return parts.join('|');
  }

  bool _isRecordCacheEntryFresh(_RecordCacheEntry? entry) {
    if (entry == null) return false;
    return DateTime.now().difference(entry.cachedAt) <= _recordCacheTtl;
  }

  bool _isRecordPageCacheEntryFresh(_RecordPageCacheEntry? entry) {
    if (entry == null) return false;
    return DateTime.now().difference(entry.cachedAt) <= _fullListCacheTtl;
  }

  String _recordCacheKey(String collectionId, String id, String? expand) {
    return '${_normalizeCollectionId(collectionId)}:$id:${expand?.trim() ?? ''}';
  }

  Map<String, dynamic> _cloneRecordData(Map<String, dynamic> data) {
    final cloned = _cloneExpandValue(data);
    if (cloned is Map<String, dynamic>) return cloned;
    if (cloned is Map) return Map<String, dynamic>.from(cloned);
    return Map<String, dynamic>.from(data);
  }

  List<RecordModel> _cloneRecords(List<RecordModel> records) {
    return records
        .map(
          (record) => RecordModel(
            id: record.id,
            collectionId: record.collectionId,
            data: _cloneRecordData(record.data),
          ),
        )
        .toList();
  }

  RecordPage _cloneRecordPage(RecordPage page) {
    return RecordPage(
      items: _cloneRecords(page.items),
      page: page.page,
      totalPages: page.totalPages,
      totalItems: page.totalItems,
    );
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

    final hasAuthenticatedSession = await _appwrite
        .hasAuthenticatedUserSession();
    if (!hasAuthenticatedSession) {
      _appLog(
        en: 'Avatar upload skipped: no authenticated session.',
        fr: 'Envoi de l’avatar ignoré : aucune session authentifiée.',
      );
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
      _appLog(
        en: 'Avatar update failed: $e. Verify authenticated create/write storage permissions.',
        fr: 'La mise à jour de l’avatar a échoué : $e. Vérifiez les permissions de création/écriture du stockage pour les utilisateurs authentifiés.',
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
        _appLog(
          en: 'Avatar upload response parsing failed; continuing with the generated file identifier.',
          fr: 'L’analyse de la réponse d’envoi de l’avatar a échoué ; poursuite avec l’identifiant de fichier généré.',
        );
      } else {
        _appLog(
          en: 'Avatar update failed: $e',
          fr: 'La mise à jour de l’avatar a échoué : $e',
        );
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
      _appLog(
        en: 'The avatar was uploaded but the profile update failed: $e',
        fr: 'L’avatar a été envoyé, mais la mise à jour du profil a échoué : $e',
      );
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
    bool forceRefresh = false,
  }) async {
    final normalizedUntilDays = untilDays.clamp(0, 365);
    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit < 1 ? 30 : limit;
    final hasAuthenticatedSession = await _appwrite
        .hasAuthenticatedUserSession();
    final authenticatedUserId = getConnectedUser()?.id.trim();
    final canPersist =
        !hasAuthenticatedSession || authenticatedUserId?.isNotEmpty == true;
    final userKey = hasAuthenticatedSession
        ? (authenticatedUserId?.isNotEmpty == true
              ? authenticatedUserId!
              : 'session-uncached')
        : 'public';
    final cacheKey =
        'home:$userKey:page:$safePage:limit:$safeLimit:days:$normalizedUntilDays';
    final persistentNamespace =
        'recommendations.home.page.$safePage.limit.$safeLimit.days.$normalizedUntilDays';
    final persistentEntry = canPersist
        ? await _persistentCache.read(
            persistentNamespace,
            scope: userKey,
          )
        : null;

    final cached = _recordPageCache[cacheKey];
    if (!forceRefresh && _isRecordPageCacheEntryFresh(cached)) {
      return _cloneRecordPage(cached!.page);
    }
    if (!forceRefresh && persistentEntry?.isFresh == true) {
      final restored = _recordPageFromCache(persistentEntry!.data);
      if (restored != null) {
        _recordPageCache[cacheKey] = _RecordPageCacheEntry(
          _cloneRecordPage(restored),
          DateTime.now(),
        );
        return restored;
      }
    }

    final inFlight = _recordPageInFlight[cacheKey];
    if (!forceRefresh && inFlight != null) {
      return _cloneRecordPage(await inFlight);
    }

    final future = () async {
      try {
        RecordPage result;
        if (hasAuthenticatedSession) {
          try {
            result = await _fetchRecordPage(
              path: '/api/recommendations/me',
              listKey: 'volumes',
              collectionId: 'volumes',
              normalize: _normalizeVolume,
              page: safePage,
              limit: safeLimit,
              query: <String, dynamic>{
                'untilDays': normalizedUntilDays,
                'includeExplanations': true,
                'includePlacements': true,
              },
              requiresApiKey: true,
              requiresBearer: true,
              forceRefresh: forceRefresh,
              usePersistentCache: false,
            );
            await _saveHomeRecommendations(
              cacheKey,
              persistentNamespace,
              userKey,
              result,
              persist: canPersist,
            );
            return result;
          } catch (e) {
            _appLog(
              en: 'Personalized recommendations are unavailable; using public recommendations: $e',
              fr: 'Les recommandations personnalisées sont indisponibles ; utilisation des recommandations publiques : $e',
            );
          }
        }

        result = await _fetchRecordPage(
          path: '/api/recommendations/home',
          listKey: 'volumes',
          collectionId: 'volumes',
          normalize: _normalizeVolume,
          page: safePage,
          limit: safeLimit,
          query: <String, dynamic>{
            'untilDays': normalizedUntilDays,
            'includePlacements': true,
          },
          requiresApiKey: true,
          forceRefresh: forceRefresh,
          usePersistentCache: false,
        );
        await _saveHomeRecommendations(
          cacheKey,
          persistentNamespace,
          userKey,
          result,
          persist: canPersist,
        );
        return result;
      } catch (error) {
        final restored = _recordPageFromCache(persistentEntry?.data);
        if (restored != null) {
          _appLog(
            en: 'The recommendation API is unavailable; using the persistent cache.',
            fr: 'L’API de recommandations est indisponible ; utilisation du cache persistant.',
          );
          return restored;
        }
        rethrow;
      }
    }();

    _recordPageInFlight[cacheKey] = future;
    try {
      return _cloneRecordPage(await future);
    } finally {
      _recordPageInFlight.remove(cacheKey);
    }
  }

  Future<RecordPage?> getCachedHomeRecommendationsPage({
    int page = 1,
    int limit = 30,
    int untilDays = 7,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit < 1 ? 30 : limit;
    final normalizedUntilDays = untilDays.clamp(0, 365);
    final authenticated = await _appwrite.hasAuthenticatedUserSession();
    final authenticatedUserId = getConnectedUser()?.id.trim();
    if (authenticated && authenticatedUserId?.isNotEmpty != true) return null;
    final scope = authenticated ? authenticatedUserId! : 'public';
    final namespace =
        'recommendations.home.page.$safePage.limit.$safeLimit.days.$normalizedUntilDays';
    final entry = await _persistentCache.read(namespace, scope: scope);
    return _recordPageFromCache(entry?.data);
  }

  Future<void> _saveHomeRecommendations(
    String memoryKey,
    String persistentNamespace,
    String scope,
    RecordPage page, {
    bool persist = true,
  }) async {
    _recordPageCache[memoryKey] = _RecordPageCacheEntry(
      _cloneRecordPage(page),
      DateTime.now(),
    );
    if (persist) {
      await _persistentCache.write(
        persistentNamespace,
        _recordPageToCache(page),
        scope: scope,
        ttl: _homePersistentCacheTtl,
      );
    }
  }

  Map<String, dynamic> _recordPageToCache(RecordPage page) {
    return <String, dynamic>{
      'page': page.page,
      'totalPages': page.totalPages,
      'totalItems': page.totalItems,
      'items': page.items
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'collectionId': item.collectionId,
              'data': item.data,
            },
          )
          .toList(),
    };
  }

  List<Map<String, dynamic>> _recordListToCache(
    Iterable<RecordModel> records,
  ) {
    return records
        .map(
          (record) => <String, dynamic>{
            'id': record.id,
            'collectionId': record.collectionId,
            'data': record.data,
          },
        )
        .toList();
  }

  List<RecordModel> _recordListFromCache(Object? raw) {
    if (raw is! List) return <RecordModel>[];
    try {
      return raw
          .whereType<Map>()
          .map((item) {
            final record = Map<String, dynamic>.from(item);
            return RecordModel(
              id: record['id'].toString(),
              collectionId: record['collectionId']?.toString() ?? '',
              data: Map<String, dynamic>.from(record['data'] as Map),
            );
          })
          .where((record) {
            return record.id.isNotEmpty && record.collectionId.isNotEmpty;
          })
          .toList();
    } on Object {
      return <RecordModel>[];
    }
  }

  RecordPage? _recordPageFromCache(Object? raw) {
    if (raw is! Map) return null;
    try {
      final data = Map<String, dynamic>.from(raw);
      final itemsRaw = data['items'];
      if (itemsRaw is! List) return null;
      final items = itemsRaw.whereType<Map>().map((item) {
        final record = Map<String, dynamic>.from(item);
        return RecordModel(
          id: record['id'].toString(),
          collectionId: record['collectionId']?.toString() ?? 'volumes',
          data: Map<String, dynamic>.from(record['data'] as Map),
        );
      }).toList();
      return RecordPage(
        items: items,
        page: _toIntOrDefault(data['page'], 1),
        totalPages: _toIntOrDefault(data['totalPages'], 1),
        totalItems: _toIntOrDefault(data['totalItems'], items.length),
      );
    } on Object catch (error) {
      _appLog(
        en: 'Unable to restore cached recommendations: $error',
        fr: 'Impossible de restaurer les recommandations en cache : $error',
      );
      return null;
    }
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

  Future<RecordModel?> getVolumeByEan(String ean, {String? expand}) async {
    final normalizedEan = _normalizeEanValue(ean);
    if (normalizedEan.length != 13) {
      throw const FormatException('EAN must contain exactly 13 digits');
    }
    final expandValue = expand?.trim() ?? '';
    final signature = base64Url
        .encode(utf8.encode('$normalizedEan|$expandValue'))
        .replaceAll('=', '');
    final namespace = 'catalogue.volumes.ean.$signature';
    final cachedEntry = await _persistentCache.read(
      namespace,
      maxStale: const Duration(days: 30),
    );
    final cachedVolume = _asRecordMap(cachedEntry?.data);

    try {
      final response = await _api.get(
        '/api/volumes/search/ean',
        query: <String, dynamic>{
          'ean': normalizedEan,
          if (expandValue.isNotEmpty) 'expand': expandValue,
        },
        requiresApiKey: true,
      );

      if (response.statusCode == 404) {
        await _persistentCache.remove(namespace);
        return null;
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'EAN lookup failed (status ${response.statusCode}): ${response.body}',
        );
      }

      final decoded = _api.decodeBody(response);
      final root = _asRecordMap(decoded);
      final data = _asRecordMap(root?['data']);
      final volumeMap = _asRecordMap(data?['volume']);
      if (volumeMap == null) {
        throw const FormatException('Invalid EAN lookup response');
      }

      final normalized = _normalizeVolume(volumeMap);
      final id = normalized['id']?.toString() ?? '';
      if (id.isEmpty) {
        throw const FormatException('Volume returned without an id');
      }
      await _persistentCache.write(
        namespace,
        normalized,
        ttl: const Duration(days: 1),
      );
      return RecordModel(
        id: id,
        collectionId: 'volumes',
        data: normalized,
      );
    } on Object catch (error, stackTrace) {
      final cachedId = cachedVolume?['id']?.toString() ?? '';
      if (cachedVolume != null && cachedId.isNotEmpty) {
        _appLog(
          en: 'The EAN service is unavailable; using persistent cached data.',
          fr: 'Le service EAN est indisponible ; utilisation des données persistantes en cache.',
        );
        return RecordModel(
          id: cachedId,
          collectionId: 'volumes',
          data: cachedVolume,
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  String _normalizeEanValue(dynamic value) {
    if (value == null) return '';
    if (value is int) return value.toString();
    if (value is num) return value.toInt().toString();

    var raw = value.toString().trim();
    if (raw.isEmpty || raw == '-1' || raw == '-2') return '';

    final decimalMatch = RegExp(r'^(\d+)\.0+$').firstMatch(raw);
    if (decimalMatch != null) {
      raw = decimalMatch.group(1) ?? raw;
    }

    return raw.replaceAll(RegExp(r'\D'), '');
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
    bool forceRefresh = false,
    bool usePersistentCache = true,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit < 1 ? 30 : limit;
    final requestQuery = <String, dynamic>{
      'page': safePage,
      'limit': safeLimit,
      ...?query,
    };
    final sortedQueryEntries = requestQuery.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final signature = base64Url
        .encode(
          utf8.encode(
            '$path|${jsonEncode(Map<String, dynamic>.fromEntries(sortedQueryEntries))}',
          ),
        )
        .replaceAll('=', '');
    final persistentNamespace =
        'catalogue.${_normalizeCollectionId(collectionId)}.pages.$signature';
    final authenticatedUserId = getConnectedUser()?.id.trim();
    final canUsePersistentCache =
        usePersistentCache &&
        (!requiresBearer || authenticatedUserId?.isNotEmpty == true);
    final persistentScope = requiresBearer
        ? (authenticatedUserId ?? 'uncached')
        : 'public';
    final persistentEntry = canUsePersistentCache
        ? await _persistentCache.read(
            persistentNamespace,
            scope: persistentScope,
            maxStale: const Duration(days: 30),
          )
        : null;
    final persistentPage = _recordPageFromCache(persistentEntry?.data);
    if (!forceRefresh &&
        persistentEntry?.isFresh == true &&
        persistentPage != null) {
      return persistentPage;
    }

    try {
      final response = await _api.get(
        path,
        query: requestQuery,
        requiresApiKey: requiresApiKey,
        requiresBearer: requiresBearer,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'HTTP ${response.statusCode} while loading $collectionId',
        );
      }

      final decoded = _api.decodeBody(response);
      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          RuntimeLocalization.text(
            en: 'The API returned an unexpected response.',
            fr: 'L’API a renvoyé une réponse inattendue.',
          ),
        );
      }

      final data = decoded['data'];
      final dataMap = data is Map<String, dynamic> ? data : <String, dynamic>{};
      final rows =
          dataMap[listKey] ??
          decoded[listKey] ??
          (dataMap.length == 1 ? dataMap.values.first : null);
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
      final pagination = paginationRaw is Map<String, dynamic>
          ? paginationRaw
          : <String, dynamic>{};

      final totalItemsFromPagination = _toIntOrDefault(
        pagination['totalItems'] ??
            pagination['total'] ??
            pagination['count'] ??
            pagination['totalCount'],
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
      final result = RecordPage(
        items: records,
        page: currentPage,
        totalPages: totalPages < 1 ? 1 : totalPages,
        totalItems: totalItemsFromPagination,
      );
      if (canUsePersistentCache) {
        await _persistentCache.write(
          persistentNamespace,
          _recordPageToCache(result),
          scope: persistentScope,
          ttl: requiresBearer
              ? const Duration(minutes: 15)
              : path.contains('/search')
              ? const Duration(minutes: 15)
              : const Duration(hours: 6),
        );
      }
      return result;
    } on Object catch (error, stackTrace) {
      if (persistentPage != null) {
        _appLog(
          en: 'The catalogue page is unavailable; using persistent cached data.',
          fr: 'La page du catalogue est indisponible ; utilisation des données persistantes en cache.',
        );
        return persistentPage;
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<List<RecordModel>> getCollectionFullList(
    String collectionId, {
    String? expand,
  }) async {
    final normalized = _normalizeCollectionId(collectionId);
    final requestedExpand = expand?.trim() ?? '';
    final cacheKey = _fullListCacheKey(normalized, expand: requestedExpand);

    final cached = _fullListCache[cacheKey];
    if (_isCacheEntryFresh(cached)) {
      return _cloneRecords(cached!.records);
    }

    final inFlight = _fullListInFlight[cacheKey];
    if (inFlight != null) {
      return _cloneRecords(await inFlight);
    }

    final privateCollection = normalized == 'owned' || normalized == 'followed';
    final authenticatedUserId = getConnectedUser()?.id.trim();
    final canUsePersistentCache =
        !privateCollection || authenticatedUserId?.isNotEmpty == true;
    final persistentScope = privateCollection
        ? (authenticatedUserId ?? 'uncached')
        : 'public';
    final expandKey = base64Url
        .encode(utf8.encode(requestedExpand))
        .replaceAll('=', '');
    final persistentNamespace =
        'catalogue.$normalized.full.${expandKey.isEmpty ? 'default' : expandKey}';
    final persistentEntry = canUsePersistentCache
        ? await _persistentCache.read(
            persistentNamespace,
            scope: persistentScope,
            maxStale: const Duration(days: 30),
          )
        : null;
    final persistentRecords = _recordListFromCache(persistentEntry?.data);

    final future = () async {
      try {
        final list = await _fetchCollectionNormalized(
          normalized,
          fullList: true,
          expand: requestedExpand.isEmpty ? null : requestedExpand,
        );
        final records = list
            .map(
              (item) => RecordModel(
                id: item['id'].toString(),
                collectionId: normalized,
                data: item,
              ),
            )
            .toList();
        final shouldCacheEmpty = privateCollection;
        if (records.isNotEmpty || shouldCacheEmpty) {
          _fullListCache[cacheKey] = _RecordListCacheEntry(
            _cloneRecords(records),
            DateTime.now(),
          );
          if (canUsePersistentCache) {
            await _persistentCache.write(
              persistentNamespace,
              _recordListToCache(records),
              scope: persistentScope,
              ttl: privateCollection
                  ? const Duration(minutes: 15)
                  : const Duration(hours: 6),
            );
          }
        } else {
          _fullListCache.remove(cacheKey);
        }
        return records;
      } on Object catch (_) {
        if (persistentRecords.isNotEmpty) {
          _appLog(
            en: 'The catalogue API is unavailable; using persistent cached data.',
            fr: 'L’API du catalogue est indisponible ; utilisation des données persistantes en cache.',
          );
          _fullListCache[cacheKey] = _RecordListCacheEntry(
            _cloneRecords(persistentRecords),
            DateTime.now(),
          );
          return persistentRecords;
        }
        rethrow;
      }
    }();

    _fullListInFlight[cacheKey] = future;
    try {
      return _cloneRecords(await future);
    } finally {
      _fullListInFlight.remove(cacheKey);
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
    final normalized = _normalizeCollectionId(collectionId);
    if (query.trim().isEmpty) {
      return getCollectionFullList(normalized, expand: expand);
    }

    final list = await _fetchCollectionNormalized(
      normalized,
      fullList: true,
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

  Stream<List<RecordModel>> getCollectionDataListener(String collectionId) {
    final subject = PublishSubject<List<RecordModel>>();

    final subscription = listenToCollectionEvents(collectionId).listen((
      _,
    ) async {
      _invalidateCollectionCache(collectionId);
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
    final normalized = _normalizeCollectionId(collectionId);
    return _realtimeSync.watch(normalized).map((event) {
      _invalidateCollectionCache(normalized);
      return event;
    });
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
      _appLog(
        en: 'Unable to load the analytics summary: $e',
        fr: 'Impossible de charger le résumé des statistiques : $e',
      );
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
      _appLog(
        en: 'Unable to load monthly analytics: $e',
        fr: 'Impossible de charger les statistiques mensuelles : $e',
      );
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

  Future<List<RecordModel>> getSubSeriesVolumes(
    String id, {
    RecordModel? sourceVolume,
  }) async {
    final volumesById = <String, RecordModel>{};
    final volumeIds = <String>{};

    void collectVolumes(dynamic value) {
      for (final volumeMap in _expandedRecordMaps(value)) {
        final normalized = _normalizeVolume(volumeMap);
        final volumeId = normalized['id']?.toString() ?? '';
        if (volumeId.isEmpty) continue;
        volumesById[volumeId] = RecordModel(
          id: volumeId,
          collectionId: 'volumes',
          data: normalized,
        );
      }
      volumeIds.addAll(_relationIds(value));
    }

    final sourceExpand = _asRecordMap(sourceVolume?.data['expand']);
    for (final key in const <String>[
      'subSeries',
      'subseries',
      'sub_series',
      'sub_serie',
    ]) {
      final expandedSubSeries = _asRecordMap(sourceExpand?[key]);
      if (expandedSubSeries == null) continue;
      final expandedSubSeriesRelations = _asRecordMap(
        expandedSubSeries['expand'],
      );
      collectVolumes(
        expandedSubSeriesRelations?['volumes'] ?? expandedSubSeries['volumes'],
      );
    }

    try {
      final subSeries = await getOneExpand('sub_series', id, '[volumes]');
      if (subSeries.isNotEmpty) {
        final data = subSeries.first.data;
        final expand = _asRecordMap(data['expand']);
        collectVolumes(expand?['volumes'] ?? data['volumes']);
      }
    } catch (error) {
      _appLog(
        en: 'Unable to load related volumes for a sub-series: $error',
        fr: 'Impossible de charger les volumes liés à une sous-série : $error',
      );
    }

    final missingVolumeIds = volumeIds.where(
      (volumeId) => !volumesById.containsKey(volumeId),
    );
    final missingVolumes = await Future.wait(
      missingVolumeIds.map((volumeId) async {
        try {
          return await _fetchOneNormalized('volumes', volumeId);
        } catch (error) {
          _appLog(
            en: 'Unable to load a related volume: $error',
            fr: 'Impossible de charger un volume associé : $error',
          );
          return null;
        }
      }),
    );
    for (final volumeMap in missingVolumes.whereType<Map<String, dynamic>>()) {
      final volumeId = volumeMap['id']?.toString() ?? '';
      if (volumeId.isEmpty) continue;
      volumesById[volumeId] = RecordModel(
        id: volumeId,
        collectionId: 'volumes',
        data: volumeMap,
      );
    }

    return volumesById.values.toList();
  }

  Future<List<String>> getSubSerieVolumesImages(String id) async {
    final subSeries = await getOneExpand('sub_series', id, 'volumes');
    final volumes =
        (subSeries.first.data['expand']?['volumes'] as List?) ??
        const <dynamic>[];

    final sorted =
        List<Map<String, dynamic>>.from(
          volumes.whereType<Map<String, dynamic>>(),
        )..sort((a, b) {
          final aTome = (a['tome_number'] as num?) ?? 0;
          final bTome = (b['tome_number'] as num?) ?? 0;
          return aTome.compareTo(bTome);
        });

    return sorted
        .map((volume) => volume['image']?.toString() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
  }

  Future<void> _ensureOwnedIndexes() async {
    if (_ownedVolumeIdsIndex != null &&
        _ownedReadStateIndex != null &&
        _isCacheEntryFresh(_fullListCache['owned'])) {
      return;
    }

    final entries = await getCollectionFullList('owned');
    final ids = <String>{};
    final readState = <String, bool>{};

    for (final entry in entries) {
      final volumeId = _ownedEntryVolumeId(entry.data);
      if (volumeId.isEmpty) continue;
      ids.add(volumeId);
      readState[volumeId] = entry.data['readed'] == true;
    }

    _ownedVolumeIdsIndex = ids;
    _ownedReadStateIndex = readState;
  }

  Future<Set<String>> getOwnedVolumeIds({bool forceRefresh = false}) async {
    if (forceRefresh) {
      _invalidateCollectionCache('owned');
    }
    await _ensureOwnedIndexes();
    return Set<String>.from(_ownedVolumeIdsIndex ?? const <String>{});
  }

  String _ownedEntryVolumeId(Map<String, dynamic> data) {
    final direct =
        _relationId(data['volume']) ??
        data['volumeId']?.toString() ??
        _relationId(data['volumes']) ??
        '';
    if (direct.isNotEmpty && direct != 'null' && direct != 'undefined') {
      return direct;
    }

    final expand = _asRecordMap(data['expand']);
    final expandedVolume = _asRecordMap(
      expand?['volume'] ?? expand?['volumes'] ?? data['volumeData'],
    );
    return expandedVolume?['id']?.toString() ??
        expandedVolume?[r'$id']?.toString() ??
        '';
  }

  Future<void> _ensureFollowedIndex() async {
    if (_followedSubSeriesIdsIndex != null &&
        _isCacheEntryFresh(_fullListCache['followed'])) {
      return;
    }
    final entries = await getCollectionFullList('followed');
    _followedSubSeriesIdsIndex = entries
        .map((entry) => _followedEntrySubSeriesId(entry.data))
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  String _followedEntrySubSeriesId(Map<String, dynamic> data) {
    final expand = _asRecordMap(data['expand']);
    for (final candidate in <dynamic>[
      data['subSeriesId'],
      data['subSeries'],
      data['subSerie'],
      data['sub_series'],
      data['sub_serie'],
      expand?['subSeries'],
      expand?['subSerie'],
      expand?['sub_series'],
      expand?['sub_serie'],
    ]) {
      final id = _relationId(candidate);
      if (id != null && id.isNotEmpty) return id;
    }
    return '';
  }

  @visibleForTesting
  String followedEntrySubSeriesIdForTesting(Map<String, dynamic> data) {
    return _followedEntrySubSeriesId(data);
  }

  String followedEntrySubSeriesId(Map<String, dynamic> data) {
    return _followedEntrySubSeriesId(data);
  }

  Future<AddVolumeToOwnedResult> addVolumeToOwned(
    String userId,
    String volumeId,
    bool readState, {
    String? subSeriesId,
  }) async {
    final response = await _api.post(
      '/api/users/me/owned',
      requiresApiKey: true,
      requiresBearer: true,
      body: <String, dynamic>{'volumeId': volumeId, 'readed': readState},
    );
    final wasAlreadyOwned = _isAlreadyExistingResponse(
      response.statusCode,
      response.body,
    );
    if ((response.statusCode < 200 || response.statusCode >= 300) &&
        !wasAlreadyOwned) {
      throw Exception(
        'Unable to add volume to collection (status ${response.statusCode}): '
        '${response.body}',
      );
    }
    _invalidateCollectionCache('owned');
    if (!wasAlreadyOwned) {
      unawaited(
        PromotionTrackingService().trackConversionForVolume(volumeId),
      );
    }

    var normalizedSubSeriesId = subSeriesId?.trim() ?? '';
    if (normalizedSubSeriesId.isEmpty) {
      try {
        final volume = await _fetchOneNormalized('volumes', volumeId);
        normalizedSubSeriesId =
            _relationId(
              volume['subSeries'] ??
                  volume['subSeriesId'] ??
                  volume['sub_series'] ??
                  volume['sub_serie'],
            ) ??
            '';
      } catch (error) {
        _appLog(
          en: 'Unable to resolve the sub-series for an added volume: $error',
          fr: 'Impossible de déterminer la sous-série d’un volume ajouté : $error',
        );
      }
    }
    if (normalizedSubSeriesId.isEmpty) {
      return AddVolumeToOwnedResult(
        wasAlreadyOwned: wasAlreadyOwned,
        subSeriesFollowed: false,
      );
    }

    try {
      final alreadyFollowed = await isSubSeriesFollowed(
        userId,
        normalizedSubSeriesId,
      );
      if (!alreadyFollowed) {
        await addSubSeriesToFollowed(userId, normalizedSubSeriesId);
      }
      return AddVolumeToOwnedResult(
        wasAlreadyOwned: wasAlreadyOwned,
        subSeriesFollowed: true,
      );
    } catch (error) {
      _appLog(
        en: 'The volume was added, but its sub-series could not be followed: $error',
        fr: 'Le volume a été ajouté, mais sa sous-série n’a pas pu être suivie : $error',
      );
      return AddVolumeToOwnedResult(
        wasAlreadyOwned: wasAlreadyOwned,
        subSeriesFollowed: false,
        followError: error,
      );
    }
  }

  bool _isAlreadyExistingResponse(int statusCode, String body) {
    if (statusCode == 409) return true;
    if (statusCode != 400) return false;
    final normalizedBody = body.toLowerCase();
    return normalizedBody.contains('already exist') ||
        normalizedBody.contains('exists already') ||
        normalizedBody.contains('already owned') ||
        normalizedBody.contains('already followed') ||
        normalizedBody.contains('duplicate');
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
      _appLog(
        en: 'Unable to fetch the current user review: $e',
        fr: 'Impossible de récupérer l’avis de l’utilisateur actuel : $e',
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
      final reviews = response.rows
          .map<Map<String, dynamic>>((doc) => _normalizeReviewDocument(doc))
          .where((review) {
            final checked = review['commentChecked'] == true;
            final isPendingForUser =
                includePendingUser.isNotEmpty &&
                review['userId']?.toString() == includePendingUser;
            return checked || isPendingForUser;
          })
          .toList();

      return reviews;
    } catch (e) {
      _appLog(
        en: 'Unable to fetch volume reviews: $e',
        fr: 'Impossible de récupérer les avis du volume : $e',
      );
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
      throw Exception(
        RuntimeLocalization.text(
          en: 'You must be signed in to submit a review.',
          fr: 'Vous devez être connecté pour publier un avis.',
        ),
      );
    }

    final normalizedStars = stars.clamp(1, 5);
    final cleanedComment = comment.trim();
    final cleanedFavCharacters = favCharacters
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();

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
    final response = await _api.post(
      '/api/users/me/followed',
      requiresApiKey: true,
      requiresBearer: true,
      body: <String, dynamic>{'subSeriesId': subSeriesId},
    );
    final alreadyFollowed = _isAlreadyExistingResponse(
      response.statusCode,
      response.body,
    );
    if ((response.statusCode < 200 || response.statusCode >= 300) &&
        !alreadyFollowed) {
      throw Exception(
        'Unable to follow sub-series (status ${response.statusCode}): '
        '${response.body}',
      );
    }
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

  Future<String> get appVersion async =>
      (await PackageInfo.fromPlatform()).version;

  Future<String> get buildVersion async =>
      (await PackageInfo.fromPlatform()).buildNumber;

  String get serverUrl => 'https://api.mymangatheque.com';

  AppwriteCompatClient connector() => AppwriteCompatClient(this);

  ValueNotifier<RealtimeSyncMetrics> get realtimeSyncMetrics =>
      _realtimeSync.metrics;

  Future<void> registerPushTarget({
    required String deviceToken,
    required String targetId,
  }) {
    return _notifications.registerPushTarget(
      deviceToken: deviceToken,
      targetId: targetId,
    );
  }

  ValueNotifier<PushNotificationState> get pushNotificationState =>
      _notifications.state;

  Stream<String> listenToNotificationOpenRoutes() =>
      _notifications.openedRoutes;

  String? takePendingNotificationOpenRoute() =>
      _notifications.takePendingOpenRoute();

  Future<bool> enablePushNotifications() =>
      _notifications.requestPermissionAndEnable();

  Future<void> disablePushNotifications() =>
      _notifications.disablePushNotifications();

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
      case 'subSeries':
        return 'sub_series';
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
      _ => throw UnsupportedError(
        RuntimeLocalization.text(
          en: 'Unsupported collection.',
          fr: 'Collection non prise en charge.',
        ),
      ),
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
    final normalized = _normalizeCollectionId(collectionId);
    final cacheKey = _recordCacheKey(normalized, id, expand);
    final cached = _recordCache[cacheKey];
    if (_isRecordCacheEntryFresh(cached)) {
      return _cloneRecordData(cached!.data);
    }

    final privateCollection = normalized == 'owned' || normalized == 'followed';
    final authenticatedUserId = getConnectedUser()?.id.trim();
    final canUsePersistentCache =
        !privateCollection || authenticatedUserId?.isNotEmpty == true;
    final persistentScope = privateCollection
        ? (authenticatedUserId ?? 'uncached')
        : 'public';
    final persistentSignature = base64Url
        .encode(utf8.encode('$id|${expand?.trim() ?? ''}'))
        .replaceAll('=', '');
    final persistentNamespace =
        'catalogue.$normalized.details.$persistentSignature';
    final persistentEntry = canUsePersistentCache
        ? await _persistentCache.read(
            persistentNamespace,
            scope: persistentScope,
            maxStale: const Duration(days: 30),
          )
        : null;
    final persistentRecord = _asRecordMap(persistentEntry?.data);
    if (persistentEntry?.isFresh == true && persistentRecord != null) {
      _recordCache[cacheKey] = _RecordCacheEntry(
        _cloneRecordData(persistentRecord),
        DateTime.now(),
      );
      return _cloneRecordData(persistentRecord);
    }

    final inFlight = _recordInFlight[cacheKey];
    if (inFlight != null) {
      return _cloneRecordData(await inFlight);
    }

    final future = () async {
      try {
        final record = await _fetchOneNormalizedUncached(
          normalized,
          id,
          expand: expand,
        );
        if (record.isNotEmpty && canUsePersistentCache) {
          await _persistentCache.write(
            persistentNamespace,
            record,
            scope: persistentScope,
            ttl: privateCollection
                ? const Duration(minutes: 15)
                : const Duration(hours: 24),
          );
        }
        return record;
      } on Object catch (error, stackTrace) {
        if (persistentRecord != null && persistentRecord.isNotEmpty) {
          _appLog(
            en: 'The catalogue item is unavailable; using persistent cached data.',
            fr: 'La fiche du catalogue est indisponible ; utilisation des données persistantes en cache.',
          );
          return persistentRecord;
        }
        Error.throwWithStackTrace(error, stackTrace);
      }
    }();
    _recordInFlight[cacheKey] = future;
    try {
      final record = await future;
      if (record.isNotEmpty) {
        _recordCache[cacheKey] = _RecordCacheEntry(
          _cloneRecordData(record),
          DateTime.now(),
        );
      }
      return _cloneRecordData(record);
    } finally {
      _recordInFlight.remove(cacheKey);
    }
  }

  Future<Map<String, dynamic>> _fetchOneNormalizedUncached(
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
          (entry) =>
              entry['volume']?.toString() == id ||
              entry['id']?.toString() == id,
          orElse: () => <String, dynamic>{'id': id},
        ),
      'followed' =>
        (await _fetchCollectionNormalized(
          'followed',
          fullList: true,
          expand: expand,
        )).firstWhere(
          (entry) =>
              entry['sub_serie']?.toString() == id ||
              entry['id']?.toString() == id,
          orElse: () => <String, dynamic>{'id': id},
        ),
      _ => throw UnsupportedError(
        RuntimeLocalization.text(
          en: 'Unsupported collection.',
          fr: 'Collection non prise en charge.',
        ),
      ),
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
      query: expand == null || expand.trim().isEmpty
          ? null
          : <String, dynamic>{'expand': expand},
      requiresApiKey: requiresApiKey,
    );

    final decoded = _api.decodeBody(response);
    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        RuntimeLocalization.text(
          en: 'The API returned an unexpected response.',
          fr: 'L’API a renvoyé une réponse inattendue.',
        ),
      );
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
    if (rawExpand is Map) {
      return _cloneExpandValue(Map<String, dynamic>.from(rawExpand));
    }

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

    throw Exception(
      RuntimeLocalization.text(
        en: 'The API returned an unexpected item response.',
        fr: 'L’API a renvoyé une réponse d’élément inattendue.',
      ),
    );
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
                if (expand != null && expand.trim().isNotEmpty)
                  'expand': expand,
                if (filterQuery != null && filterQuery.trim().isNotEmpty)
                  'filter': filterQuery,
              },
              requiresApiKey: requiresApiKey,
            )
          : await () async {
              final response = await _api.get(
                path,
                query: <String, dynamic>{
                  'page': 1,
                  'limit': 20,
                  if (expand != null && expand.trim().isNotEmpty)
                    'expand': expand,
                  if (filterQuery != null && filterQuery.trim().isNotEmpty)
                    'filter': filterQuery,
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
        _appLog(
          en: 'The mobile API key is unavailable; attempting an offline fallback.',
          fr: 'La clé API mobile est indisponible ; tentative de repli hors ligne.',
        );
      }
      rethrow;
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map((raw) => normalize(raw))
        .toList();
  }

  Future<List<Map<String, dynamic>>> _fetchUserCollection(
    String path,
    String listKey, {
    required Map<String, dynamic> Function(Map<String, dynamic>) normalize,
    String? expand,
  }) async {
    final requestedExpand = expand?.trim() ?? '';
    dynamic response;
    try {
      response = await _api.get(
        path,
        query: requestedExpand.isEmpty
            ? null
            : <String, dynamic>{'expand': requestedExpand},
        requiresApiKey: true,
        requiresBearer: true,
      );
    } catch (e) {
      _appLog(
        en: 'Unable to load a user collection: $e',
        fr: 'Impossible de charger une collection utilisateur : $e',
      );
      rethrow;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (requestedExpand.isEmpty) {
        throw Exception(
          'User collection request failed with HTTP ${response.statusCode}.',
        );
      }

      try {
        response = await _api.get(
          path,
          requiresApiKey: true,
          requiresBearer: true,
        );
      } catch (e) {
        _appLog(
          en: 'User collection retry without relationships failed: $e',
          fr: 'La nouvelle tentative de collection utilisateur sans relations a échoué : $e',
        );
        rethrow;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'User collection request failed with HTTP ${response.statusCode}.',
        );
      }
    }

    final decoded = _api.decodeBody(response);
    final list = _extractUserCollectionList(decoded, listKey);
    if (list.isEmpty) return <Map<String, dynamic>>[];

    return list
        .map(_asRecordMap)
        .whereType<Map<String, dynamic>>()
        .map((raw) => normalize(raw))
        .toList();
  }

  List<dynamic> _extractUserCollectionList(dynamic decoded, String listKey) {
    if (decoded is List<dynamic>) return decoded;
    if (decoded is! Map<String, dynamic>) return const <dynamic>[];

    final exact = _findListByKeys(
      decoded,
      _userCollectionListKeys(listKey),
    );
    if (exact != null) return exact;

    final generic = _findListByKeys(
      decoded,
      const <String>{'items', 'results', 'rows', 'documents', 'records'},
    );
    if (generic != null) return generic;

    final data = decoded['data'];
    if (data is List) return List<dynamic>.from(data);

    return const <dynamic>[];
  }

  Set<String> _userCollectionListKeys(String listKey) {
    return switch (listKey) {
      'ownedVolumes' => const <String>{
        'ownedVolumes',
        'owned',
        'ownedMangas',
        'ownedManga',
        'ownedItems',
        'volumes',
      },
      'followedSubSeries' => const <String>{
        'followedSubSeries',
        'followed',
        'followedSeries',
        'subSeries',
        'sub_series',
      },
      _ => <String>{listKey},
    };
  }

  List<dynamic>? _findListByKeys(
    dynamic value,
    Set<String> keys, {
    int depth = 0,
  }) {
    if (depth > 6) return null;

    final map = _asRecordMap(value);
    if (map == null) return null;

    for (final key in keys) {
      if (!map.containsKey(key)) continue;
      final candidate = map[key];
      if (candidate is List) return List<dynamic>.from(candidate);
      final nested = _findListByKeys(candidate, keys, depth: depth + 1);
      if (nested != null) return nested;
    }

    for (final candidate in map.values) {
      final nested = _findListByKeys(candidate, keys, depth: depth + 1);
      if (nested != null) return nested;
    }

    return null;
  }

  Map<String, dynamic>? _asRecordMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  Future<Map<String, dynamic>> _appendExpand(
    String collectionId,
    Map<String, dynamic> record,
    String expand,
  ) async {
    final expandedRecord = Map<String, dynamic>.from(record);
    final normalizedExpand = expand
        .trim()
        .replaceFirst(RegExp(r'^\['), '')
        .replaceFirst(
          RegExp(r'\]$'),
          '',
        );
    final paths = normalizedExpand
        .split(',')
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .map(
          (path) => path
              .split('.')
              .map((part) => part.trim())
              .where((part) => part.isNotEmpty)
              .toList(),
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

    await Future.wait(
      _expandedRecordMaps(
        expandedValue,
      ).map(
        (nestedRecord) =>
            _appendExpandPath(spec.collectionId, nestedRecord, nestedPath),
      ),
    );
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
    if (value is Map) {
      return <Map<String, dynamic>>[Map<String, dynamic>.from(value)];
    }
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) => item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item),
          )
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  dynamic _normalizeExpandedValue(_RelationSpec spec, dynamic value) {
    final records = _expandedRecordMaps(value)
        .map((item) => _normalizeRecordForCollection(spec.collectionId, item))
        .toList();
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

    final records = (await Future.wait(
      ids.map((id) async {
        try {
          return await _fetchOneNormalized(spec.collectionId, id);
        } catch (e) {
          _appLog(
            en: 'Unable to expand a related catalogue record: $e',
            fr: 'Impossible de développer une relation du catalogue : $e',
          );
          return null;
        }
      }),
    )).whereType<Map<String, dynamic>>().toList();

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
        if (normalizedRelation == 'volume' || normalizedRelation == 'volumes') {
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
            sourceKeys: <String>[
              'subSeries',
              'subSeriesId',
              'subseries',
              'sub_series',
              'sub_serie',
              'sub_series_id',
            ],
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
    final rawSubSeries =
        raw['subSeries'] ??
        raw['subSeriesId'] ??
        raw['subseries'] ??
        raw['sub_series'] ??
        raw['sub_serie'] ??
        raw['sub_series_id'];
    Map<String, dynamic>? expandedSubSeries;
    for (final candidate in <dynamic>[
      raw['subSeries'],
      raw['subseries'],
      raw['sub_series'],
      raw['sub_serie'],
      expand['subSeries'],
      expand['subseries'],
      expand['sub_series'],
      expand['sub_serie'],
    ]) {
      expandedSubSeries = _asRecordMap(candidate);
      if (expandedSubSeries != null) break;
    }
    if (expandedSubSeries != null) {
      final subSeries = _normalizeSubSeries(expandedSubSeries);
      expand['subSeries'] = subSeries;
      expand['sub_series'] = subSeries;
      expand['sub_serie'] = subSeries;
    }

    final parsedInfo = _parseJsonObject(raw['infoVolume'] ?? raw['info']);
    final parsedLinks = _parseJsonList(raw['bookLink'] ?? raw['book_link']);
    final contains = _toStringList(raw['contain'] ?? raw['contains']);
    final subSeriesId =
        _relationId(rawSubSeries) ?? _relationId(expandedSubSeries) ?? '';

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
      'sub_series': subSeriesId,
      'subSeries': subSeriesId,
      'subSeriesId': subSeriesId,
      'sub_serie': subSeriesId,
      'sub_series_id': subSeriesId,
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
      'support':
          raw['support']?.toString() ?? raw['type']?.toString() ?? 'manga',
      'genre_jap': raw['genderJp'] ?? raw['genre_jap'],
      'created': raw[r'$createdAt'] ?? raw['created'],
      'updated': raw[r'$updatedAt'] ?? raw['updated'],
      if (raw['recommendationMeta'] != null)
        'recommendationMeta': raw['recommendationMeta'],
      if (raw['sponsorshipMeta'] != null)
        'sponsorshipMeta': raw['sponsorshipMeta'],
      if (raw['editorialMeta'] != null) 'editorialMeta': raw['editorialMeta'],
      if (raw['source'] != null) 'source': raw['source'],
    };
  }

  Map<String, dynamic> _normalizeAuthor(Map<String, dynamic> raw) {
    final id = _extractId(raw);
    final jobs = raw['jobs'];
    final jobValue = jobs is List
        ? jobs.map((e) => e.toString()).join(', ')
        : raw['job']?.toString() ?? '';
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
    final expand = _cloneExpandMap(raw['expand']);
    final rawVolume =
        raw['volume'] ??
        raw['volumes'] ??
        raw['volumeData'] ??
        raw['volumeRecord'] ??
        expand['volume'] ??
        expand['volumes'];
    final expandedVolume = _asRecordMap(rawVolume);
    final rawLooksLikeVolume =
        expandedVolume == null &&
        (raw.containsKey('tomeNumber') ||
            raw.containsKey('tome_number') ||
            raw.containsKey('ean') ||
            raw.containsKey('publicationDate')) &&
        (raw.containsKey('subSeries') ||
            raw.containsKey('sub_series') ||
            raw.containsKey('sub_serie'));
    final normalizedVolume = expandedVolume != null
        ? _normalizeVolume(expandedVolume)
        : rawLooksLikeVolume
        ? _normalizeVolume(raw)
        : null;
    final volumeId =
        raw['volumeId']?.toString() ??
        _relationId(rawVolume) ??
        normalizedVolume?['id']?.toString() ??
        '';

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

    if (normalizedVolume != null) {
      expand['volume'] = normalizedVolume;
      expand['volumes'] = normalizedVolume;
    }
    if (expand.isNotEmpty) {
      data['expand'] = expand;
    }

    return data;
  }

  Map<String, dynamic> _normalizeFollowedEntry(Map<String, dynamic> raw) {
    final id = _extractId(raw);
    final expand = _cloneExpandMap(raw['expand']);
    final subSeriesId = _followedEntrySubSeriesId(<String, dynamic>{
      ...raw,
      if (expand.isNotEmpty) 'expand': expand,
    });

    final data = <String, dynamic>{
      'id': id,
      'user': _connectedUser.valueOrNull?.id ?? '',
      'sub_serie': subSeriesId,
      'created': raw[r'$createdAt'] ?? raw['created'],
      'updated': raw[r'$updatedAt'] ?? raw['updated'],
    };

    final expandedSubSeries =
        raw['subSeries'] ??
        raw['subSerie'] ??
        raw['sub_series'] ??
        raw['sub_serie'] ??
        expand['subSeries'] ??
        expand['subSerie'] ??
        expand['sub_series'] ??
        expand['sub_serie'];
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
      if (normalized.isEmpty ||
          normalized == 'null' ||
          normalized == 'undefined') {
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
      return value
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return <String>[];
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          return decoded
              .map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList();
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
  AppwriteCompatClient(this._connector);

  final AppwriteConnector _connector;

  AppwriteCompatCollection collection(String collectionId) {
    return AppwriteCompatCollection(_connector, collectionId);
  }
}

class AppwriteCompatCollection {
  AppwriteCompatCollection(this._connector, this._collectionId);

  final AppwriteConnector _connector;
  final String _collectionId;

  CompatSubscription subscribe(String topic, Function(dynamic) callback) {
    final subscription = _connector
        .listenToCollectionEvents(_collectionId)
        .listen(callback);
    var cancelled = false;
    return CompatSubscription(() {
      if (cancelled) return;
      cancelled = true;
      unawaited(subscription.cancel());
    });
  }
}
