import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/import/collection_import_models.dart';
import 'package:mymangatheque/src/back/services/import/collection_import_service.dart';
import 'package:mymangatheque/src/front/page/profile/collection_import_page.dart';

class _FakeImportService extends CollectionImportService {
  _FakeImportService();

  @override
  Future<List<CollectionImportHistoryEntry>> history() async =>
      const <CollectionImportHistoryEntry>[];

  @override
  List<CollectionImportEntry> parse(
    CollectionImportSource source,
    String content,
  ) => const <CollectionImportEntry>[
    CollectionImportEntry(sourceIndex: 1, title: 'Monster', volumeNumber: 1),
  ];

  @override
  Future<CollectionImportPreview> buildPreview(
    CollectionImportSource source,
    List<CollectionImportEntry> entries, {
    CollectionImportCancellationToken? cancellation,
    CollectionImportProgress? onProgress,
  }) async {
    final item = CollectionImportItem(
      entry: entries.single,
      status: CollectionImportItemStatus.ready,
      candidate: const CollectionImportCandidate(
        id: 'volume-1',
        title: 'Monster',
        volumeNumber: 1,
      ),
    );
    onProgress?.call(1, 1, item);
    return CollectionImportPreview(
      id: 'preview-1',
      source: source,
      createdAt: DateTime.utc(2026, 8, 9),
      items: <CollectionImportItem>[item],
    );
  }
}

void main() {
  testWidgets('collection import always displays a preview before commit', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        home: CollectionImportPage(service: _FakeImportService()),
      ),
    );
    await tester.pump();

    await tester.tap(
      find.byType(DropdownButtonFormField<CollectionImportSource>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Text list').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Monster volume 1');
    await tester.tap(find.text('Analyse and preview'));
    await tester.pumpAndSettle();

    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Monster'), findsOneWidget);
    expect(find.text('Import 1 matched volumes'), findsOneWidget);
    expect(find.textContaining('synchron'), findsNothing);
  });
}
