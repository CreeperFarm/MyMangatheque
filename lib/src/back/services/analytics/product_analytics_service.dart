import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/api/mobile_api_client.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProductAnalyticsService {
  ProductAnalyticsService._internal();

  static final ProductAnalyticsService _singleton =
      ProductAnalyticsService._internal();

  factory ProductAnalyticsService() => _singleton;

  final MobileApiClient _api = MobileApiClient();
  final String _sessionId = _newAnonymousSessionId();

  Future<void>? _sessionStart;
  String? _lastRoute;
  DateTime? _lastRouteAt;

  Future<void> trackPageView(String routeName) async {
    final route = routeName.trim();
    if (route.isEmpty || route.toLowerCase().startsWith('admin')) return;
    final now = DateTime.now();
    if (_lastRoute == route &&
        _lastRouteAt != null &&
        now.difference(_lastRouteAt!) < const Duration(milliseconds: 750)) {
      return;
    }
    _lastRoute = route;
    _lastRouteAt = now;
    await _ensureSessionStarted();
    await _send(
      eventName: 'page.view',
      entityType: 'route',
      entityId: route,
      properties: <String, dynamic>{'route': route},
    );
  }

  Future<void> trackReliabilityFailure(String category) async {
    final normalized = category.trim();
    if (normalized.isEmpty) return;
    await _send(
      eventName: 'app.failure',
      entityType: 'reliability',
      entityId: normalized,
      properties: <String, dynamic>{'category': normalized},
    );
  }

  Future<void> trackSyncTransport(
    String collectionId,
    String transport,
  ) async {
    final collection = collectionId.trim();
    final selectedTransport = transport.trim();
    if (collection.isEmpty || selectedTransport.isEmpty) return;
    await _send(
      eventName: 'sync.transport.changed',
      entityType: 'collection',
      entityId: collection,
      properties: <String, dynamic>{
        'collectionId': collection,
        'transport': selectedTransport,
      },
    );
  }

  Future<void> _ensureSessionStarted() {
    return _sessionStart ??= _send(
      eventName: 'app.session.started',
      entityType: 'session',
      entityId: _sessionId,
    );
  }

  Future<void> _send({
    required String eventName,
    required String entityType,
    required String entityId,
    Map<String, dynamic> properties = const <String, dynamic>{},
  }) async {
    try {
      final package = await PackageInfo.fromPlatform();
      final response = await _api.post(
        '/api/analytics/events',
        body: <String, dynamic>{
          'eventName': eventName,
          'occurredAt': DateTime.now().toUtc().toIso8601String(),
          'sessionId': _sessionId,
          'entityType': entityType,
          'entityId': entityId,
          'properties': <String, dynamic>{
            ...properties,
            'platform': _platform,
            'appVersion': package.version,
            'buildNumber': package.buildNumber,
          },
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        RuntimeLocalization.debug(
          en: 'Product analytics event rejected (${response.statusCode}).',
          fr: 'Événement de statistiques produit refusé (${response.statusCode}).',
        );
      }
    } catch (error) {
      RuntimeLocalization.debug(
        en: 'Product analytics event failed: $error',
        fr: 'L’événement de statistiques produit a échoué : $error',
      );
    }
  }

  String get _platform {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }
}

String _newAnonymousSessionId() {
  final random = Random.secure();
  final entropy = List<int>.generate(
    4,
    (_) => random.nextInt(1 << 32),
  ).map((value) => value.toRadixString(16).padLeft(8, '0')).join();
  return '${DateTime.now().toUtc().microsecondsSinceEpoch}-$entropy';
}

class ProductAnalyticsNavigationObserver extends NavigatorObserver {
  ProductAnalyticsNavigationObserver({ProductAnalyticsService? analytics})
    : _analytics = analytics ?? ProductAnalyticsService();

  final ProductAnalyticsService _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _track(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) _track(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _track(newRoute);
  }

  void _track(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    unawaited(_analytics.trackPageView(name));
  }
}
