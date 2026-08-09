import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/front/page/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('home exposes a retry and recovers after an initial failure', (
    tester,
  ) async {
    var calls = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MyHomePage(
            title: 'Home',
            recommendationLoader: ({required page, required limit}) async {
              calls += 1;
              if (calls == 1) throw Exception('offline');
              return RecordPage(
                items: <RecordModel>[
                  RecordModel(
                    id: 'volume-1',
                    collectionId: 'volumes',
                    data: <String, dynamic>{
                      'id': 'volume-1',
                      'title': 'Recovered recommendation',
                      'coverUrl': '',
                    },
                  ),
                ],
                page: 1,
                totalPages: 1,
                totalItems: 1,
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();

    expect(calls, 2);
    expect(find.text('Recovered recommendation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows persistent recommendations before network refresh', (
    tester,
  ) async {
    final refresh = Completer<RecordPage>();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MyHomePage(
            title: 'Home',
            cacheLoader: ({required page, required limit}) async => RecordPage(
              items: <RecordModel>[
                _recommendation('cached', 'Cached recommendation'),
              ],
              page: 1,
              totalPages: 1,
              totalItems: 1,
            ),
            recommendationLoader: ({required page, required limit}) {
              return refresh.future;
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Cached recommendation'), findsOneWidget);

    refresh.complete(
      RecordPage(
        items: <RecordModel>[
          _recommendation('fresh', 'Fresh recommendation'),
        ],
        page: 1,
        totalPages: 1,
        totalItems: 1,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fresh recommendation'), findsOneWidget);
    expect(find.text('Cached recommendation'), findsNothing);
  });

  testWidgets('shows recommendation reasons and hides irrelevant suggestions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MyHomePage(
              title: 'Home',
              recommendationLoader: ({required page, required limit}) async {
                return RecordPage(
                  items: <RecordModel>[
                    RecordModel(
                      id: 'explained',
                      collectionId: 'volumes',
                      data: <String, dynamic>{
                        'id': 'explained',
                        'title': 'Explained suggestion',
                        'coverUrl': '',
                        'recommendationMeta': <String, dynamic>{
                          'explanation': 'Similar to Monster',
                        },
                      },
                    ),
                  ],
                  page: 1,
                  totalPages: 1,
                  totalItems: 1,
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Similar to Monster'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not relevant to me'));
    await tester.pump();

    expect(find.text('Explained suggestion'), findsNothing);
    expect(find.textContaining('Feedback saved'), findsOneWidget);
  });
}

RecordModel _recommendation(String id, String title) => RecordModel(
  id: id,
  collectionId: 'volumes',
  data: <String, dynamic>{'id': id, 'title': title, 'coverUrl': ''},
);
