import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/notifications/notification_service.dart';

void main() {
  late DateTime now;
  late List<({String name, InAppNotification notification, int? latency})>
  events;
  late NotificationService service;

  setUp(() {
    now = DateTime.utc(2026, 8, 8, 10);
    events = [];
    service = NotificationService.forTesting(
      clock: () => now,
      lifecycleReporter: (name, notification, latency) async {
        events.add((name: name, notification: notification, latency: latency));
      },
    );
  });

  tearDown(() {
    service.dispose();
    RuntimeLocalization.setLanguageCode('en');
  });

  test('ingests, orders and emits immutable notification snapshots', () async {
    final snapshots = <List<InAppNotification>>[];
    final subscription = service.stream.listen(snapshots.add);

    service.ingestIncomingPush(<String, dynamic>{
      'notificationId': 'old',
      'title': 'Old',
      'body': 'First',
      'deliveredAt': '2026-08-08T09:00:00Z',
    });
    service.ingestIncomingPush(<String, dynamic>{
      'notification_id': 'new',
      'title': 'New',
      'body': 'Second',
      'delivered_at': '2026-08-08T10:00:00Z',
    });
    await Future<void>.delayed(Duration.zero);

    expect(service.notifications.map((item) => item.id), ['new', 'old']);
    expect(snapshots, hasLength(2));
    expect(
      () => snapshots.last.add(service.notifications.first),
      throwsUnsupportedError,
    );
    expect(events.map((event) => event.name), [
      'notification.received',
      'notification.received',
    ]);
    await subscription.cancel();
  });

  test('deduplicates notification IDs and keeps the newest payload', () async {
    service.ingestIncomingPush(<String, dynamic>{
      'id': 'same',
      'title': 'First',
    });
    now = now.add(const Duration(seconds: 1));
    service.ingestIncomingPush(<String, dynamic>{
      'id': 'same',
      'title': 'Replacement',
    });
    await Future<void>.delayed(Duration.zero);

    expect(service.notifications, hasLength(1));
    expect(service.notifications.single.title, 'Replacement');
    expect(service.notifications.single.createdAt, now);
    expect(
      events.where((event) => event.name == 'notification.received'),
      hasLength(1),
    );
  });

  test('serializes inbox records and rejects corrupted entries', () {
    final notification = InAppNotification(
      id: 'persisted',
      title: 'Release',
      body: 'Volume 4',
      createdAt: now,
      openedAt: now.add(const Duration(minutes: 1)),
      payload: const <String, dynamic>{'route': '/planning'},
    );

    final restored = InAppNotification.tryFromJson(notification.toJson());

    expect(restored?.id, notification.id);
    expect(restored?.openedAt, notification.openedAt);
    expect(restored?.payload?['route'], '/planning');
    expect(InAppNotification.tryFromJson(const <String, dynamic>{}), isNull);
    expect(InAppNotification.tryFromJson('invalid'), isNull);
  });

  test('tracks unread state and can mark the complete inbox as read', () {
    service.ingestIncomingPush(const <String, dynamic>{'id': 'one'});
    service.ingestIncomingPush(const <String, dynamic>{'id': 'two'});

    expect(service.unreadCount, 2);
    service.markAllOpened();

    expect(service.unreadCount, 0);
    expect(service.notifications.every((item) => item.openedAt == now), isTrue);
  });

  test('opening an inbox item reports once and emits its safe route', () async {
    service.ingestIncomingPush(const <String, dynamic>{
      'id': 'route-me',
      'route': '/planning',
    });
    final route = service.openedRoutes.first;

    service.openNotification('route-me');
    service.openNotification('route-me');

    expect(await route, '/planning');
    expect(
      events.where((event) => event.name == 'notification.opened'),
      hasLength(1),
    );
  });

  test('uses a localized default title', () {
    RuntimeLocalization.setLanguageCode('fr');
    service.ingestIncomingPush(const <String, dynamic>{'id': 'fallback'});

    expect(service.notifications.single.title, 'Notification');
    expect(service.notifications.single.body, isEmpty);
  });

  test('marks a notification opened once and reports its latency', () async {
    service.ingestIncomingPush(<String, dynamic>{
      'id': 'open-me',
      'deliveredAt': now.toIso8601String(),
      'campaignId': 'campaign-1',
      'platform': 'ios',
    });
    now = now.add(const Duration(minutes: 5));

    service.markOpened('open-me');
    service.markOpened('open-me');
    service.markOpened('unknown');
    await Future<void>.delayed(Duration.zero);

    expect(service.notifications.single.openedAt, now);
    expect(
      events.where((event) => event.name == 'notification.opened'),
      hasLength(1),
    );
    final opened = events.last;
    expect(opened.latency, const Duration(minutes: 5).inMilliseconds);
    expect(opened.notification.payload?['campaignId'], 'campaign-1');
    expect(opened.notification.payload?['platform'], 'ios');
  });

  test('never reports a negative opening latency when clocks differ', () async {
    service.ingestIncomingPush(<String, dynamic>{
      'id': 'future-delivery',
      'deliveredAt': now.add(const Duration(minutes: 1)).toIso8601String(),
    });

    service.markOpened('future-delivery');
    await Future<void>.delayed(Duration.zero);

    final opened = events.singleWhere(
      (event) => event.name == 'notification.opened',
    );
    expect(opened.latency, 0);
  });

  test('clears notifications and emits an empty snapshot', () async {
    final emitted = Completer<List<InAppNotification>>();
    service.ingestIncomingPush(const <String, dynamic>{'id': 'one'});
    final subscription = service.stream.listen((snapshot) {
      if (snapshot.isEmpty && !emitted.isCompleted) emitted.complete(snapshot);
    });

    service.clearInApp();

    expect(service.notifications, isEmpty);
    expect(await emitted.future, isEmpty);
    await subscription.cancel();
  });

  group('push notification deep links', () {
    test('accepts public application destinations', () {
      expect(
        PushNotificationRouteResolver.resolve(
          const <String, dynamic>{'route': '/library/volume/volume-42'},
        ),
        '/library/volume/volume-42',
      );
      expect(
        PushNotificationRouteResolver.resolve(
          const <String, dynamic>{'route': '/planning'},
        ),
        '/planning',
      );
    });

    test('builds an entity route from a trusted identifier', () {
      expect(
        PushNotificationRouteResolver.resolve(
          const <String, dynamic>{'volumeId': 'volume_42'},
        ),
        '/volume/volume_42',
      );
      expect(
        PushNotificationRouteResolver.resolve(
          const <String, dynamic>{'seriesId': 'series-7'},
        ),
        '/serie/series-7',
      );
    });

    test('rejects external, traversal, authentication and admin routes', () {
      for (final route in <String>[
        'https://evil.example/volume/1',
        '//evil.example/volume/1',
        '/volume/../admin',
        '/admin',
        '/profile/signin',
        '/auth/callback',
      ]) {
        expect(
          PushNotificationRouteResolver.resolve(
            <String, dynamic>{'route': route},
          ),
          isNull,
          reason: route,
        );
      }
    });
  });
}
