import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/const_info.dart';
import 'package:mymangatheque/src/front/components/my_author_tile.dart';
import 'package:mymangatheque/src/front/components/my_genres_show.dart';
import 'package:mymangatheque/src/front/components/my_icon_text_label.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_picture_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';

class VolumePage extends StatefulWidget {
  final String volumeId;
  final String initRoute;

  const VolumePage({required this.volumeId, required this.initRoute, super.key});

  @override
  State<VolumePage> createState() => _VolumePageState();
}

class _VolumePageState extends State<VolumePage> {
  final PocketBaseConnector connector = PocketBaseConnector();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PocketBaseConnector().getOneExpand('volumes', widget.volumeId, 'authors,genres,contains'),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Chargement..."),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Aucune connexion"),
            ),
            body: Center(
              child: const Text("Aucune connexion"),
            ),
          );
        }
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return Scaffold(
            appBar: AppBar(
              title: Text("Une erreur est survenue"),
            ),
            body: Center(
              child: const Text("Une erreur est survenue"),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // ? Declaring variables
          Map<String, dynamic> data = json.decode(snapshot.data.toString())[0];
          final List<dynamic> contain = data['contain'];
          final List<dynamic> genres = data['expand']['genres'];
          final List<dynamic> authors = data['expand']['authors'];
          final DateTime release = DateTime.parse(data['release'].toString());

          // ? Return Scaffold
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                data['title'].toString(),
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            body: MyScrollColumn(
              columnMainAxisAlignment: MainAxisAlignment.start,
              children: [
                MyPictureDisplay(
                  pictureUrl: "https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${data['id'].toString()}/${data['image'].toString()}",
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
                      (data['support'] == null || data['support'] == "manga")
                          ? SizedBox()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                data['support'].toString().replaceAll('-', ' '),
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
                                    for (var i = 0; i < genres.length; i += 1) MyGenresShow(data: genres[i]),
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
                      Text(
                        'Information :',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (data['release'] == null)
                                ? SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: MyIconTextLabel(
                                      iconName: 'calendar',
                                      text: 'Date de sortie: ${release.day} ${month[release.month.toString()]} ${release.year}',
                                      heightIcon: 30,
                                    ),
                                  ),
                            (data['ean'] == null)
                                ? SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: MyIconTextLabel(
                                      iconName: 'barcode',
                                      text: 'EAN : ${data['ean']}',
                                      heightIcon: 30,
                                    ),
                                  ),
                            (data['info']['pageNumber'] == null)
                                ? SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: MyIconTextLabel(
                                      iconName: 'book_open',
                                      text: "Nombre de page : ${data['info']['pageNumber'].toString()}",
                                      heightIcon: 30,
                                    ),
                                  ),
                            (contain == null)
                                ? SizedBox()
                                : Column(
                                    children: [
                                      MyLine(
                                        width: MediaQuery.of(context).size.width,
                                        vertical: 10,
                                        horizontal: 0,
                                      ), // TODO: Finir la partie contient
                                    ],
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
              title: Text("Le volume n'existe pas"),
            ),
            body: Center(
              child: const Text("Le volume n'existe pas"),
            ),
          );
        }
      },
    );
  }
}
