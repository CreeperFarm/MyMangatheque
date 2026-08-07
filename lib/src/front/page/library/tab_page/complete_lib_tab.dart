import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/safe_expand_reader.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';

class CompleteLibTab extends ConsumerStatefulWidget {
  const CompleteLibTab({
    this.searchQuery = '',
    this.order = 'manga',
    super.key,
  });

  final String searchQuery;
  final String order;

  @override
  ConsumerState createState() => _CompleteLibTabState();
}

class _CompleteLibTabState extends ConsumerState<CompleteLibTab> {
  final AppwriteConnector connector = AppwriteConnector();
  List<SubSerieForCollection> notOwnedSubSeriesList = [];
  String _lastOwnedSignature = '';
  bool _isFetching = false;

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
    final id = data['id']?.toString() ?? '';
    if (id.isEmpty) return null;

    final expand = _asMap(data['expand']);
    return Volume(
      id: id,
      title: data['title']?.toString() ?? data['titleFr']?.toString() ?? '',
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
      subSeries: (data['sub_series'] ?? data['subSeries'])?.toString() ?? '',
      readed: false,
      authors: _asStringList(expand['authors'] ?? data['authors']),
      series: data['series']?.toString() ?? data['serie']?.toString() ?? '',
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
    final volumeMaps = _asMapList(expand['volumes']);
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
    });

    final loadedSubSeries = await Future.wait(
      ownedSubSeries.map((subSerie) async {
        try {
          final resList = await connector.getOneExpand(
            "sub_series",
            subSerie.id,
            "volumes",
          );
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
          debugPrint('Unable to load missing volumes for ${subSerie.id}: $e');
          return null;
        }
      }),
    );

    final nextNotOwned = loadedSubSeries
        .whereType<SubSerieForCollection>()
        .toList();

    if (!mounted) return;
    setState(() {
      notOwnedSubSeriesList = nextNotOwned;
      _lastOwnedSignature = signature;
      _isFetching = false;
    });
  }

  List<SubSerieForCollection> _visibleSubSeries() {
    final query = widget.searchQuery.trim().toLowerCase();
    final visible = notOwnedSubSeriesList.where((subSerie) {
      if (query.isEmpty) return true;
      return subSerie.title.toLowerCase().contains(query) ||
          subSerie.volumes.any(
            (volume) => volume.title.toLowerCase().contains(query),
          );
    }).toList();

    visible.sort((a, b) {
      if (widget.order == 'releaseDate') {
        final aDate = a.volumes
            .map(
              (volume) =>
                  volume.release ?? DateTime.fromMillisecondsSinceEpoch(0),
            )
            .reduce(
              (value, element) => value.isAfter(element) ? value : element,
            );
        final bDate = b.volumes
            .map(
              (volume) =>
                  volume.release ?? DateTime.fromMillisecondsSinceEpoch(0),
            )
            .reduce(
              (value, element) => value.isAfter(element) ? value : element,
            );
        return bDate.compareTo(aDate);
      }
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return visible;
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
    final volumeNotOwned = getNumberVolumesNotOwned(ownedSubSeries);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: MyScrollColumn(
        children: [
          MyTomeNumberShow(
            tomeTotal: volumeNotOwned.toString(),
            editionTotal: getNumberSeriesNotOwned(ownedSubSeries).toString(),
            localizations: localizations,
          ),
          (volumeNotOwned == 0 && !_isFetching)
              ? Text(
                  localizations.allVolumesOwned,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const SizedBox(),
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
