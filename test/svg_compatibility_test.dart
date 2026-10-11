import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bundled SVG icons avoid unsupported filter elements', () {
    final unsupported = Directory('assets')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.svg'))
        .where((file) => file.readAsStringSync().contains('<filter'))
        .map((file) => file.path)
        .toList();

    expect(unsupported, isEmpty);
  });
}
