import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/back/services/models/api_record_model.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/front/page/library/tab_page/collection_tab.dart';
import 'package:mymangatheque/src/front/page/library/tab_page/complete_lib_tab.dart';
import 'package:mymangatheque/src/front/page/library/tab_page/envy_tab.dart';
import 'package:mymangatheque/src/front/page/library/tab_page/read_pile_tab.dart';
import 'package:mymangatheque/src/front/page/library/library_tab_data.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:mymangatheque/src/models/local_storage/service_locator.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('library tab data', () {
    test('counts actual hydrated volumes instead of stale metadata', () {
      final series = <SubSerieForCollection>[
        _subSeries(
          id: 'a',
          title: 'A',
          reportedOwned: 99,
          volumes: <Volume>[
            _volume('a-1', tome: 1, read: true),
            _volume('a-2', tome: 2, read: false),
          ],
        ),
      ];

      expect(ownedLibraryVolumeCount(series), 2);
      expect(readLibraryVolumeCount(series), 1);
    });

    test('builds a read pile containing only unread sorted volumes', () {
      final result = buildReadPileSubSeries(<SubSerieForCollection>[
        _subSeries(
          id: 'b',
          title: 'Beta',
          volumes: <Volume>[
            _volume('b-3', tome: 3, read: false),
            _volume('b-1', tome: 1, read: true),
            _volume('b-2', tome: 2, read: false),
          ],
        ),
        _subSeries(
          id: 'a',
          title: 'Alpha',
          volumes: <Volume>[_volume('a-1', tome: 1, read: true)],
        ),
      ]);

      expect(result, hasLength(1));
      expect(result.single.id, 'b');
      expect(result.single.numberOwnedVolumes, 3);
      expect(result.single.volumes.map((volume) => volume.id), ['b-2', 'b-3']);
    });

    test('searches volume titles and orders by the latest known release', () {
      final old = _subSeries(
        id: 'old',
        title: 'Alpha',
        volumes: <Volume>[
          _volume('old-1', tome: 1, title: 'Special search', year: 2020),
        ],
      );
      final recent = _subSeries(
        id: 'recent',
        title: 'Zulu',
        volumes: <Volume>[_volume('recent-1', tome: 1, year: 2026)],
      );

      expect(
        filterLibrarySubSeries(
          <SubSerieForCollection>[old, recent],
          searchQuery: 'special',
        ).single.id,
        'old',
      );
      expect(
        filterLibrarySubSeries(
          <SubSerieForCollection>[old, recent],
          order: 'releaseDate',
        ).map((item) => item.id),
        ['recent', 'old'],
      );
    });

    test('extracts relation IDs from every supported API shape', () {
      expect(libraryRelationId('sub-1'), 'sub-1');
      expect(libraryRelationId(<String, dynamic>{'id': 'sub-2'}), 'sub-2');
      expect(libraryRelationId(<String, dynamic>{r'$id': 'sub-3'}), 'sub-3');
      expect(
        libraryRelationId(<dynamic>[
          null,
          <String, dynamic>{'id': 'sub-4'},
        ]),
        'sub-4',
      );
      expect(libraryRelationId(<String, dynamic>{'title': 'No ID'}), isEmpty);
    });

    test('prioritizes wanted and available missing volumes', () {
      final now = DateTime.utc(2026, 8, 8);
      final available = _volume('available', tome: 3, year: 2026);
      final announced = _volume('announced', tome: 1, year: 2027);
      final wanted = _volume('wanted', tome: 2);

      final result = prioritizeMissingVolumes(
        <Volume>[announced, wanted, available],
        wantedVolumeIds: const <String>{'wanted'},
        now: now,
      );

      expect(result.map((volume) => volume.id), [
        'wanted',
        'available',
        'announced',
      ]);
      expect(
        missingVolumeAvailability(available, now: now),
        MissingVolumeAvailability.available,
      );
      expect(
        missingVolumeAvailability(announced, now: now),
        MissingVolumeAvailability.announced,
      );
      expect(
        missingVolumeAvailability(wanted, now: now),
        MissingVolumeAvailability.unreleased,
      );
    });
  });

  group('MangaOwnedNotifier mutations', () {
    late ProviderContainer container;
    late MangaOwnedNotifier notifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await getIt.reset();
      setupServiceLocator();
      container = ProviderContainer();
      notifier = container.read(mangaOwnedProvider.notifier);
    });

    tearDown(() async {
      container.dispose();
      await getIt.reset();
    });

    test('uses stable IDs and prevents detached duplicate objects', () async {
      final original = _subSeries(
        id: 'sub-1',
        title: 'Original',
        volumes: <Volume>[_volume('volume-1', tome: 1)],
      );
      final detachedDuplicate = _subSeries(
        id: 'sub-1',
        title: 'Detached',
        volumes: <Volume>[_volume('volume-1', tome: 1)],
      );

      await notifier.addSubSeriesToOwned(original);
      await notifier.addSubSeriesToOwned(detachedDuplicate);

      expect(container.read(mangaOwnedProvider), hasLength(1));
      expect(notifier.isSubSeriesOwned(detachedDuplicate), isTrue);
      expect(
        notifier.isVolumeOwned(detachedDuplicate, _volume('volume-1', tome: 1)),
        isTrue,
      );
    });

    test(
      'adds, sorts and removes volumes while notifying provider state',
      () async {
        final original = _subSeries(
          id: 'sub-1',
          title: 'Series',
          volumes: <Volume>[_volume('volume-2', tome: 2)],
        );
        await notifier.addSubSeriesToOwned(original);
        var emissions = 0;
        final subscription = container.listen<Set<SubSerieForCollection>>(
          mangaOwnedProvider,
          (_, _) => emissions += 1,
        );

        final detached = _subSeries(id: 'sub-1', title: 'Detached');
        await notifier.addVolumeToSubSeries(
          detached,
          _volume('volume-1', tome: 1),
        );

        var current = container.read(mangaOwnedProvider).single;
        expect(current.volumes.map((volume) => volume.id), [
          'volume-1',
          'volume-2',
        ]);
        expect(current.numberOwnedVolumes, 2);
        expect(emissions, 1);

        await notifier.removeVolumeFromSubSeries(
          detached,
          _volume('volume-1', tome: 1),
        );
        current = container.read(mangaOwnedProvider).single;
        expect(current.volumes.single.id, 'volume-2');
        expect(current.numberOwnedVolumes, 1);

        await notifier.removeVolumeFromSubSeries(
          detached,
          _volume('volume-2', tome: 2),
        );
        expect(container.read(mangaOwnedProvider), isEmpty);
        subscription.close();
      },
    );

    test('clears private in-memory data immediately on user switch', () async {
      notifier.handleUserChanged('user-one');
      await notifier.addSubSeriesToOwned(
        _subSeries(id: 'private-series', title: 'Private series'),
      );
      expect(container.read(mangaOwnedProvider), hasLength(1));

      notifier.handleUserChanged('user-two');

      expect(container.read(mangaOwnedProvider), isEmpty);
      final storage = getIt<LocalStorage>();
      expect(
        (await storage.getOwnedSubSerie(userId: 'user-one'))!.single.id,
        'private-series',
      );
      expect(await storage.getOwnedSubSerie(userId: 'user-two'), isNull);
    });
  });

  group('library tab widgets', () {
    testWidgets('collection and reading pile render safely on narrow screens', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final fixture = <SubSerieForCollection>{
        _subSeries(
          id: 'sub-1',
          title: 'A very long collection title that must remain responsive',
          volumes: <Volume>[
            _volume('volume-1', tome: 1, read: false),
            _volume('volume-2', tome: 2, read: true),
          ],
        ),
      };

      await tester.pumpWidget(_libraryApp(const CollectionTab(), fixture));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('A very long collection'), findsOneWidget);

      await tester.pumpWidget(_libraryApp(const ReadPileTab(), fixture));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('A very long collection'), findsOneWidget);
    });

    testWidgets('large collections lazily build only visible cover rows', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final fixture = <SubSerieForCollection>{
        for (var index = 0; index < 100; index++)
          _subSeries(
            id: 'sub-$index',
            title: 'Series $index',
            volumes: <Volume>[
              _volume('volume-$index', tome: 1, read: false),
            ],
          ),
      };

      await tester.pumpWidget(_libraryApp(const CollectionTab(), fixture));
      await tester.pump();

      expect(find.byType(SafeNetworkImage).evaluate().length, lessThan(25));
      expect(tester.takeException(), isNull);
    });

    testWidgets('wishlist loads even when the owned collection is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        _libraryApp(
          EnvyTab(
            followedLoader: () async => <ApiRecordModel>[
              ApiRecordModel(
                id: 'followed-1',
                collectionId: 'followed',
                data: <String, dynamic>{
                  'sub_serie': <String, dynamic>{'id': 'wish-1'},
                  'expand': <String, dynamic>{
                    'sub_serie': <String, dynamic>{
                      'id': 'wish-1',
                      'title': 'Wishlist series',
                      'volumes': <String>['v1', 'v2'],
                      'coverUrl': '',
                      'expand': <String, dynamic>{
                        'authors': <Map<String, dynamic>>[
                          <String, dynamic>{'name': 'Wishlist author'},
                        ],
                      },
                    },
                  },
                },
              ),
            ],
          ),
          const <SubSerieForCollection>{},
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Wishlist series'), findsOneWidget);
      expect(find.textContaining('Wishlist author'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('complete tab displays only missing volumes from the API', (
      tester,
    ) async {
      final fixture = <SubSerieForCollection>{
        _subSeries(
          id: 'sub-1',
          title: 'Incomplete series',
          volumes: <Volume>[_volume('volume-1', tome: 1)],
        ),
      };
      await tester.pumpWidget(
        _libraryApp(
          CompleteLibTab(
            missingVolumesLoader: (_) async => <ApiRecordModel>[
              ApiRecordModel(
                id: 'sub-1',
                collectionId: 'sub_series',
                data: <String, dynamic>{
                  'id': 'sub-1',
                  'expand': <String, dynamic>{
                    'volumes': <Map<String, dynamic>>[
                      _volumeJson('volume-1', 1),
                      _volumeJson('volume-2', 2),
                    ],
                  },
                },
              ),
            ],
          ),
          fixture,
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Incomplete series'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _libraryApp(
  Widget child,
  Set<SubSerieForCollection> fixture,
) {
  return ProviderScope(
    overrides: [
      mangaOwnedProvider.overrideWith(() => _FixtureOwnedNotifier(fixture)),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

class _FixtureOwnedNotifier extends MangaOwnedNotifier {
  _FixtureOwnedNotifier(this.fixture);

  final Set<SubSerieForCollection> fixture;

  @override
  Set<SubSerieForCollection> build() => fixture;
}

Map<String, dynamic> _volumeJson(String id, num tome) => <String, dynamic>{
  'id': id,
  'title': 'Volume $tome',
  'tomeNumber': tome,
  'price': 8,
  'coverUrl': '',
  'over18': false,
  'resume': '',
  'bookLink': <dynamic>[],
  'release': '2026-01-01T00:00:00Z',
  'ean': 0,
  'language': 'fr',
  'subSeries': 'sub-1',
  'series': 'series-1',
  'authors': <String>[],
  'support': 'paper',
};

SubSerieForCollection _subSeries({
  required String id,
  required String title,
  List<Volume> volumes = const <Volume>[],
  int? reportedOwned,
}) {
  return SubSerieForCollection(
    id: id,
    title: title,
    numberOfVolumes: volumes.length + 2,
    numberOwnedVolumes: reportedOwned ?? volumes.length,
    volumes: List<Volume>.from(volumes),
  );
}

Volume _volume(
  String id, {
  required num tome,
  String? title,
  bool read = false,
  int? year,
}) {
  return Volume(
    id: id,
    title: title ?? 'Volume $tome',
    tomeNumber: tome,
    price: 8,
    image: '',
    over18: false,
    resume: '',
    bookLink: const <dynamic>[],
    release: year == null ? null : DateTime.utc(year),
    ean: 0,
    language: 'fr',
    subSeries: 'sub-1',
    series: 'series-1',
    readed: read,
    authors: const <String>[],
    contains: null,
    info: null,
    support: 'paper',
    japGenre: null,
    lastTimeChecked: DateTime.utc(2026, 8, 8),
  );
}
