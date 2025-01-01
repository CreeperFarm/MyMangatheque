import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_series_tile.dart';

class EditorPage extends StatefulWidget {
  final String editorId;
  final String initRoute;

  const EditorPage({required this.editorId, required this.initRoute, super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final PocketBaseConnector connector = PocketBaseConnector();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: connector.getOneExpand('editors', widget.editorId, 'series.editors'),
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
            final List<dynamic> series = data['expand']['series'];

            // ? Building the widget
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  data['name'].toString(),
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
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: 275,
                      maxWidth: MediaQuery.of(context).size.width,
                    ),
                    child: Image.network(
                      'https://api.mymangatheque.com/api/files/whwwobw02cwbhtj/${data['id'].toString()}/${data['logo'].toString()}',
                      fit: BoxFit.fill,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'].toString(),
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
                        (series == null)
                            ? SizedBox()
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (series.length == 1) ? 'Série :' : 'Séries :',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    ListView(
                                      shrinkWrap: true,
                                      children: [
                                        for (var i = 0; i < series.length; i += 1)
                                          Column(
                                            children: [
                                              MySeriesTile(
                                                seriesData: series[i],
                                                initRoute: widget.initRoute,
                                              ),
                                              if (i != series.length - 1)
                                                MyLine(width: MediaQuery.of(context).size.width, vertical: 0, horizontal: 10),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
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
