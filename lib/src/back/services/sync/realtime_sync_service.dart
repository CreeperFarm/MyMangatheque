import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/analytics/product_analytics_service.dart';
import 'package:mymangatheque/src/back/services/appwrite_client.dart';
import 'package:mymangatheque/src/back/services/models/api_record_model.dart';

typedef RealtimeConnectionFactory =
    RealtimeSyncConnection Function(
      String databaseId,
      String collectionId,
    );

class RealtimeSyncConnection {
  const RealtimeSyncConnection({required this.stream, required this.close});

  final Stream<ApiRecordSubscriptionEvent> stream;
  final Future<void> Function() close;
}

class RealtimeSyncMetrics {
  const RealtimeSyncMetrics({
    this.activeChannels = 0,
    this.realtimeEvents = 0,
    this.fallbackPolls = 0,
    this.reconnections = 0,
  });

  final int activeChannels;
  final int realtimeEvents;
  final int fallbackPolls;
  final int reconnections;

  RealtimeSyncMetrics copyWith({
    int? activeChannels,
    int? realtimeEvents,
    int? fallbackPolls,
    int? reconnections,
  }) {
    return RealtimeSyncMetrics(
      activeChannels: activeChannels ?? this.activeChannels,
      realtimeEvents: realtimeEvents ?? this.realtimeEvents,
      fallbackPolls: fallbackPolls ?? this.fallbackPolls,
      reconnections: reconnections ?? this.reconnections,
    );
  }
}

/// Shares one Appwrite Realtime connection per collection and only polls when
/// that connection cannot be established or is interrupted.
class RealtimeSyncService {
  RealtimeSyncService._internal({
    RealtimeConnectionFactory? connectionFactory,
    Duration fallbackMinimum = const Duration(seconds: 15),
    Duration fallbackMaximum = const Duration(minutes: 2),
    Duration reconnectDelay = const Duration(seconds: 30),
    Future<void> Function(String collectionId, String transport)?
    transportReporter,
  }) : _connectionFactory =
           connectionFactory ?? _createAppwriteRealtimeConnection,
       _fallbackMinimum = fallbackMinimum,
       _fallbackMaximum = fallbackMaximum,
       _reconnectDelay = reconnectDelay,
       _transportReporter =
           transportReporter ??
           ((collectionId, transport) => ProductAnalyticsService()
               .trackSyncTransport(collectionId, transport));

  static final RealtimeSyncService _singleton = RealtimeSyncService._internal();

  factory RealtimeSyncService() => _singleton;

  factory RealtimeSyncService.forTesting({
    required RealtimeConnectionFactory connectionFactory,
    Duration fallbackMinimum = const Duration(milliseconds: 10),
    Duration fallbackMaximum = const Duration(milliseconds: 40),
    Duration reconnectDelay = const Duration(milliseconds: 25),
    Future<void> Function(String collectionId, String transport)?
    transportReporter,
  }) {
    return RealtimeSyncService._internal(
      connectionFactory: connectionFactory,
      fallbackMinimum: fallbackMinimum,
      fallbackMaximum: fallbackMaximum,
      reconnectDelay: reconnectDelay,
      transportReporter: transportReporter ?? (_, _) async {},
    );
  }

  static const String databaseId = 'manga-db';

  final RealtimeConnectionFactory _connectionFactory;
  final Duration _fallbackMinimum;
  final Duration _fallbackMaximum;
  final Duration _reconnectDelay;
  final Future<void> Function(String collectionId, String transport)
  _transportReporter;
  final Map<String, _SharedRealtimeChannel> _channels =
      <String, _SharedRealtimeChannel>{};

  final ValueNotifier<RealtimeSyncMetrics> metrics =
      ValueNotifier<RealtimeSyncMetrics>(const RealtimeSyncMetrics());

  Stream<ApiRecordSubscriptionEvent> watch(String collectionId) {
    final normalized = collectionId.trim();
    late StreamController<ApiRecordSubscriptionEvent> output;
    StreamSubscription<ApiRecordSubscriptionEvent>? forwarding;
    _SharedRealtimeChannel? shared;

    output = StreamController<ApiRecordSubscriptionEvent>(
      onListen: () {
        shared = _channels.putIfAbsent(
          normalized,
          () => _createSharedChannel(normalized),
        );
        shared!.listeners += 1;
        forwarding = shared!.controller.stream.listen(
          output.add,
          onError: output.addError,
        );
      },
      onCancel: () {
        final forwardingSubscription = forwarding;
        if (forwardingSubscription != null) {
          unawaited(forwardingSubscription.cancel());
        }
        final channel = shared;
        if (channel == null) return;
        channel.listeners -= 1;
        if (channel.listeners <= 0) {
          _channels.remove(normalized);
          unawaited(channel.dispose());
          _setActiveChannelCount();
        }
      },
    );
    return output.stream;
  }

  _SharedRealtimeChannel _createSharedChannel(String collectionId) {
    late _SharedRealtimeChannel channel;
    channel = _SharedRealtimeChannel(
      collectionId: collectionId,
      connectionFactory: _connectionFactory,
      fallbackMinimum: _fallbackMinimum,
      fallbackMaximum: _fallbackMaximum,
      reconnectDelay: _reconnectDelay,
      onRealtimeEvent: () {
        metrics.value = metrics.value.copyWith(
          realtimeEvents: metrics.value.realtimeEvents + 1,
        );
      },
      onFallbackPoll: () {
        metrics.value = metrics.value.copyWith(
          fallbackPolls: metrics.value.fallbackPolls + 1,
        );
      },
      onReconnect: () {
        metrics.value = metrics.value.copyWith(
          reconnections: metrics.value.reconnections + 1,
        );
      },
      onTransportChanged: (transport) {
        unawaited(_transportReporter(collectionId, transport));
      },
    );
    scheduleMicrotask(() {
      channel.start();
      _setActiveChannelCount();
    });
    return channel;
  }

  void _setActiveChannelCount() {
    metrics.value = metrics.value.copyWith(activeChannels: _channels.length);
  }

  Future<void> dispose() async {
    final channels = _channels.values.toList(growable: false);
    _channels.clear();
    await Future.wait(channels.map((channel) => channel.dispose()));
    _setActiveChannelCount();
    metrics.dispose();
  }

  static RealtimeSyncConnection _createAppwriteRealtimeConnection(
    String databaseId,
    String collectionId,
  ) {
    final subscription = AppwriteClientService().realtime.subscribe(<Object>[
      'databases.$databaseId.collections.$collectionId.documents',
    ]);
    return RealtimeSyncConnection(
      stream: subscription.stream.map((message) {
        final payload = Map<String, dynamic>.from(message.payload);
        final recordId =
            payload[r'$id']?.toString() ?? payload['id']?.toString();
        final action = message.events.isEmpty
            ? 'update'
            : message.events.first.split('.').last;
        return ApiRecordSubscriptionEvent(
          collectionId: collectionId,
          action: action,
          record: recordId == null || recordId.isEmpty
              ? null
              : ApiRecordModel(
                  id: recordId,
                  collectionId: collectionId,
                  data: payload,
                ),
        );
      }),
      close: subscription.close,
    );
  }
}

class _SharedRealtimeChannel {
  _SharedRealtimeChannel({
    required this.collectionId,
    required this.connectionFactory,
    required this.fallbackMinimum,
    required this.fallbackMaximum,
    required this.reconnectDelay,
    required this.onRealtimeEvent,
    required this.onFallbackPoll,
    required this.onReconnect,
    required this.onTransportChanged,
  });

  final String collectionId;
  final RealtimeConnectionFactory connectionFactory;
  final Duration fallbackMinimum;
  final Duration fallbackMaximum;
  final Duration reconnectDelay;
  final VoidCallback onRealtimeEvent;
  final VoidCallback onFallbackPoll;
  final VoidCallback onReconnect;
  final void Function(String transport) onTransportChanged;
  final StreamController<ApiRecordSubscriptionEvent> controller =
      StreamController<ApiRecordSubscriptionEvent>.broadcast();

  int listeners = 0;
  int _generation = 0;
  int _fallbackAttempt = 0;
  bool _disposed = false;
  Timer? _fallbackTimer;
  Timer? _reconnectTimer;
  RealtimeSyncConnection? _connection;
  StreamSubscription<ApiRecordSubscriptionEvent>? _subscription;

  void start() => _connect();

  void _connect() {
    if (_disposed) return;
    final generation = ++_generation;
    try {
      final connection = connectionFactory(
        RealtimeSyncService.databaseId,
        collectionId,
      );
      _connection = connection;
      _subscription = connection.stream.listen(
        (event) {
          if (_disposed || generation != _generation) return;
          _fallbackAttempt = 0;
          _fallbackTimer?.cancel();
          onRealtimeEvent();
          controller.add(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          if (_disposed || generation != _generation) return;
          RuntimeLocalization.debug(
            en: 'Realtime synchronization interrupted for $collectionId: $error',
            fr: 'Synchronisation temps réel interrompue pour $collectionId : $error',
          );
          _activateFallback();
        },
        onDone: () {
          if (_disposed || generation != _generation) return;
          _activateFallback();
        },
        cancelOnError: true,
      );
      _fallbackTimer?.cancel();
      _fallbackTimer = null;
      _fallbackAttempt = 0;
      onTransportChanged('realtime');
    } catch (error) {
      RuntimeLocalization.debug(
        en: 'Realtime synchronization unavailable for $collectionId: $error',
        fr: 'Synchronisation temps réel indisponible pour $collectionId : $error',
      );
      _activateFallback();
    }
  }

  void _activateFallback() {
    if (_disposed || _fallbackTimer != null) return;
    unawaited(_closeCurrentConnection());
    onTransportChanged('fallback');
    _emitFallbackPoll();
    _scheduleReconnect();
  }

  void _emitFallbackPoll() {
    if (_disposed) return;
    onFallbackPoll();
    controller.add(
      ApiRecordSubscriptionEvent(
        collectionId: collectionId,
        action: 'poll',
      ),
    );
    final multiplier = 1 << _fallbackAttempt.clamp(0, 8);
    final requested = Duration(
      milliseconds: fallbackMinimum.inMilliseconds * multiplier,
    );
    final interval = requested > fallbackMaximum ? fallbackMaximum : requested;
    _fallbackAttempt += 1;
    _fallbackTimer = Timer(interval, () {
      _fallbackTimer = null;
      _emitFallbackPoll();
    });
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectTimer != null) return;
    _reconnectTimer = Timer(reconnectDelay, () {
      _reconnectTimer = null;
      if (_disposed) return;
      onReconnect();
      _connect();
    });
  }

  Future<void> _closeCurrentConnection() async {
    _generation += 1;
    await _subscription?.cancel();
    _subscription = null;
    final connection = _connection;
    _connection = null;
    if (connection != null) {
      try {
        await connection.close();
      } catch (_) {
        // Closing an already interrupted socket is harmless.
      }
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _fallbackTimer?.cancel();
    _reconnectTimer?.cancel();
    await _closeCurrentConnection();
    await controller.close();
  }
}
