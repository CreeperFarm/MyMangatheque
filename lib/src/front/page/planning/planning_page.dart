import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  List<dynamic>? latestManga;
  final AppwriteConnector connector = AppwriteConnector();

  Future<void> getLatestManga() async {
    await connector
        .getCollectionDataWithFilter(
          "volumes",
          'release?<="${DateTime.now().add(const Duration(days: 14)).toUtc()}"&&release?>="${DateTime.now().subtract(const Duration(days: 14)).toIso8601String()}"',
        )
        .then((value) {
          if (value.isNotEmpty && !value[0].toString().contains("statusCode: 404")) {
            setState(() {
              latestManga = value;
            });
          }
        });
    debugPrint(latestManga.toString());
  }

  Future<String> getAllAuthorsName(List<dynamic> authorsId) async {
    final authors = <String>[];
    for (var authorId in authorsId) {
      authors.add(await connector.getAuthorName(authorId));
    }
    return authors.join(" & ");
  }

  String textLength(dynamic text, int length) {
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
      appBar: AppBar(title: const Text("Planning")),
      body: const Center(child: Text("TODO: Add the planning page")),
    );
  }
}
