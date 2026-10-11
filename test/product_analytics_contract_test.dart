import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/analytics/product_analytics_service.dart';

void main() {
  test('product analytics only emits events accepted by production', () {
    final source = File(
      'lib/src/back/services/analytics/product_analytics_service.dart',
    ).readAsStringSync();
    final eventNames = RegExp(
      r"eventName: '([^']+)'",
    ).allMatches(source).map((match) => match.group(1)).whereType<String>();

    expect(
      eventNames.toSet(),
      equals(<String>{'app.session.started', 'page.view'}),
    );
    expect(source, isNot(contains('app.failure')));
    expect(source, isNot(contains('sync.transport.changed')));
  });

  test('product analytics normalizes router names to safe paths', () {
    expect(normalizeProductAnalyticsRoute('Home'), '/home');
    expect(normalizeProductAnalyticsRoute('Editor Home'), '/editor-home');
    expect(
      normalizeProductAnalyticsRoute('/planning?month=2026-08'),
      '/planning',
    );
    expect(normalizeProductAnalyticsRoute('  '), isNull);
  });
}
