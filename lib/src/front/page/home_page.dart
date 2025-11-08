import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/front/components/my_manga_show_tile.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final PocketBaseConnector connector = PocketBaseConnector();

    return StreamBuilder(
      stream: connector.listenToUserChanges(),
      builder: (context, snapshot) {
        return FutureBuilder(
          future: connector.getCollectionFullListOrder('volumes', '-release'),
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(localizations.loading),
                ),
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.none) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(localizations.noConnection),
                ),
                body: Center(
                  child: Text(localizations.noConnection),
                ),
              );
            }
            if (snapshot.hasError) {
              debugPrint(snapshot.error.toString());
              return Scaffold(
                appBar: AppBar(
                  title: Text(localizations.errorOccurred),
                ),
                body: Center(
                  child: Text(localizations.errorOccurred),
                ),
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
              return LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 1200) {
                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: json.decode(snapshot.data!.toString()).length,
                    itemBuilder: (BuildContext context, int index) {
                      return MyMangaShowTile(
                        mangaData: json.decode(snapshot.data!.toString())[index],
                        initRoute: "/",
                        width: constraints.maxWidth / 4 - 30,
                        height: (constraints.maxWidth / 4 - 30) * 1.5 + 10,
                      );
                    },
                  );
                } else if (constraints.maxWidth > 800) {
                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.7,
                    ),
                    scrollDirection: Axis.vertical,
                    itemCount: json.decode(snapshot.data!.toString()).length,
                    itemBuilder: (BuildContext context, int index) {
                      return MyMangaShowTile(
                        mangaData: json.decode(snapshot.data!.toString())[index],
                        initRoute: "/",
                        width: constraints.maxWidth / 3 - 30,
                        height: (constraints.maxWidth / 3 - 30) * 1.5 + 10,
                      );
                    },
                  );
                } else {
                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: json.decode(snapshot.data!.toString()).length,
                    itemBuilder: (BuildContext context, int index) {
                      return MyMangaShowTile(
                        mangaData: json.decode(snapshot.data!.toString())[index],
                        initRoute: "/",
                        width: constraints.maxWidth / 2 - 30,
                        height: (constraints.maxWidth / 2 - 30) * 1.5 + 10,
                      );
                    },
                  );
                }
              });
            } else {
              debugPrint(snapshot.error.toString());
              return Scaffold(
                appBar: AppBar(
                  title: Text(localizations.errorOccurred),
                ),
                body: Center(
                  child: Text(localizations.errorOccurred),
                ),
              );
            }
          },
        );
      },
    );
  }
}
