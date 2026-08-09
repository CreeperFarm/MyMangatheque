import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/app_router/app_navigation.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/back/services/cache/persistent_cache_store.dart';
import 'package:mymangatheque/src/front/page/planning/planning_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('planning is restored as the third main navigation branch', () {
    final shell = AppNavigation.router.configuration.routes
        .whereType<StatefulShellRoute>()
        .single;
    final paths = shell.branches
        .map((branch) => (branch.routes.single as GoRoute).path)
        .toList();
    expect(paths, ['/', '/library', '/planning', '/search', '/profile']);
  });

  testWidgets('renders and pages through real release results', (tester) async {
    final now = DateTime(2026, 8, 8, 12);
    var requestedMonth = 0;
    await tester.pumpWidget(
      _app(
        PlanningPage(
          clock: () => now,
          loader: (start, end) async {
            requestedMonth = start.month;
            return <RecordModel>[
              _record('volume-1', 'Release one', DateTime(2026, 8, 12)),
            ];
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Release one'), findsOneWidget);
    expect(find.textContaining('August 2026'), findsOneWidget);
    expect(requestedMonth, 8);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(requestedMonth, 9);
  });

  testWidgets('keeps stale planning data available while offline', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 8, 8, 12);
    final cache = PersistentCacheStore(clock: () => now);
    final cachedRecord = _record(
      'cached-volume',
      'Cached release',
      DateTime(2026, 8, 10),
    );
    await cache.write(
      'planning.2026.08',
      <Map<String, dynamic>>[
        <String, dynamic>{
          'id': cachedRecord.id,
          'collectionId': cachedRecord.collectionId,
          'data': cachedRecord.data,
        },
      ],
      ttl: const Duration(hours: 1),
    );

    await tester.pumpWidget(
      _app(
        PlanningPage(
          clock: () => now,
          cacheStore: cache,
          loader: (start, end) async => throw Exception('offline'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cached release'), findsOneWidget);
    expect(find.textContaining('Offline data'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

RecordModel _record(String id, String title, DateTime release) => RecordModel(
  id: id,
  collectionId: 'volumes',
  data: <String, dynamic>{
    'id': id,
    'title': title,
    'tome_number': 1,
    'coverUrl': '',
    'release': release.toIso8601String(),
  },
);
