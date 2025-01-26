import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class CollectionTab extends ConsumerStatefulWidget {
  const CollectionTab({super.key});

  @override
  ConsumerState<CollectionTab> createState() => _CollectionTabState();
}

class _CollectionTabState extends ConsumerState<CollectionTab> {
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
    final data = ref.watch(mangaOwnedProvider);
    try {
      for (var i = 0; i < data.length; i++) {
        int length = data[i]['volumes'].length;
        numberMangaOwned += length;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    ref.read(mangaOwnedProvider);
    getNumberOfMangaOwned();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subSeries = ref.watch(mangaOwnedProvider);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: MyScrollColumn(
        children: [
          MyTomeNumberShow(tomeTotal: numberMangaOwned.toString(), editionTotal: subSeries.length.toString()),
          for (var i = 0; i < subSeries.length; i++)
            Column(
              children: [
                InkWell(
                  onTap: () {
                    pushOrGo(context, '/library/sub_serie/${subSeries[i]['id']}');
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 65,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subSeries[i]['title'].replaceAll(' - Edition Standard', ''),
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "${subSeries[i]['volumes'].length} tomes sur ${subSeries[i]['number_of_volumes']}",
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width - 65,
                                    child: Stack(
                                      children: [
                                        for (var j = 0; j < subSeries[i]['volumes'].length; j++)
                                          (j == 0)
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  child: Image.network(
                                                    'https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${subSeries[i]['volumes'][j]['id']}/${subSeries[i]['volumes'][j]['image']}',
                                                    width: 65,
                                                  ),
                                                )
                                              : Positioned(
                                                  left: j * 45.0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                                                          spreadRadius: 1,
                                                          blurRadius: 2,
                                                          offset: const Offset(0, 1),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(10.0),
                                                      child: Image.network(
                                                        'https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${subSeries[i]['volumes'][j]['id']}/${subSeries[i]['volumes'][j]['image']}',
                                                        width: 65,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        OwnIcon(
                          iconColor: Theme.of(context).colorScheme.primary,
                          iconName: 'arrow-right',
                        ),
                      ],
                    ),
                  ),
                ),
                MyLine(
                  width: MediaQuery.of(context).size.width,
                  vertical: 10,
                ),
              ],
            )
        ],
      ),
    );
  }
}
