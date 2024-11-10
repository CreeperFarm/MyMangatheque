import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_picture_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';

class SeriePage extends StatefulWidget {
  final String serieId;

  const SeriePage({required this.serieId, super.key});

  @override
  State<SeriePage> createState() => _SeriePageState();
}

class _SeriePageState extends State<SeriePage> {
  final PocketBaseConnector connector = PocketBaseConnector();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Series"),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: connector.getOne('series', widget.serieId),
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
            final List<dynamic> subSeries = data['sub_series'];
            final List<dynamic> authors = data['authors'];
            return MyScrollColumn(
              columnMainAxisAlignment: MainAxisAlignment.start,
              children: [
                MyPictureDisplay(
                  pictureUrl: "https://api.mymangatheque.com/api/files/utbujxtz8wtq0ar/${data['id'].toString()}/${data['image'].toString()}",
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'].toString(),
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w300,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
                        vertical: 10,
                        horizontal: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: (subSeries.isEmpty)
                            ? SizedBox()
                            : (subSeries.length == 1)
                                ? Text(
                                    'Edition :',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text(
                                    'Editions :',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                      ),
                      for (var i = 0; i < subSeries.length; i += 1)
                        Column(
                          children: [
                            FutureBuilder(
                              future: connector.getSubSerie(subSeries[i]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (snapshot.connectionState == ConnectionState.none) {
                                  return const Text("Aucune connexion");
                                }
                                if (snapshot.hasError) {
                                  debugPrint(snapshot.error.toString());
                                  return const Text("Une erreur est survenue");
                                }
                                if (snapshot.hasData && snapshot.data == null) {
                                  return const Text("Il n'existe pas de sous-série");
                                }
                                if (snapshot.connectionState == ConnectionState.done) {
                                  Map<String, dynamic> subSerie = snapshot.data!;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          context.go('/search/sub_series/${subSerie['id']}');
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            LayoutBuilder(
                                              builder: (context, constraints) {
                                                if (constraints.minWidth > 1200) {
                                                  return pageDisplayEditor(
                                                    connector,
                                                    MediaQuery.of(context).size.width - 350,
                                                    data,
                                                    subSerie,
                                                    context,
                                                  );
                                                } else {
                                                  return pageDisplayEditor(
                                                    connector,
                                                    MediaQuery.of(context).size.width - 50,
                                                    data,
                                                    subSerie,
                                                    context,
                                                  );
                                                }
                                              },
                                            ),
                                            OwnIcon(
                                              iconColor: Theme.of(context).colorScheme.primary,
                                              iconName: 'arrow-right',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return const CircularProgressIndicator();
                              },
                            ),
                            if (i != subSeries.length - 1)
                              MyLine(
                                width: MediaQuery.of(context).size.width,
                                vertical: 10,
                                horizontal: 0,
                              ),
                          ],
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
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
          return Center(
            child: const CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

Widget pageDisplayEditor(PocketBaseConnector connector, double width, Map<String, dynamic> data, Map<String, dynamic> subSerie, context) {
  return Container(
    width: width,
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width - 450,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: FutureBuilder(
            future: connector.getEditorName(subSerie['editor']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Text(
                  '${subSerie['title'].toString().replaceFirst(data['title'] + ' - ', '')} • ${snapshot.data}',
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                );
              } else {
                return Text(
                  subSerie['title'].toString().replaceFirst(data['title'] + ' - ', ''),
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                );
              }
            },
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: connector.getSubSerieVolumesImages(subSerie['id']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < json.decode(snapshot.data.toString()).length; i += 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: SizedBox(
                                width: 75,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(snapshot.data![i].replaceAll('"', '')),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ],
          ),
        )
      ],
    ),
  );
}
