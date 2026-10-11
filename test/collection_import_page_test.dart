import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/import/collection_import_background_controller.dart';
import 'package:mymangatheque/src/back/services/import/collection_import_models.dart';
import 'package:mymangatheque/src/back/services/import/collection_import_service.dart';
import 'package:mymangatheque/src/const/layout.dart';
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

class _ProgressImportService extends CollectionImportService {
  final Completer<void> executeGate = Completer<void>();
  int executeCalls = 0;
  bool? lastCancelled;

  CollectionImportItem _item(String id, String title) => CollectionImportItem(
    entry: CollectionImportEntry(sourceIndex: int.parse(id), title: title),
    status: CollectionImportItemStatus.ready,
    candidate: CollectionImportCandidate(id: id, title: title),
  );

  @override
  Future<List<CollectionImportHistoryEntry>> history() async =>
      const <CollectionImportHistoryEntry>[];

  @override
  List<CollectionImportEntry> parse(
    CollectionImportSource source,
    String content,
  ) => const <CollectionImportEntry>[
    CollectionImportEntry(sourceIndex: 1, title: 'Monster'),
    CollectionImportEntry(sourceIndex: 2, title: 'Pluto'),
  ];

  @override
  Future<CollectionImportPreview> buildPreview(
    CollectionImportSource source,
    List<CollectionImportEntry> entries, {
    CollectionImportCancellationToken? cancellation,
    CollectionImportProgress? onProgress,
  }) async {
    final items = <CollectionImportItem>[
      _item('1', 'Monster'),
      _item('2', 'Pluto'),
    ];
    onProgress?.call(1, items.length, items.first);
    onProgress?.call(2, items.length, items.last);
    return CollectionImportPreview(
      id: 'preview-progress',
      source: source,
      createdAt: DateTime.utc(2026, 8, 16),
      items: items,
    );
  }

  @override
  Future<CollectionImportResult> execute(
    CollectionImportPreview preview, {
    CollectionImportCancellationToken? cancellation,
    CollectionImportProgress? onProgress,
  }) async {
    executeCalls += 1;
    final items = List<CollectionImportItem>.from(preview.items);
    items[0] = items[0].copyWith(status: CollectionImportItemStatus.imported);
    onProgress?.call(1, items.length, items[0]);
    await executeGate.future;
    if (cancellation?.isCancelled == true) {
      lastCancelled = true;
      return CollectionImportResult(
        preview: preview.copyWith(items: items),
        importedVolumeIds: const <String>['1'],
        cancelled: true,
      );
    }
    items[1] = items[1].copyWith(status: CollectionImportItemStatus.imported);
    onProgress?.call(2, items.length, items[1]);
    lastCancelled = false;
    return CollectionImportResult(
      preview: preview.copyWith(items: items),
      importedVolumeIds: const <String>['1', '2'],
      cancelled: false,
    );
  }
}

class _FakeBackgroundController
    implements CollectionImportBackgroundController {
  _FakeBackgroundController({this.failOnStart = false});

  final bool failOnStart;
  int startCalls = 0;
  int stopCalls = 0;
  final List<({int completed, int total, String title})> updates = [];

  @override
  Future<void> start({required int total}) async {
    startCalls += 1;
    if (failOnStart) throw StateError('foreground service unavailable');
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }

  @override
  Future<void> update({
    required int completed,
    required int total,
    required String title,
  }) async {
    updates.add((completed: completed, total: total, title: title));
  }
}

Future<void> _pumpImportPage(
  WidgetTester tester, {
  required CollectionImportService service,
  CollectionImportBackgroundController? backgroundController,
  Size size = const Size(390, 844),
  EdgeInsets viewInsets = EdgeInsets.zero,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      home: MediaQuery(
        data: MediaQueryData(size: size, viewInsets: viewInsets),
        child: CollectionImportPage(
          service: service,
          backgroundController: backgroundController,
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _prepareTextPreview(WidgetTester tester) async {
  await tester.tap(
    find.byType(DropdownButtonFormField<CollectionImportSource>),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Text list').last);
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).first, 'Monster\nPluto');
  await tester.tap(find.text('Analyse and preview'));
  await tester.pumpAndSettle();
}

Future<void> _confirmImport(WidgetTester tester, int count) async {
  final importButton = find.text('Import $count matched volumes');
  await tester.ensureVisible(importButton);
  await tester.pumpAndSettle();
  await tester.tap(importButton);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Import'));
  await tester.pump();
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

  testWidgets(
    'import shows fixed progress and updates the Android controller',
    (
      tester,
    ) async {
      final service = _ProgressImportService();
      final background = _FakeBackgroundController();
      await _pumpImportPage(
        tester,
        service: service,
        backgroundController: background,
      );
      await _prepareTextPreview(tester);
      await _confirmImport(tester, 2);

      expect(
        find.byKey(const ValueKey('collection-import-progress-banner')),
        findsOneWidget,
      );
      expect(find.text('Adding volumes'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text('50 %'), findsOneWidget);
      expect(find.text('Monster'), findsWidgets);
      expect(background.startCalls, 1);
      expect(background.updates.single.completed, 1);
      expect(background.updates.single.title, 'Monster');

      service.executeGate.complete();
      await tester.pumpAndSettle();

      expect(background.updates.last.completed, 2);
      expect(background.updates.last.title, 'Pluto');
      expect(background.stopCalls, 1);
      expect(
        find.byKey(const ValueKey('collection-import-progress-banner')),
        findsNothing,
      );
    },
  );

  testWidgets('stopping the banner keeps the partial import result', (
    tester,
  ) async {
    final service = _ProgressImportService();
    final background = _FakeBackgroundController();
    await _pumpImportPage(
      tester,
      service: service,
      backgroundController: background,
    );
    await _prepareTextPreview(tester);
    await _confirmImport(tester, 2);

    await tester.tap(find.text('Stop'));
    service.executeGate.complete();
    await tester.pumpAndSettle();

    expect(service.lastCancelled, isTrue);
    expect(background.stopCalls, 1);
    expect(find.textContaining('1 volumes were added'), findsOneWidget);
  });

  testWidgets('a foreground service start failure prevents all additions', (
    tester,
  ) async {
    final service = _ProgressImportService();
    final background = _FakeBackgroundController(failOnStart: true);
    await _pumpImportPage(
      tester,
      service: service,
      backgroundController: background,
    );
    await _prepareTextPreview(tester);
    await _confirmImport(tester, 2);
    await tester.pumpAndSettle();

    expect(service.executeCalls, 0);
    expect(background.startCalls, 1);
    expect(background.stopCalls, 0);
    expect(find.textContaining('No volume was added'), findsOneWidget);
  });

  testWidgets('bottom clearance follows phone navigation and keyboard', (
    tester,
  ) async {
    final service = _FakeImportService();
    await _pumpImportPage(tester, service: service);

    Padding clearance() => tester.widget<Padding>(
      find.byKey(const ValueKey('collection-import-bottom-clearance')),
    );

    expect(
      (clearance().padding as EdgeInsets).bottom,
      phoneBottomNavigationClearance,
    );

    await _pumpImportPage(
      tester,
      service: service,
      viewInsets: const EdgeInsets.only(bottom: 300),
    );
    expect((clearance().padding as EdgeInsets).bottom, 0);

    await _pumpImportPage(
      tester,
      service: service,
      size: const Size(900, 844),
    );
    expect((clearance().padding as EdgeInsets).bottom, 0);
  });
}
