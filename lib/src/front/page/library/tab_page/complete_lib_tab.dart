import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';

class CompleteLibTab extends ConsumerStatefulWidget {
  const CompleteLibTab({super.key});

  @override
  ConsumerState createState() => _CompleteLibTabState();
}

class _CompleteLibTabState extends ConsumerState<CompleteLibTab> {
  PocketBaseConnector connector = PocketBaseConnector();
  int volumeNotOwned = 0;
  int volumeOwned = 0;
  List<SubSerieForCollection> ownedSubSeriesList = [];
  List<SubSerieForCollection> notOwnedSubSeriesList = [];
  dynamic _ownedSubscription; // Subscription to listen to changes in owned manga

  dynamic ownedSubSeries;

  Future<void> _fetchData() async {
    ownedSubSeriesList = ownedSubSeries.toList();
    notOwnedSubSeriesList = [];

    for (var subSerie in ownedSubSeries) {
      final resList = await connector.getOneExpand("sub_series", subSerie.id, "volumes");
      final res = json.decode(resList.toString());
      List<Volume> volumes = [];

      for (var volumeData in res[0]['expand']['volumes']) {
        volumes.add(
          Volume(
            id: volumeData['id'],
            title: volumeData['title'],
            tomeNumber: volumeData['tome_number'],
            price: volumeData['price'],
            image: 'https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${volumeData['id']}/${volumeData['image']}',
            over18: volumeData['over18'],
            resume: volumeData['resume'],
            bookLink: volumeData['book_link'],
            release: DateTime.parse(volumeData['release']),
            ean: volumeData['ean'],
            language: volumeData['language'],
            subSeries: volumeData['sub_series'],
            readed: false,
            // Not owned volumes are not readed
            authors: volumeData['authors'] != null ? List<String>.from(volumeData['authors']) : [],
            series: volumeData['series'],
            contains: volumeData['contains'],
            info: volumeData['info'],
            support: volumeData['support'],
            japGenre: volumeData['genre_jap'],
            lastTimeChecked: DateTime.now(),
          ),
        );
      }

      notOwnedSubSeriesList.add(
        SubSerieForCollection(
          id: subSerie.id,
          title: subSerie.title,
          numberOfVolumes: subSerie.numberOfVolumes,
          numberOwnedVolumes: subSerie.numberOwnedVolumes,
          volumes: volumes,
        ),
      );
      for (int j = 0; j < notOwnedSubSeriesList.length; j++) {
        debugPrint(notOwnedSubSeriesList[j].volumes.toString());
        if (notOwnedSubSeriesList[j].id == subSerie.id) {
          for (int i = 0; i < notOwnedSubSeriesList[j].volumes.length; i++) {
            Volume volume = notOwnedSubSeriesList[j].volumes[i];

            if (subSerie.containsVolume(volume)) {
              volumeNotOwned++;
              notOwnedSubSeriesList[j].removeVolume(volume);
              debugPrint("Removed : ${volume.title}");
            } else {
              volumeNotOwned++;
            }
          }

          if (notOwnedSubSeriesList[j].volumes.isEmpty) {
            notOwnedSubSeriesList.removeAt(j);
          } else {
            // Order volumes by tome number
            notOwnedSubSeriesList[j].volumes.sort((a, b) => (a.tomeNumber ?? 0).compareTo(b.tomeNumber ?? 0));
          }
        }
      }
    }

    setState(() {});
  }

  int getNumberVolumesNotOwned() {
    final subSeries = ref.watch(mangaOwnedProvider);
    int number = 0;
    for (var subSerie in subSeries) {
      number += subSerie.numberOfVolumes - subSerie.numberOwnedVolumes;
    }
    return number;
  }

  int getNumberSeriesNotOwned() {
    final subSeries = ref.watch(mangaOwnedProvider);
    int number = 0;
    for (var subSerie in subSeries) {
      if (subSerie.numberOwnedVolumes == subSerie.numberOfVolumes) {
        number = number;
      } else {
        number += 1;
      }
    }
    return number;
  }

  void _cancelRealtime() {
    try {
      if (_ownedSubscription != null) {
        try {
          _ownedSubscription.unsubscribe();
        } catch (_) {}
        _ownedSubscription = null;
      }
    } catch (_) {}
  }

  void _setupRealtimeOrFallback() {
    _cancelRealtime();
    try {
      _ownedSubscription = connector.connector().collection('owned').subscribe('*', (event) async {
        debugPrint("Got an event");
        await ref.read(mangaOwnedProvider.notifier).initData();
        _fetchData();
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
      // Initialize the owned subseries data
      ownedSubSeries = ref.read(mangaOwnedProvider);
      _initDatas();
    });
  }

  Future<void> _initDatas() async {
    _fetchData();
    _setupRealtimeOrFallback();
  }

  @override
  void dispose() {
    _cancelRealtime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    ownedSubSeries = ref.read(mangaOwnedProvider);
    if (ownedSubSeries == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(10),
      child: MyScrollColumn(
        children: [
          MyTomeNumberShow(
            tomeTotal: getNumberVolumesNotOwned().toString(),
            editionTotal: getNumberSeriesNotOwned().toString(),
            localizations: localizations,
          ),
          (volumeNotOwned == 0)
              ? Text(
                  localizations.allVolumesOwned,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : SizedBox(),
          for (var i = 0; i < notOwnedSubSeriesList.length; i++)
            InkWell(
              onTap: () {
                pushOrGo(context, '/library/sub_serie/${notOwnedSubSeriesList[i].id}');
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
                        notOwnedSubSeriesList[i].title.replaceAll(' - Edition Standard', ''),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        localizations.volumeOwnedOverX(
                          notOwnedSubSeriesList[i].numberOwnedVolumes,
                          notOwnedSubSeriesList[i].numberOfVolumes,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: (notOwnedSubSeriesList[i].numberOwnedVolumes != 0) ? 100 : 0,
                        child: Stack(
                          children: [
                            for (var j = 0; j < notOwnedSubSeriesList[i].volumes.length; j++)
                              (j == 0)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        notOwnedSubSeriesList[i].volumes[j].image,
                                        width: 65,
                                      ),
                                    )
                                  : Positioned(
                                      left: j * 45.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                                              spreadRadius: 1,
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10.0),
                                          child: Image.network(
                                            notOwnedSubSeriesList[i].volumes[j].image,
                                            width: 65,
                                          ),
                                        ),
                                      ),
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
              ),
            ),
        ],
      ),
    );
  }
}
