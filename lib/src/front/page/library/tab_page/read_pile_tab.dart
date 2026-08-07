import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/const/routes.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_loader_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';

class ReadPileTab extends ConsumerStatefulWidget {
  const ReadPileTab({this.searchQuery = '', this.order = 'manga', super.key});

  final String searchQuery;
  final String order;

  @override
  ConsumerState createState() => _ReadPileTabState();
}

class _ReadPileTabState extends ConsumerState<ReadPileTab> {
  int numberVolumeReaded(List<Volume> volumes) {
    int volumeReaded = 0;
    for (var volume in volumes) {
      if (volume.readed) {
        volumeReaded++;
      }
    }
    return volumeReaded;
  }

  int _numberVolumeOwned(Iterable<SubSerieForCollection> subSeries) {
    return subSeries.fold<int>(
      0,
      (total, subSerie) => total + subSerie.numberOwnedVolumes,
    );
  }

  int _numberVolumeReaded(Iterable<SubSerieForCollection> subSeries) {
    return subSeries.fold<int>(
      0,
      (total, subSerie) => total + numberVolumeReaded(subSerie.volumes),
    );
  }

  List<SubSerieForCollection> _pendingSubSeries(
    Iterable<SubSerieForCollection> subSeries,
  ) {
    final query = widget.searchQuery.trim().toLowerCase();
    final pending = <SubSerieForCollection>[];

    for (final subSerie in subSeries) {
      final unreadVolumes =
          subSerie.volumes.where((volume) => !volume.readed).toList()
            ..sort((a, b) => (a.tomeNumber ?? 0).compareTo(b.tomeNumber ?? 0));
      if (unreadVolumes.isEmpty) continue;

      final matchesQuery =
          query.isEmpty ||
          subSerie.title.toLowerCase().contains(query) ||
          unreadVolumes.any(
            (volume) => volume.title.toLowerCase().contains(query),
          );
      if (!matchesQuery) continue;

      pending.add(
        SubSerieForCollection(
          id: subSerie.id,
          title: subSerie.title,
          numberOfVolumes: subSerie.numberOfVolumes,
          numberOwnedVolumes: subSerie.numberOwnedVolumes,
          volumes: unreadVolumes,
          cover: subSerie.cover,
        ),
      );
    }

    pending.sort((a, b) {
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

    return pending;
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final subSeries = ref.watch(mangaOwnedProvider);
    final volumeOwned = _numberVolumeOwned(subSeries);
    final volumeReaded = _numberVolumeReaded(subSeries);
    final pendingSubSeries = _pendingSubSeries(subSeries);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: MyScrollColumn(
        columnCrossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (volumeOwned == 0)
              ? Text(
                  localizations.zeroVolumesOwned,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : (volumeOwned == volumeReaded)
              ? Text(
                  localizations.allVolumesReaded,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Column(
                  children: [
                    Text(
                      localizations.volumeReadedOverX(
                        volumeReaded,
                        volumeOwned,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    MyLoaderDisplay(percentage: volumeReaded / volumeOwned),
                  ],
                ),
          MyLine(
            width: MediaQuery.of(context).size.width,
            vertical: 10,
            horizontal: 0,
          ),
          for (final subSerie in pendingSubSeries)
            InkWell(
              onTap: () {
                pushOrGo(context, Routes.librarySubSerie(subSerie.id));
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        subSerie.title.replaceAll(' - Edition Standard', ''),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  localizations.volumeReadedOverSeriesX(
                                    subSerie.numberOwnedVolumes -
                                        subSerie.volumes.length,
                                    subSerie.numberOwnedVolumes,
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
                    MyLine(
                      width: MediaQuery.of(context).size.width,
                      vertical: 10,
                      horizontal: 0,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
