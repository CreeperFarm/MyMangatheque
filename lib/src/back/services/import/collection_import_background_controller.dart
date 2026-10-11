import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract interface class CollectionImportBackgroundController {
  Future<void> start({required int total});

  Future<void> update({
    required int completed,
    required int total,
    required String title,
  });

  Future<void> stop();
}

class PlatformCollectionImportBackgroundController
    implements CollectionImportBackgroundController {
  static const MethodChannel _channel = MethodChannel(
    'com.mymangatheque/collection_import_foreground',
  );

  bool get _isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<void> start({required int total}) async {
    if (!_isSupported) return;
    await _channel.invokeMethod<void>('start', <String, Object>{
      'total': total,
    });
  }

  @override
  Future<void> update({
    required int completed,
    required int total,
    required String title,
  }) async {
    if (!_isSupported) return;
    await _channel.invokeMethod<void>('update', <String, Object>{
      'completed': completed,
      'total': total,
      'title': title,
    });
  }

  @override
  Future<void> stop() async {
    if (!_isSupported) return;
    await _channel.invokeMethod<void>('stop');
  }
}
