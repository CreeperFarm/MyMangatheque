import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_picture_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';

class SubSeriePage extends StatefulWidget {
  final String serieId;

  const SubSeriePage({required this.serieId, super.key});

  @override
  State<SubSeriePage> createState() => _SubSeriePageState();
}

class _SubSeriePageState extends State<SubSeriePage> {
  final PocketBaseConnector connector = PocketBaseConnector();

  Map month = {
    '1': 'Janvier',
    '2': 'Février',
    '3': 'Mars',
    '4': 'Avril',
    '5': 'Mai',
    '6': 'Juin',
    '7': 'Juillet',
    '8': 'Août',
    '9': 'Septembre',
    '10': 'Octobre',
    '11': 'Novembre',
    '12': 'Décembre',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: PocketBaseConnector().getOne('sub_series', widget.serieId),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.connectionState == ConnectionState.none) {
            return Center(
              child: const Text("Aucune connexion"),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: const Text("Une erreur est survenue"),
            );
          }
          if (snapshot.hasData && snapshot.data == null) {
            return Center(
              child: const Text("La série n'existent pas"),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = json.decode(snapshot.data.toString())[0];
            final List<dynamic> authors = data['authors'];
            final List<dynamic> volumes = data['volumes'];
            return MyScrollColumn(
              columnMainAxisAlignment: MainAxisAlignment.start,
              children: [
                MyPictureDisplay(
                  pictureUrl: "https://api.mymangatheque.com/api/files/ofwxwbyrhy5dcor/${data['id'].toString()}/${data['image'].toString()}",
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'].toString(),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10,
                        horizontal: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Genres :',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  children: [
                                    for (var i = 0; i < data['genres'].length; i += 1)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            color: Theme.of(context).colorScheme.onSecondary,
                                            child: Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: FutureBuilder(
                                                future: connector.getOne('genres', data['genres'][i]),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.done) {
                                                    return Text(
                                                      jsonDecode(snapshot.data![0].toString())['name'].toString(),
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.secondary,
                                                      ),
                                                    );
                                                  }
                                                  return const SizedBox();
                                                },
                                              ),
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
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10.0,
                        horizontal: 0.0,
                      ),
                      (authors.isEmpty)
                          ? SizedBox()
                          : (authors.length == 1)
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    'Auteur :',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    'Auteurs :',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                      for (var i = 0; i < authors.length; i += 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder(
                              future: connector.getOne('authors', authors[i]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done) {
                                  final authorData = json.decode(snapshot.data.toString())[0];
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: GestureDetector(
                                      onTap: () => context.go('/search/author/${authors[i]}'),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image.network(
                                                    "https://api.mymangatheque.com/api/files/hper195bzhpmjp9/${authors[i].toString()}/${authorData['image'].toString()}",
                                                    height: 50,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      authorData['name'].toString(),
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      softWrap: false,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      authorData['job'].toString(),
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                      ),
                                                      softWrap: false,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          OwnIcon(
                                            iconColor: Theme.of(context).colorScheme.primary,
                                            iconName: 'arrow-right',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return const CircularProgressIndicator();
                              },
                            ),
                            (i != authors.length - 1 && authors.length > 1)
                                ? MyLine(
                                    width: MediaQuery.of(context).size.width,
                                    vertical: 5,
                                    horizontal: 0,
                                  )
                                : SizedBox(),
                          ],
                        ),
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10,
                        horizontal: 0,
                      ),
                      (volumes.isEmpty)
                          ? SizedBox()
                          : (volumes.length == 1)
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    'Volume :',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    'Volumes :',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                      for (var i = 0; i < volumes.length; i += 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder(
                              future: connector.getOne('volumes', volumes[i]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done) {
                                  final volumeData = json.decode(snapshot.data.toString())[0];
                                  final DateTime release = DateTime.parse(volumeData['release'].toString());
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: GestureDetector(
                                      onTap: () => context.go('/search/volume/${authors[i]}'),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image.network(
                                                    "https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${volumes[i].toString()}/${volumeData['image'].toString()}",
                                                    height: 75,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Tome ${volumeData['tome_number']}',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      softWrap: false,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      '${release.day} ${month[release.month.toString()]} ${release.year}',
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                      ),
                                                      softWrap: false,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          OwnIcon(
                                            iconColor: Theme.of(context).colorScheme.primary,
                                            iconName: 'arrow-right',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return const CircularProgressIndicator();
                              },
                            ),
                            (i != authors.length - 1 && authors.length > 1)
                                ? MyLine(
                                    width: MediaQuery.of(context).size.width,
                                    vertical: 5,
                                    horizontal: 0,
                                  )
                                : SizedBox(),
                          ],
                        ),
                    ],
                  ),
                )
              ],
            );
          }
          return const Text("loading");
        },
      ),
    );
  }
}
