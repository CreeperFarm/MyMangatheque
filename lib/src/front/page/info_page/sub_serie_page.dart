import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/front/components/my_author_tile.dart';
import 'package:mymangatheque/src/front/components/my_editor_show.dart';
import 'package:mymangatheque/src/front/components/my_genres_show.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_picture_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_volume_tile.dart';

class SubSeriePage extends StatefulWidget {
  final String serieId;
  final String initRoute;

  const SubSeriePage({required this.serieId, required this.initRoute, super.key});

  @override
  State<SubSeriePage> createState() => _SubSeriePageState();
}

class _SubSeriePageState extends State<SubSeriePage> {
  final PocketBaseConnector connector = PocketBaseConnector();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PocketBaseConnector().getOneExpand(
        'sub_series',
        widget.serieId,
        'authors,volumes,serie.genres,editor',
      ),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: Center(
              child: const Text("Aucune connexion"),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: Center(
              child: const Text("Une erreur est survenue"),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // ? Define variables
          Map<String, dynamic> data = json.decode(snapshot.data.toString())[0];
          final List<dynamic> authors = data['expand']['authors'];
          final List<dynamic> volumes = data['expand']['volumes'];
          final Map<String, dynamic> series = data['expand']['serie'];
          final Map<String, dynamic> editor = data['expand']['editor'];

          // ? Sort volumes
          volumes.sort((a, b) {
            if (a['tome_number'] < b['tome_number']) {
              return -1;
            } else if (a['tome_number'] > b['tome_number']) {
              return 1;
            } else {
              return 0;
            }
          });

          // ? Display on screen
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                data['title'].toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            body: MyScrollColumn(
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
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      (volumes[0]["support"].toString() == "manga")
                          ? SizedBox()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                volumes[0]["support"].toString().replaceAll('-', ' '),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w200,
                                ),
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
                                    for (var i = 0; i < series["expand"]["genres"].length; i += 1) MyGenresShow(data: series["expand"]["genres"][i]),
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
                            MyAuthorTile(
                              authorData: authors[i],
                              initRoute: widget.initRoute,
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
                          children: [
                            MyVolumeTile(
                              volumeData: volumes[i],
                              initRoute: widget.initRoute,
                            ),
                            (i != volumes.length - 1 && volumes.length > 1)
                                ? MyLine(
                                    width: MediaQuery.of(context).size.width,
                                    vertical: 5,
                                    horizontal: 0,
                                  )
                                : SizedBox(),
                          ],
                        ),
                      (editor.isEmpty)
                          ? SizedBox()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyLine(
                                    width: MediaQuery.of(context).size.width,
                                    vertical: 5,
                                    horizontal: 0,
                                  ),
                                  Text(
                                    'Éditeur :',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  MyEditorShow(
                                    editor: editor,
                                    initRoute: widget.initRoute,
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                )
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: Center(
              child: const Text("La sous-série n'existe pas"),
            ),
          );
        }
      },
    );
  }
}
