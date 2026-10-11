import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/api/mobile_api_client.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

class ProductAnalyticsService {
  ProductAnalyticsService._internal();

  static final ProductAnalyticsService _singleton =
      ProductAnalyticsService._internal();

  factory ProductAnalyticsService() => _singleton;

  final MobileApiClient _api = MobileApiClient();
  final String _sessionId = const Uuid().v4();

  Future<void>? _sessionStart;
  String? _lastRoute;
  DateTime? _lastRouteAt;
  bool _disabledForSession = false;

  Future<void> trackPageView(String routeName) async {
    if (_disabledForSession) return;
    final route = normalizeProductAnalyticsRoute(routeName);
    if (route == null || route.startsWith('/admin')) return;
    final now = DateTime.now();
    if (_lastRoute == route &&
        _lastRouteAt != null &&
        now.difference(_lastRouteAt!) < const Duration(milliseconds: 750)) {
      return;
    }
    _lastRoute = route;
    _lastRouteAt = now;
    await _ensureSessionStarted();
    if (_disabledForSession) return;
    await _send(
      eventName: 'page.view',
      entityType: 'route',
      entityId: route,
      properties: <String, dynamic>{'route': route},
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
    if (_disabledForSession) return;
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
        if (response.statusCode >= 500) {
          _disabledForSession = true;
        }
        final details = redactSensitiveText(response.body).trim();
        RuntimeLocalization.debug(
          en: 'Product analytics event rejected (${response.statusCode})${details.isEmpty ? '.' : ': $details'}',
          fr: 'Événement de statistiques produit refusé (${response.statusCode})${details.isEmpty ? '.' : ' : $details'}',
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

/// Converts GoRouter's human-readable route names to the privacy-safe path
/// format accepted by the production analytics contract.
String? normalizeProductAnalyticsRoute(String routeName) {
  var route = routeName.trim();
  if (route.isEmpty) return null;

  if (route.startsWith('/')) {
    route = Uri.tryParse(route)?.path ?? route;
  } else {
    route = '/${route.toLowerCase()}';
  }

  route = route
      .replaceAll(RegExp(r'[^A-Za-z0-9/_.:-]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'/$'), '');
  if (route.isEmpty) return '/';
  return route.length <= 200 ? route : route.substring(0, 200);
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
