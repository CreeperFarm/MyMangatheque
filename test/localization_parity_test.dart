import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and French ARB catalogues expose the same messages', () {
    final english = _messageKeys('lib/l10n/intl_en.arb');
    final french = _messageKeys('lib/l10n/intl_fr.arb');

    expect(english.difference(french), isEmpty, reason: 'Missing French keys');
    expect(french.difference(english), isEmpty, reason: 'Missing English keys');
  });
}

Set<String> _messageKeys(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  final catalogue = Map<String, dynamic>.from(decoded as Map);
  return catalogue.keys.where((key) => !key.startsWith('@')).toSet();
}
