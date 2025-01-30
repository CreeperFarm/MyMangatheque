import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';
import 'package:once/once.dart';

class MangaOwnedNotifier extends Notifier<Set<SubSerieForCollection>> {
  @override
  Set<SubSerieForCollection> build() => <SubSerieForCollection>{};

  // Init the data
  Future<void> initData() async {
    Set<SubSerieForCollection>? temp = await LocalStorage().getOwnedSubSerie();

    if (temp != null) {
      state = temp;
      final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
      if (kIsWeb || connectivityResult.contains(ConnectivityResult.ethernet)) {
        if (PocketBaseConnector().isLoggedIn()) {
          Once.runHourly(
            'manga_owned_notifier_init_data',
            callback: () async {
              try {
                final result = await PocketBaseConnector().getCollectionDataWithFilterExpand(
                  'owned',
                  "user='${PocketBaseConnector().getConnectedUser()!.id}'",
                  'volume.sub_series.editor',
                );
                final data = json.decode(result.toString());
                state.clear();
                for (var i = 0; i < data.length; i++) {
                  String idLocal = data[i]['expand']['volume']['expand']['sub_series']['id'];
                  String titleLocal = data[i]['expand']['volume']['expand']['sub_series']['title'];
                  if (state.any((subSeries) => subSeries.title == titleLocal && subSeries.id == idLocal)) {
                    List<String> authorsLocal = [];
                    for (var author in data[i]['expand']['volume']['authors']) {
                      authorsLocal.add(author);
                    }
                    state.firstWhere((subSeries) => subSeries.title == titleLocal && subSeries.id == idLocal).volumes.add(
                          Volume(
                            id: data[i]['expand']['volume']['id'],
                            title: data[i]['expand']['volume']['title'],
                            tomeNumber: data[i]['expand']['volume']['tome_number'],
                            price: data[i]['expand']['volume']['price'],
                            image:
                                'https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${data[i]['expand']['volume']['id']}/${data[i]['expand']['volume']['image']}',
                            over18: data[i]['expand']['volume']['over18'],
                            resume: data[i]['expand']['volume']['resume'],
                            bookLink: data[i]['expand']['volume']['book_link'],
                            release: DateTime.parse(data[i]['expand']['volume']['release']),
                            ean: data[i]['expand']['volume']['ean'],
                            language: data[i]['expand']['volume']['language'],
                            subSeries: data[i]['expand']['volume']['sub_series'],
                            readed: data[i]['readed'],
                            authors: authorsLocal,
                            series: data[i]['expand']['volume']['series'],
                            contains: data[i]['expand']['volume']['contains'],
                            info: data[i]['expand']['volume']['info'],
                            support: data[i]['expand']['volume']['support'],
                            japGenre: data[i]['expand']['volume']['genre_jap'],
                          ),
                        );
                    state.firstWhere((subSeries) => subSeries.title == titleLocal && subSeries.id == idLocal).numberOwnedVolumes += 1;
                  } else {
                    List<String> authorsLocal = [];
                    for (var author in data[i]['expand']['volume']['authors']) {
                      authorsLocal.add(author);
                    }
                    state.add(
                      SubSerieForCollection(
                        id: data[i]['expand']['volume']['expand']['sub_series']['id'],
                        title: data[i]['expand']['volume']['expand']['sub_series']['title'],
                        numberOfVolumes: data[i]['expand']['volume']['expand']['sub_series']['volumes'].length,
                        numberOwnedVolumes: 1,
                        volumes: [
                          Volume(
                            id: data[i]['expand']['volume']['id'],
                            title: data[i]['expand']['volume']['title'],
                            tomeNumber: data[i]['expand']['volume']['tome_number'],
                            price: data[i]['expand']['volume']['price'],
                            image:
                                'https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${data[i]['expand']['volume']['id']}/${data[i]['expand']['volume']['image']}',
                            over18: data[i]['expand']['volume']['over18'],
                            resume: data[i]['expand']['volume']['resume'],
                            bookLink: data[i]['expand']['volume']['book_link'],
                            release: DateTime.parse(data[i]['expand']['volume']['release']),
                            ean: data[i]['expand']['volume']['ean'],
                            language: data[i]['expand']['volume']['language'],
                            subSeries: data[i]['expand']['volume']['sub_series'],
                            readed: data[i]['readed'],
                            authors: authorsLocal,
                            series: data[i]['expand']['volume']['series'],
                            // TODO: Convert it to a Volume List
                            contains: data[i]['expand']['volume']['contains'],
                            info: data[i]['expand']['volume']['info'],
                            support: data[i]['expand']['volume']['support'],
                            japGenre: data[i]['expand']['volume']['genre_jap'],
                          )
                        ],
                      ),
                    );
                  }
                }
              } catch (e) {
                // Print the error to the debug console
                debugPrint(e.toString());
              }
              await LocalStorage().deleteOwnedSubSerie();
              await LocalStorage().saveOwnedSubSerie(state);
            },
          );
        } else {
          // Do Nothing
        }
      } else {
        // Do nothing
      }
    } else {
      try {
        final result = await PocketBaseConnector().getCollectionDataWithFilterExpand(
          'owned',
          "user='${PocketBaseConnector().getConnectedUser()!.id}'",
          'volume.sub_series.editor',
        );
        final data = json.decode(result.toString());
        state.clear();
        for (var i = 0; i < data.length; i++) {
          String idLocal = data[i]['expand']['volume']['expand']['sub_series']['id'];
          String titleLocal = data[i]['expand']['volume']['expand']['sub_series']['title'];
          if (state.any((subSeries) => subSeries.title == titleLocal && subSeries.id == idLocal)) {
            List<String> authorsLocal = [];
            for (var author in data[i]['expand']['volume']['authors']) {
              authorsLocal.add(author);
            }
            state.firstWhere((subSeries) => subSeries.title == titleLocal && subSeries.id == idLocal).volumes.add(
                  Volume(
                    id: data[i]['expand']['volume']['id'],
                    title: data[i]['expand']['volume']['title'],
                    tomeNumber: data[i]['expand']['volume']['tome_number'],
                    price: data[i]['expand']['volume']['price'],
                    image:
                        'https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${data[i]['expand']['volume']['id']}/${data[i]['expand']['volume']['image']}',
                    over18: data[i]['expand']['volume']['over18'],
                    resume: data[i]['expand']['volume']['resume'],
                    bookLink: data[i]['expand']['volume']['book_link'],
                    release: DateTime.parse(data[i]['expand']['volume']['release']),
                    ean: data[i]['expand']['volume']['ean'],
                    language: data[i]['expand']['volume']['language'],
                    subSeries: data[i]['expand']['volume']['sub_series'],
                    readed: data[i]['readed'],
                    authors: authorsLocal,
                    series: data[i]['expand']['volume']['series'],
                    contains: data[i]['expand']['volume']['contains'],
                    info: data[i]['expand']['volume']['info'],
                    support: data[i]['expand']['volume']['support'],
                    japGenre: data[i]['expand']['volume']['genre_jap'],
                  ),
                );
            state.firstWhere((subSeries) => subSeries.title == titleLocal && subSeries.id == idLocal).numberOwnedVolumes += 1;
          } else {
            List<String> authorsLocal = [];
            for (var author in data[i]['expand']['volume']['authors']) {
              authorsLocal.add(author);
            }
            state.add(
              SubSerieForCollection(
                id: data[i]['expand']['volume']['expand']['sub_series']['id'],
                title: data[i]['expand']['volume']['expand']['sub_series']['title'],
                numberOfVolumes: data[i]['expand']['volume']['expand']['sub_series']['volumes'].length,
                numberOwnedVolumes: 1,
                volumes: [
                  Volume(
                    id: data[i]['expand']['volume']['id'],
                    title: data[i]['expand']['volume']['title'],
                    tomeNumber: data[i]['expand']['volume']['tome_number'],
                    price: data[i]['expand']['volume']['price'],
                    image:
                        'https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${data[i]['expand']['volume']['id']}/${data[i]['expand']['volume']['image']}',
                    over18: data[i]['expand']['volume']['over18'],
                    resume: data[i]['expand']['volume']['resume'],
                    bookLink: data[i]['expand']['volume']['book_link'],
                    release: DateTime.parse(data[i]['expand']['volume']['release']),
                    ean: data[i]['expand']['volume']['ean'],
                    language: data[i]['expand']['volume']['language'],
                    subSeries: data[i]['expand']['volume']['sub_series'],
                    readed: data[i]['readed'],
                    authors: authorsLocal,
                    series: data[i]['expand']['volume']['series'],
                    // TODO: Convert it to a Volume List
                    contains: data[i]['expand']['volume']['contains'],
                    info: data[i]['expand']['volume']['info'],
                    support: data[i]['expand']['volume']['support'],
                    japGenre: data[i]['expand']['volume']['genre_jap'],
                  )
                ],
              ),
            );
          }
        }
        await LocalStorage().deleteOwnedSubSerie();
        await LocalStorage().saveOwnedSubSerie(state);
      } catch (e) {
        // Print the error to the debug console
        debugPrint(e.toString());
      }
    }
  }

  // Add a sub series to the owned list
  void addSubSeriesToOwned(SubSerieForCollection subSeries) {
    if (!state.contains(subSeries)) {
      state.add(subSeries);
    }
  }

  // Remove a sub series from the owned list
  void removeSubSeriesFromOwned(SubSerieForCollection subSeries) {
    if (state.contains(subSeries)) {
      state.remove(subSeries);
    }
  }

  // Add a volume to a sub series
  void addVolumeToSubSeries(SubSerieForCollection subSerie, Volume volume) {
    if (state.contains(subSerie)) {
      if (!subSerie.volumes.contains(volume)) {
        state.firstWhere((subSeries) => subSeries == subSerie).volumes.add(volume);
        state.firstWhere((subSeries) => subSeries == subSerie).numberOwnedVolumes += 1;
      }
    }
  }

  // Remove a volume from a sub series
  void removeVolumeFromSubSeries(SubSerieForCollection subSerie, Volume volume) {
    if (state.contains(subSerie)) {
      if (subSerie.volumes.contains(volume)) {
        state.firstWhere((subSeries) => subSeries == subSerie).volumes.remove(volume);
        state.firstWhere((subSeries) => subSeries == subSerie).numberOwnedVolumes -= 1;
      }
    }
  }

  // Check if a sub series is owned
  bool isSubSeriesOwned(SubSerieForCollection subSeries) {
    return state.contains(subSeries);
  }

  // Check if a volume is owned
  bool isVolumeOwned(SubSerieForCollection subSeries, Volume volume) {
    return subSeries.volumes.contains(volume);
  }

  // Find a sub series index from it's title and it's id
  SubSerieForCollection findSubSeriesFromTitle(String title, String id) {
    return state.firstWhere((subSeries) => subSeries.title == title && subSeries.id == id);
  }

  // Find a volume from it's id
  Volume findVolumeFromId(SubSerieForCollection subSeries, String title, String id) {
    final index = subSeries.volumes.indexWhere((volume) => volume.title == title && volume.id == id);
    return subSeries.volumes[index];
  }

  // Clear the data
  void clear() {
    state.clear();
  }
}

final mangaOwnedProvider = NotifierProvider<MangaOwnedNotifier, Set<SubSerieForCollection>>(() {
  return MangaOwnedNotifier();
});
