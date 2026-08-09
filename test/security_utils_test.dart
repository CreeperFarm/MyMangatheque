import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';

void main() {
  group('redactSensitiveText', () {
    test('redacts JWTs, bearer tokens, query secrets and JSON secrets', () {
      const jwt = 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOiIxIn0.signature';
      final result = redactSensitiveText(
        'Bearer abc.def.ghi $jwt https://example.com/cb?secret=value '
        '&access_token=oauth-secret&x-api-key=mobile-secret '
        '{"password":"hunter2","refresh_token":"refresh-secret"}',
      );

      expect(result, isNot(contains('abc.def.ghi')));
      expect(result, isNot(contains(jwt)));
      expect(result, isNot(contains('secret=value')));
      expect(result, isNot(contains('hunter2')));
      expect(result, isNot(contains('oauth-secret')));
      expect(result, isNot(contains('mobile-secret')));
      expect(result, isNot(contains('refresh-secret')));
      expect(result, contains('[REDACTED]'));
    });

    test('limits attacker-controlled error output', () {
      final result = redactSensitiveText(
        List<String>.filled(100, 'x').join(),
        maxLength: 20,
      );
      expect(result, 'xxxxxxxxxxxxxxxxxxxx…');
    });
  });

  group('parseSafeHttpsUri', () {
    test('accepts HTTPS without embedded credentials', () {
      expect(parseSafeHttpsUri('https://mymangatheque.com/path'), isNotNull);
      expect(parseSafeHttpsUri('http://mymangatheque.com/path'), isNull);
      expect(parseSafeHttpsUri('javascript:alert(1)'), isNull);
      expect(parseSafeHttpsUri('https://user:pass@example.com'), isNull);
    });

    test('can enforce an explicit host allowlist', () {
      const hosts = <String>{'mymangatheque.com'};
      expect(
        parseSafeHttpsUri(
          'https://mymangatheque.com/auth',
          allowedHosts: hosts,
        ),
        isNotNull,
      );
      expect(
        parseSafeHttpsUri('https://evil.example/auth', allowedHosts: hosts),
        isNull,
      );
    });
  });

  group('isSafeApiPath', () {
    test('accepts API paths and rejects traversal or query injection', () {
      expect(isSafeApiPath('/api/volumes/123'), isTrue);
      expect(isSafeApiPath('/api/../admin'), isFalse);
      expect(isSafeApiPath('/api/%2e%2e/admin'), isFalse);
      expect(isSafeApiPath('/api/volumes?admin=true'), isFalse);
      expect(isSafeApiPath(r'/api/volumes\admin'), isFalse);
      expect(isSafeApiPath('https://evil.example/api/volumes'), isFalse);
    });
  });
}
