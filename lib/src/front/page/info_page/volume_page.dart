import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs_lite.dart';
import 'package:intl/intl.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_author_tile.dart';
import 'package:mymangatheque/src/front/components/my_editor_show.dart';
import 'package:mymangatheque/src/front/components/my_icon_text_label.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_picture_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_series_tile.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class VolumePage extends StatefulWidget {
  final String volumeId;
  final String initRoute;

  const VolumePage({
    required this.volumeId,
    required this.initRoute,
    super.key,
  });

  @override
  State<VolumePage> createState() => _VolumePageState();
}

class _VolumePageState extends State<VolumePage> {
  bool isVolumeOwned = false;
  bool isSubSeriesFollowed = false;
  bool isVolumeReaded = false;
  bool showMore = false;

  final PocketBaseConnector connector = PocketBaseConnector();

  void switchShowMoreState() {
    setState(() {
      showMore = !showMore;
    });
  }

  void _checkVolumeOwnership() async {
    if (connector.isLoggedIn()) {
      bool owned = await connector.isVolumeOwned(
        connector.getConnectedUser()!.id,
        widget.volumeId,
      );
      setState(() {
        isVolumeOwned = owned;
      });
      if (owned) {
        bool readed = await connector.isVolumeReaded(
          connector.getConnectedUser()!.id,
          widget.volumeId,
        );
        setState(() {
          isVolumeReaded = readed;
        });
      }
    } else {
      setState(() {
        isVolumeOwned = false;
      });
    }
  }

  void _checkSubSeriesFollowing() async {
    if (connector.isLoggedIn()) {
      final result = await connector.getOneExpand(
        'volumes',
        widget.volumeId,
        'sub_series',
      );
      final Map<String, dynamic> data = json.decode(result.toString())[0];
      bool owned = await connector.isSubSeriesFollowed(
        connector.getConnectedUser()!.id,
        data['expand']['sub_series']['id'].toString(),
      );
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
    _checkVolumeOwnership();
    _checkSubSeriesFollowing();
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder(
      future: connector.getOneExpand(
        'volumes',
        widget.volumeId,
        'authors,contains,editor,series.editors,sub_series',
      ),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(localizations.loading)),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            appBar: AppBar(title: Text(localizations.noConnection)),
            body: Center(child: Text(localizations.noConnection)),
          );
        } else if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return Scaffold(
            appBar: AppBar(title: Text(localizations.errorOccurred)),
            body: Center(child: Text(localizations.errorOccurred)),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          // ? Declaring variables
          Map<String, dynamic> data = json.decode(snapshot.data.toString())[0];
          final List<dynamic> contain = data['contain'];
          final List<dynamic> authors = data['expand']['authors'];
          final Map<String, dynamic> editor = data['expand']['editor'];
          final Map<String, dynamic> series = data['expand']['series'];
          final Map<String, dynamic> subSeries = data['expand']['sub_series'];
          final DateTime release = DateTime.parse(data['release'].toString());
          double widthAddAndFollowButton =
              MediaQuery.of(context).size.width * 0.5 - 15;

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
                  pictureUrl:
                      "https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${data['id'].toString()}/${data['image'].toString()}",
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
                                localizations.supportIs(
                                  data['support'].toString(),
                                ),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: widthAddAndFollowButton,
                            height: 32 * 5 / 6 + 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF1780A3),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: (!isVolumeOwned)
                                          ? WidgetStateProperty.all<Color>(
                                              Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                            )
                                          : WidgetStateProperty.all<Color>(
                                              Color(0xFF1780A3),
                                            ),
                                      iconColor: (!isVolumeOwned)
                                          ? WidgetStateProperty.all<Color>(
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            )
                                          : WidgetStateProperty.all<Color>(
                                              Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                            ),
                                      elevation:
                                          WidgetStateProperty.all<double>(0),
                                    ),
                                    onPressed: () async {
                                      if (connector.isLoggedIn()) {
                                        if (!isVolumeOwned) {
                                          if (!isSubSeriesFollowed) {
                                            connector.addVolumeToOwned(
                                              connector.getConnectedUser()!.id,
                                              data['id'].toString(),
                                              false,
                                            );
                                            connector.addSubSeriesToFollowed(
                                              connector.getConnectedUser()!.id,
                                              subSeries['id'].toString(),
                                            );
                                            setState(() {
                                              isVolumeOwned = true;
                                              isSubSeriesFollowed = true;
                                            });
                                          } else {
                                            connector.addVolumeToOwned(
                                              connector.getConnectedUser()!.id,
                                              data['id'].toString(),
                                              false,
                                            );
                                            setState(() {
                                              isVolumeOwned = true;
                                            });
                                          }
                                        } else {
                                          connector.removeVolumeFromOwned(
                                            connector.getConnectedUser()!.id,
                                            data['id'].toString(),
                                          );
                                          setState(() {
                                            isVolumeOwned = false;
                                          });
                                        }
                                      } else {
                                        pushOrGo(context, '/profile/signin');
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        (!isVolumeOwned)
                                            ? Icon(Icons.add)
                                            : Icon(Icons.check),
                                        Text(
                                          (!isVolumeOwned)
                                              ? localizations.add
                                              : localizations.remove,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: (!isVolumeOwned)
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: widthAddAndFollowButton,
                            height: 32 * 5 / 6 + 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.green),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: (!isSubSeriesFollowed)
                                          ? WidgetStateProperty.all<Color>(
                                              Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                            )
                                          : WidgetStateProperty.all<Color>(
                                              Colors.green,
                                            ),
                                      iconColor: (!isSubSeriesFollowed)
                                          ? WidgetStateProperty.all<Color>(
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            )
                                          : WidgetStateProperty.all<Color>(
                                              Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                            ),
                                      elevation:
                                          WidgetStateProperty.all<double>(0),
                                    ),
                                    onPressed: () async {
                                      if (connector.isLoggedIn()) {
                                        if (!isSubSeriesFollowed) {
                                          connector.addSubSeriesToFollowed(
                                            connector.getConnectedUser()!.id,
                                            subSeries['id'].toString(),
                                          );
                                          setState(() {
                                            isSubSeriesFollowed = true;
                                          });
                                        } else {
                                          connector.removeSubSeriesToFollowed(
                                            connector.getConnectedUser()!.id,
                                            subSeries['id'].toString(),
                                          );
                                          setState(() {
                                            isSubSeriesFollowed = false;
                                          });
                                        }
                                      } else {
                                        pushOrGo(context, '/profile/signin');
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        (!isSubSeriesFollowed)
                                            ? Icon(Icons.bookmark_border)
                                            : Icon(Icons.bookmark),
                                        Text(
                                          (!isSubSeriesFollowed)
                                              ? localizations.follow
                                              : localizations.followed,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: (!isSubSeriesFollowed)
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      (isVolumeOwned)
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 32 * 5 / 6 + 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: ElevatedButton.icon(
                                        style: ButtonStyle(
                                          backgroundColor: (!isVolumeReaded)
                                              ? WidgetStateProperty.all<Color>(
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.surface,
                                                )
                                              : WidgetStateProperty.all<Color>(
                                                  Colors.red,
                                                ),
                                          iconColor: (!isVolumeReaded)
                                              ? WidgetStateProperty.all<Color>(
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                )
                                              : WidgetStateProperty.all<Color>(
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary,
                                                ),
                                          elevation:
                                              WidgetStateProperty.all<double>(
                                                0,
                                              ),
                                        ),
                                        onPressed: () async {
                                          if (connector.isLoggedIn()) {
                                            connector.changeReadState(
                                              connector.getConnectedUser()!.id,
                                              data['id'].toString(),
                                              !isVolumeReaded,
                                            );
                                            setState(() {
                                              isVolumeReaded = !isVolumeReaded;
                                            });
                                          } else {
                                            pushOrGo(
                                              context,
                                              '/profile/signin',
                                            );
                                          }
                                        },
                                        label: Text(
                                          (!isVolumeReaded)
                                              ? localizations.read
                                              : localizations.readed,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: (!isVolumeReaded)
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary,
                                          ),
                                        ),
                                        icon: (!isVolumeReaded)
                                            ? Icon(Icons.bookmark_add_rounded)
                                            : Icon(
                                                Icons.bookmark_remove_rounded,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
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
                                  '${localizations.summary} :',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: Text(
                                    data['resume'].toString(),
                                    style: const TextStyle(fontSize: 15),
                                    textAlign: TextAlign.justify,
                                    maxLines: (showMore) ? null : 3,
                                    softWrap: true,
                                    overflow: (showMore)
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 10,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      showMore = !showMore;
                                    }),
                                    child: Text(
                                      (showMore)
                                          ? localizations.seeMore
                                          : localizations.seeLess,
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
                              '${localizations.editor} :',
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
                              '${localizations.series} :',
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
                              localizations.volumeNotAvailableAnymore,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${localizations.price} : ${NumberFormat.currency(locale: "fr_FR", symbol: "€", decimalDigits: 2).format(data['price'])}',
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
                                          SizedBox(height: 10),
                                          for (
                                            var i = 0;
                                            i < data['book_link'].length;
                                            i += 1
                                          )
                                            (data['book_link'][i]['seller'] !=
                                                    "bdfugue")
                                                ? SizedBox()
                                                : (data['price'] == "0" ||
                                                      data['price'] == "-1")
                                                ? Text(
                                                    localizations
                                                        .volumeNotAvailableForSale,
                                                  )
                                                : Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            (data["book_link"][i]["available"]
                                                                        .contains(
                                                                          "shippingUnder",
                                                                        )! ==
                                                                    false)
                                                                ? localizations
                                                                      .availability(
                                                                        data["book_link"][i]["available"],
                                                                      )
                                                                : (data["book_link"][i]["available"]
                                                                      .contains(
                                                                        "Days",
                                                                      ))
                                                                ? localizations.shippingUnderDays(
                                                                    data["book_link"][i]["available"]
                                                                        .replace(
                                                                          "shippingUnder",
                                                                          "",
                                                                        )
                                                                        .replaces(
                                                                          "days",
                                                                          "",
                                                                        )
                                                                        .replace(
                                                                          " ",
                                                                          "",
                                                                        ),
                                                                  )
                                                                : localizations.shippingUnderWeeks(
                                                                    data["book_link"][i]["available"]
                                                                        .replace(
                                                                          "shippingUnder",
                                                                          "",
                                                                        )
                                                                        .replaces(
                                                                          "week",
                                                                          "",
                                                                        )
                                                                        .replace(
                                                                          "s",
                                                                          "",
                                                                        )
                                                                        .replace(
                                                                          " ",
                                                                          "",
                                                                        ),
                                                                  ),
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  (data["book_link"][i]["available"] ==
                                                                          "inStock" ||
                                                                      data["book_link"][i]["available"] ==
                                                                          "availanle")
                                                                  ? Colors.green
                                                                  : (data["book_link"][i]["available"] ==
                                                                            "onPreorder" ||
                                                                        data["book_link"][i]["available"] ==
                                                                            "preorder")
                                                                  ? Colors.blue
                                                                  : (data["book_link"][i]["available"]
                                                                        .contains(
                                                                          "shippingUnder",
                                                                        ))
                                                                  ? Colors
                                                                        .orange
                                                                  : Colors.red,
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Text(
                                                            localizations.soldAndShippedBy(
                                                              data["book_link"][i]["seller"]
                                                                          .toString() ==
                                                                      "bdfugue"
                                                                  ? "BDFugue"
                                                                  : data["book_link"][i]["seller"]
                                                                        .toString(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      ElevatedButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              WidgetStateProperty.all<
                                                                Color
                                                              >(Colors.red),
                                                        ),
                                                        onPressed: () {
                                                          launchUrl(
                                                            Uri.parse(
                                                              data["book_link"][i]["url"]
                                                                  .toString(),
                                                            ),
                                                          );
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Transform.translate(
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    3.5,
                                                                  ),
                                                              child: OwnIcon(
                                                                iconColor:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .primary,
                                                                iconSrc: Assets
                                                                    .icons
                                                                    .shoppingCart,
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              localizations.buyOn(
                                                                data["book_link"][i]["seller"]
                                                                            .toString() ==
                                                                        "bdfugue"
                                                                    ? "BDFugue"
                                                                    : data["book_link"][i]["seller"]
                                                                          .toString(),
                                                              ),
                                                              style: TextStyle(
                                                                color: Theme.of(
                                                                  context,
                                                                ).colorScheme.primary,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                        '${localizations.informations} :',
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    child: MyIconTextLabel(
                                      iconSrc: Assets.icons.calendar,
                                      text:
                                          '${localizations.publicationDate} : ${DateFormat.yMMMMd(localizations.localeName).format(release)}',
                                      heightIcon: 30,
                                    ),
                                  ),
                            (data['ean'] == null)
                                ? SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    child: MyIconTextLabel(
                                      iconSrc: Assets.icons.barcode,
                                      text:
                                          '${localizations.ean} : ${data['ean']}',
                                      heightIcon: 30,
                                    ),
                                  ),
                            (data['info'] == null)
                                ? SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    child: MyIconTextLabel(
                                      iconSrc: Assets.icons.bookOpen,
                                      text:
                                          "${localizations.numberOfPages} : ${data['info']['pageNumber'].toString()}",
                                      heightIcon: 30,
                                    ),
                                  ),
                            (contain.isEmpty || contain.toString() == "")
                                ? SizedBox()
                                : Column(
                                    children: [
                                      MyLine(
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
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
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: Text("Le volume n'existe pas")),
            body: Center(child: const Text("Le volume n'existe pas")),
          );
        }
      },
    );
  }
}
