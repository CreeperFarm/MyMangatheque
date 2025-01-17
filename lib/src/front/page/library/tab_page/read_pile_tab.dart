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

    for (int i = 0; i < readedSubSeries.length; i++) {
      for (int j = 0; j < readedSubSeries[i]['volumes'].length; j++) {
        if (readedSubSeries[i]['volumes'][j]['readed'] == true) {
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
          Column(
            children: [
              Text(
                '$volumeReaded tomes lu sur $volumeOwned tomes possédés.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // TODO: Ajouter une progress bar
            ],
          ),
          MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
          for (var i = 0; i < readedSubSeries.length; i++) Text('data'),
        ],
      ),
    );
  }
}
