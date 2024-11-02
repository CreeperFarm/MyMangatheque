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

  Future<void> getLatestManga() async {
    await PocketBaseConnector()
        .getCollectionDataWithFilter("volumes",
            'release?>="${DateTime.now().add(const Duration(days: 14)).toUtc()}"' /* && release <= "${DateTime.now().subtract(const Duration(days: 14)).toIso8601String()}"'*/) //TODO: Remove the comment so it only show recent manga
        .then((value) {
      if (value.isNotEmpty && !value[0].toString().contains("statusCode: 404")) {
        setState(() {
          latestManga = value;
        });
      }
    });
    debugPrint(latestManga.toString());
  }

  Future<String> getAuthorName(String authorId) async {
    var author = await PocketBaseConnector().getOne('authors', authorId);
    return json.decode(author[0].toString())['name'].toString();
  }

  Future<String> getAllAuthorsName(List authorsId) async {
    var authors = [];
    for (var authorId in authorsId) {
      authors.add(await getAuthorName(authorId));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Planning"),
      ),
      body: ListView.builder(
        itemCount: latestManga.length,
        itemBuilder: (context, index) {
          return FutureBuilder(
            future: PocketBaseConnector().getCollectionDataWithFilter("volumes",
                'release?>="${DateTime.now().add(const Duration(days: 14)).toUtc()}"' /* && release <= "${DateTime.now().subtract(const Duration(days: 14)).toIso8601String()}"'*/),
            //TODO: Remove the comment so it only show recent manga
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                final manga = json.decode(snapshot.data![index].toString());
                return LayoutBuilder(
                  builder: (context, constraints) {
                    int itemPerLine = (constraints.maxWidth / 200).toInt();
                    print(itemPerLine);
                    var itemHeight = (MediaQuery.of(context).size.height - kToolbarHeight - 24) / itemPerLine;
                    var itemWidth = constraints.maxWidth / itemPerLine;
                    print(itemHeight);
                    print(itemWidth);
                    return SizedBox(
                      height: itemHeight,
                      width: itemWidth,
                      child: Column(
                        children: [
                          Center(
                            child: SizedBox(
                              height: itemHeight - 150,
                              width: (itemHeight - 150) * 16.5 / 24,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  'https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${manga['id']}/${manga['image']}',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            textLength(manga['title'], 25),
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            textLength(manga['resume'], 50),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
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
