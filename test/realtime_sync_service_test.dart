import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/models/api_record_model.dart';
import 'package:mymangatheque/src/back/services/sync/realtime_sync_service.dart';

void main() {
  test('forwards native events without periodic polling', () async {
    final source = StreamController<ApiRecordSubscriptionEvent>();
    var connections = 0;
    var closes = 0;
    final service = RealtimeSyncService.forTesting(
      connectionFactory: (_, _) {
        connections += 1;
        return RealtimeSyncConnection(
          stream: source.stream,
          close: () async => closes += 1,
        );
      },
    );
    final events = <ApiRecordSubscriptionEvent>[];
    final subscription = service.watch('owned').listen(events.add);
    await Future<void>.delayed(Duration.zero);

    source.add(
      ApiRecordSubscriptionEvent(collectionId: 'owned', action: 'update'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(connections, 1);
    expect(events.single.action, 'update');
    expect(service.metrics.value.realtimeEvents, 1);
    expect(service.metrics.value.fallbackPolls, 0);

    await subscription.cancel();
    await source.close();
    expect(closes, 1);
    await service.dispose();
  });

  test(
    'shares one realtime socket between listeners of a collection',
    () async {
      final source = StreamController<ApiRecordSubscriptionEvent>.broadcast();
      var connections = 0;
      final service = RealtimeSyncService.forTesting(
        connectionFactory: (_, _) {
          connections += 1;
          return RealtimeSyncConnection(
            stream: source.stream,
            close: () async {},
          );
        },
      );

      final first = service.watch('followed').listen((_) {});
      final second = service.watch('followed').listen((_) {});
      await Future<void>.delayed(Duration.zero);

      expect(connections, 1);
      expect(service.metrics.value.activeChannels, 1);

      await first.cancel();
      expect(service.metrics.value.activeChannels, 1);
      await second.cancel();
      await Future<void>.delayed(Duration.zero);
      expect(service.metrics.value.activeChannels, 0);
      await source.close();
      await service.dispose();
    },
  );

  test('falls back adaptively and reconnects after an interruption', () async {
    final recovered = StreamController<ApiRecordSubscriptionEvent>();
    var attempts = 0;
    final transports = <String>[];
    final service = RealtimeSyncService.forTesting(
      fallbackMinimum: const Duration(milliseconds: 5),
      fallbackMaximum: const Duration(milliseconds: 10),
      reconnectDelay: const Duration(milliseconds: 12),
      transportReporter: (_, transport) async => transports.add(transport),
      connectionFactory: (_, _) {
        attempts += 1;
        if (attempts == 1) throw StateError('offline');
        return RealtimeSyncConnection(
          stream: recovered.stream,
          close: () async {},
        );
      },
    );
    final events = <ApiRecordSubscriptionEvent>[];
    final subscription = service.watch('owned').listen(events.add);

    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(attempts, greaterThanOrEqualTo(2));
    expect(events.where((event) => event.action == 'poll'), isNotEmpty);
    expect(service.metrics.value.fallbackPolls, greaterThanOrEqualTo(1));
    expect(service.metrics.value.reconnections, greaterThanOrEqualTo(1));
    expect(transports, containsAllInOrder(<String>['fallback', 'realtime']));

    recovered.add(
      ApiRecordSubscriptionEvent(collectionId: 'owned', action: 'create'),
    );
    await Future<void>.delayed(Duration.zero);
    expect(events.last.action, 'create');

    await subscription.cancel();
    await recovered.close();
    await service.dispose();
  });
}
