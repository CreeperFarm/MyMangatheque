import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/const/routes.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/safe_expand_reader.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';

class EnvyTab extends ConsumerStatefulWidget {
  const EnvyTab({this.searchQuery = '', this.order = 'manga', super.key});

  final String searchQuery;
  final String order;

  @override
  ConsumerState createState() => _EnvyTabState();
}

class _EnvyTabState extends ConsumerState<EnvyTab> {
  final AppwriteConnector connector = AppwriteConnector();
  int followedVolumeNumber = 0;
  int followedSubSeriesNumber = 0;
  List<SubSerieForCollection> followedSubSeriesList = [];
  Map<String, String> authorNamesBySubSeriesId = <String, String>{};
  dynamic _ownedSubscription;
  dynamic _followedSubscription;
  String _lastOwnedSignature = '';
  bool _isFetching = false;

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
      return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
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
    final authors = _asMapList(expand['authors'] ?? subSeries['authors']);
    final names = authors.map((author) => author['name']?.toString() ?? '').where((name) => name.isNotEmpty).toList();
    return names.join(', ');
  }

  Future<String> getAuthorNameOfSubSeries(String id) async {
    final res = await connector.getOneExpand("sub_series", id, "authors");
    if (res.isEmpty) return "error";
    final data = Map<String, dynamic>.from(res.first.data);
    final authorName = _authorNamesFromSubSeries(data);
    return authorName.isEmpty ? "error" : authorName;
  }

  String displayAuthorWithSubSeriesId(String id) {
    return authorNamesBySubSeriesId[id] ?? "error";
  }

  String _ownedSignature(Iterable<SubSerieForCollection> subSeries) {
    final parts = subSeries.map((subSerie) => '${subSerie.id}:${subSerie.numberOwnedVolumes}').toList()..sort();
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
    setState(() {
      _isFetching = true;
    });

    final nextFollowed = <SubSerieForCollection>[];
    final nextAuthors = <String, String>{};
    var nextVolumeNumber = 0;
    var nextSubSeriesNumber = 0;

    final res = await connector.getCollectionFullDataWithFilterExpand(
      "followed",
      '',
      'sub_serie.authors',
    );

    for (final followedRecord in res) {
      final followed = Map<String, dynamic>.from(followedRecord.data);
      final expand = SafeExpandReader.asMap(followed['expand']);

      // Helper to get the subSeries map from multiple possible locations
      Map<String, dynamic> extractSubSeriesMap() {
        // Try expanded forms first
        final candidates = [
          expand['sub_serie'],
          expand['sub_series'],
          expand['subSeries'],
          expand['sub_serie'] is List ? (expand['sub_serie'] as List).firstWhere((_) => true, orElse: () => null) : null,
        ];
        for (final c in candidates) {
          final m = _firstMap(c);
          if (m.isNotEmpty) return m;
        }

        // Try top-level keys on followed
        final top = _firstMap(followed['sub_serie'] ?? followed['subSeries'] ?? followed['sub_series'] ?? followed['subSerie']);
        if (top.isNotEmpty) return top;

        return <String, dynamic>{};
      }

      final subSerie = extractSubSeriesMap();
      final subSerieId = (followed['sub_serie'] ?? followed['subSeries'] ?? followed['sub_series'] ?? subSerie['id'])?.toString() ?? '';

      if (subSerieId.isEmpty || getNumberVolumesOwnedOfSubSeries(subSerieId, ownedSubSeries) != 0) {
        continue;
      }

      final numberOfVolumes = _volumeCount(subSerie);
      nextFollowed.add(
        SubSerieForCollection(
          id: subSerieId,
          title: subSerie['title']?.toString() ?? subSerie['titleFr']?.toString() ?? '',
          numberOfVolumes: numberOfVolumes,
          volumes: const <Volume>[],
          numberOwnedVolumes: 0,
          cover: subSerie['coverUrl']?.toString() ?? subSerie['image']?.toString() ?? '',
        ),
      );
      nextSubSeriesNumber += 1;
      nextVolumeNumber += numberOfVolumes;

      var author = _authorNamesFromSubSeries(subSerie);
      if (author.isEmpty) {
        author = await getAuthorNameOfSubSeries(subSerieId);
      }
      nextAuthors[subSerieId] = author;
    }

    if (!mounted) return;
    setState(() {
      followedSubSeriesList = nextFollowed;
      followedVolumeNumber = nextVolumeNumber;
      followedSubSeriesNumber = nextSubSeriesNumber;
      authorNamesBySubSeriesId = nextAuthors;
      _lastOwnedSignature = signature;
      _isFetching = false;
    });
  }

  List<SubSerieForCollection> _visibleSubSeries() {
    final query = widget.searchQuery.trim().toLowerCase();
    final visible = followedSubSeriesList.where((subSerie) {
      if (query.isEmpty) return true;
      return subSerie.title.toLowerCase().contains(query) ||
          displayAuthorWithSubSeriesId(
            subSerie.id,
          ).toLowerCase().contains(query);
    }).toList();

    visible.sort((a, b) {
      if (widget.order == 'releaseDate') {
        return b.numberOfVolumes.compareTo(a.numberOfVolumes);
      }
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return visible;
  }

  void _cancelRealtime() {
    try {
      if (_ownedSubscription != null) {
        try {
          _ownedSubscription.unsubscribe();
        } catch (_) {}
        _ownedSubscription = null;
      }
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
      _ownedSubscription = connector.connector().collection('owned').subscribe(
        '*',
        (event) async {
          debugPrint("Got an event");
          await ref.read(mangaOwnedProvider.notifier).initData();
          _lastOwnedSignature = '';
          final ownedSubSeries = ref.read(mangaOwnedProvider);
          if (mounted) {
            _fetchData(ownedSubSeries, _ownedSignature(ownedSubSeries));
          }
        },
      );
      _followedSubscription = connector.connector().collection('followed').subscribe('*', (event) async {
        debugPrint("Got an event");
        await ref.read(mangaOwnedProvider.notifier).initData();
        _lastOwnedSignature = '';
        final ownedSubSeries = ref.read(mangaOwnedProvider);
        if (mounted) {
          _fetchData(ownedSubSeries, _ownedSignature(ownedSubSeries));
        }
      });

      debugPrint('Realtime subscriptions established.');
    } catch (e) {
      debugPrint('Realtime subscription failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mangaOwnedProvider.notifier).initData();
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
          (followedVolumeNumber == 0 && !_isFetching)
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
          for (var subSerie in visibleSubSeries)
            Column(
              children: [
                InkWell(
                  onTap: () => pushOrGo(context, Routes.librarySubSerie(subSerie.id)),
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
                                  displayAuthorWithSubSeriesId(subSerie.id),
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
