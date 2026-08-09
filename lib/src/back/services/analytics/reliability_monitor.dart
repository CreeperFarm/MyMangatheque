import 'dart:collection';

import 'package:flutter/foundation.dart';

class ApiReliabilityEvent {
  const ApiReliabilityEvent({
    required this.method,
    required this.path,
    required this.duration,
    required this.occurredAt,
    this.statusCode,
    this.failureType,
  });

  final String method;
  final String path;
  final Duration duration;
  final DateTime occurredAt;
  final int? statusCode;
  final String? failureType;

  bool get succeeded =>
      failureType == null &&
      statusCode != null &&
      statusCode! >= 200 &&
      statusCode! < 400;
}

class ApiReliabilitySnapshot {
  const ApiReliabilitySnapshot({
    required this.requestCount,
    required this.failureCount,
    required this.averageLatency,
    required this.recentEvents,
  });

  const ApiReliabilitySnapshot.empty()
    : requestCount = 0,
      failureCount = 0,
      averageLatency = Duration.zero,
      recentEvents = const <ApiReliabilityEvent>[];

  final int requestCount;
  final int failureCount;
  final Duration averageLatency;
  final List<ApiReliabilityEvent> recentEvents;
}

/// Privacy-safe, in-process API health metrics for diagnostics and tests.
class ReliabilityMonitor {
  ReliabilityMonitor._();

  static final ReliabilityMonitor instance = ReliabilityMonitor._();
  static const int _maximumEvents = 100;

  final Queue<ApiReliabilityEvent> _events = Queue<ApiReliabilityEvent>();
  final ValueNotifier<ApiReliabilitySnapshot> snapshot =
      ValueNotifier<ApiReliabilitySnapshot>(
        const ApiReliabilitySnapshot.empty(),
      );

  void record({
    required String method,
    required String path,
    required Duration duration,
    int? statusCode,
    String? failureType,
  }) {
    _events.addLast(
      ApiReliabilityEvent(
        method: method,
        path: _normalizedPath(path),
        duration: duration,
        occurredAt: DateTime.now().toUtc(),
        statusCode: statusCode,
        failureType: failureType,
      ),
    );
    while (_events.length > _maximumEvents) {
      _events.removeFirst();
    }
    _publish();
  }

  @visibleForTesting
  void reset() {
    _events.clear();
    snapshot.value = const ApiReliabilitySnapshot.empty();
  }

  void _publish() {
    final events = List<ApiReliabilityEvent>.unmodifiable(_events);
    final totalMicros = events.fold<int>(
      0,
      (total, event) => total + event.duration.inMicroseconds,
    );
    snapshot.value = ApiReliabilitySnapshot(
      requestCount: events.length,
      failureCount: events.where((event) => !event.succeeded).length,
      averageLatency: events.isEmpty
          ? Duration.zero
          : Duration(microseconds: totalMicros ~/ events.length),
      recentEvents: events,
    );
  }

  String _normalizedPath(String path) {
    return path
        .split('/')
        .map((segment) {
          if (segment.length >= 16 || RegExp(r'^\d{6,}$').hasMatch(segment)) {
            return ':id';
          }
          return segment;
        })
        .join('/');
  }
}
