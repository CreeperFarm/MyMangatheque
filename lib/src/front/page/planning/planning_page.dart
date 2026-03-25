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
        .getCollectionDataWithFilter(
          "volumes",
          'release?<="${DateTime.now().add(const Duration(days: 14)).toUtc()}"&&release?>="${DateTime.now().subtract(const Duration(days: 14)).toIso8601String()}"',
        )
        .then((value) {
          if (value.isNotEmpty &&
              !value[0].toString().contains("statusCode: 404")) {
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
    return authors.join(" & ");
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
    var itemHeight =
        (MediaQuery.of(context).size.height - kToolbarHeight - 24) /
        itemPerLine;
    var itemWidth = MediaQuery.of(context).size.width / itemPerLine;
    return Scaffold(
      appBar: AppBar(title: Text("Planning")),
      body: Center(child: Text("TODO: Add the planning page")),
    );
  }
}
