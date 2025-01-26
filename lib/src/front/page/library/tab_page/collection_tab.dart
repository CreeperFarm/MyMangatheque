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
  PocketBaseConnector connector = PocketBaseConnector();

  String textLength(text, length) {
    if (text.length > length) {
      return text.substring(0, length) + "...";
    } else {
      return text;
    }
  }

  int getNumberVolume() {
    final subSeries = ref.watch(mangaOwnedProvider);
    int number = 0;
    for (var subSerie in subSeries) {
      number += subSerie.numberOwnedVolumes;
    }
    return number;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration(seconds: 1),
      () {
        setState(() {});
      },
    );
    final subSeries = ref.watch(mangaOwnedProvider);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: MyScrollColumn(
        children: [
          MyTomeNumberShow(tomeTotal: getNumberVolume().toString(), editionTotal: subSeries.length.toString()),
          ...subSeries.map((subSerie) {
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    pushOrGo(context, '/library/sub_serie/${subSerie.id}');
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
                                  subSerie.title.replaceAll(' - Edition Standard', ''),
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "${subSerie.numberOwnedVolumes} tomes sur ${subSerie.numberOfVolumes}",
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width - 65,
                                    child: Stack(
                                      children: [
                                        for (var i = 0; i < subSerie.volumes.length; i++)
                                          (i == 0)
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  child: Image.network(
                                                    subSerie.volumes[i].image,
                                                    width: 65,
                                                  ),
                                                )
                                              : Positioned(
                                                  left: i * 45.0,
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
                                                        subSerie.volumes[i].image,
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
                  horizontal: 0,
                ),
              ],
            );
          })
        ],
      ),
    );
  }
}
