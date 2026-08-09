import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/front/page/library/library_tab_data.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/safe_expand_reader.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';

typedef MissingVolumesLoader =
    Future<List<RecordModel>> Function(
      String subSeriesId,
    );

class CompleteLibTab extends ConsumerStatefulWidget {
  const CompleteLibTab({
    this.searchQuery = '',
    this.order = 'manga',
    this.missingVolumesLoader,
    super.key,
  });

  final String searchQuery;
  final String order;
  final MissingVolumesLoader? missingVolumesLoader;

  @override
  ConsumerState createState() => _CompleteLibTabState();
}

class _CompleteLibTabState extends ConsumerState<CompleteLibTab> {
  final AppwriteConnector connector = AppwriteConnector();
  List<SubSerieForCollection> notOwnedSubSeriesList = [];
  String? _lastOwnedSignature;
  bool _isFetching = false;
  bool _loadFailed = false;
  bool _updatingTracking = false;
  Set<String> _wantedVolumeIds = <String>{};
  Set<String> _followedSubSeriesIds = <String>{};

  String? get _userId => connector.getConnectedUser()?.id;

  @override
  void initState() {
    super.initState();
    unawaited(_loadTrackingPreferences());
  }

  Future<void> _loadTrackingPreferences() async {
    final userId = _userId;
    final wanted = await LocalStorage().getWantedMissingVolumeIds(
      userId: userId,
    );
    final followed = <String>{};
    if (userId != null) {
      try {
        final entries = await connector.getCollectionFullList('followed');
        for (final entry in entries) {
          final id = connector.followedEntrySubSeriesId(entry.data);
          if (id.isNotEmpty) followed.add(id);
        }
      } on Object catch (error) {
        RuntimeLocalization.debug(
          en: 'Unable to load release tracking preferences: $error',
          fr: 'Impossible de charger les préférences de suivi des sorties : $error',
        );
      }
    }
    if (!mounted) return;
    setState(() {
      _wantedVolumeIds = wanted;
      _followedSubSeriesIds = followed;
    });
  }

  Future<void> _toggleWanted(Volume volume) async {
    final nextWanted = !_wantedVolumeIds.contains(volume.id);
    setState(() {
      nextWanted
          ? _wantedVolumeIds.add(volume.id)
          : _wantedVolumeIds.remove(volume.id);
    });
    await LocalStorage().setMissingVolumeWanted(
      volume.id,
      wanted: nextWanted,
      userId: _userId,
    );
  }

  Future<void> _toggleReleaseTracking(String subSeriesId) async {
    final userId = _userId;
    if (userId == null || _updatingTracking) return;
    final currentlyFollowed = _followedSubSeriesIds.contains(subSeriesId);
    setState(() => _updatingTracking = true);
    try {
      if (currentlyFollowed) {
        await connector.removeSubSeriesToFollowed(userId, subSeriesId);
      } else {
        await connector.addSubSeriesToFollowed(userId, subSeriesId);
      }
      if (!mounted) return;
      setState(() {
        currentlyFollowed
            ? _followedSubSeriesIds.remove(subSeriesId)
            : _followedSubSeriesIds.add(subSeriesId);
      });
    } on Object catch (error) {
      RuntimeLocalization.debug(
        en: 'Unable to update release tracking: $error',
        fr: 'Impossible de modifier le suivi des sorties : $error',
      );
    } finally {
      if (mounted) setState(() => _updatingTracking = false);
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
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

  List<dynamic> _asList(dynamic value) {
    return value is List ? value : <dynamic>[];
  }

  List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) {
            if (item is Map) {
              return (item['name'] ?? item['id'] ?? '').toString();
            }
            return item.toString();
          })
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }
    if (value == null) return <String>[];
    final item = value.toString().trim();
    return item.isEmpty ? <String>[] : <String>[item];
  }

  Volume? _volumeFromMap(Map<String, dynamic> data) {
    final id = libraryRelationId(data);
    if (id.isEmpty) return null;

    final expand = _asMap(data['expand']);
    return Volume(
      id: id,
      title: (data['title']?.toString().trim().isNotEmpty ?? false)
          ? data['title'].toString()
          : data['titleFr']?.toString() ?? '',
      tomeNumber: data['tome_number'] ?? data['tomeNumber'],
      price: data['price'] ?? -1,
      image: data['coverUrl']?.toString() ?? data['image']?.toString() ?? '',
      over18: data['over18'] == true,
      resume: data['resume']?.toString() ?? '',
      bookLink: _asList(data['book_link'] ?? data['bookLink']),
      release: DateTime.tryParse(
        (data['release'] ?? data['publicationDate'])?.toString() ?? '',
      ),
      ean: num.tryParse(data['ean']?.toString() ?? '') ?? 0,
      language: data['language']?.toString(),
      subSeries: libraryRelationId(data['sub_series'] ?? data['subSeries']),
      readed: false,
      authors: _asStringList(expand['authors'] ?? data['authors']),
      series: libraryRelationId(data['series'] ?? data['serie']),
      contains: data['contains'] != null
          ? _asStringList(data['contains'])
          : null,
      info: _asMap(data['info']).isEmpty ? null : _asMap(data['info']),
      support: data['support']?.toString() ?? 'manga',
      japGenre: data['genre_jap']?.toString() ?? data['genderJp']?.toString(),
      lastTimeChecked: DateTime.now(),
    );
  }

  List<Volume> _volumesFromSubSeriesRecord(Map<String, dynamic> data) {
    final expand = SafeExpandReader.asMap(data['expand']);
    final volumeMaps = _asMapList(expand['volumes'] ?? data['volumes']);
    final volumes = <Volume>[];

    for (final volumeData in volumeMaps) {
      final volume = _volumeFromMap(volumeData);
      if (volume != null) volumes.add(volume);
    }

    volumes.sort((a, b) => (a.tomeNumber ?? 0).compareTo(b.tomeNumber ?? 0));
    return volumes;
  }

  String _ownedSignature(Iterable<SubSerieForCollection> subSeries) {
    final parts = subSeries.map((subSerie) {
      final volumeIds = subSerie.volumes.map((volume) => volume.id).toList()
        ..sort();
      return '${subSerie.id}:${subSerie.numberOwnedVolumes}:${volumeIds.join(',')}';
    }).toList()..sort();
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
      _loadFailed = false;
    });

    var failedRequests = 0;
    try {
      final loadedSubSeries = await Future.wait(
        ownedSubSeries.map((subSerie) async {
          try {
            final resList =
                await (widget.missingVolumesLoader?.call(
                      subSerie.id,
                    ) ??
                    connector.getOneExpand(
                      "sub_series",
                      subSerie.id,
                      "volumes",
                    ));
            if (resList.isEmpty) return null;

            final data = Map<String, dynamic>.from(resList.first.data);
            final volumes = _volumesFromSubSeriesRecord(data);
            final ownedVolumeIds = subSerie.volumes
                .map((volume) => volume.id)
                .toSet();
            final missingVolumes =
                volumes
                    .where((volume) => !ownedVolumeIds.contains(volume.id))
                    .toList()
                  ..sort(
                    (a, b) => (a.tomeNumber ?? 0).compareTo(b.tomeNumber ?? 0),
                  );

            if (missingVolumes.isEmpty) return null;

            return SubSerieForCollection(
              id: subSerie.id,
              title: subSerie.title,
              numberOfVolumes: max(subSerie.numberOfVolumes, volumes.length),
              numberOwnedVolumes: subSerie.numberOwnedVolumes,
              volumes: missingVolumes,
              cover: subSerie.cover,
            );
          } catch (e) {
            failedRequests += 1;
            RuntimeLocalization.debug(
              en: 'Unable to load missing volumes for a sub-series: $e',
              fr: 'Impossible de charger les volumes manquants d’une sous-série : $e',
            );
            return null;
          }
        }),
      );

      final nextNotOwned = loadedSubSeries
          .whereType<SubSerieForCollection>()
          .toList();
      if (ownedSubSeries.isNotEmpty &&
          failedRequests == ownedSubSeries.length) {
        throw StateError('Every missing-volume request failed.');
      }

      if (!mounted) return;
      setState(() {
        notOwnedSubSeriesList = nextNotOwned;
        _lastOwnedSignature = signature;
      });
    } catch (error) {
      RuntimeLocalization.debug(
        en: 'Unable to load the missing-volume list: $error',
        fr: 'Impossible de charger la liste des volumes manquants : $error',
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
    final visible = filterLibrarySubSeries(
      notOwnedSubSeriesList,
      searchQuery: widget.searchQuery,
      order: widget.order,
    );
    for (final subSeries in visible) {
      final prioritized = prioritizeMissingVolumes(
        subSeries.volumes,
        wantedVolumeIds: _wantedVolumeIds,
      );
      subSeries.volumes
        ..clear()
        ..addAll(prioritized);
    }
    visible.sort((a, b) {
      final wantedA = a.volumes
          .where((volume) => _wantedVolumeIds.contains(volume.id))
          .length;
      final wantedB = b.volumes
          .where((volume) => _wantedVolumeIds.contains(volume.id))
          .length;
      final wantedComparison = wantedB.compareTo(wantedA);
      if (wantedComparison != 0) return wantedComparison;
      final completionA = a.volumes.length == 1 ? 1 : 0;
      final completionB = b.volumes.length == 1 ? 1 : 0;
      final completionComparison = completionB.compareTo(completionA);
      if (completionComparison != 0) return completionComparison;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return visible;
  }

  String _availabilityLabel(
    BuildContext context,
    MissingVolumeAvailability availability,
  ) {
    return switch (availability) {
      MissingVolumeAvailability.available => context.localized(
        en: 'Available',
        fr: 'Disponible',
      ),
      MissingVolumeAvailability.announced => context.localized(
        en: 'Announced',
        fr: 'Annoncé',
      ),
      MissingVolumeAvailability.unreleased => context.localized(
        en: 'Date unknown',
        fr: 'Date inconnue',
      ),
    };
  }

  int getNumberVolumesNotOwned(Set<SubSerieForCollection> subSeries) {
    int number = 0;
    for (var subSerie in subSeries) {
      number += max(0, subSerie.numberOfVolumes - subSerie.numberOwnedVolumes);
    }
    return number;
  }

  int getNumberSeriesNotOwned(Set<SubSerieForCollection> subSeries) {
    int number = 0;
    for (var subSerie in subSeries) {
      if (subSerie.numberOwnedVolumes < subSerie.numberOfVolumes) {
        number += 1;
      }
    }
    return number;
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
    final estimatedMissingVolumes = getNumberVolumesNotOwned(ownedSubSeries);
    final volumeNotOwned = _lastOwnedSignature == null
        ? estimatedMissingVolumes
        : notOwnedSubSeriesList.fold<int>(
            0,
            (total, item) => total + item.volumes.length,
          );
    final missingSeries = _lastOwnedSignature == null
        ? getNumberSeriesNotOwned(ownedSubSeries)
        : notOwnedSubSeriesList.length;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: MyScrollColumn(
        children: [
          MyTomeNumberShow(
            tomeTotal: volumeNotOwned.toString(),
            editionTotal: missingSeries.toString(),
            localizations: localizations,
          ),
          if (_isFetching && notOwnedSubSeriesList.isEmpty)
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
          (ownedSubSeries.isEmpty && !_isFetching && !_loadFailed)
              ? Text(
                  localizations.noVolumeOwned,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : (volumeNotOwned == 0 && !_isFetching && !_loadFailed)
              ? Text(
                  localizations.allVolumesOwned,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const SizedBox(),
          if (!_isFetching &&
              !_loadFailed &&
              notOwnedSubSeriesList.isNotEmpty &&
              visibleSubSeries.isEmpty)
            Text(localizations.noResults),
          for (final subSerie in visibleSubSeries)
            Column(
              children: [
                InkWell(
                  onTap: () {
                    pushOrGo(context, '/library/sub_serie/${subSerie.id}');
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
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
                                    ),
                                    IconButton(
                                      tooltip:
                                          _followedSubSeriesIds.contains(
                                            subSerie.id,
                                          )
                                          ? context.localized(
                                              en: 'Stop tracking releases',
                                              fr: 'Arrêter le suivi des sorties',
                                            )
                                          : context.localized(
                                              en: 'Track future releases',
                                              fr: 'Suivre les prochaines sorties',
                                            ),
                                      onPressed:
                                          _userId == null || _updatingTracking
                                          ? null
                                          : () => _toggleReleaseTracking(
                                              subSerie.id,
                                            ),
                                      icon: Icon(
                                        _followedSubSeriesIds.contains(
                                              subSerie.id,
                                            )
                                            ? Icons.notifications_active_rounded
                                            : Icons.notifications_none_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  localizations.volumeOwnedOverX(
                                    subSerie.numberOwnedVolumes,
                                    subSerie.numberOfVolumes,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      for (final volume in subSerie.volumes)
                                        ActionChip(
                                          avatar: Icon(
                                            _wantedVolumeIds.contains(volume.id)
                                                ? Icons.bookmark_rounded
                                                : Icons.bookmark_border_rounded,
                                            size: 18,
                                          ),
                                          tooltip:
                                              _wantedVolumeIds.contains(
                                                volume.id,
                                              )
                                              ? context.localized(
                                                  en: 'Remove from wanted volumes',
                                                  fr: 'Retirer des tomes souhaités',
                                                )
                                              : context.localized(
                                                  en: 'Mark as wanted',
                                                  fr: 'Marquer comme souhaité',
                                                ),
                                          label: Text(
                                            context.localized(
                                              en: 'Vol. ${volume.tomeNumber ?? '?'} · ${_availabilityLabel(context, missingVolumeAvailability(volume))}',
                                              fr: 'T. ${volume.tomeNumber ?? '?'} · ${_availabilityLabel(context, missingVolumeAvailability(volume))}',
                                            ),
                                          ),
                                          onPressed: () =>
                                              _toggleWanted(volume),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 10,
                                  right: 10,
                                ),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: subSerie.volumes.isNotEmpty ? 100 : 0,
                                  child: Stack(
                                    children: [
                                      for (
                                        var j = 0;
                                        j < min(9, subSerie.volumes.length);
                                        j++
                                      )
                                        (j == 0)
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: SafeNetworkImage(
                                                  imageUrl:
                                                      subSerie.volumes[j].image,
                                                  width: 65,
                                                ),
                                              )
                                            : Positioned(
                                                left: j * 45.0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary
                                                            .withValues(
                                                              alpha: 0.9,
                                                            ),
                                                        spreadRadius: 1,
                                                        blurRadius: 2,
                                                        offset: const Offset(
                                                          0,
                                                          1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10.0,
                                                        ),
                                                    child: SafeNetworkImage(
                                                      imageUrl: subSerie
                                                          .volumes[j]
                                                          .image,
                                                      width: 65,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                    ],
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
