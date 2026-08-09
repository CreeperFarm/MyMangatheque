import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:mymangatheque/environment.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/oauth_flow.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
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

    final endpointUri = Uri.tryParse(Environment.appwritePublicEndpoint);
    final localDebugEndpoint =
        !kReleaseMode &&
        endpointUri != null &&
        <String>{'localhost', '127.0.0.1', '::1'}.contains(endpointUri.host);
    if (endpointUri == null ||
        endpointUri.host.isEmpty ||
        endpointUri.userInfo.isNotEmpty ||
        (!localDebugEndpoint && endpointUri.scheme.toLowerCase() != 'https')) {
      throw StateError(
        RuntimeLocalization.text(
          en: 'The Appwrite endpoint configuration is invalid.',
          fr: 'La configuration du point d’accès Appwrite est invalide.',
        ),
      );
    }

    _client = Client()
      ..setEndpoint(Environment.appwritePublicEndpoint)
      ..setProject(Environment.appwriteProjectId);

    // Keep self-signed only in local debug environments.
    if (localDebugEndpoint) {
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
          RuntimeLocalization.debug(
            en: 'Anonymous authentication is disabled in Appwrite. The guest fallback will be used.',
            fr: 'L’authentification anonyme est désactivée dans Appwrite. Le mode invité de secours sera utilisé.',
          );
          _anonymousUnsupportedAlreadyLogged = true;
        }
        return;
      }
      RuntimeLocalization.debug(
        en: 'Anonymous session creation skipped: $e',
        fr: 'Création de la session anonyme ignorée : $e',
      );
    } catch (e) {
      RuntimeLocalization.debug(
        en: 'Anonymous session creation skipped: $e',
        fr: 'Création de la session anonyme ignorée : $e',
      );
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
      final oauthUrl = OAuthFlow.webEntrypoint(
        endpoint: Environment.appwritePublicEndpoint,
        projectId: Environment.appwriteProjectId,
        successUrl: successUrl,
        failureUrl: failureUrl,
      );

      final launched = await launchUrl(oauthUrl, webOnlyWindowName: '_self');
      if (!launched) {
        throw AppwriteException(
          RuntimeLocalization.text(
            en: 'Unable to open the Google OAuth page.',
            fr: 'Impossible d’ouvrir la page OAuth Google.',
          ),
          500,
        );
      }
      return true;
    }

    await _loginWithGoogleMobile();
    return false;
  }

  Future<void> _loginWithGoogleMobile() async {
    final callbackScheme = OAuthFlow.mobileCallbackScheme(
      Environment.appwriteProjectId,
    );
    final oauthEntrypoint = OAuthFlow.mobileEntrypoint(
      endpoint: Environment.appwritePublicEndpoint,
      projectId: Environment.appwriteProjectId,
    );

    RuntimeLocalization.debug(
      en: 'Opening the Google OAuth mobile flow.',
      fr: 'Ouverture du parcours OAuth Google mobile.',
    );
    final callback = await FlutterWebAuth2.authenticate(
      url: oauthEntrypoint.toString(),
      callbackUrlScheme: callbackScheme,
      options: const FlutterWebAuth2Options(useWebview: false),
    );

    late final OAuthCallbackPayload callbackPayload;
    try {
      callbackPayload = OAuthFlow.parseMobileCallback(
        callback: callback,
        expectedScheme: callbackScheme,
      );
    } on FormatException {
      throw AppwriteException(
        RuntimeLocalization.text(
          en: 'The OAuth callback origin is invalid.',
          fr: 'L’origine du callback OAuth est invalide.',
        ),
        400,
      );
    }
    final callbackUri = callbackPayload.uri;
    final callbackParams = callbackPayload.parameters;

    if (callbackPayload.isFailure) {
      final errorDetails =
          callbackParams['error_description'] ??
          callbackParams['error'] ??
          RuntimeLocalization.text(
            en: 'The identity provider returned an OAuth error.',
            fr: 'Le fournisseur d’identité a renvoyé une erreur OAuth.',
          );
      final sessionAlreadyExists = callbackPayload.describesExistingSession;
      if (sessionAlreadyExists) {
        final currentUser = await tryGetCurrentUser();
        if (currentUser != null) {
          RuntimeLocalization.debug(
            en: 'Google OAuth returned an existing session. Reusing it.',
            fr: 'OAuth Google a renvoyé une session existante. Réutilisation de celle-ci.',
          );
          return;
        }
      }
      throw AppwriteException(
        RuntimeLocalization.text(
          en: 'Google OAuth failed: $errorDetails',
          fr: 'OAuth Google a échoué : $errorDetails',
        ),
        401,
      );
    }

    final userId = callbackPayload.userId;
    final secret = callbackPayload.secret;
    if (userId == null || userId.isEmpty || secret == null || secret.isEmpty) {
      final sessionKey = callbackPayload.sessionKey;
      if (sessionKey != null && sessionKey.isNotEmpty && secret != null) {
        _client.setSession(secret);
        final currentUser = await tryGetCurrentUser();
        if (currentUser != null) {
          return;
        }
      }
      RuntimeLocalization.debug(
        en:
            'Unexpected OAuth callback payload (sensitive values redacted): '
            '${redactSensitiveText(callbackUri)}',
        fr:
            'Réponse OAuth inattendue (valeurs sensibles masquées) : '
            '${redactSensitiveText(callbackUri)}',
      );
      throw AppwriteException(
        RuntimeLocalization.text(
          en: 'Invalid OAuth2 callback payload. Required identifiers are missing.',
          fr: 'Réponse OAuth2 invalide. Des identifiants requis sont absents.',
        ),
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
          RuntimeLocalization.debug(
            en: 'Google OAuth finished with an existing active session. Reusing it.',
            fr: 'OAuth Google s’est terminé avec une session active existante. Réutilisation de celle-ci.',
          );
          return;
        }
      }
      rethrow;
    }
  }

  Future<void> logoutCurrentSession() async {
    await init();
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (e) {
      RuntimeLocalization.debug(
        en: 'Deleting the current session failed: $e',
        fr: 'La suppression de la session courante a échoué : $e',
      );
    }
  }

  Future<void> logoutAllSessions() async {
    await init();
    try {
      await _account.deleteSessions();
    } catch (e) {
      RuntimeLocalization.debug(
        en: 'Deleting all sessions failed: $e',
        fr: 'La suppression de toutes les sessions a échoué : $e',
      );
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
    try {
      await _account.createPushTarget(
        targetId: targetId,
        identifier: identifier,
        providerId: Environment.appwriteFcmProviderId,
      );
    } on AppwriteException catch (error) {
      if (error.code != 409) rethrow;
      await _account.updatePushTarget(
        targetId: targetId,
        identifier: identifier,
      );
    }
  }

  Future<void> deletePushTarget({required String targetId}) async {
    await init();
    await _account.deletePushTarget(targetId: targetId);
  }
}
