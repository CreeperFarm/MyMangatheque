import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:mymangatheque/environment.dart';
import 'package:url_launcher/url_launcher.dart';

class AppwriteClientService {
  AppwriteClientService._internal();

  static final AppwriteClientService _singleton =
      AppwriteClientService._internal();

  factory AppwriteClientService() => _singleton;

  late final Client _client;
  late final Account _account;
  late final Storage _storage;
  late final Realtime _realtime;

  bool _initialized = false;
  bool _anonymousSessionUnavailable = false;
  bool _anonymousUnsupportedAlreadyLogged = false;

  Future<void> init() async {
    if (_initialized) return;

    _client = Client()
      ..setEndpoint(Environment.appwritePublicEndpoint)
      ..setProject(Environment.appwriteProjectId);

    // Keep self-signed only in local debug environments.
    if (!kReleaseMode &&
        Environment.appwritePublicEndpoint.contains('localhost')) {
      _client.setSelfSigned(status: true);
    }

    _account = Account(_client);
    _storage = Storage(_client);
    _realtime = Realtime(_client);
    _initialized = true;
  }

  Account get account => _account;

  Storage get storage => _storage;

  Realtime get realtime => _realtime;

  Client get client => _client;

  Future<models.User?> tryGetCurrentUser() async {
    await init();
    try {
      return await _account.get();
    } catch (_) {
      return null;
    }
  }

  Future<void> ensureGuestSession() async {
    await init();
    if (_anonymousSessionUnavailable) return;
    final user = await tryGetCurrentUser();
    if (user != null) return;
    try {
      await _account.createAnonymousSession();
    } on AppwriteException catch (e) {
      // Project-level setting may disable anonymous auth.
      if (e.type == 'user_auth_method_unsupported' || e.code == 501) {
        _anonymousSessionUnavailable = true;
        if (!_anonymousUnsupportedAlreadyLogged) {
          debugPrint(
            'Anonymous auth disabled on Appwrite project. Guest session fallback will be used.',
          );
          _anonymousUnsupportedAlreadyLogged = true;
        }
        return;
      }
      debugPrint('Anonymous session creation skipped: $e');
    } catch (e) {
      debugPrint('Anonymous session creation skipped: $e');
    }
  }

  Future<bool> hasAuthenticatedUserSession() async {
    await init();
    try {
      final session = await _account.getSession(sessionId: 'current');
      return session.provider.toLowerCase() != 'anonymous';
    } catch (_) {
      return false;
    }
  }

  Future<models.User> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    await init();
    return _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
  }

  Future<models.Session> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await init();
    return _account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  /// Starts Google OAuth.
  ///
  /// Returns `true` when Web navigation has started, because the current app
  /// instance must stop its post-login work and let the callback route finish
  /// it after the full-page redirect.
  Future<bool> loginWithGoogle() async {
    await init();

    if (kIsWeb) {
      const successUrl = 'https://mymangatheque.com/auth/callback';
      const failureUrl = 'https://mymangatheque.com/auth/callback?error=true';
      final oauthUrl =
          Uri.parse(
            '${Environment.appwritePublicEndpoint}/account/sessions/oauth2/google',
          ).replace(
            queryParameters: <String, String>{
              'project': Environment.appwriteProjectId,
              'success': successUrl,
              'failure': failureUrl,
            },
          );

      final launched = await launchUrl(oauthUrl, webOnlyWindowName: '_self');
      if (!launched) {
        throw AppwriteException('Unable to open the Google OAuth page.', 500);
      }
      return true;
    }

    await _loginWithGoogleMobile();
    return false;
  }

  Future<void> _loginWithGoogleMobile() async {
    final callbackScheme = 'appwrite-callback-${Environment.appwriteProjectId}';
    final mobileSuccessUrl = '$callbackScheme://oauth2success';
    final mobileFailureUrl = '$callbackScheme://oauth2failure';
    final oauthEntrypoint =
        Uri.parse(
          '${Environment.appwritePublicEndpoint}/account/tokens/oauth2/google',
        ).replace(
          queryParameters: <String, String>{
            'project': Environment.appwriteProjectId,
            'success': mobileSuccessUrl,
            'failure': mobileFailureUrl,
          },
        );

    debugPrint('Google OAuth Appwrite mobile entrypoint: $oauthEntrypoint');
    final callback = await FlutterWebAuth2.authenticate(
      url: oauthEntrypoint.toString(),
      callbackUrlScheme: callbackScheme,
      options: const FlutterWebAuth2Options(useWebview: false),
    );

    final callbackUri = Uri.parse(callback);
    final callbackParams = _queryAndFragmentParams(callbackUri);

    final callbackHost = callbackUri.host.toLowerCase();
    final hasOAuthError =
        callbackHost == 'oauth2failure' ||
        callbackParams.containsKey('error') ||
        callbackParams.containsKey('error_description');
    if (hasOAuthError) {
      final errorDetails =
          callbackParams['error_description'] ??
          callbackParams['error'] ??
          callbackUri.toString();
      final sessionAlreadyExists =
          errorDetails.contains('user_session_already_exists') ||
          errorDetails.contains('session is active');
      if (sessionAlreadyExists) {
        final currentUser = await tryGetCurrentUser();
        if (currentUser != null) {
          debugPrint(
            'Google OAuth returned "session already exists". Reusing current session.',
          );
          return;
        }
      }
      throw AppwriteException('Google OAuth failed: $errorDetails', 401);
    }

    final userId = callbackParams['userId'] ?? callbackParams['user_id'];
    final secret = callbackParams['secret'];
    if (userId == null || userId.isEmpty || secret == null || secret.isEmpty) {
      final sessionKey = callbackParams['key'];
      if (sessionKey != null && sessionKey.isNotEmpty && secret != null) {
        _client.setSession(secret);
        final currentUser = await tryGetCurrentUser();
        if (currentUser != null) {
          return;
        }
      }
      debugPrint('Unexpected OAuth callback payload: $callbackUri');
      throw AppwriteException(
        'Invalid OAuth2 callback payload. userId/secret missing.',
        500,
      );
    }

    try {
      await _account.createSession(userId: userId, secret: secret);
    } on AppwriteException catch (e) {
      final sessionAlreadyExists =
          e.type == 'user_session_already_exists' || e.code == 409;
      if (sessionAlreadyExists) {
        final currentUser = await tryGetCurrentUser();
        if (currentUser != null) {
          debugPrint(
            'Google OAuth finished with an existing active session. Reusing current session.',
          );
          return;
        }
      }
      rethrow;
    }
  }

  Map<String, String> _queryAndFragmentParams(Uri uri) {
    final params = <String, String>{...uri.queryParameters};
    final fragment = uri.fragment;
    if (fragment.isEmpty || !fragment.contains('=')) {
      return params;
    }

    try {
      params.addAll(Uri.splitQueryString(fragment));
    } catch (_) {
      // Ignore malformed fragment payloads.
    }

    return params;
  }

  Future<void> logoutCurrentSession() async {
    await init();
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (e) {
      debugPrint('deleteSession(current) failed: $e');
    }
  }

  Future<void> logoutAllSessions() async {
    await init();
    try {
      await _account.deleteSessions();
    } catch (e) {
      debugPrint('deleteSessions failed: $e');
    }
  }

  Future<models.Jwt> createJwt({int durationSeconds = 900}) async {
    await init();
    return _account.createJWT(duration: durationSeconds);
  }

  Future<void> sendEmailVerification() async {
    await init();
    await _account.createEmailVerification(
      url: 'https://mymangatheque.com/auth/callback',
    );
  }

  Future<void> createRecoveryEmail(String email) async {
    await init();
    await _account.createRecovery(
      email: email,
      url: 'https://mymangatheque.com/auth/callback',
    );
  }

  Future<void> completeRecovery({
    required String userId,
    required String secret,
    required String newPassword,
  }) async {
    await init();
    await _account.updateRecovery(
      userId: userId,
      secret: secret,
      password: newPassword,
    );
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await init();
    await _account.updatePassword(
      password: newPassword,
      oldPassword: oldPassword,
    );
  }

  Future<void> blockCurrentAccount() async {
    await init();
    await _account.updateStatus();
  }

  Future<void> updateName(String name) async {
    await init();
    await _account.updateName(name: name);
  }

  Future<void> registerPushTarget({
    required String targetId,
    required String identifier,
  }) async {
    await init();
    await _account.createPushTarget(targetId: targetId, identifier: identifier);
  }
}
