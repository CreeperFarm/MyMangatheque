import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mymangatheque/src/back/services/api/mobile_api_client.dart';
import 'package:mymangatheque/src/back/services/appwrite_client.dart';

class InAppNotification {
  InAppNotification({required this.id, required this.title, required this.body, required this.createdAt, this.payload});

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final Map<String, dynamic>? payload;
}

class NotificationService {
  NotificationService._internal();

  static final NotificationService _singleton = NotificationService._internal();

  factory NotificationService() => _singleton;

  final AppwriteClientService _appwriteClient = AppwriteClientService();
  final MobileApiClient _apiClient = MobileApiClient();

  final StreamController<List<InAppNotification>> _controller = StreamController<List<InAppNotification>>.broadcast();
  final List<InAppNotification> _notifications = <InAppNotification>[];

  Timer? _pollingTimer;

  Stream<List<InAppNotification>> get stream => _controller.stream;

  Future<void> init() async {
    await _appwriteClient.init();
    await _apiClient.init();
  }

  Future<void> registerPushTarget({required String deviceToken, required String targetId}) async {
    await init();
    await _appwriteClient.registerPushTarget(targetId: targetId, identifier: deviceToken);
  }

  void ingestIncomingPush(Map<String, dynamic> payload) {
    final title = payload['title']?.toString() ?? 'Notification';
    final body = payload['body']?.toString() ?? '';

    _notifications.insert(
      0,
      InAppNotification(id: '${DateTime.now().microsecondsSinceEpoch}', title: title, body: body, createdAt: DateTime.now(), payload: payload),
    );

    _controller.add(List<InAppNotification>.unmodifiable(_notifications));
  }

  void startFallbackPolling({Duration interval = const Duration(minutes: 5)}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) async {
      try {
        // Lightweight heartbeat endpoint used as fallback trigger.
        final response = await _apiClient.get('/api/analytics/health', requiresApiKey: false);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          ingestIncomingPush(<String, dynamic>{'title': 'Analytics heartbeat', 'body': 'Background sync completed.'});
        }
      } catch (e) {
        debugPrint('Notification polling fallback failed: $e');
      }
    });
  }

  void stopFallbackPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void clearInApp() {
    _notifications.clear();
    _controller.add(List<InAppNotification>.unmodifiable(_notifications));
  }

  void dispose() {
    stopFallbackPolling();
    _controller.close();
  }
}
