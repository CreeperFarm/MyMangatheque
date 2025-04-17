import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class MyMangaShowTile extends StatefulWidget {
  final Map<String, dynamic> mangaData;
  final String initRoute;
  final double width;
  final double height;

  const MyMangaShowTile({
    required this.mangaData,
    required this.initRoute,
    required this.width,
    required this.height,
    super.key,
  });

  @override
  State<MyMangaShowTile> createState() => _MyMangaShowTileState();
}

class _MyMangaShowTileState extends State<MyMangaShowTile> {
  bool isOwned = false;
  bool isLoggedIn = PocketBaseConnector().isLoggedIn();

  Future<void> _checkIfOwned() async {
    if (PocketBaseConnector().isLoggedIn()) {
      bool isOwnedData = await PocketBaseConnector().isVolumeOwned(PocketBaseConnector().getConnectedUser()!.id, widget.mangaData['id']);
      setState(() {
        isOwned = isOwnedData;
      });
    } else {
      setState(() {
        isOwned = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfOwned();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 10.0,
        bottom: 10.0,
      ),
      child: GestureDetector(
        onTap: () {
          pushOrGo(
            context,
            '${(widget.initRoute == "/") ? "" : widget.initRoute}/volume/${widget.mangaData['id']}',
          );
        },
        child: OverflowBox(
          maxWidth: widget.width,
          maxHeight: widget.height,
          minWidth: widget.width,
          minHeight: widget.height,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: widget.width,
              maxHeight: widget.height,
              minWidth: widget.width,
              minHeight: widget.height,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: OverflowBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        width: widget.width,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Positioned(
                              top: 5,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 10.0,
                                  right: 10.0,
                                  left: 20.0,
                                ),
                                child: SizedBox(
                                  height: widget.height * 0.74 - 10,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Wrap(
                                      children: [
                                        Image.network(
                                          'https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${widget.mangaData['id']}/${widget.mangaData['image']}',
                                          height: widget.height * 0.74 - 10,
                                          fit: BoxFit.fill,
                                        ),
                                        BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                          child: Container(
                                            alignment: Alignment.center,
                                            color: Colors.grey.withValues(alpha: .4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Display the image
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
                                  ), // Added border color
                                ),
                                height: widget.height * 0.74 - 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    'https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${widget.mangaData['id']}/${widget.mangaData['image']}',
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),

                            // Show a badge if the volume is owned
                            (isLoggedIn)
                                ? FutureBuilder(
                                    future: PocketBaseConnector().isVolumeOwned(PocketBaseConnector().getConnectedUser()!.id, widget.mangaData['id']),
                                    builder: (BuildContext context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                        if (snapshot.data == false) {
                                          return Container();
                                        } else {
                                          return Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xFF1780A3),
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(10.0),
                                                  topLeft: Radius.circular(10.0),
                                                  bottomRight: Radius.circular(10.0),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 5.0,
                                                  vertical: 2.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    Text(
                                                      'Possédé',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        return Container();
                                      }
                                    },
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Text(
                        widget.mangaData['title'].toString().replaceAll(' - Tome ${widget.mangaData['tome_number']}', ""),
                        style: TextStyle(
                          fontSize: 17,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 10.0,
                        left: 10.0,
                        bottom: 10.0,
                      ),
                      child: Text(
                        'Tome ${widget.mangaData['tome_number']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
