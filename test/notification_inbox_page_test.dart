import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/notifications/notification_service.dart';
import 'package:mymangatheque/src/front/page/profile/notification_inbox_page.dart';

void main() {
  testWidgets('shows the empty notification inbox state', (tester) async {
    final service = NotificationService.forTesting(
      lifecycleReporter: (_, _, _) async {},
    );

    await tester.pumpWidget(
      MaterialApp(home: NotificationInboxPage(notificationService: service)),
    );

    expect(find.text('No notifications yet'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    service.dispose();
  });

  testWidgets('renders, opens and clears persisted-style notifications', (
    tester,
  ) async {
    final service = NotificationService.forTesting(
      lifecycleReporter: (_, _, _) async {},
    );
    service.ingestIncomingPush(const <String, dynamic>{
      'id': 'release-1',
      'title': 'A new volume is available',
      'body': 'Open the release calendar.',
      'route': '/planning',
    });

    await tester.pumpWidget(
      MaterialApp(home: NotificationInboxPage(notificationService: service)),
    );
    await tester.pump();

    expect(find.text('A new volume is available'), findsOneWidget);
    expect(service.unreadCount, 1);

    await tester.tap(find.text('A new volume is available'));
    await tester.pump();
    expect(service.unreadCount, 0);

    await tester.tap(find.byTooltip('Clear notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Clear notifications?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
    await tester.pumpAndSettle();

    expect(service.notifications, isEmpty);
    expect(find.text('No notifications yet'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    service.dispose();
  });
}
