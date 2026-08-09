import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/cache/persistent_cache_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DateTime now;
  late PersistentCacheStore cache;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    now = DateTime.utc(2026, 8, 8, 12);
    cache = PersistentCacheStore(clock: () => now);
  });

  test('distinguishes fresh, stale and expired entries', () async {
    await cache.write(
      'home',
      <String, dynamic>{'value': 1},
      ttl: const Duration(hours: 1),
    );

    expect((await cache.read('home'))?.isFresh, isTrue);
    now = now.add(const Duration(hours: 2));
    expect(
      (await cache.read('home'))?.freshness,
      PersistentCacheFreshness.stale,
    );
    now = now.add(const Duration(days: 15));
    expect(await cache.read('home'), isNull);
  });

  test('isolates private cache entries by user scope', () async {
    await cache.write(
      'collection',
      <String>['private-a'],
      scope: 'user-a',
      ttl: const Duration(days: 1),
    );
    await cache.write(
      'collection',
      <String>['private-b'],
      scope: 'user-b',
      ttl: const Duration(days: 1),
    );

    expect((await cache.read('collection', scope: 'user-a'))?.data, [
      'private-a',
    ]);
    expect((await cache.read('collection', scope: 'user-b'))?.data, [
      'private-b',
    ]);

    await cache.clear(scope: 'user-a');
    expect(await cache.read('collection', scope: 'user-a'), isNull);
    expect(await cache.read('collection', scope: 'user-b'), isNotNull);
  });

  test('prunes least-recently-written entries and invalid envelopes', () async {
    for (var index = 0; index < 4; index++) {
      await cache.write(
        'entry-$index',
        index,
        ttl: const Duration(days: 1),
        maxEntries: 3,
      );
      now = now.add(const Duration(minutes: 1));
    }
    expect(await cache.read('entry-0'), isNull);
    expect(await cache.read('entry-3'), isNotNull);

    final preferences = await SharedPreferences.getInstance();
    final key = preferences.getKeys().first;
    await preferences.setString(key, jsonEncode(<String, Object>{'bad': true}));
    await cache.prune();
    expect(preferences.containsKey(key), isFalse);
  });

  test('enforces the storage quota by evicting oldest entries', () async {
    await cache.write(
      'oldest',
      'a' * 300,
      ttl: const Duration(days: 1),
      maxBytes: 100000,
    );
    now = now.add(const Duration(minutes: 1));
    await cache.write(
      'newest',
      'b' * 300,
      ttl: const Duration(days: 1),
      maxBytes: 650,
    );

    expect(await cache.read('oldest'), isNull);
    expect(await cache.read('newest'), isNotNull);
  });

  test('pruning removes entries beyond their stale retention window', () async {
    await cache.write(
      'expired',
      <String, dynamic>{'value': true},
      ttl: const Duration(hours: 1),
    );
    now = now.add(const Duration(days: 15));

    await cache.prune();

    expect(await cache.read('expired'), isNull);
  });
}
