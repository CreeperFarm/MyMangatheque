import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/api/mobile_api_key_manager.dart';

void main() {
  group('MobileApiKeyManager.generateCandidate', () {
    final manager = MobileApiKeyManager();

    test('generates a 256-bit secret and its SHA-256 digest', () {
      final candidate = manager.generateCandidate();
      final padding = '=' * ((4 - candidate.value.length % 4) % 4);

      expect(base64Url.decode('${candidate.value}$padding'), hasLength(32));
      expect(candidate.keyHash, hasLength(64));
      expect(
        candidate.keyHash,
        sha256.convert(utf8.encode(candidate.value)).toString(),
      );
    });
  });

  group('MobileApiKeyManager.parseKeyFromResponseBody', () {
    final manager = MobileApiKeyManager();

    test('parses top-level key + expiresAt', () {
      const body = '''
      {
        "key": "abc123",
        "expiresAt": "2026-04-16T14:00:00.000Z"
      }
      ''';

      final parsed = manager.parseKeyFromResponseBody(body);
      expect(parsed.value, 'abc123');
      expect(
        parsed.expiresAt.toUtc().toIso8601String(),
        '2026-04-16T14:00:00.000Z',
      );
    });

    test('parses nested data.key + expires_at', () {
      const body = '''
      {
        "status": "success",
        "data": {
          "key": "nested-key",
          "expires_at": "2026-04-16T16:30:00.000Z"
        }
      }
      ''';

      final parsed = manager.parseKeyFromResponseBody(body);
      expect(parsed.value, 'nested-key');
      expect(
        parsed.expiresAt.toUtc().toIso8601String(),
        '2026-04-16T16:30:00.000Z',
      );
    });

    test('falls back to now+2h when expiresAt is missing', () {
      const body = '{"key":"no-exp"}';
      final before = DateTime.now().toUtc();
      final parsed = manager.parseKeyFromResponseBody(body);
      final after = DateTime.now().toUtc();

      expect(parsed.value, 'no-exp');
      expect(
        parsed.expiresAt.isAfter(
          before.add(const Duration(hours: 1, minutes: 59)),
        ),
        isTrue,
      );
      expect(
        parsed.expiresAt.isBefore(
          after.add(const Duration(hours: 2, minutes: 1)),
        ),
        isTrue,
      );
    });

    test('uses the locally generated key with the current API response', () {
      const body = '''
      {
        "status": "success",
        "data": {
          "id": "tmp-123",
          "expiresAt": "2026-04-16T18:00:00.000Z",
          "expiresIn": 7200
        }
      }
      ''';

      final parsed = manager.parseKeyFromResponseBody(
        body,
        clientGeneratedKey: 'locally-generated-secret',
      );

      expect(parsed.value, 'locally-generated-secret');
      expect(
        parsed.expiresAt.toUtc().toIso8601String(),
        '2026-04-16T18:00:00.000Z',
      );
    });
  });
}
