class OAuthCallbackPayload {
  const OAuthCallbackPayload({
    required this.uri,
    required this.parameters,
    required this.isFailure,
  });

  final Uri uri;
  final Map<String, String> parameters;
  final bool isFailure;

  String? get userId => parameters['userId'] ?? parameters['user_id'];
  String? get secret => parameters['secret'];
  String? get sessionKey => parameters['key'];

  String? get error => parameters['error_description'] ?? parameters['error'];

  bool get hasRequiredTokenPair =>
      userId?.isNotEmpty == true && secret?.isNotEmpty == true;

  bool get describesExistingSession {
    final details = error?.toLowerCase() ?? '';
    return details.contains('user_session_already_exists') ||
        details.contains('session is active');
  }
}

class OAuthFlow {
  const OAuthFlow._();

  static String mobileCallbackScheme(String projectId) =>
      'appwrite-callback-$projectId';

  static Uri webEntrypoint({
    required String endpoint,
    required String projectId,
    required String successUrl,
    required String failureUrl,
  }) {
    return _entrypoint(
      endpoint: endpoint,
      path: 'account/sessions/oauth2/google',
      projectId: projectId,
      successUrl: successUrl,
      failureUrl: failureUrl,
    );
  }

  static Uri mobileEntrypoint({
    required String endpoint,
    required String projectId,
  }) {
    final scheme = mobileCallbackScheme(projectId);
    return _entrypoint(
      endpoint: endpoint,
      path: 'account/tokens/oauth2/google',
      projectId: projectId,
      successUrl: '$scheme://oauth2success',
      failureUrl: '$scheme://oauth2failure',
    );
  }

  static Uri _entrypoint({
    required String endpoint,
    required String path,
    required String projectId,
    required String successUrl,
    required String failureUrl,
  }) {
    final normalizedEndpoint = endpoint.endsWith('/')
        ? endpoint.substring(0, endpoint.length - 1)
        : endpoint;
    return Uri.parse('$normalizedEndpoint/$path').replace(
      queryParameters: <String, String>{
        'project': projectId,
        'success': successUrl,
        'failure': failureUrl,
      },
    );
  }

  static OAuthCallbackPayload parseMobileCallback({
    required String callback,
    required String expectedScheme,
  }) {
    final fragmentStart = callback.indexOf('#');
    final rawFragment = fragmentStart < 0
        ? ''
        : callback.substring(fragmentStart + 1);
    if (RegExp(r'%(?![0-9A-Fa-f]{2})').hasMatch(rawFragment)) {
      throw const FormatException('Malformed OAuth callback fragment.');
    }
    final uri = Uri.tryParse(callback);
    if (uri == null ||
        uri.scheme != expectedScheme ||
        !const <String>{
          'oauth2success',
          'oauth2failure',
        }.contains(uri.host.toLowerCase())) {
      throw const FormatException('Invalid OAuth callback origin.');
    }

    final parameters = <String, String>{...uri.queryParameters};
    if (uri.fragment.isNotEmpty) {
      try {
        parameters.addAll(Uri.splitQueryString(uri.fragment));
      } on FormatException {
        throw const FormatException('Malformed OAuth callback fragment.');
      }
    }

    return OAuthCallbackPayload(
      uri: uri,
      parameters: Map<String, String>.unmodifiable(parameters),
      isFailure:
          uri.host.toLowerCase() == 'oauth2failure' ||
          parameters.containsKey('error') ||
          parameters.containsKey('error_description'),
    );
  }
}
