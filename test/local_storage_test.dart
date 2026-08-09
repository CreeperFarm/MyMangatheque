import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:mymangatheque/src/models/manga/author.dart';
import 'package:mymangatheque/src/models/manga/editor.dart';
import 'package:mymangatheque/src/models/manga/serie.dart';
import 'package:mymangatheque/src/models/manga/sub_serie.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const secureStorage = FlutterSecureStorage();
  late LocalStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    storage = LocalStorage();
  });

  test('migrates a legacy token and removes the plaintext copy', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{'token': 'legacy'});

    expect(await storage.getToken(), 'legacy');
    expect(await secureStorage.read(key: 'token'), 'legacy');
    expect(
      (await SharedPreferences.getInstance()).containsKey('token'),
      isFalse,
    );
  });

  test('prefers the secure token over stale legacy storage', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      'token': 'secure',
    });
    SharedPreferences.setMockInitialValues(<String, Object>{'token': 'stale'});

    expect(await storage.getToken(), 'secure');
  });

  test('writes and deletes authentication tokens securely', () async {
    await storage.setToken('new-token');
    expect(await secureStorage.read(key: 'token'), 'new-token');

    await storage.deleteToken();
    expect(await secureStorage.read(key: 'token'), isNull);
  });

  test('round-trips and deletes language and content preferences', () async {
    expect(await storage.getLanguageCode(), isNull);
    expect(await storage.getAdultContentEnabled(), isFalse);

    await storage.setLanguageCode('fr');
    await storage.setAdultContentEnabled(true);
    expect(await storage.getLanguageCode(), 'fr');
    expect(await storage.getAdultContentEnabled(), isTrue);

    await storage.deleteLanguageCode();
    await storage.deleteAdultContentEnabled();
    expect(await storage.getLanguageCode(), isNull);
    expect(await storage.getAdultContentEnabled(), isFalse);
  });

  test('round-trips every local catalogue cache', () async {
    final checkedAt = DateTime.utc(2026, 8, 8);
    final volume = _volume(checkedAt);
    final owned = SubSerieForCollection(
      id: 'owned-1',
      title: 'Owned',
      numberOfVolumes: 2,
      numberOwnedVolumes: 1,
      volumes: <Volume>[volume],
      cover: 'https://cdn.example/owned.webp',
    );
    final serie = Serie(
      id: 'serie-1',
      image: 'https://cdn.example/serie.webp',
      title: 'Serie',
      subSeries: <String>['sub-1'],
      authors: <String>['author-1'],
      editors: <String>['editor-1'],
      genres: <String>['genre-1'],
      lastTimeChecked: checkedAt,
    );
    final subSerie = SubSerie(
      id: 'sub-1',
      title: 'Sub',
      serie: 'serie-1',
      volumes: <String>['volume-1'],
      authors: <String>['author-1'],
      editor: 'editor-1',
      image: 'https://cdn.example/sub.webp',
      genres: <String>['genre-1'],
      firstPublication: DateTime.utc(2020),
      lastTimeChecked: checkedAt,
    );
    final author = Author(
      id: 'author-1',
      name: 'Author',
      image: 'https://cdn.example/author.webp',
      series: <String>['serie-1'],
      job: 'Writer',
      lastTimeChecked: checkedAt,
    );
    final editor = Editor(
      id: 'editor-1',
      name: 'Editor',
      image: 'https://cdn.example/editor.webp',
      series: <String>['serie-1'],
      lastTimeChecked: checkedAt,
    );

    await storage.saveOwnedSubSerie(<SubSerieForCollection>{owned});
    await storage.saveCacheSeries(<Serie>{serie});
    await storage.saveCacheSubSeries(<SubSerie>{subSerie});
    await storage.saveCacheVolumes(<Volume>{volume});
    await storage.saveCacheAuthors(<Author>{author});
    await storage.saveCacheEditors(<Editor>{editor});

    expect((await storage.getOwnedSubSerie())!.single.cover, owned.cover);
    expect((await storage.getCacheSeries())!.single.title, 'Serie');
    expect((await storage.getCacheSubSeries())!.single.editor, 'editor-1');
    expect((await storage.getCacheVolumes())!.single.id, 'volume-1');
    expect((await storage.getCacheAuthors())!.single.job, 'Writer');
    expect((await storage.getCacheEditors())!.single.name, 'Editor');
  });

  test(
    'isolates owned collection caches between authenticated users',
    () async {
      final first = SubSerieForCollection(
        id: 'first-user-series',
        title: 'First user series',
        numberOfVolumes: 1,
        numberOwnedVolumes: 1,
        volumes: <Volume>[_volume(DateTime.utc(2026, 8, 8))],
      );
      final second = SubSerieForCollection(
        id: 'second-user-series',
        title: 'Second user series',
        numberOfVolumes: 1,
        numberOwnedVolumes: 0,
        volumes: const <Volume>[],
      );

      await storage.saveOwnedSubSerie(
        <SubSerieForCollection>{first},
        userId: 'user/one',
      );
      await storage.saveOwnedSubSerie(
        <SubSerieForCollection>{second},
        userId: 'user/two',
      );

      expect(
        (await storage.getOwnedSubSerie(userId: 'user/one'))!.single.id,
        'first-user-series',
      );
      expect(
        (await storage.getOwnedSubSerie(userId: 'user/two'))!.single.id,
        'second-user-series',
      );

      await storage.deleteOwnedSubSerie(userId: 'user/one');
      expect(await storage.getOwnedSubSerie(userId: 'user/one'), isNull);
      expect(await storage.getOwnedSubSerie(userId: 'user/two'), isNotNull);
    },
  );

  test('discards a malformed owned collection cache safely', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'ownedSubSerie:user': '{not-json',
    });

    expect(await storage.getOwnedSubSerie(userId: 'user'), isNull);
    expect(
      (await SharedPreferences.getInstance()).containsKey(
        'ownedSubSerie:user',
      ),
      isFalse,
    );
  });

  test(
    'clearAllCache removes catalogue data but preserves preferences',
    () async {
      final checkedAt = DateTime.utc(2026, 8, 8);
      await storage.saveCacheVolumes(<Volume>{_volume(checkedAt)});
      await storage.setLanguageCode('fr');
      await storage.setAdultContentEnabled(true);
      await storage.setScanPreviousVolumesSuggestionEnabled(false);

      await storage.clearAllCache();

      expect(await storage.getCacheVolumes(), isNull);
      expect(await storage.getLanguageCode(), 'fr');
      expect(await storage.getAdultContentEnabled(), isTrue);
      expect(await storage.getScanPreviousVolumesSuggestionEnabled(), isFalse);
    },
  );

  test(
    'persists display density and user-scoped missing-volume choices',
    () async {
      await storage.setDisplayDensity(AppDisplayDensity.compact);
      await storage.setMissingVolumeWanted(
        'volume-1',
        wanted: true,
        userId: 'user-a',
      );
      await storage.setReleaseAlert(
        'sub-series-1',
        enabled: true,
        userId: 'user-a',
      );

      expect(await storage.getDisplayDensity(), AppDisplayDensity.compact);
      expect(await storage.getWantedMissingVolumeIds(userId: 'user-a'), {
        'volume-1',
      });
      expect(
        await storage.getWantedMissingVolumeIds(userId: 'user-b'),
        isEmpty,
      );
      expect(await storage.getReleaseAlertSubSeriesIds(userId: 'user-a'), {
        'sub-series-1',
      });
    },
  );
}

Volume _volume(DateTime checkedAt) => Volume(
  id: 'volume-1',
  title: 'Volume',
  tomeNumber: 1,
  price: 7.95,
  image: 'https://cdn.example/volume.webp',
  over18: false,
  resume: 'Summary',
  bookLink: <dynamic>['https://shop.example/volume'],
  release: null,
  ean: 9780306406157,
  language: 'fr',
  subSeries: 'sub-1',
  series: 'serie-1',
  readed: true,
  authors: const <String>['author-1'],
  contains: const <String>['chapter-1'],
  info: const <String, dynamic>{'pages': 192},
  support: 'paper',
  japGenre: 'shonen',
  lastTimeChecked: checkedAt,
);
