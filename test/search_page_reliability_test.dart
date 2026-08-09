import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/front/page/search/search_page.dart';

void main() {
  testWidgets('a stale realtime response never replaces the latest query', (
    tester,
  ) async {
    final requests = <String, Completer<List<RecordModel>>>{};

    await tester.pumpWidget(
      _app(
        SearchPage(
          debounceDuration: Duration.zero,
          pageLoader: _singlePageLoader,
          suggestionLoader: (mode, query, limit) {
            final completer = Completer<List<RecordModel>>();
            requests[query] = completer;
            return completer.future;
          },
        ),
      ),
    );
    await tester.pump();

    final field = find.byType(CupertinoTextField);
    await tester.enterText(field, 'na');
    await tester.pump();
    expect(requests, contains('na'));

    await tester.enterText(field, 'nar');
    await tester.pump();
    expect(requests, contains('nar'));

    requests['nar']!.complete(<RecordModel>[_series('latest', 'Naruto')]);
    await tester.pump();
    expect(find.text('Naruto'), findsOneWidget);

    requests['na']!.complete(<RecordModel>[_series('stale', 'Nana')]);
    await tester.pump();
    expect(find.text('Naruto'), findsOneWidget);
    expect(find.text('Nana'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pagination does not start the same next page twice', (
    tester,
  ) async {
    final secondPage = Completer<RecordPage>();
    var secondPageCalls = 0;

    Future<RecordPage> loader(
      String mode,
      String? query,
      int page,
      int limit,
    ) {
      if (page == 1) {
        return Future<RecordPage>.value(
          RecordPage(
            items: List<RecordModel>.generate(
              30,
              (index) => _series('series-$index', 'Series $index'),
            ),
            page: 1,
            totalPages: 3,
            totalItems: 60,
          ),
        );
      }
      secondPageCalls += 1;
      return secondPage.future;
    }

    await tester.pumpWidget(
      _app(SearchPage(pageLoader: loader, suggestionLoader: _noSuggestions)),
    );
    await tester.pump();

    final list = find.byType(ListView);
    await tester.drag(list, const Offset(0, -4000));
    await tester.pump();
    await tester.drag(list, const Offset(0, -1000));
    await tester.pump();

    expect(secondPageCalls, 1);

    secondPage.complete(
      const RecordPage(
        items: <RecordModel>[],
        page: 2,
        totalPages: 2,
        totalItems: 30,
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

Future<RecordPage> _singlePageLoader(
  String mode,
  String? query,
  int page,
  int limit,
) async {
  return RecordPage(
    items: <RecordModel>[_series('browse', 'Browse result')],
    page: 1,
    totalPages: 1,
    totalItems: 1,
  );
}

Future<List<RecordModel>> _noSuggestions(
  String mode,
  String query,
  int limit,
) async => <RecordModel>[];

RecordModel _series(String id, String title) {
  return RecordModel(
    id: id,
    collectionId: 'series',
    data: <String, dynamic>{
      'id': id,
      'title': title,
      'coverUrl': '',
    },
  );
}

Widget _app(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}
