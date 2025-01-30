import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';

class ReadPileTab extends ConsumerStatefulWidget {
  const ReadPileTab({super.key});

  @override
  ConsumerState createState() => _ReadPileTabState();
}

class _ReadPileTabState extends ConsumerState<ReadPileTab> {
  @override
  Widget build(BuildContext context) {
    final readedSubSeries = ref.watch(mangaOwnedProvider);

    int volumeReaded = 0;
    int volumeOwned = 0;

    for (var subSerie in readedSubSeries) {
      for (var volume in subSerie.volumes) {
        if (volume.readed) {
          volumeReaded++;
        }
        volumeOwned++;
      }
    }

    return Padding(
      padding: EdgeInsets.all(10),
      child: MyScrollColumn(
        columnCrossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (volumeOwned == 0)
              ? Text(
                  "Aucun tome n'est possédé.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Column(
                  children: [
                    Text(
                      '$volumeReaded tomes lu sur $volumeOwned tomes possédés.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 20,
                        width: MediaQuery.of(context).size.width,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 20,
                                width: MediaQuery.of(context).size.width * (volumeReaded / volumeOwned),
                                color: Theme.of(context).colorScheme.tertiaryFixed,
                              ),
                            ),
                          ],
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
          for (var i = 0; i < readedSubSeries.length; i++)
            Column(
              children: [
                Text(
                  readedSubSeries.toList()[i].title.replaceAll(' - Edition Standard', ''),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                MyLine(
                  width: MediaQuery.of(context).size.width,
                  vertical: 10,
                  horizontal: 0,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
