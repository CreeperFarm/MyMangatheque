import 'dart:convert';

import 'package:flutter/material.dart';
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
        future: PocketBaseConnector().getOne('series', this.widget.serieId),
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
            final subSeries = data['sub_series'];
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
                      (subSeries.length == 0)
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
                                          Navigator.pushNamed(context, '/sub_series', arguments: subSerie['id']);
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
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
                                                    }),
                                                FutureBuilder(
                                                  future: connector.getEditorName(subSerie['editor']),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.connectionState == ConnectionState.done) {
                                                      return Text(
                                                          '${subSerie['title'].toString().replaceFirst(data['title'] + ' - ', '')} • ${snapshot.data}');
                                                    } else {
                                                      return Text(subSerie['title'].toString().replaceFirst(data['title'] + ' - ', ''));
                                                    }
                                                  },
                                                ),
                                                SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      for (var i = subSerie['volumes'].length - 1; i >= 0; i -= 1)
                                                        FutureBuilder(
                                                          future: connector.getOne('volumes', subSerie['volumes'][i]),
                                                          builder: (context, snapshot) {
                                                            if (snapshot.connectionState == ConnectionState.done) {
                                                              Map<String, dynamic> volume = json.decode(snapshot.data.toString())[0];
                                                              return Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                child: SizedBox(
                                                                  width: 75,
                                                                  child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    child: Image.network(
                                                                      "https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${volume['id'].toString()}/${volume['image'].toString()}",
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            return const SizedBox();
                                                          },
                                                        ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            OwnIcon(iconColor: Theme.of(context).colorScheme.primary, iconName: 'arrow-right'),
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
