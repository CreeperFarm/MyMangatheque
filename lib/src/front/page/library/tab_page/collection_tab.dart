import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';

class CollectionTab extends ConsumerStatefulWidget {
  const CollectionTab({super.key});

  @override
  ConsumerState<CollectionTab> createState() => _CollectionTabState();
}

class _CollectionTabState extends ConsumerState<CollectionTab> {
  int numberMangaOwned = 0;
  PocketBaseConnector connector = PocketBaseConnector();

  String textLength(text, length) {
    if (text.length > length) {
      return text.substring(0, length) + "...";
    } else {
      return text;
    }
  }

  getNumberOfMangaOwned() async {
    try {
      int countMangaOwned = await connector.getNumberOwnedManga(connector.getConnectedUser()!.id);
      setState(() {
        numberMangaOwned = countMangaOwned;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    //ref.read(MangaOwnedProvider);
    getNumberOfMangaOwned();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (connector.getConnectedUser() == null) {
      context.go('/profile/signin');
    }
    //var subSeriesProv = ref.watch(MangaOwnedProvider);
    //print(subSeriesProv);
    return FutureBuilder(
        future: connector.getCollectionDataWithFilterExpand('owned', "user='${connector.getConnectedUser()!.id}'", 'volume.sub_series'),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.none) {
            return const Text("Aucune connexion");
          } else if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return const Text("Une erreur est survenue");
          } else if (snapshot.hasData && snapshot.data != null) {
            final data = json.decode(snapshot.data.toString());
            Map<String, dynamic> subSeriesMap = {};
            for (var i = 0; i < data.length; i++) {
              String title = data[i]['expand']['volume']['expand']['sub_series']['title'];
              if (subSeriesMap.containsKey(title)) {
                subSeriesMap[title]['volumes'].add({
                  'title': data[i]['expand']['volume']['title'],
                  'image': data[i]['expand']['volume']['image'],
                  'id': data[i]['expand']['volume']['id']
                });
              } else {
                subSeriesMap[title] = {
                  'title': title,
                  'id': data[i]['expand']['volume']['expand']['sub_series']['id'],
                  'first_index_data': i,
                  'volumes': [
                    {
                      'title': data[i]['expand']['volume']['title'],
                      'image': data[i]['expand']['volume']['image'],
                      'id': data[i]['expand']['volume']['id']
                    }
                  ]
                };
              }
            }
            List<dynamic> subSeries = subSeriesMap.values.toList();

            return Padding(
              padding: const EdgeInsets.all(10),
              child: MyScrollColumn(
                children: [
                  MyTomeNumberShow(tomeTotal: numberMangaOwned.toString(), editionTotal: subSeries.length.toString()),
                  for (var i = 0; i < subSeries.length; i++)
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            context.go('/library/sub_serie/${subSeries[i]['id']}');
                          },
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width - 65,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subSeries[i]['title'].replaceAll(' - Edition Standard', ''),
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "${subSeries[i]['volumes'].length} tomes sur ${data[subSeries[i]['first_index_data']]['expand']['volume']['expand']['sub_series']['volumes'].length}",
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: SizedBox(
                                            width: MediaQuery.of(context).size.width - 65,
                                            child: Stack(
                                              children: [
                                                for (var j = 0; j < subSeries[i]['volumes'].length; j++)
                                                  (j == 0)
                                                      ? ClipRRect(
                                                          borderRadius: BorderRadius.circular(10.0),
                                                          child: Image.network(
                                                            'https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${subSeries[i]['volumes'][j]['id']}/${subSeries[i]['volumes'][j]['image']}',
                                                            width: 65,
                                                          ),
                                                        )
                                                      : Positioned(
                                                          left: j * 45.0,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                                                                  spreadRadius: 1,
                                                                  blurRadius: 2,
                                                                  offset: const Offset(0, 1),
                                                                ),
                                                              ],
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(10.0),
                                                              child: Image.network(
                                                                'https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${subSeries[i]['volumes'][j]['id']}/${subSeries[i]['volumes'][j]['image']}',
                                                                width: 65,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                OwnIcon(
                                  iconColor: Theme.of(context).colorScheme.primary,
                                  iconName: 'arrow-right',
                                ),
                              ],
                            ),
                          ),
                        ),
                        MyLine(
                          width: MediaQuery.of(context).size.width,
                          vertical: 10,
                        ),
                      ],
                    )
                ],
              ),
            );
          } else {
            return Text("Une erreur est survenue");
          }
        });
  }
}
