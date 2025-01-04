import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';

class CollectionTab extends StatefulWidget {
  const CollectionTab({super.key});

  @override
  State<CollectionTab> createState() => _CollectionTabState();
}

class _CollectionTabState extends State<CollectionTab> {
  int numberMangaOwned = 0;
  PocketBaseConnector connector = PocketBaseConnector();

  String textLength(text, length) {
    if (text.length > length) {
      return text.substring(0, length) + "...";
    } else {
      return text;
    }
  }

  getNumberOfMangaOwned() async {
    try {
      int countMangaOwned = await connector.getNumberOwnedManga(connector.getConnectedUser()!.id);
      setState(() {
        numberMangaOwned = countMangaOwned;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getNumberOfMangaOwned();
  }

  @override
  Widget build(BuildContext context) {
    if (connector.getConnectedUser() == null) {
      context.go('/profile/signin');
    }
    return FutureBuilder(
        future: connector.getCollectionDataWithFilterExpand('owned', "user='${connector.getConnectedUser()!.id}'", 'volume.sub_series'),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.none) {
            return const Text("Aucune connexion");
          } else if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return const Text("Une erreur est survenue");
          } else if (snapshot.hasData && snapshot.data != null) {
            final data = json.decode(snapshot.data.toString());
            List<dynamic> subSeries = [];
            // TODO: Make the data be group by sub_series
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  MyTomeNumberShow(tomeTotal: numberMangaOwned.toString(), editionTotal: "Soon..."),
                ],
              ),
            );
          } else {
            return Text("Une erreur est survenue");
          }
        });
  }
}
