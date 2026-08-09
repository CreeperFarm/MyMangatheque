import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/const/routes.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/front/page/library/library_tab_data.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/safe_expand_reader.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';

typedef FollowedSubSeriesLoader = Future<List<RecordModel>> Function();

class EnvyTab extends ConsumerStatefulWidget {
  const EnvyTab({
    this.searchQuery = '',
    this.order = 'manga',
    this.followedLoader,
    super.key,
  });

  final String searchQuery;
  final String order;
  final FollowedSubSeriesLoader? followedLoader;

  @override
  ConsumerState createState() => _EnvyTabState();
}

class _EnvyTabState extends ConsumerState<EnvyTab> {
  final AppwriteConnector connector = AppwriteConnector();
  int followedVolumeNumber = 0;
  int followedSubSeriesNumber = 0;
  List<SubSerieForCollection> followedSubSeriesList = [];
  Map<String, String> authorNamesBySubSeriesId = <String, String>{};
  dynamic _followedSubscription;
  String? _lastOwnedSignature;
  bool _isFetching = false;
  bool _loadFailed = false;

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Map<String, dynamic> _firstMap(dynamic value) {
    final direct = _asMap(value);
    if (direct.isNotEmpty) return direct;
    if (value is List) {
      for (final item in value) {
        final map = _asMap(item);
        if (map.isNotEmpty) return map;
      }
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  int _volumeCount(Map<String, dynamic> subSeries) {
    final volumes = subSeries['volumes'];
    if (volumes is List) return volumes.length;

    final candidates = <dynamic>[
      subSeries['numberOfVolumes'],
      subSeries['volumeCount'],
      subSeries['volumesCount'],
      subSeries['totalVolumes'],
    ];
    for (final candidate in candidates) {
      if (candidate is int) return candidate;
      if (candidate is num) return candidate.toInt();
      final parsed = int.tryParse(candidate?.toString() ?? '');
      if (parsed != null) return parsed;
    }

    return 0;
  }

  int getNumberVolumesOwnedOfSubSeries(
    String id,
    Iterable<SubSerieForCollection> ownedSubSeries,
  ) {
    for (var subSeries in ownedSubSeries) {
      if (subSeries.id == id) {
        return subSeries.numberOwnedVolumes;
      }
    }
    return 0;
  }

  String _authorNamesFromSubSeries(Map<String, dynamic> subSeries) {
    final expand = SafeExpandReader.asMap(subSeries['expand']);
    final rawAuthors = expand['authors'] ?? subSeries['authors'];
    final names = rawAuthors is List
        ? rawAuthors
              .map((author) {
                if (author is Map) return author['name']?.toString() ?? '';
                return author.toString();
              })
              .where((name) => name.trim().isNotEmpty)
              .toList()
        : _asMapList(rawAuthors)
              .map((author) => author['name']?.toString() ?? '')
              .where((name) => name.trim().isNotEmpty)
              .toList();
    return names.join(', ');
  }

  Future<String> getAuthorNameOfSubSeries(String id) async {
    final res = await connector.getOneExpand("sub_series", id, "authors");
    if (res.isEmpty) return '';
    final data = Map<String, dynamic>.from(res.first.data);
    final authorName = _authorNamesFromSubSeries(data);
    return authorName;
  }

  String displayAuthorWithSubSeriesId(String id) {
    return authorNamesBySubSeriesId[id] ?? '';
  }

  String _ownedSignature(Iterable<SubSerieForCollection> subSeries) {
    final parts =
        subSeries
            .map((subSerie) => '${subSerie.id}:${subSerie.numberOwnedVolumes}')
            .toList()
          ..sort();
    return parts.join('|');
  }

  void _scheduleFetchIfNeeded(Set<SubSerieForCollection> ownedSubSeries) {
    final signature = _ownedSignature(ownedSubSeries);
    if (_isFetching || signature == _lastOwnedSignature) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchData(ownedSubSeries, signature);
    });
  }

  Future<void> _fetchData(
    Set<SubSerieForCollection> ownedSubSeries,
    String signature,
  ) async {
    if (!mounted) return;
    setState(() {
      _isFetching = true;
      _loadFailed = false;
    });
    try {
      final res =
          await (widget.followedLoader?.call() ??
              connector.getCollectionFullDataWithFilterExpand(
                "followed",
                '',
                'subSeries.authors',
              ));
      final ownedSubSeriesIds = ownedSubSeries
          .map((subSeries) => subSeries.id)
          .toSet();

      final loadedEntries =
          await Future.wait<MapEntry<SubSerieForCollection, String>?>(
            res.map((followedRecord) async {
              final followed = Map<String, dynamic>.from(followedRecord.data);
              final expand = SafeExpandReader.asMap(followed['expand']);

              // Helper to get the subSeries map from multiple possible locations
              Map<String, dynamic> extractSubSeriesMap() {
                // Try expanded forms first
                final candidates = [
                  expand['sub_serie'],
                  expand['sub_series'],
                  expand['subSeries'],
                  expand['sub_serie'] is List
                      ? (expand['sub_serie'] as List).firstWhere(
                          (_) => true,
                          orElse: () => null,
                        )
                      : null,
                ];
                for (final c in candidates) {
                  final m = _firstMap(c);
                  if (m.isNotEmpty) return m;
                }

                // Try top-level keys on followed
                final top = _firstMap(
                  followed['sub_serie'] ??
                      followed['subSeries'] ??
                      followed['sub_series'] ??
                      followed['subSerie'],
                );
                if (top.isNotEmpty) return top;

                return <String, dynamic>{};
              }

              final subSerie = extractSubSeriesMap();
              final subSerieId = libraryRelationId(
                followed['sub_serie'] ??
                    followed['subSeries'] ??
                    followed['sub_series'] ??
                    subSerie,
              );

              if (subSerieId.isEmpty ||
                  ownedSubSeriesIds.contains(subSerieId)) {
                return null;
              }

              final numberOfVolumes = _volumeCount(subSerie);
              final subSeries = SubSerieForCollection(
                id: subSerieId,
                title:
                    subSerie['title']?.toString() ??
                    subSerie['titleFr']?.toString() ??
                    '',
                numberOfVolumes: numberOfVolumes,
                volumes: const <Volume>[],
                numberOwnedVolumes: 0,
                cover:
                    subSerie['coverUrl']?.toString() ??
                    subSerie['image']?.toString() ??
                    '',
              );

              var author = _authorNamesFromSubSeries(subSerie);
              if (author.isEmpty) {
                author = await getAuthorNameOfSubSeries(subSerieId);
              }
              return MapEntry(subSeries, author);
            }),
          );

      final nextFollowed = <SubSerieForCollection>[];
      final nextAuthors = <String, String>{};
      var nextVolumeNumber = 0;

      for (final entry
          in loadedEntries
              .whereType<MapEntry<SubSerieForCollection, String>>()) {
        final subSeries = entry.key;
        nextFollowed.add(subSeries);
        nextAuthors[subSeries.id] = entry.value;
        nextVolumeNumber += subSeries.numberOfVolumes;
      }

      if (!mounted) return;
      setState(() {
        followedSubSeriesList = nextFollowed;
        followedVolumeNumber = nextVolumeNumber;
        followedSubSeriesNumber = nextFollowed.length;
        authorNamesBySubSeriesId = nextAuthors;
        _lastOwnedSignature = signature;
      });
    } catch (error) {
      RuntimeLocalization.debug(
        en: 'Unable to load the wishlist: $error',
        fr: 'Impossible de charger la liste d’envies : $error',
      );
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
        _lastOwnedSignature = signature;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }

  List<SubSerieForCollection> _visibleSubSeries() {
    return filterLibrarySubSeries(
      followedSubSeriesList,
      searchQuery: widget.searchQuery,
      order: widget.order,
      additionalSearchText: (subSerie) =>
          displayAuthorWithSubSeriesId(subSerie.id),
    );
  }

  void _cancelRealtime() {
    try {
      if (_followedSubscription != null) {
        try {
          _followedSubscription.unsubscribe();
        } catch (_) {}
        _followedSubscription = null;
      }
    } catch (_) {}
  }

  void _setupRealtimeOrFallback() {
    _cancelRealtime();
    try {
      _followedSubscription = connector
          .connector()
          .collection('followed')
          .subscribe('*', (event) async {
            RuntimeLocalization.debug(
              en: 'Wishlist realtime update received.',
              fr: 'Mise à jour temps réel de la liste d’envies reçue.',
            );
            _lastOwnedSignature = null;
            final ownedSubSeries = ref.read(mangaOwnedProvider);
            if (mounted) {
              _fetchData(ownedSubSeries, _ownedSignature(ownedSubSeries));
            }
          });

      RuntimeLocalization.debug(
        en: 'Realtime subscriptions established.',
        fr: 'Abonnements temps réel établis.',
      );
    } catch (e) {
      RuntimeLocalization.debug(
        en: 'Realtime subscription failed: $e',
        fr: 'L’abonnement temps réel a échoué : $e',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupRealtimeOrFallback();
    });
  }

  @override
  void dispose() {
    _cancelRealtime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ownedSubSeries = ref.watch(mangaOwnedProvider);
    _scheduleFetchIfNeeded(ownedSubSeries);
    final visibleSubSeries = _visibleSubSeries();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: MyScrollColumn(
        children: [
          MyTomeNumberShow(
            tomeTotal: "$followedVolumeNumber",
            editionTotal: "$followedSubSeriesNumber",
            localizations: localizations,
          ),
          if (_isFetching && followedSubSeriesList.isEmpty)
            const Center(child: CircularProgressIndicator()),
          if (_loadFailed)
            Center(
              child: Column(
                children: [
                  Text(localizations.errorOccurred),
                  TextButton(
                    onPressed: () => _fetchData(
                      ownedSubSeries,
                      _ownedSignature(ownedSubSeries),
                    ),
                    child: Text(localizations.tryAgain),
                  ),
                ],
              ),
            ),
          (followedVolumeNumber == 0 && !_isFetching && !_loadFailed)
              ? Center(
                  child: Text(
                    localizations.noFollowedSubSerie,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : const SizedBox(),
          if (!_isFetching &&
              !_loadFailed &&
              followedSubSeriesList.isNotEmpty &&
              visibleSubSeries.isEmpty)
            Text(localizations.noResults),
          for (var subSerie in visibleSubSeries)
            Column(
              children: [
                InkWell(
                  onTap: () =>
                      pushOrGo(context, Routes.librarySubSerie(subSerie.id)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: SafeNetworkImage(
                            imageUrl: subSerie.cover,
                            width: 65,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                subSerie.title.replaceAll(
                                  ' - Edition Standard',
                                  '',
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                localizations.subSerieVolumeNumber(
                                  subSerie.numberOfVolumes,
                                ),
                              ),
                              Text(
                                localizations.subSerieFromAuthor(
                                  displayAuthorWithSubSeriesId(
                                        subSerie.id,
                                      ).isEmpty
                                      ? localizations.notAvailable
                                      : displayAuthorWithSubSeriesId(
                                          subSerie.id,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        OwnIcon(
                          iconColor: Theme.of(context).colorScheme.primary,
                          iconSrc: Assets.icons.arrowRight,
                        ),
                      ],
                    ),
                  ),
                ),
                MyLine(
                  width: MediaQuery.of(context).size.width,
                  vertical: 10,
                  horizontal: 0,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
