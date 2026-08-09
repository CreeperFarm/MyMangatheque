import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('application code uses the redacting localized logger', () {
    final offenders = <String>[];
    for (final file in _applicationDartFiles()) {
      if (file.path.endsWith('runtime_localization.dart')) continue;
      final source = file.readAsStringSync();
      if (RegExp(r'\b(?:debugPrint|print)\s*\(').hasMatch(source)) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty);
  });

  test('network images are centralized behind HTTPS validation', () {
    final offenders = <String>[];
    for (final file in _applicationDartFiles()) {
      if (file.path.endsWith('safe_network_image.dart')) continue;
      if (file.readAsStringSync().contains('Image.network(')) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty);
  });
}

Iterable<File> _applicationDartFiles() sync* {
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.contains('/generated/') || entity.path.contains('/l10n/')) {
      continue;
    }
    yield entity;
  }
}
