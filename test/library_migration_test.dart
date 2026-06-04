import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';

void main() {
  group('Library Page Data Flow Migration', () {
    test('AppwriteConnector should be singleton', () {
      final connector1 = AppwriteConnector();
      final connector2 = AppwriteConnector();
      expect(identical(connector1, connector2), true);
    });

    test('AppwriteConnector.connector() should return AppwriteCompatClient', () {
      final connector = AppwriteConnector();
      final compatClient = connector.connector();
      expect(compatClient, isNotNull);
    });

    test('Volume model should be properly constructed with required fields', () {
      final volume = Volume(
        id: 'vol-123',
        title: 'Test Volume',
        tomeNumber: 1,
        price: 15,
        image: 'https://example.com/image.jpg',
        over18: false,
        resume: 'Test resume',
        bookLink: const [],
        release: DateTime.now(),
        ean: 123456789,
        language: 'en',
        subSeries: 'sub-series-123',
        readed: false,
        authors: const ['Author 1'],
        series: 'series-123',
        contains: null,
        info: null,
        support: 'manga',
        japGenre: 'Shonen',
        lastTimeChecked: DateTime.now(),
      );

      expect(volume.id, 'vol-123');
      expect(volume.title, 'Test Volume');
      expect(volume.tomeNumber, 1);
      expect(volume.authors.contains('Author 1'), true);
    });

    test('SubSerieForCollection should aggregate volumes correctly', () {
      final vol1 = Volume(
        id: 'vol-1',
        title: 'Volume 1',
        tomeNumber: 1,
        price: 15,
        image: 'https://example.com/img1.jpg',
        over18: false,
        resume: '',
        bookLink: const [],
        release: DateTime.now(),
        ean: 0,
        language: 'en',
        subSeries: 'sub-series-123',
        readed: false,
        authors: const [],
        series: 'series-123',
        contains: null,
        info: null,
        support: 'manga',
        japGenre: null,
        lastTimeChecked: DateTime.now(),
      );

      final subSerie = SubSerieForCollection(
        id: 'sub-series-123',
        title: 'Test Sub Series',
        numberOfVolumes: 10,
        numberOwnedVolumes: 1,
        volumes: [vol1],
        cover: 'https://example.com/cover.jpg',
      );

      expect(subSerie.id, 'sub-series-123');
      expect(subSerie.title, 'Test Sub Series');
      expect(subSerie.numberOwnedVolumes, 1);
      expect(subSerie.volumes.length, 1);
      expect(subSerie.volumes.first.title, 'Volume 1');
    });

    test('Sub series collection should support volume sorting', () {
      final volumes = [
        Volume(
          id: 'vol-3',
          title: 'Volume 3',
          tomeNumber: 3,
          price: 15,
          image: 'img3.jpg',
          over18: false,
          resume: '',
          bookLink: const [],
          release: DateTime(2024, 3),
          ean: 0,
          language: 'en',
          subSeries: 'sub-123',
          readed: false,
          authors: const [],
          series: 'series-123',
          contains: null,
          info: null,
          support: 'manga',
          japGenre: null,
          lastTimeChecked: DateTime.now(),
        ),
        Volume(
          id: 'vol-1',
          title: 'Volume 1',
          tomeNumber: 1,
          price: 15,
          image: 'img1.jpg',
          over18: false,
          resume: '',
          bookLink: const [],
          release: DateTime(2024, 1),
          ean: 0,
          language: 'en',
          subSeries: 'sub-123',
          readed: false,
          authors: const [],
          series: 'series-123',
          contains: null,
          info: null,
          support: 'manga',
          japGenre: null,
          lastTimeChecked: DateTime.now(),
        ),
        Volume(
          id: 'vol-2',
          title: 'Volume 2',
          tomeNumber: 2,
          price: 15,
          image: 'img2.jpg',
          over18: false,
          resume: '',
          bookLink: const [],
          release: DateTime(2024, 2),
          ean: 0,
          language: 'en',
          subSeries: 'sub-123',
          readed: false,
          authors: const [],
          series: 'series-123',
          contains: null,
          info: null,
          support: 'manga',
          japGenre: null,
          lastTimeChecked: DateTime.now(),
        ),
      ];

      volumes.sort((a, b) => (a.tomeNumber ?? 0).compareTo(b.tomeNumber ?? 0));

      expect(volumes[0].tomeNumber, 1);
      expect(volumes[1].tomeNumber, 2);
      expect(volumes[2].tomeNumber, 3);
    });
  });
}
