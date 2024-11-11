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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          MyTomeNumberShow(tomeTotal: numberMangaOwned.toString(), editionTotal: "5"),
          /*Expanded(
            child: ListView.builder(
              itemCount: _resultsList.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: SizedBox(
                                  width: 50,
                                  child: Image.network(
                                    'https://cdn.statically.io/gh/CreeperFarm/AppManga/main/${_resultsList[index]['img']}.jpg',
                                    width: 50,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    textLength(_resultsList[index]['manga'], 27),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    textLength(_resultsList[index]['author'], 40),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _resultsList[index]['releaseDate'],
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                      onTap: () {
                        context.go('/library/series/${_resultsList[index]['manga']}');
                      },
                    ),
                    MyLine(
                      width: MediaQuery.of(context).size.width,
                      vertical: 0,
                    ),
                  ],
                );
              },
            ),
          ),*/
        ],
      ),
    );
  }
}
