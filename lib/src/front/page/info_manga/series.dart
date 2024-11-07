import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_picture_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';

class SeriesPages extends StatefulWidget {
  final String seriesId;

  const SeriesPages({required this.seriesId, super.key});

  @override
  State<SeriesPages> createState() => _SeriesPagesState();
}

class _SeriesPagesState extends State<SeriesPages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Series"),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: PocketBaseConnector().getOne('series', this.widget.seriesId),
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
            print(data);
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
                      Text(data['authors'].toString()),
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10,
                        horizontal: 0,
                      ),
                      Text(data['type'].toString()),
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
