import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  var latestManga;

  void getLatestManga() {
    PocketBaseConnector()
        .getCollectionDataWithFilter("manga",
            'release >= "${DateTime.now().subtract(const Duration(days: 14)).toIso8601String()}" && release <= "${DateTime.now().add(const Duration(days: 14)).toIso8601String()}" ')
        .then((value) {
      setState(() {
        latestManga = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getLatestManga();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Planning"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Planning",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              const Image(
                image: AssetImage("assets/images/splash_bg.png"),
              ),
              Text(latestManga.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
