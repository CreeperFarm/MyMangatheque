import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_loader_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';

class ReadPileTab extends ConsumerStatefulWidget {
  const ReadPileTab({super.key});

  @override
  ConsumerState createState() => _ReadPileTabState();
}

class _ReadPileTabState extends ConsumerState<ReadPileTab> {
  @override
  Widget build(BuildContext context) {
    final readedSubSeries = ref.watch(mangaOwnedProvider);
    List<dynamic> readSubSeriesList = readedSubSeries.toList();

    int volumeReaded = 0;
    int volumeOwned = 0;

    // SubSerieForCollection notReadedBook;

    for (var subSerie in readedSubSeries) {
      // int numberOfTomesReaded = 0;
      for (int i = 0; i < subSerie.volumes.length; i++) {
        Volume volume = subSerie.volumes[i];
        if (volume.readed) {
          volumeReaded++;
          // numberOfTomesReaded++;
          // subSerie.volumes.removeAt(i);
        }
        volumeOwned++;
      }
      // if (numberOfTomesReaded < subSerie.numberOwnedVolumes) {
      //   notReadedBook = subSerie;
      // }
    }

    int numberVolumeReaded(List<Volume> volumes) {
      int volumeReaded = 0;
      for (var volume in volumes) {
        if (volume.readed) {
          volumeReaded++;
        }
      }
      return volumeReaded;
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
                    MyLoaderDisplay(percentage: (volumeReaded / volumeOwned)),
                  ],
                ),
          MyLine(
            width: MediaQuery.of(context).size.width,
            vertical: 10,
            horizontal: 0,
          ),
          // TODO: Display only the image of volumes owned but not readed
          for (var i = 0; i < readedSubSeries.length; i++)
            Column(
              children: [
                Text(
                  readSubSeriesList[i].title.replaceAll(' - Edition Standard', ''),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: MyLoaderDisplay(
                    percentage: numberVolumeReaded(readSubSeriesList[i].volumes) / readSubSeriesList[i].numberOwnedVolumes,
                    paddingWidth: 40,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        for (var j = 0; j < readSubSeriesList[i].numberOwnedVolumes - numberVolumeReaded(readSubSeriesList[i].volumes); j++)
                          (!readSubSeriesList[i].volumes[j].readed)
                              ? (j == 0)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        readSubSeriesList[i].volumes[j].image,
                                        width: 65,
                                      ),
                                    )
                                  : Positioned(
                                      left: j * 45.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                                              spreadRadius: 1,
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10.0),
                                          child: Image.network(
                                            readSubSeriesList[i].volumes[j].image,
                                            width: 65,
                                          ),
                                        ),
                                      ),
                                    )
                              : Container(),
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
            ),
        ],
      ),
    );
  }
}
