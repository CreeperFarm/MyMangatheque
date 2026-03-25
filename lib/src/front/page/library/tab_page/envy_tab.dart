import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/const/routes.dart';

class EnvyTab extends ConsumerStatefulWidget {
  const EnvyTab({super.key});

  @override
  ConsumerState createState() => _EnvyTabState();
}

class _EnvyTabState extends ConsumerState<EnvyTab> {
  PocketBaseConnector connector = PocketBaseConnector();
  int followedVolumeNumber = 0;
  int followedSubSeriesNumber = 0;
  List<SubSerieForCollection> ownedSubSeriesList = [];
  List<SubSerieForCollection> followedSubSeriesList = [];
  List authorsNameLinkSubSeriesId = [];
  dynamic
  _ownedSubscription; // Subscription to listen to changes in owned manga
  dynamic
  _followedSubscription; // Subscription to listen to changes in followed manga
  dynamic ownedSubSeries;

  int getNumberVolumesOwnedOfSubSeries(String id) {
    int count = 0;
    for (var subSeries in ownedSubSeriesList) {
      if (subSeries.id == id) {
        count = subSeries.numberOwnedVolumes;
        break;
      }
    }
    return count;
  }

  Future<String> getAuthorNameOfSubSeries(String id) async {
    String authorName = "";
    final res = await connector.getOneExpand("sub_series", id, "authors");
    final data = json.decode(res.toString());
    final length = data[0]['expand']['authors'].length;
    for (var i = 0; i < length; i++) {
      if (i != length - 1) {
        authorName += data[0]['expand']['authors'][i]['name'] + ", ";
      } else {
        authorName += data[0]['expand']['authors'][i]['name'];
      }
    }
    if (authorName == "") {
      authorName = "error";
    }
    return authorName;
  }

  String displayAuthorWithSubSeriesId(String id) {
    String authorName = "error";
    for (var subSerie in authorsNameLinkSubSeriesId) {
      if (subSerie['id'] == id) {
        authorName = subSerie['author'];
        break;
      }
    }
    return authorName;
  }

  Future<void> _fetchData() async {
    ownedSubSeriesList = ownedSubSeries.toList();
    followedSubSeriesList = [];
    followedVolumeNumber = 0;
    followedSubSeriesNumber = 0;

    // Get the favorite sub series from local storage
    final res = await connector.getCollectionFullDataWithFilterExpand(
      "followed",
      "user='${PocketBaseConnector().getConnectedUser()!.id}'",
      'sub_serie',
    );
    final data = json.decode(res.toString());
    for (var followed in data) {
      if (getNumberVolumesOwnedOfSubSeries(followed["sub_serie"]) == 0) {
        followedSubSeriesList.add(
          SubSerieForCollection(
            id: followed['sub_serie'],
            title: followed['expand']['sub_serie']['title'],
            numberOfVolumes: followed['expand']['sub_serie']['volumes'].length,
            volumes: [],
            numberOwnedVolumes: 0,
            cover:
                'https://api.mymangatheque.com/api/files/ofwxwbyrhy5dcor/${followed['sub_serie']}/${followed['expand']['sub_serie']['image']}',
          ),
        );
        followedSubSeriesNumber += 1;
      }
    }

    for (var subSerie in followedSubSeriesList) {
      followedVolumeNumber += subSerie.numberOfVolumes;
      final author = await getAuthorNameOfSubSeries(subSerie.id);
      authorsNameLinkSubSeriesId.add({'id': subSerie.id, 'author': author});
    }

    if (!mounted) return;
    setState(() {});
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
          _fetchData();
        },
      );
      _followedSubscription = connector
          .connector()
          .collection('followed')
          .subscribe('*', (event) async {
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          MyTomeNumberShow(
            tomeTotal: "$followedVolumeNumber",
            editionTotal: "$followedSubSeriesNumber",
            localizations: localizations,
          ),
          (followedVolumeNumber == 0)
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
          Column(
            children: [
              for (var subSerie in followedSubSeriesList)
                Column(
                  children: [
                    InkWell(
                      onTap: () => pushOrGo(
                        context,
                        Routes.librarySubSerie(subSerie.id),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                subSerie.cover ??
                                    'https://placehold.co/514x728?text=No%20Image',
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
        ],
      ),
    );
  }
}
