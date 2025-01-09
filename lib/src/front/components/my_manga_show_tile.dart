import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';

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
      child: InkWell(
        onTap: () {
          context.push('${(widget.initRoute == "/") ? "" : widget.initRoute}/volume/${widget.mangaData['id']}');
        },
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
                          // Display the image
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                            ),
                            child: SizedBox(
                              height: widget.height * 0.79,
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
                                          right: 0,
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
    );
  }
}
