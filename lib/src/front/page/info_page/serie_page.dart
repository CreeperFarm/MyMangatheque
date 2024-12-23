import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/front/components/my_author_tile.dart';
import 'package:mymangatheque/src/front/components/my_genres_show.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_picture_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_sub_series_tile.dart';

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
    return FutureBuilder(
        future: connector.getOneExpand('series', widget.serieId, 'sub_series.volumes,sub_series.editor,genres,authors'),
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
          if (snapshot.hasData && snapshot.data != null) {
            // ? Define variables
            Map<String, dynamic> data = json.decode(snapshot.data.toString())[0];
            final List<dynamic> subSeries = data['expand']['sub_series'];
            final List<dynamic> authors = data['expand']['authors'];
            final List<dynamic> genres = data['expand']['genres'];

            // ? Building the widget
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  data['title'].toString(),
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                backgroundColor: Colors.transparent,
              ),
              body: MyScrollColumn(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MySubSeriesTile(data: subSeries[i]),
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
                              MyAuthorTile(
                                authorData: authors[i],
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
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text("La série n'existe pas"),
              ),
              body: Center(
                child: const Text("La série n'existe pas"),
              ),
            );
          }
        });
  }
}
