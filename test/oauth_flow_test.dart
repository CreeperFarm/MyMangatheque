import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/oauth_flow.dart';

void main() {
  group('OAuthFlow entrypoints', () {
    test('builds the web session URL and preserves the Appwrite base path', () {
      final uri = OAuthFlow.webEntrypoint(
        endpoint: 'https://appwrite.example/v1/',
        projectId: 'project-1',
        successUrl: 'https://app.example/auth/callback',
        failureUrl: 'https://app.example/auth/callback?error=true',
      );

      expect(uri.scheme, 'https');
      expect(uri.host, 'appwrite.example');
      expect(uri.path, '/v1/account/sessions/oauth2/google');
      expect(uri.queryParameters['project'], 'project-1');
      expect(
        uri.queryParameters['success'],
        'https://app.example/auth/callback',
      );
      expect(
        uri.queryParameters['failure'],
        'https://app.example/auth/callback?error=true',
      );
    });

    test('builds matching mobile callback URLs', () {
      final uri = OAuthFlow.mobileEntrypoint(
        endpoint: 'https://appwrite.example/v1',
        projectId: 'project-1',
      );

      expect(uri.path, '/v1/account/tokens/oauth2/google');
      expect(
        uri.queryParameters['success'],
        'appwrite-callback-project-1://oauth2success',
      );
      expect(
        uri.queryParameters['failure'],
        'appwrite-callback-project-1://oauth2failure',
      );
    });
  });

  group('OAuthFlow mobile callback parsing', () {
    const scheme = 'appwrite-callback-project-1';

    test('accepts identifiers in query parameters', () {
      final payload = OAuthFlow.parseMobileCallback(
        callback: '$scheme://oauth2success?userId=user-1&secret=secret-1',
        expectedScheme: scheme,
      );

      expect(payload.isFailure, isFalse);
      expect(payload.hasRequiredTokenPair, isTrue);
      expect(payload.userId, 'user-1');
      expect(payload.secret, 'secret-1');
    });

    test('merges fragment parameters and supports snake case user IDs', () {
      final payload = OAuthFlow.parseMobileCallback(
        callback:
            '$scheme://oauth2success?key=session#user_id=user-2&secret=s2',
        expectedScheme: scheme,
      );

      expect(payload.userId, 'user-2');
      expect(payload.secret, 's2');
      expect(payload.sessionKey, 'session');
    });

    test('classifies provider and callback-host errors', () {
      final providerError = OAuthFlow.parseMobileCallback(
        callback:
            '$scheme://oauth2success?error_description=user_session_already_exists',
        expectedScheme: scheme,
      );
      final failureHost = OAuthFlow.parseMobileCallback(
        callback: '$scheme://oauth2failure',
        expectedScheme: scheme,
      );

      expect(providerError.isFailure, isTrue);
      expect(providerError.describesExistingSession, isTrue);
      expect(failureHost.isFailure, isTrue);
    });

    test('rejects hostile origins and unexpected callback hosts', () {
      expect(
        () => OAuthFlow.parseMobileCallback(
          callback: 'https://attacker.example/oauth2success?secret=stolen',
          expectedScheme: scheme,
        ),
        throwsFormatException,
      );
      expect(
        () => OAuthFlow.parseMobileCallback(
          callback: '$scheme://unexpected?userId=u&secret=s',
          expectedScheme: scheme,
        ),
        throwsFormatException,
      );
    });

    test('rejects malformed fragments instead of partially trusting them', () {
      expect(
        () => OAuthFlow.parseMobileCallback(
          callback: '$scheme://oauth2success#secret=%ZZ',
          expectedScheme: scheme,
        ),
        throwsFormatException,
      );
    });
  });
}
