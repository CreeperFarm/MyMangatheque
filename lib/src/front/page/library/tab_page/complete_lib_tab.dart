import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';

class CompleteLibTab extends ConsumerStatefulWidget {
  const CompleteLibTab({super.key});

  @override
  ConsumerState createState() => _CompleteLibTabState();
}

class _CompleteLibTabState extends ConsumerState<CompleteLibTab> {
  PocketBaseConnector connector = PocketBaseConnector();

  int getNumberVolumesNotOwned() {
    final subSeries = ref.watch(mangaOwnedProvider);
    int number = 0;
    for (var subSerie in subSeries) {
      number += subSerie.numberOfVolumes - subSerie.numberOwnedVolumes;
    }
    return number;
  }

  int getNumberSeriesNotOwned() {
    final subSeries = ref.watch(mangaOwnedProvider);
    int number = 0;
    for (var subSerie in subSeries) {
      if (subSerie.numberOwnedVolumes == subSerie.numberOfVolumes) {
        number = number;
      } else {
        number += 1;
      }
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    final subSeries = ref.watch(mangaOwnedProvider);

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          MyTomeNumberShow(tomeTotal: getNumberVolumesNotOwned().toString(), editionTotal: getNumberSeriesNotOwned().toString()),
          // TODO: Add the list of volumes not owned
        ],
      ),
    );
  }
}
