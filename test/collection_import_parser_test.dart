import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/import/collection_import_models.dart';
import 'package:mymangatheque/src/back/services/import/collection_import_parser.dart';

void main() {
  const parser = CollectionImportParser();

  group('CSV collection import', () {
    test('supports French headers, semicolons and quoted titles', () {
      final entries = parser.parseCsv(
        'Titre;Tome;EAN;Lu\n"JoJo, aventure";2;9781234567890;oui',
      );

      expect(entries, hasLength(1));
      expect(entries.single.title, 'JoJo, aventure');
      expect(entries.single.volumeNumber, 2);
      expect(entries.single.ean, '9781234567890');
      expect(entries.single.read, isTrue);
    });

    test('accepts a headerless title, volume and EAN document', () {
      final entries = parser.parseCsv('Berserk,1,9781234567890');

      expect(entries.single.title, 'Berserk');
      expect(entries.single.volumeNumber, 1);
      expect(entries.single.ean, '9781234567890');
    });
  });

  group('JSON collection import', () {
    test('accepts common export wrappers and aliases', () {
      final entries = parser.parseJson('''
        {"collection":[
          {"titre":"Monster","numero":"3","isbn":"978-1-23-456789-0"},
          {"name":"Pluto","tomeNumber":2}
        ]}
      ''');

      expect(entries, hasLength(2));
      expect(entries.first.title, 'Monster');
      expect(entries.first.volumeNumber, 3);
      expect(entries.first.ean, '9781234567890');
      expect(entries.last.title, 'Pluto');
      expect(entries.last.volumeNumber, 2);
    });

    test('accepts an API-style nested data envelope', () {
      final entries = parser.parseJson(
        '{"data":{"items":[{"title":"Akira","volume":1}]}}',
      );

      expect(entries.single.title, 'Akira');
      expect(entries.single.volumeNumber, 1);
    });

    test('rejects documents without importable data', () {
      expect(
        () => parser.parseJson('{"items":[{"unknown":true}]}'),
        throwsA(isA<CollectionImportFormatException>()),
      );
    });
  });

  group('EAN and text collection import', () {
    test('normalizes a mixed EAN and ISBN list', () {
      final entries = parser.parseEanList(
        '978-1-23-456789-0\n0-306-40615-2;9780987654321',
      );

      expect(
        entries.map((entry) => entry.ean),
        <String>['9781234567890', '0306406152', '9780987654321'],
      );
    });

    test('expands a tome range without blocking on manual repetition', () {
      final entries = parser.parseText('Berserk tome 1 à 12');

      expect(entries, hasLength(12));
      expect(entries.first.title, 'Berserk');
      expect(entries.first.volumeNumber, 1);
      expect(entries.last.volumeNumber, 12);
    });

    test('accepts titles, single tome declarations and EANs together', () {
      final entries = parser.parse(
        CollectionImportSource.text,
        'Akira\nMonster volume 4\n9781234567890',
      );

      expect(entries, hasLength(3));
      expect(entries[0].title, 'Akira');
      expect(entries[1].title, 'Monster');
      expect(entries[1].volumeNumber, 4);
      expect(entries[2].ean, '9781234567890');
    });

    test('rejects pathological ranges and oversized imports', () {
      final entries = parser.parseText('Series tome 1 à 999');
      expect(entries, hasLength(1));
      expect(entries.single.title, 'Series tome 1 à 999');

      final huge = List<String>.generate(
        10001,
        (_) => '9781234567890',
      ).join('\n');
      expect(
        () => parser.parseEanList(huge),
        throwsA(isA<CollectionImportFormatException>()),
      );
    });
  });

  test(
    'history serialization preserves undo state and user-safe identifiers',
    () {
      final entry = CollectionImportHistoryEntry(
        id: 'import-1',
        source: CollectionImportSource.csv,
        createdAt: DateTime.utc(2026, 8, 9),
        importedVolumeIds: const <String>['v1', 'v2'],
        failedCount: 1,
      );

      final restored = CollectionImportHistoryEntry.fromJson(entry.toJson());
      expect(restored.id, entry.id);
      expect(restored.importedVolumeIds, entry.importedVolumeIds);
      expect(restored.canUndo, isTrue);
      expect(restored.markUndone(DateTime.utc(2026, 8, 10)).canUndo, isFalse);
    },
  );
}
