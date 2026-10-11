import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/import/collection_import_parser.dart';
import 'package:mymangatheque/src/back/services/import/collection_import_service.dart';

void main() {
  group('Mangacollec collection URL', () {
    test('expands a username to the public collection URL', () {
      expect(
        CollectionImportService.mangacollecCollectionUrl('manga-reader'),
        'https://www.mangacollec.com/user/manga-reader/collection',
      );
    });

    test('canonicalizes supported profile and collection URLs', () {
      expect(
        CollectionImportService.mangacollecCollectionUrl(
          'https://mangacollec.com/user/manga-reader',
        ),
        'https://www.mangacollec.com/user/manga-reader/collection',
      );
      expect(
        CollectionImportService.mangacollecCollectionUrl(
          'https://www.mangacollec.com/user/manga-reader/collection',
        ),
        'https://www.mangacollec.com/user/manga-reader/collection',
      );
    });

    test('rejects insecure, foreign and malformed profile URLs', () {
      for (final profile in <String>[
        'http://www.mangacollec.com/user/reader/collection',
        'https://attacker.example/user/reader/collection',
        'https://www.mangacollec.com/reader/collection',
        'reader/collection',
      ]) {
        expect(
          () => CollectionImportService.mangacollecCollectionUrl(profile),
          throwsA(isA<CollectionImportFormatException>()),
          reason: profile,
        );
      }
    });
  });
}
