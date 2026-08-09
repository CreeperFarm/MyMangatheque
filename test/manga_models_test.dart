import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/models/api_record_model.dart';
import 'package:mymangatheque/src/models/manga/author.dart';
import 'package:mymangatheque/src/models/manga/editor.dart';
import 'package:mymangatheque/src/models/manga/serie.dart';
import 'package:mymangatheque/src/models/manga/sub_serie.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';

void main() {
  final checkedAt = DateTime.utc(2026, 8, 8, 12, 30);

  test('Author supports coverUrl compatibility and JSON round-trip', () {
    final author = Author.fromJson(<String, dynamic>{
      'id': 'author-1',
      'name': 'Author',
      'coverUrl': 'https://cdn.example/author.webp',
      'series': <String>['serie-1'],
      'job': 'Writer',
      'lastTimeChecked': checkedAt.toIso8601String(),
    });

    expect(author.image, 'https://cdn.example/author.webp');
    expect(Author.fromJson(author.toJson()).toJson(), author.toJson());
  });

  test('Editor supports image compatibility and JSON round-trip', () {
    final editor = Editor.fromJson(<String, dynamic>{
      'id': 'editor-1',
      'name': 'Editor',
      'image': 'https://cdn.example/editor.webp',
      'series': <String>['serie-1'],
      'lastTimeChecked': checkedAt.toIso8601String(),
    });

    expect(editor.image, 'https://cdn.example/editor.webp');
    expect(Editor.fromJson(editor.toJson()).toJson(), editor.toJson());
  });

  test('Serie supports coverUrl compatibility and JSON round-trip', () {
    final serie = Serie.fromJson(<String, dynamic>{
      'id': 'serie-1',
      'title': 'Serie',
      'coverUrl': 'https://cdn.example/serie.webp',
      'subSeries': <String>['sub-1'],
      'authors': <String>['author-1'],
      'editors': <String>['editor-1'],
      'genres': <String>['genre-1'],
      'lastTimeChecked': checkedAt.toIso8601String(),
    });

    expect(serie.image, 'https://cdn.example/serie.webp');
    expect(Serie.fromJson(serie.toJson()).toJson(), serie.toJson());
  });

  test('SubSerie supports coverUrl compatibility and JSON round-trip', () {
    final subSerie = SubSerie.fromJson(<String, dynamic>{
      'id': 'sub-1',
      'title': 'Sub',
      'serie': 'serie-1',
      'volumes': <String>['volume-1'],
      'authors': <String>['author-1'],
      'editor': 'editor-1',
      'coverUrl': 'https://cdn.example/sub.webp',
      'genres': <String>['genre-1'],
      'firstPublication': DateTime.utc(2020).toIso8601String(),
      'lastTimeChecked': checkedAt.toIso8601String(),
    });

    expect(subSerie.image, 'https://cdn.example/sub.webp');
    expect(SubSerie.fromJson(subSerie.toJson()).toJson(), subSerie.toJson());
  });

  test('Volume keeps nullable release and optional structured fields', () {
    final json = <String, dynamic>{
      'id': 'volume-1',
      'title': 'Volume',
      'tomeNumber': 1.5,
      'price': 8.25,
      'coverUrl': 'https://cdn.example/volume.webp',
      'over18': false,
      'resume': 'Summary',
      'bookLink': <String>['https://shop.example/volume'],
      'release': null,
      'ean': 9780306406157,
      'language': null,
      'subSeries': 'sub-1',
      'series': 'serie-1',
      'authors': <String>['author-1'],
      'contains': <String>['chapter-1'],
      'info': <String, dynamic>{'pages': 192},
      'support': 'paper',
      'japGenre': null,
      'readed': false,
      'lastTimeChecked': checkedAt.toIso8601String(),
    };

    final volume = Volume.fromJson(json);

    expect(volume.release, isNull);
    expect(volume.image, 'https://cdn.example/volume.webp');
    expect(volume.contains, <String>['chapter-1']);
    expect(volume.info, <String, dynamic>{'pages': 192});
    expect(Volume.fromJson(volume.toJson()).toJson(), volume.toJson());
  });

  test('SubSerieForCollection preserves cover and manages volumes by ID', () {
    final volume = Volume.fromJson(<String, dynamic>{
      'id': 'volume-1',
      'title': 'Volume',
      'tomeNumber': 1,
      'price': 8,
      'image': '',
      'over18': false,
      'resume': '',
      'bookLink': <dynamic>[],
      'release': null,
      'ean': 0,
      'language': 'fr',
      'subSeries': 'sub-1',
      'series': 'serie-1',
      'authors': <String>[],
      'contains': null,
      'info': null,
      'support': 'paper',
      'japGenre': null,
      'readed': false,
      'lastTimeChecked': checkedAt.toIso8601String(),
    });
    final collection = SubSerieForCollection.fromJson(<String, dynamic>{
      'id': 'sub-1',
      'title': 'Sub',
      'numberOfVolumes': 1,
      'numberOwnedVolumes': 1,
      'cover': 'https://cdn.example/sub.webp',
      'volumes': <Map<String, dynamic>>[volume.toJson()],
    });

    expect(collection.cover, 'https://cdn.example/sub.webp');
    expect(collection.containsVolume(volume), isTrue);
    collection.removeVolume(volume);
    expect(collection.containsVolume(volume), isFalse);
    expect(collection.toJson()['cover'], 'https://cdn.example/sub.webp');
  });

  test('ApiRecordModel flattens data and serializes predictably', () {
    final record = ApiRecordModel(
      id: 'record-1',
      collectionId: 'collection-1',
      data: <String, dynamic>{'title': 'Title', 'enabled': true},
    );

    expect(record.toJson(), <String, dynamic>{
      'id': 'record-1',
      'collectionId': 'collection-1',
      'title': 'Title',
      'enabled': true,
    });
    expect(record.toString(), contains('"record-1"'));
  });

  test('CompatSubscription calls unsubscribe for every explicit request', () {
    var calls = 0;
    final subscription = CompatSubscription(() => calls++);

    subscription.unsubscribe();
    subscription.unsubscribe();

    expect(calls, 2);
  });
}
