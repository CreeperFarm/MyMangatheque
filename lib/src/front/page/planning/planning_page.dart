import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  var latestManga;
  final PocketBaseConnector connector = PocketBaseConnector();

  Future<void> getLatestManga() async {
    await connector
        .getCollectionDataWithFilter("volumes",
            'release?<="${DateTime.now().add(const Duration(days: 14)).toUtc()}"&&release?>="${DateTime.now().subtract(const Duration(days: 14)).toIso8601String()}"')
        .then((value) {
      if (value.isNotEmpty && !value[0].toString().contains("statusCode: 404")) {
        setState(() {
          latestManga = value;
        });
      }
    });
    debugPrint(latestManga.toString());
  }

  Future<String> getAllAuthorsName(List authorsId) async {
    var authors = [];
    for (var authorId in authorsId) {
      authors.add(await connector.getAuthorName(authorId));
    }
    return authors.join(" et ");
  }

  String textLength(text, length) {
    if (text.length > length) {
      return text.substring(0, length) + "...";
    } else {
      return text;
    }
  }

  @override
  void initState() {
    super.initState();
    getLatestManga();
  }

  @override
  Widget build(BuildContext context) {
    int itemPerLine = (MediaQuery.of(context).size.width / 200).toInt();
    var itemHeight = (MediaQuery.of(context).size.height - kToolbarHeight - 24) / itemPerLine;
    var itemWidth = MediaQuery.of(context).size.width / itemPerLine;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Planning"),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: itemWidth,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: 16.5 / 25,
        ),
        itemCount: latestManga.length,
        itemBuilder: (context, index) {
          return FutureBuilder(
            future: connector.getCollectionDataWithFilter("volumes",
                'release?<="${DateTime.now().add(const Duration(days: 14)).toUtc()}"&&release?>="${DateTime.now().subtract(const Duration(days: 14)).toIso8601String()}"'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                final manga = json.decode(snapshot.data![index].toString());
                return SizedBox(
                  height: itemHeight,
                  width: itemWidth,
                  child: Container(
                    color: Colors.pink,
                    child: Column(
                      children: [
                        Center(
                          child: SizedBox(
                            height: itemHeight - 175,
                            width: (itemHeight - 175) * 16.5 / 24,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  'https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${manga['id']}/${manga['image']}',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          textLength(manga['title'], 20),
                          style: const TextStyle(fontSize: 18),
                        ),
                        FutureBuilder(
                          future: getAllAuthorsName(manga['authors']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              return Text(
                                textLength(snapshot.data.toString(), 34),
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              );
                            } else {
                              return SizedBox(
                                height: 18,
                                width: 18,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        },
      ),
    );
  }
}
