String redactSensitiveText(Object? value, {int maxLength = 500}) {
  var text = value?.toString() ?? '';

  text = text.replaceAll(
    RegExp(r'Bearer\s+[A-Za-z0-9._~+/=-]+', caseSensitive: false),
    'Bearer [REDACTED]',
  );
  text = text.replaceAll(
    RegExp(r'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+'),
    '[REDACTED_JWT]',
  );
  text = text.replaceAllMapped(
    RegExp(
      r'([?&#](?:secret|token|access_token|refresh_token|key|api[_-]?key|x-api-key|authorization)=)[^&#\s]+',
      caseSensitive: false,
    ),
    (match) => '${match.group(1)}[REDACTED]',
  );
  text = text.replaceAllMapped(
    RegExp(
      r'("(?:secret|token|access_token|refresh_token|api[_-]?key|x-api-key|authorization|password)"\s*:\s*")[^"]*"',
      caseSensitive: false,
    ),
    (match) => '${match.group(1)}[REDACTED]"',
  );
  text = text.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), ' ');

  if (maxLength < 1 || text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}…';
}

Uri? parseSafeHttpsUri(String? rawUrl, {Set<String>? allowedHosts}) {
  final normalized = rawUrl?.trim() ?? '';
  if (normalized.isEmpty) return null;
  final uri = Uri.tryParse(normalized);
  if (uri == null ||
      uri.scheme.toLowerCase() != 'https' ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    return null;
  }
  if (allowedHosts != null &&
      !allowedHosts
          .map((host) => host.toLowerCase())
          .contains(
            uri.host.toLowerCase(),
          )) {
    return null;
  }
  return uri;
}

bool isSafeApiPath(String path) {
  final uri = Uri.tryParse(path);
  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      uri.query.isNotEmpty ||
      uri.fragment.isNotEmpty ||
      uri.path != path ||
      !uri.path.startsWith('/api/') ||
      path.contains(r'\')) {
    return false;
  }
  return !uri.pathSegments.any((segment) => segment == '.' || segment == '..');
}
