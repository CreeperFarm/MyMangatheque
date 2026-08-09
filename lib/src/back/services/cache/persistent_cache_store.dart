import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PersistentCacheFreshness { fresh, stale }

class PersistentCacheEntry {
  const PersistentCacheEntry({
    required this.data,
    required this.savedAt,
    required this.expiresAt,
    required this.freshness,
  });

  final Object? data;
  final DateTime savedAt;
  final DateTime expiresAt;
  final PersistentCacheFreshness freshness;

  bool get isFresh => freshness == PersistentCacheFreshness.fresh;
}

/// Versioned JSON cache shared by catalogue, recommendations and planning.
///
/// Authentication material is deliberately excluded: this store only accepts
/// JSON-compatible application data. Private entries must provide a user scope.
class PersistentCacheStore {
  PersistentCacheStore({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const String _prefix = 'mymangatheque.cache.v1:';
  static const int _schemaVersion = 1;
  static const int _webMaxBytes = 4 * 1024 * 1024;
  static const int _nativeMaxBytes = 16 * 1024 * 1024;

  static int get defaultMaxBytes => kIsWeb ? _webMaxBytes : _nativeMaxBytes;

  final DateTime Function() _clock;

  String _key(String namespace, String? scope) {
    final normalizedScope = scope?.trim().isNotEmpty == true
        ? scope!.trim()
        : 'public';
    final raw = '$namespace::$normalizedScope';
    return '$_prefix${base64Url.encode(utf8.encode(raw)).replaceAll('=', '')}';
  }

  Future<PersistentCacheEntry?> read(
    String namespace, {
    String? scope,
    Duration maxStale = const Duration(days: 14),
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final key = _key(namespace, scope);
    final raw = preferences.getString(key);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) throw const FormatException('Invalid cache shape');
      final envelope = Map<String, dynamic>.from(decoded);
      if (envelope['schema'] != _schemaVersion ||
          envelope['namespace'] != namespace) {
        await preferences.remove(key);
        return null;
      }

      final savedAt = DateTime.parse(envelope['savedAt'].toString()).toUtc();
      final expiresAt = DateTime.parse(
        envelope['expiresAt'].toString(),
      ).toUtc();
      final now = _clock().toUtc();
      if (now.isAfter(expiresAt.add(maxStale))) {
        await preferences.remove(key);
        return null;
      }

      return PersistentCacheEntry(
        data: envelope['data'],
        savedAt: savedAt,
        expiresAt: expiresAt,
        freshness: now.isAfter(expiresAt)
            ? PersistentCacheFreshness.stale
            : PersistentCacheFreshness.fresh,
      );
    } on Object catch (error) {
      await preferences.remove(key);
      RuntimeLocalization.debug(
        en: 'Discarded an invalid persistent application cache: $error',
        fr: 'Un cache applicatif persistant invalide a été supprimé : $error',
      );
      return null;
    }
  }

  Future<void> write(
    String namespace,
    Object? data, {
    String? scope,
    required Duration ttl,
    int maxEntries = 80,
    int? maxBytes,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final now = _clock().toUtc();
    final normalizedScope = scope?.trim().isNotEmpty == true
        ? scope!.trim()
        : 'public';
    final envelope = <String, dynamic>{
      'schema': _schemaVersion,
      'namespace': namespace,
      'scope': normalizedScope,
      'savedAt': now.toIso8601String(),
      'expiresAt': now.add(ttl).toIso8601String(),
      'data': data,
    };
    await preferences.setString(
      _key(namespace, normalizedScope),
      jsonEncode(envelope),
    );
    await prune(
      maxEntries: maxEntries,
      maxBytes: maxBytes ?? defaultMaxBytes,
    );
  }

  Future<void> remove(String namespace, {String? scope}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key(namespace, scope));
  }

  Future<void> clear({String? scope}) async {
    final preferences = await SharedPreferences.getInstance();
    final normalizedScope = scope?.trim();
    final keys = preferences.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      if (normalizedScope == null || normalizedScope.isEmpty) {
        await preferences.remove(key);
        continue;
      }
      final envelope = _decodeEnvelope(preferences.getString(key));
      if (envelope?['scope'] == normalizedScope) {
        await preferences.remove(key);
      }
    }
  }

  Future<void> clearNamespace(String namespacePrefix) async {
    final preferences = await SharedPreferences.getInstance();
    final keys = preferences.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      final envelope = _decodeEnvelope(preferences.getString(key));
      final namespace = envelope?['namespace']?.toString() ?? '';
      if (namespace == namespacePrefix ||
          namespace.startsWith('$namespacePrefix.')) {
        await preferences.remove(key);
      }
    }
  }

  Future<void> prune({int maxEntries = 80, int? maxBytes}) async {
    final preferences = await SharedPreferences.getInstance();
    final entries = <({String key, DateTime savedAt, int bytes})>[];
    final now = _clock().toUtc();
    for (final key in preferences.getKeys().where(
      (item) => item.startsWith(_prefix),
    )) {
      final raw = preferences.getString(key);
      final envelope = _decodeEnvelope(raw);
      final savedAt = DateTime.tryParse(envelope?['savedAt']?.toString() ?? '');
      final expiresAt = DateTime.tryParse(
        envelope?['expiresAt']?.toString() ?? '',
      );
      if (envelope == null || savedAt == null || expiresAt == null) {
        await preferences.remove(key);
        continue;
      }
      if (now.isAfter(expiresAt.toUtc().add(const Duration(days: 14)))) {
        await preferences.remove(key);
        continue;
      }
      entries.add((
        key: key,
        savedAt: savedAt,
        bytes: utf8.encode(raw ?? '').length,
      ));
    }

    entries.sort((a, b) => a.savedAt.compareTo(b.savedAt));
    final byteLimit = maxBytes ?? defaultMaxBytes;
    var totalBytes = entries.fold<int>(
      0,
      (total, entry) => total + entry.bytes,
    );
    var entriesToRemove = entries.length > maxEntries
        ? entries.length - maxEntries
        : 0;
    var index = 0;
    while (index < entries.length &&
        (entriesToRemove > 0 || totalBytes > byteLimit)) {
      final entry = entries[index++];
      await preferences.remove(entry.key);
      totalBytes -= entry.bytes;
      if (entriesToRemove > 0) entriesToRemove -= 1;
    }
  }

  Map<String, dynamic>? _decodeEnvelope(String? raw) {
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } on Object {
      return null;
    }
  }
}
