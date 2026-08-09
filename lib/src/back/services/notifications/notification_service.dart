import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/api/mobile_api_client.dart';
import 'package:mymangatheque/src/back/services/appwrite_client.dart';
import 'package:mymangatheque/environment.dart';
import 'package:mymangatheque/firebase_options.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum PushAuthorizationState { unavailable, notDetermined, denied, authorized }

class PushNotificationState {
  const PushNotificationState({
    required this.authorization,
    required this.enabled,
    this.busy = false,
    this.error,
  });

  const PushNotificationState.unavailable()
    : authorization = PushAuthorizationState.unavailable,
      enabled = false,
      busy = false,
      error = null;

  final PushAuthorizationState authorization;
  final bool enabled;
  final bool busy;
  final String? error;

  PushNotificationState copyWith({
    PushAuthorizationState? authorization,
    bool? enabled,
    bool? busy,
    String? error,
    bool clearError = false,
  }) {
    return PushNotificationState(
      authorization: authorization ?? this.authorization,
      enabled: enabled ?? this.enabled,
      busy: busy ?? this.busy,
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// Resolves notification deep links without allowing external URLs or access
/// to sensitive application routes such as authentication and administration.
class PushNotificationRouteResolver {
  PushNotificationRouteResolver._();

  static String? resolve(Map<String, dynamic> payload) {
    var candidate =
        payload['route']?.toString() ??
        payload['deepLink']?.toString() ??
        payload['deeplink']?.toString();
    candidate = candidate?.trim();

    if (candidate == null || candidate.isEmpty) {
      final volumeId = payload['volumeId']?.toString();
      final seriesId = payload['seriesId']?.toString();
      if (_isSafeIdentifier(volumeId)) {
        candidate = '/volume/$volumeId';
      } else if (_isSafeIdentifier(seriesId)) {
        candidate = '/serie/$seriesId';
      }
    }
    if (candidate == null ||
        !candidate.startsWith('/') ||
        candidate.startsWith('//')) {
      return null;
    }
    final uri = Uri.tryParse(candidate);
    if (uri == null ||
        uri.hasScheme ||
        uri.hasAuthority ||
        uri.fragment.isNotEmpty) {
      return null;
    }
    final segments = uri.pathSegments;
    if (segments.any(
      (segment) =>
          segment == '..' || segment.isEmpty || !_isSafeIdentifier(segment),
    )) {
      return null;
    }
    if (segments.isEmpty) return '/';
    const topLevel = <String>{'library', 'planning', 'search', 'profile'};
    const entityRoutes = <String>{
      'volume',
      'serie',
      'sub_serie',
      'editor',
      'author',
    };
    if (segments.length == 1 && topLevel.contains(segments.first)) {
      return uri.path;
    }
    if (segments.length == 2 &&
        segments.first == 'profile' &&
        segments.last == 'notifications') {
      return uri.path;
    }
    if (segments.length == 2 && entityRoutes.contains(segments.first)) {
      return uri.path;
    }
    if (segments.length == 3 &&
        segments.first == 'library' &&
        entityRoutes.contains(segments[1])) {
      return uri.path;
    }
    return null;
  }

  static bool _isSafeIdentifier(String? value) {
    return value != null && RegExp(r'^[A-Za-z0-9._~-]+$').hasMatch(value);
  }
}

class InAppNotification {
  const InAppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.openedAt,
    this.payload,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? openedAt;
  final Map<String, dynamic>? payload;

  InAppNotification copyWith({DateTime? openedAt}) {
    return InAppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      openedAt: openedAt ?? this.openedAt,
      payload: payload,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'body': body,
    'createdAt': createdAt.toUtc().toIso8601String(),
    if (openedAt != null) 'openedAt': openedAt!.toUtc().toIso8601String(),
    if (payload != null) 'payload': payload,
  };

  static InAppNotification? tryFromJson(dynamic value) {
    if (value is! Map) return null;
    try {
      final json = Map<String, dynamic>.from(value);
      final id = json['id']?.toString().trim() ?? '';
      final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
      if (id.isEmpty || createdAt == null) return null;
      final rawPayload = json['payload'];
      return InAppNotification(
        id: id,
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        createdAt: createdAt,
        openedAt: DateTime.tryParse(json['openedAt']?.toString() ?? ''),
        payload: rawPayload is Map
            ? Map<String, dynamic>.from(rawPayload)
            : null,
      );
    } catch (_) {
      return null;
    }
  }
}

class NotificationService {
  NotificationService._internal({
    Future<void> Function(
      String eventName,
      InAppNotification notification,
      int? latencyMs,
    )?
    lifecycleReporter,
    DateTime Function()? clock,
    bool persistLocalState = true,
  }) : _lifecycleReporter = lifecycleReporter,
       _clock = clock ?? DateTime.now,
       _persistLocalState = persistLocalState;

  static final NotificationService _singleton = NotificationService._internal();

  factory NotificationService() => _singleton;

  factory NotificationService.forTesting({
    required Future<void> Function(
      String eventName,
      InAppNotification notification,
      int? latencyMs,
    )
    lifecycleReporter,
    DateTime Function()? clock,
  }) {
    return NotificationService._internal(
      lifecycleReporter: lifecycleReporter,
      clock: clock,
      persistLocalState: false,
    );
  }

  final AppwriteClientService _appwriteClient = AppwriteClientService();
  final MobileApiClient _apiClient = MobileApiClient();

  final StreamController<List<InAppNotification>> _controller =
      StreamController<List<InAppNotification>>.broadcast();
  final StreamController<String> _openRouteController =
      StreamController<String>.broadcast();
  final List<InAppNotification> _notifications = <InAppNotification>[];
  final Future<void> Function(
    String eventName,
    InAppNotification notification,
    int? latencyMs,
  )?
  _lifecycleReporter;
  final DateTime Function() _clock;
  final bool _persistLocalState;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Timer? _pollingTimer;
  Timer? _lifecycleRetryTimer;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _initialized = false;
  bool _flushingLifecycle = false;
  int _lifecycleRetryAttempt = 0;
  int _fallbackPollingAttempt = 0;
  String? _pendingOpenRoute;
  final Map<String, Map<String, dynamic>> _pendingLifecycleEvents =
      <String, Map<String, dynamic>>{};

  static const String _enabledPreferenceKey = 'pushNotificationsEnabled.v1';
  static const String _targetIdPreferenceKey = 'appwritePushTargetId.v1';
  static const String _inboxPreferenceKey = 'notificationInbox.v2';
  static const String _lifecycleQueuePreferenceKey =
      'notificationLifecycleQueue.v1';
  static const int _maximumInboxLength = 100;
  static const String _androidChannelId = 'mymangatheque_notifications';
  static const String _androidChannelName = 'MyMangatheque notifications';

  final ValueNotifier<PushNotificationState> state =
      ValueNotifier<PushNotificationState>(
        DefaultFirebaseOptions.isSupported
            ? const PushNotificationState(
                authorization: PushAuthorizationState.notDetermined,
                enabled: false,
              )
            : const PushNotificationState.unavailable(),
      );

  Stream<List<InAppNotification>> get stream => _controller.stream;

  Stream<String> get openedRoutes => _openRouteController.stream;

  List<InAppNotification> get notifications =>
      List<InAppNotification>.unmodifiable(_notifications);

  int get unreadCount => _notifications
      .where((notification) => notification.openedAt == null)
      .length;

  Future<void> init() async {
    if (_initialized) return;
    await _appwriteClient.init();
    await _apiClient.init();
    await _restoreLocalState();
    unawaited(_flushLifecycleEvents());
    if (!DefaultFirebaseOptions.isSupported) {
      state.value = const PushNotificationState.unavailable();
      _initialized = true;
      return;
    }

    await _initializeLocalNotifications();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: false,
            badge: false,
            sound: false,
          );
    }
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      (message) => unawaited(_handleForegroundMessage(message)),
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleOpenedRemoteMessage,
    );
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((token) => unawaited(_handleTokenRefresh(token)));

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleOpenedRemoteMessage(initialMessage);
    }
    await refreshState();
    _initialized = true;
    unawaited(synchronizePushTargetIfEnabled());
  }

  Future<void> registerPushTarget({
    required String deviceToken,
    required String targetId,
  }) async {
    await init();
    await _appwriteClient.registerPushTarget(
      targetId: targetId,
      identifier: deviceToken,
    );
  }

  /// Persists and reports a message received while the mobile application is
  /// suspended without initializing UI-only notification listeners.
  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    await _apiClient.init();
    await _restoreLocalState();
    ingestIncomingPush(_payloadFromRemoteMessage(message));
  }

  Future<PushNotificationState> refreshState() async {
    if (!DefaultFirebaseOptions.isSupported) {
      state.value = const PushNotificationState.unavailable();
      return state.value;
    }
    final preferences = await SharedPreferences.getInstance();
    final enabled = preferences.getBool(_enabledPreferenceKey) ?? false;
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    state.value = PushNotificationState(
      authorization: _mapAuthorization(settings.authorizationStatus),
      enabled: enabled && _isAuthorized(settings.authorizationStatus),
    );
    return state.value;
  }

  /// Requests the operating-system/browser permission from a user gesture,
  /// obtains the FCM token and associates it with the current Appwrite user.
  Future<bool> requestPermissionAndEnable() async {
    if (!DefaultFirebaseOptions.isSupported || state.value.busy) return false;
    state.value = state.value.copyWith(busy: true, clearError: true);
    try {
      if (!await _appwriteClient.hasAuthenticatedUserSession()) {
        throw StateError(
          RuntimeLocalization.text(
            en: 'Sign in before enabling notifications.',
            fr: 'Connectez-vous avant d’activer les notifications.',
          ),
        );
      }
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      if (!_isAuthorized(settings.authorizationStatus)) {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setBool(_enabledPreferenceKey, false);
        state.value = PushNotificationState(
          authorization: _mapAuthorization(settings.authorizationStatus),
          enabled: false,
        );
        return false;
      }

      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_enabledPreferenceKey, true);
      await _synchronizePushTarget();
      state.value = const PushNotificationState(
        authorization: PushAuthorizationState.authorized,
        enabled: true,
      );
      return true;
    } catch (error) {
      RuntimeLocalization.debug(
        en: 'Push notification activation failed: $error',
        fr: 'L’activation des notifications push a échoué : $error',
      );
      state.value = state.value.copyWith(
        busy: false,
        error: error.toString(),
      );
      return false;
    }
  }

  Future<void> synchronizePushTargetIfEnabled() async {
    if (!DefaultFirebaseOptions.isSupported) return;
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_enabledPreferenceKey) != true) return;
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (!_isAuthorized(settings.authorizationStatus)) {
      await preferences.setBool(_enabledPreferenceKey, false);
      await refreshState();
      return;
    }
    if (!await _appwriteClient.hasAuthenticatedUserSession()) return;

    try {
      await _synchronizePushTarget();
      state.value = const PushNotificationState(
        authorization: PushAuthorizationState.authorized,
        enabled: true,
      );
    } catch (error) {
      RuntimeLocalization.debug(
        en: 'Push target synchronization will be retried: $error',
        fr: 'La synchronisation de la cible push sera réessayée : $error',
      );
      state.value = state.value.copyWith(error: error.toString());
    }
  }

  Future<void> disablePushNotifications() async {
    if (state.value.busy) return;
    state.value = state.value.copyWith(busy: true, clearError: true);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enabledPreferenceKey, false);
    await unregisterPushTarget(deleteFcmToken: true);
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    state.value = PushNotificationState(
      authorization: _mapAuthorization(settings.authorizationStatus),
      enabled: false,
    );
  }

  Future<void> unregisterPushTarget({bool deleteFcmToken = false}) async {
    if (!DefaultFirebaseOptions.isSupported) return;
    final preferences = await SharedPreferences.getInstance();
    final targetId = preferences.getString(_targetIdPreferenceKey);
    if (targetId != null && targetId.isNotEmpty) {
      try {
        await _appwriteClient.deletePushTarget(targetId: targetId);
      } catch (error) {
        // A missing/expired session or an already deleted target is harmless;
        // a fresh target ID is generated on the next sign-in.
        RuntimeLocalization.debug(
          en: 'Push target cleanup was skipped: $error',
          fr: 'Le nettoyage de la cible push a été ignoré : $error',
        );
      }
      await preferences.remove(_targetIdPreferenceKey);
    }
    if (deleteFcmToken) {
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (error) {
        RuntimeLocalization.debug(
          en: 'FCM token cleanup was skipped: $error',
          fr: 'Le nettoyage du jeton FCM a été ignoré : $error',
        );
      }
    }
  }

  String? takePendingOpenRoute() {
    final route = _pendingOpenRoute;
    _pendingOpenRoute = null;
    return route;
  }

  void ingestIncomingPush(Map<String, dynamic> payload) {
    final title =
        payload['title']?.toString() ??
        RuntimeLocalization.text(en: 'Notification', fr: 'Notification');
    final body = payload['body']?.toString() ?? '';
    final now = _clock();
    final deliveredAt =
        DateTime.tryParse(
          (payload['deliveredAt'] ?? payload['delivered_at'] ?? '').toString(),
        ) ??
        now;
    final notificationId =
        payload['notificationId']?.toString() ??
        payload['notification_id']?.toString() ??
        payload['id']?.toString() ??
        '${now.microsecondsSinceEpoch}';

    final existingIndex = _notifications.indexWhere(
      (item) => item.id == notificationId,
    );
    final existing = existingIndex < 0 ? null : _notifications[existingIndex];
    final notification = InAppNotification(
      id: notificationId,
      title: title,
      body: body,
      createdAt: deliveredAt,
      openedAt: existing?.openedAt,
      payload: payload,
    );
    if (existingIndex >= 0) _notifications.removeAt(existingIndex);
    _notifications.insert(0, notification);
    if (_notifications.length > _maximumInboxLength) {
      _notifications.removeRange(_maximumInboxLength, _notifications.length);
    }

    _controller.add(List<InAppNotification>.unmodifiable(_notifications));
    _persistInbox();
    if (existing == null) {
      unawaited(_trackLifecycle('notification.received', notification));
    }
  }

  void markOpened(String notificationId) {
    final index = _notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );
    if (index < 0 || _notifications[index].openedAt != null) return;

    final openedAt = _clock();
    final notification = _notifications[index].copyWith(openedAt: openedAt);
    _notifications[index] = notification;
    _controller.add(List<InAppNotification>.unmodifiable(_notifications));
    _persistInbox();
    unawaited(
      _trackLifecycle(
        'notification.opened',
        notification,
        latencyMs: openedAt.isBefore(notification.createdAt)
            ? 0
            : openedAt.difference(notification.createdAt).inMilliseconds,
      ),
    );
  }

  void markAllOpened() {
    final openedAt = _clock();
    var changed = false;
    for (var index = 0; index < _notifications.length; index++) {
      if (_notifications[index].openedAt != null) continue;
      _notifications[index] = _notifications[index].copyWith(
        openedAt: openedAt,
      );
      changed = true;
    }
    if (!changed) return;
    _controller.add(List<InAppNotification>.unmodifiable(_notifications));
    _persistInbox();
  }

  void openNotification(String notificationId) {
    InAppNotification? selected;
    for (final notification in _notifications) {
      if (notification.id == notificationId) {
        selected = notification;
        break;
      }
    }
    if (selected == null) return;
    markOpened(notificationId);
    final route = PushNotificationRouteResolver.resolve(
      selected.payload ?? const <String, dynamic>{},
    );
    if (route == null) return;
    _pendingOpenRoute = route;
    _openRouteController.add(route);
  }

  void startFallbackPolling({Duration interval = const Duration(minutes: 5)}) {
    _pollingTimer?.cancel();
    _fallbackPollingAttempt = 0;
    _scheduleFallbackPoll(interval);
  }

  void _scheduleFallbackPoll(Duration minimumInterval) {
    final exponent = _fallbackPollingAttempt.clamp(0, 3);
    final multiplier = 1 << exponent;
    final requested = Duration(
      milliseconds: minimumInterval.inMilliseconds * multiplier,
    );
    const maximum = Duration(minutes: 30);
    final delay = requested > maximum ? maximum : requested;
    _pollingTimer = Timer(delay, () async {
      try {
        final response = await _apiClient.get(
          '/api/analytics/health',
          requiresApiKey: false,
        );
        if (response.statusCode < 200 || response.statusCode >= 300) {
          RuntimeLocalization.debug(
            en: 'Notification fallback heartbeat was rejected.',
            fr: 'Le signal de secours des notifications a été refusé.',
          );
        }
      } catch (e) {
        RuntimeLocalization.debug(
          en: 'Notification fallback polling failed: $e',
          fr: 'L’interrogation de secours des notifications a échoué : $e',
        );
      }
      _fallbackPollingAttempt = (_fallbackPollingAttempt + 1).clamp(0, 3);
      _scheduleFallbackPoll(minimumInterval);
    });
  }

  void stopFallbackPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void clearInApp() {
    _notifications.clear();
    _controller.add(List<InAppNotification>.unmodifiable(_notifications));
    _persistInbox();
  }

  void dispose() {
    stopFallbackPolling();
    _lifecycleRetryTimer?.cancel();
    unawaited(_foregroundSubscription?.cancel());
    unawaited(_openedSubscription?.cancel());
    unawaited(_tokenRefreshSubscription?.cancel());
    _controller.close();
    _openRouteController.close();
    state.dispose();
  }

  Future<void> _initializeLocalNotifications() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final encoded = response.payload;
        if (encoded == null || encoded.isEmpty) return;
        try {
          _handleOpenedPayload(
            Map<String, dynamic>.from(jsonDecode(encoded) as Map),
          );
        } catch (error) {
          RuntimeLocalization.debug(
            en: 'Invalid local notification payload ignored: $error',
            fr: 'Données de notification locale invalides ignorées : $error',
          );
        }
      },
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _androidChannelId,
              _androidChannelName,
              description:
                  'Collection updates, releases and account notifications.',
              importance: Importance.high,
            ),
          );
    }

    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    final encoded = launchDetails?.notificationResponse?.payload;
    if (launchDetails?.didNotificationLaunchApp == true &&
        encoded != null &&
        encoded.isNotEmpty) {
      try {
        _handleOpenedPayload(
          Map<String, dynamic>.from(jsonDecode(encoded) as Map),
        );
      } catch (_) {
        // The remote FCM initial-message handler remains the fallback.
      }
    }
  }

  Future<void> _synchronizePushTarget() async {
    final token = await _getFcmToken();
    if (token == null || token.isEmpty) {
      throw StateError(
        RuntimeLocalization.text(
          en: 'Firebase did not return a notification token.',
          fr: 'Firebase n’a pas renvoyé de jeton de notification.',
        ),
      );
    }
    final preferences = await SharedPreferences.getInstance();
    var targetId = preferences.getString(_targetIdPreferenceKey);
    if (targetId == null || targetId.isEmpty) {
      targetId = const Uuid().v4();
      await preferences.setString(_targetIdPreferenceKey, targetId);
    }
    await registerPushTarget(deviceToken: token, targetId: targetId);
  }

  Future<String?> _getFcmToken() async {
    if (kIsWeb) {
      final vapidKey = Environment.firebaseWebVapidKey.trim();
      if (vapidKey.isEmpty) {
        throw StateError(
          RuntimeLocalization.text(
            en: 'The Firebase Web VAPID key is missing from the build.',
            fr: 'La clé VAPID Firebase Web manque dans le build.',
          ),
        );
      }
      return FirebaseMessaging.instance.getToken(vapidKey: vapidKey);
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Firebase cannot issue a usable iOS FCM token until APNs has provided
      // its device token. This becomes active as soon as Apple signing and the
      // Push Notifications capability are configured.
      String? apnsToken;
      for (var attempt = 0; attempt < 20 && apnsToken == null; attempt++) {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      }
      if (apnsToken == null) {
        throw StateError(
          RuntimeLocalization.text(
            en: 'APNs did not return an iOS device token.',
            fr: 'APNs n’a pas renvoyé de jeton pour l’appareil iOS.',
          ),
        );
      }
    }
    return FirebaseMessaging.instance.getToken();
  }

  Future<void> _handleTokenRefresh(String token) async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_enabledPreferenceKey) != true ||
        !await _appwriteClient.hasAuthenticatedUserSession()) {
      return;
    }
    var targetId = preferences.getString(_targetIdPreferenceKey);
    if (targetId == null || targetId.isEmpty) {
      targetId = const Uuid().v4();
      await preferences.setString(_targetIdPreferenceKey, targetId);
    }
    try {
      await registerPushTarget(deviceToken: token, targetId: targetId);
    } catch (error) {
      RuntimeLocalization.debug(
        en: 'Unable to refresh the Appwrite push target: $error',
        fr: 'Impossible d’actualiser la cible push Appwrite : $error',
      );
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final payload = _payloadFromRemoteMessage(message);
    ingestIncomingPush(payload);
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    await _localNotifications.show(
      id:
          (message.messageId ?? payload['notificationId'].toString()).hashCode &
          0x7fffffff,
      title: payload['title']?.toString(),
      body: payload['body']?.toString(),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription:
              'Collection updates, releases and account notifications.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
          presentList: true,
        ),
      ),
      payload: jsonEncode(payload),
    );
  }

  void _handleOpenedRemoteMessage(RemoteMessage message) {
    _handleOpenedPayload(_payloadFromRemoteMessage(message));
  }

  void _handleOpenedPayload(Map<String, dynamic> payload) {
    ingestIncomingPush(payload);
    final notificationId =
        payload['notificationId']?.toString() ??
        payload['notification_id']?.toString() ??
        payload['id']?.toString();
    if (notificationId != null) markOpened(notificationId);

    final route = PushNotificationRouteResolver.resolve(payload);
    if (route == null) return;
    _pendingOpenRoute = route;
    _openRouteController.add(route);
  }

  Map<String, dynamic> _payloadFromRemoteMessage(RemoteMessage message) {
    final payload = <String, dynamic>{...message.data};
    final notification = message.notification;
    if (notification?.title != null) payload['title'] = notification!.title;
    if (notification?.body != null) payload['body'] = notification!.body;
    payload['notificationId'] =
        payload['notificationId'] ??
        payload['notification_id'] ??
        message.messageId ??
        '${_clock().microsecondsSinceEpoch}';
    payload['deliveredAt'] =
        payload['deliveredAt'] ??
        payload['delivered_at'] ??
        _clock().toUtc().toIso8601String();
    payload['platform'] = kIsWeb
        ? 'web'
        : defaultTargetPlatform.name.toLowerCase();
    return payload;
  }

  PushAuthorizationState _mapAuthorization(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized ||
      AuthorizationStatus.provisional => PushAuthorizationState.authorized,
      AuthorizationStatus.denied => PushAuthorizationState.denied,
      AuthorizationStatus.notDetermined => PushAuthorizationState.notDetermined,
    };
  }

  bool _isAuthorized(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<void> _trackLifecycle(
    String eventName,
    InAppNotification notification, {
    int? latencyMs,
  }) async {
    final lifecycleReporter = _lifecycleReporter;
    if (lifecycleReporter != null) {
      await lifecycleReporter(eventName, notification, latencyMs);
      return;
    }
    final payload = notification.payload ?? const <String, dynamic>{};
    var appVersion = '';
    var buildNumber = '';
    try {
      final package = await PackageInfo.fromPlatform();
      appVersion = package.version;
      buildNumber = package.buildNumber;
    } catch (_) {
      // Package metadata is useful but must never block delivery reporting.
    }
    final eventKey = '${notification.id}:$eventName';
    _pendingLifecycleEvents[eventKey] = <String, dynamic>{
      'eventName': eventName,
      'occurredAt': _clock().toUtc().toIso8601String(),
      'entityType': 'notification',
      'entityId': notification.id,
      'properties': <String, dynamic>{
        'eventId': eventKey,
        if (payload['campaignId'] != null)
          'campaignId': payload['campaignId'].toString(),
        if (payload['campaign_id'] != null)
          'campaignId': payload['campaign_id'].toString(),
        if (payload['platform'] != null)
          'platform': payload['platform'].toString(),
        if (appVersion.isNotEmpty) 'appVersion': appVersion,
        if (buildNumber.isNotEmpty) 'buildNumber': buildNumber,
        if (latencyMs != null) 'latencyMs': latencyMs,
      },
    };
    await _persistLifecycleQueue();
    await _flushLifecycleEvents();
  }

  Future<void> _restoreLocalState() async {
    if (!_persistLocalState) return;
    final preferences = await SharedPreferences.getInstance();
    final encodedInbox = preferences.getString(_inboxPreferenceKey);
    if (encodedInbox != null && encodedInbox.isNotEmpty) {
      try {
        final decoded = jsonDecode(encodedInbox);
        if (decoded is List) {
          _notifications
            ..clear()
            ..addAll(decoded.map(InAppNotification.tryFromJson).whereType());
          _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          if (_notifications.length > _maximumInboxLength) {
            _notifications.removeRange(
              _maximumInboxLength,
              _notifications.length,
            );
          }
          _controller.add(
            List<InAppNotification>.unmodifiable(_notifications),
          );
        }
      } catch (_) {
        await preferences.remove(_inboxPreferenceKey);
      }
    }

    final encodedQueue = preferences.getString(_lifecycleQueuePreferenceKey);
    if (encodedQueue == null || encodedQueue.isEmpty) return;
    try {
      final decoded = jsonDecode(encodedQueue);
      if (decoded is Map) {
        for (final entry in decoded.entries) {
          if (entry.value is Map) {
            _pendingLifecycleEvents[entry.key.toString()] =
                Map<String, dynamic>.from(entry.value as Map);
          }
        }
      }
    } catch (_) {
      await preferences.remove(_lifecycleQueuePreferenceKey);
    }
  }

  void _persistInbox() {
    if (!_persistLocalState) return;
    unawaited(() async {
      try {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString(
          _inboxPreferenceKey,
          jsonEncode(
            _notifications
                .map((notification) => notification.toJson())
                .toList(),
          ),
        );
      } catch (error) {
        RuntimeLocalization.debug(
          en: 'Unable to persist the notification inbox: $error',
          fr: 'Impossible de conserver la boîte de notifications : $error',
        );
      }
    }());
  }

  Future<void> _persistLifecycleQueue() async {
    if (!_persistLocalState) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _lifecycleQueuePreferenceKey,
      jsonEncode(_pendingLifecycleEvents),
    );
  }

  Future<void> _flushLifecycleEvents() async {
    if (_flushingLifecycle || _pendingLifecycleEvents.isEmpty) return;
    _flushingLifecycle = true;
    var failed = false;
    try {
      while (_pendingLifecycleEvents.isNotEmpty) {
        final entry = _pendingLifecycleEvents.entries.first;
        try {
          final response = await _apiClient.post(
            '/api/analytics/events',
            body: entry.value,
          );
          if (response.statusCode < 200 || response.statusCode >= 300) {
            failed = true;
            RuntimeLocalization.debug(
              en: 'Notification analytics event rejected (${response.statusCode}).',
              fr: 'Événement de statistiques de notification refusé (${response.statusCode}).',
            );
            break;
          }
          _pendingLifecycleEvents.remove(entry.key);
          _lifecycleRetryAttempt = 0;
          await _persistLifecycleQueue();
        } catch (error) {
          failed = true;
          RuntimeLocalization.debug(
            en: 'Notification analytics event queued for retry: $error',
            fr: 'L’événement de statistiques de notification sera renvoyé : $error',
          );
          break;
        }
      }
    } finally {
      _flushingLifecycle = false;
    }
    if (failed) _scheduleLifecycleRetry();
  }

  void _scheduleLifecycleRetry() {
    if (_lifecycleRetryTimer != null) return;
    final exponent = _lifecycleRetryAttempt.clamp(0, 6);
    final multiplier = 1 << exponent;
    final requested = Duration(minutes: multiplier);
    const maximum = Duration(hours: 1);
    final delay = requested > maximum ? maximum : requested;
    _lifecycleRetryAttempt += 1;
    _lifecycleRetryTimer = Timer(delay, () {
      _lifecycleRetryTimer = null;
      unawaited(_flushLifecycleEvents());
    });
  }
}
