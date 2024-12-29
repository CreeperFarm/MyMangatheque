import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs_lite.dart';
import 'package:intl/intl.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/const_info.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_author_tile.dart';
import 'package:mymangatheque/src/front/components/my_editor_show.dart';
import 'package:mymangatheque/src/front/components/my_icon_text_label.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_picture_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_series_tile.dart';

class VolumePage extends StatefulWidget {
  final String volumeId;
  final String initRoute;

  const VolumePage({required this.volumeId, required this.initRoute, super.key});

  @override
  State<VolumePage> createState() => _VolumePageState();
}

class _VolumePageState extends State<VolumePage> {
  bool showMore = false;
  final PocketBaseConnector connector = PocketBaseConnector();

  void switchShowMoreState() {
    setState(() {
      showMore = !showMore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PocketBaseConnector().getOneExpand('volumes', widget.volumeId, 'authors,contains,editor,series.editors'),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Chargement..."),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Aucune connexion"),
            ),
            body: Center(
              child: const Text("Aucune connexion"),
            ),
          );
        }
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return Scaffold(
            appBar: AppBar(
              title: Text("Une erreur est survenue"),
            ),
            body: Center(
              child: const Text("Une erreur est survenue"),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // ? Declaring variables
          Map<String, dynamic> data = json.decode(snapshot.data.toString())[0];
          final List<dynamic> contain = data['contain'];
          final List<dynamic> authors = data['expand']['authors'];
          final Map<String, dynamic> editor = data['expand']['editor'];
          final Map<String, dynamic> series = data['expand']['series'];
          final DateTime release = DateTime.parse(data['release'].toString());

          // ? Return Scaffold
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                data['title'].toString(),
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            body: MyScrollColumn(
              columnMainAxisAlignment: MainAxisAlignment.start,
              children: [
                MyPictureDisplay(
                  pictureUrl: "https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${data['id'].toString()}/${data['image'].toString()}",
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
                                data['support'].toString().replaceAll('-', ' '),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10,
                        horizontal: 0,
                      ),
                      (authors.isEmpty)
                          ? SizedBox()
                          : (authors.length == 1)
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    'Auteur :',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    'Auteurs :',
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
                      (data['resume'].isEmpty || data['resume'] == "")
                          ? SizedBox()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyLine(
                                  width: MediaQuery.of(context).size.width,
                                  vertical: 10,
                                  horizontal: 0,
                                ),
                                Text(
                                  'Résumé :',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    data['resume'].toString(),
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.justify,
                                    maxLines: (showMore) ? null : 3,
                                    softWrap: true,
                                    overflow: (showMore) ? TextOverflow.visible : TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      showMore = !showMore;
                                    }),
                                    child: Text(
                                      (showMore) ? "Voir moins" : "Voir plus",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                              'Éditeur :',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            MyEditorShow(
                              editor: editor,
                              initRoute: widget.initRoute,
                            ),
                          ],
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
                              'Série :',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            MySeriesTile(
                              seriesData: series,
                              initRoute: widget.initRoute,
                            ),
                          ],
                        ),
                      ),
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10,
                        horizontal: 0,
                      ),
                      (data['price'] == 0 || data['price'] == -1)
                          ? Text(
                              'Malheureusement, ce volume n\'est plus disponible à la vente.',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Prix : ${NumberFormat.currency(locale: "fr_FR", symbol: "€", decimalDigits: 2).format(data['price'])}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    /*
                              (data['book_link'] == null || data['book_link'] == "")
                                  ? SizedBox()
                                  : DropdownButton(

                                      items: [
                                        for (var i = 0; i < data['book_link'].length; i += 1)
                                          DropdownMenuItem(
                                            value: (data['book_link'][i]['seller'].toLowerCase()),
                                            child: Text((data['book_link'][i]['seller'] == "bdfugue")
                                                ? "BDfugue"
                                                : (data['book_link'][i]['seller'] == "amazon")
                                                    ? "Amazon"
                                                    : data['book_link'][i]['seller'].toString()),
                                          ),
                                      ],
                                      onChanged: (value) {
                                        value;
                                      },
                                    ),*/
                                  ],
                                ),
                                (data['book_link'].isEmpty)
                                    ? SizedBox()
                                    : Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          for (var i = 0; i < data['book_link'].length; i += 1)
                                            (data['book_link'][i]['seller'] != "bdfugue")
                                                ? SizedBox()
                                                : (data['price'] == "0" || data['price'] == "-1")
                                                    ? Text("Malheureusement, ce volume n'est pas disponible à la vente.")
                                                    : Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                data["book_link"][i]["available"].toString(),
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: (data["book_link"][i]["available"] == "En Stock" ||
                                                                          data["book_link"][i]["available"] == "Disponible")
                                                                      ? Colors.green
                                                                      : (data["book_link"][i]["available"] == "En Précommande" ||
                                                                              data["book_link"][i]["available"] == "En Precommande" ||
                                                                              data["book_link"][i]["available"] == "Precommande" ||
                                                                              data["book_link"][i]["available"] == "Précommande")
                                                                          ? Colors.blue
                                                                          : (data["book_link"][i]["available"].contains("Livraison sous"))
                                                                              ? Colors.orange
                                                                              : Colors.red,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Text("Vendu et expédié par BDfugue."),
                                                            ],
                                                          ),
                                                          ElevatedButton(
                                                            style: ButtonStyle(
                                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                                            ),
                                                            onPressed: () {
                                                              launchUrl(Uri.parse(data["book_link"][i]["url"].toString()));
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Transform.translate(
                                                                  offset: const Offset(0, 3.5),
                                                                  child: OwnIcon(
                                                                    iconColor: Theme.of(context).colorScheme.primary,
                                                                    iconName: 'shopping-cart',
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "Acheter sur BDfugue",
                                                                  style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.primary,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 16,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                        ],
                                      ),
                              ],
                            ),
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10,
                        horizontal: 0,
                      ),
                      Text(
                        'Informations :',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (data['release'] == null)
                                ? SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: MyIconTextLabel(
                                      iconName: 'calendar',
                                      text: 'Date de sortie: ${release.day} ${month[release.month.toString()]} ${release.year}',
                                      heightIcon: 30,
                                    ),
                                  ),
                            (data['ean'] == null)
                                ? SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: MyIconTextLabel(
                                      iconName: 'barcode',
                                      text: 'EAN : ${data['ean']}',
                                      heightIcon: 30,
                                    ),
                                  ),
                            (data['info'] == null)
                                ? SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: MyIconTextLabel(
                                      iconName: 'book_open',
                                      text: "Nombre de page : ${data['info']['pageNumber'].toString()}",
                                      heightIcon: 30,
                                    ),
                                  ),
                            (contain.isEmpty || contain == "")
                                ? SizedBox()
                                : Column(
                                    children: [
                                      MyLine(
                                        width: MediaQuery.of(context).size.width,
                                        vertical: 10,
                                        horizontal: 0,
                                      ), // TODO: Finir la partie contient
                                    ],
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
              title: Text("Le volume n'existe pas"),
            ),
            body: Center(
              child: const Text("Le volume n'existe pas"),
            ),
          );
        }
      },
    );
  }
}
