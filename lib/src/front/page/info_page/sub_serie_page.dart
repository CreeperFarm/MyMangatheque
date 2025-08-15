import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/front/components/my_author_tile.dart';
import 'package:mymangatheque/src/front/components/my_editor_show.dart';
import 'package:mymangatheque/src/front/components/my_genres_show.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_picture_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_volume_tile.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class SubSeriePage extends StatefulWidget {
  final String serieId;
  final String initRoute;

  const SubSeriePage({required this.serieId, required this.initRoute, super.key});

  @override
  State<SubSeriePage> createState() => _SubSeriePageState();
}

class _SubSeriePageState extends State<SubSeriePage> {
  bool isSubSeriesFollowed = false;
  final PocketBaseConnector connector = PocketBaseConnector();

  void _checkSubSeriesFollowing() async {
    if (connector.isLoggedIn()) {
      bool owned = await connector.isSubSeriesFollowed(connector.getConnectedUser()!.id, widget.serieId);
      setState(() {
        isSubSeriesFollowed = owned;
      });
    } else {
      setState(() {
        isSubSeriesFollowed = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkSubSeriesFollowing();
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

    return FutureBuilder(
      future: PocketBaseConnector().getOneExpand(
        'sub_series',
        widget.serieId,
        'authors,volumes,serie.genres,editor',
      ),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: Center(
              child: Text(localizations.noConnection),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: Center(
              child: const Text("Une erreur est survenue"),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // ? Define variables
          Map<String, dynamic> data = json.decode(snapshot.data.toString())[0];
          final List<dynamic> authors = data['expand']['authors'];
          final List<dynamic> volumes = data['expand']['volumes'];
          final Map<String, dynamic> series = data['expand']['serie'];
          final Map<String, dynamic> editor = data['expand']['editor'];

          // ? Sort volumes
          volumes.sort((a, b) {
            if (a['tome_number'] < b['tome_number']) {
              return -1;
            } else if (a['tome_number'] > b['tome_number']) {
              return 1;
            } else {
              return 0;
            }
          });

          // ? Display on screen
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                data['title'].toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            body: MyScrollColumn(
              columnMainAxisAlignment: MainAxisAlignment.start,
              children: [
                MyPictureDisplay(
                  pictureUrl: "https://api.mymangatheque.com/api/files/ofwxwbyrhy5dcor/${data['id'].toString()}/${data['image'].toString()}",
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'].toString(),
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      (data['support'] == null || data['support'] == "manga")
                          ? SizedBox()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                localizations.supportIs(data['support'].toString()),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 32 * 5 / 6 + 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: (!isSubSeriesFollowed)
                                        ? WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.surface)
                                        : WidgetStateProperty.all<Color>(Colors.green),
                                    iconColor: (!isSubSeriesFollowed)
                                        ? WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.primary)
                                        : WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimary),
                                    elevation: WidgetStateProperty.all<double>(0)),
                                onPressed: () async {
                                  if (connector.isLoggedIn()) {
                                    if (!isSubSeriesFollowed) {
                                      connector.addSubSeriesToFollowed(
                                        connector.getConnectedUser()!.id,
                                        widget.serieId.toString(),
                                      );
                                      setState(() {
                                        isSubSeriesFollowed = true;
                                      });
                                    } else {
                                      connector.removeSubSeriesToFollowed(
                                        connector.getConnectedUser()!.id,
                                        widget.serieId.toString(),
                                      );
                                      setState(() {
                                        isSubSeriesFollowed = false;
                                      });
                                    }
                                  } else {
                                    pushOrGo(
                                      context,
                                      '/profile/signin',
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    (!isSubSeriesFollowed) ? Icon(Icons.bookmark_border) : Icon(Icons.bookmark),
                                    Text(
                                      (!isSubSeriesFollowed) ? localizations.follow : localizations.followed,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color:
                                            (!isSubSeriesFollowed) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10,
                        horizontal: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${localizations.genres} :',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  children: [
                                    for (var i = 0; i < series["expand"]["genres"].length; i += 1) MyGenresShow(data: series["expand"]["genres"][i]),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10.0,
                        horizontal: 0.0,
                      ),
                      (authors.isEmpty)
                          ? SizedBox()
                          : (authors.length == 1)
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    '${localizations.author} :',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    '${localizations.authors} :',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                      for (var i = 0; i < authors.length; i += 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyAuthorTile(
                              authorData: authors[i],
                              initRoute: widget.initRoute,
                            ),
                            (i != authors.length - 1 && authors.length > 1)
                                ? MyLine(
                                    width: MediaQuery.of(context).size.width,
                                    vertical: 5,
                                    horizontal: 0,
                                  )
                                : SizedBox(),
                          ],
                        ),
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10,
                        horizontal: 0,
                      ),
                      (volumes.isEmpty)
                          ? SizedBox()
                          : (volumes.length == 1)
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    '${localizations.volume} :',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    '${localizations.volumes} :',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                      for (var i = 0; i < volumes.length; i += 1)
                        Column(
                          children: [
                            (connector.isLoggedIn())
                                ? FutureBuilder(
                                    future: connector.isVolumeOwned(connector.getConnectedUser()!.id, volumes[i]['id']),
                                    builder: (BuildContext context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                        return MyVolumeTile(
                                          volumeData: volumes[i],
                                          subSerieData: series,
                                          isVolumeOwned: snapshot.data,
                                          initRoute: widget.initRoute,
                                        );
                                      } else {
                                        return MyVolumeTile(
                                          volumeData: volumes[i],
                                          subSerieData: series,
                                          isVolumeOwned: false,
                                          initRoute: widget.initRoute,
                                        );
                                      }
                                    })
                                : MyVolumeTile(
                                    volumeData: volumes[i],
                                    subSerieData: series,
                                    isVolumeOwned: false,
                                    initRoute: widget.initRoute,
                                  ),
                            (i != volumes.length - 1 && volumes.length > 1)
                                ? MyLine(
                                    width: MediaQuery.of(context).size.width,
                                    vertical: 5,
                                    horizontal: 0,
                                  )
                                : SizedBox(),
                          ],
                        ),
                      (editor.isEmpty)
                          ? SizedBox()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyLine(
                                    width: MediaQuery.of(context).size.width,
                                    vertical: 5,
                                    horizontal: 0,
                                  ),
                                  Text(
                                    '${localizations.editor} :',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  MyEditorShow(
                                    editor: editor,
                                    initRoute: widget.initRoute,
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                )
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: Center(
              child: Text(localizations.subSeriesDoesNotExist),
            ),
          );
        }
      },
    );
  }
}
