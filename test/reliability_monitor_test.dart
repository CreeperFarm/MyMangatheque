import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/analytics/reliability_monitor.dart';

void main() {
  test(
    'aggregates latency and failures without retaining record identifiers',
    () {
      final monitor = ReliabilityMonitor.instance..reset();
      monitor.record(
        method: 'GET',
        path: '/api/volumes/69e1555c9e6371246077',
        duration: const Duration(milliseconds: 100),
        statusCode: 200,
      );
      monitor.record(
        method: 'POST',
        path: '/api/recommendations/me',
        duration: const Duration(milliseconds: 300),
        failureType: 'timeout',
      );

      final snapshot = monitor.snapshot.value;
      expect(snapshot.requestCount, 2);
      expect(snapshot.failureCount, 1);
      expect(snapshot.averageLatency, const Duration(milliseconds: 200));
      expect(snapshot.recentEvents.first.path, '/api/volumes/:id');
    },
  );
}
