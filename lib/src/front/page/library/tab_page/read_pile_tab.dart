import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_loader_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';

class ReadPileTab extends ConsumerStatefulWidget {
  const ReadPileTab({super.key});

  @override
  ConsumerState createState() => _ReadPileTabState();
}

class _ReadPileTabState extends ConsumerState<ReadPileTab> {
  int volumeReaded = 0;
  int volumeOwned = 0;
  List<dynamic> readSubSeriesList = [];
  List<dynamic> notReadedSubSeriesList = [];
  final connector = PocketBaseConnector();
  dynamic _ownedSubscription;

  dynamic readedSubSeries;

  void _fetchData() {
    readSubSeriesList = readedSubSeries.toList();
    notReadedSubSeriesList = [];

    for (var subSerie in readedSubSeries) {
      notReadedSubSeriesList.add(subSerie);
      for (int i = 0; i < subSerie.volumes.length; i++) {
        Volume volume = subSerie.volumes[i];
        if (volume.readed) {
          volumeReaded++;
          notReadedSubSeriesList.remove(volume);
        }
        volumeOwned++;
      }
    }

    setState(() {});
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

  void _cancelRealtime() {
    try {
      if (_ownedSubscription != null) {
        try {
          _ownedSubscription.unsubscribe();
        } catch (_) {}
        _ownedSubscription = null;
      }
    } catch (_) {}
  }

  void _setupRealtimeOrFallback() {
    _cancelRealtime();
    try {
      _ownedSubscription = connector.connector().collection('owned').subscribe('*', (event) async {
        debugPrint("Got an event");
        await ref.read(mangaOwnedProvider.notifier).initData();
        _fetchData();
      });

      debugPrint('Realtime subscriptions established.');
    } catch (e) {
      debugPrint('Realtime subscription failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize the owned subseries data
      readedSubSeries = ref.read(mangaOwnedProvider);
      _initDatas();
    });
  }

  Future<void> _initDatas() async {
    _fetchData();
    _setupRealtimeOrFallback();
  }

  @override
  void dispose() {
    _cancelRealtime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    readedSubSeries = ref.read(mangaOwnedProvider);
    if (readedSubSeries == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(10),
      child: MyScrollColumn(
        columnCrossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (volumeOwned == 0)
              ? Text(
                  localizations.zeroVolumesOwned,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : (volumeOwned == volumeReaded)
                  ? Text(
                      localizations.allVolumesReaded,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Column(
                      children: [
                        Text(
                          localizations.volumeReadedOverX(
                            volumeReaded,
                            volumeOwned,
                          ),
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
          for (var i = 0; i < readedSubSeries.length; i++)
            InkWell(
              onTap: () {
                pushOrGo(context, '/library/sub_serie/${readSubSeriesList[i].id}');
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        readSubSeriesList[i].title.replaceAll(' - Edition Standard', ''),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        localizations.volumeReadedOverSeriesX(
                          numberVolumeReaded(readSubSeriesList[i].volumes),
                          readSubSeriesList[i].numberOwnedVolumes,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: (readSubSeriesList[i].numberOwnedVolumes - numberVolumeReaded(readSubSeriesList[i].volumes) != 0) ? 100 : 0,
                        child: Stack(
                          children: [
                            for (var j = 0; j < readSubSeriesList[i].numberOwnedVolumes - numberVolumeReaded(readSubSeriesList[i].volumes); j++)
                              (j == 0)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        notReadedSubSeriesList[i].volumes[j].image,
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
                                            notReadedSubSeriesList[i].volumes[j].image,
                                            width: 65,
                                          ),
                                        ),
                                      ),
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
                ),
              ),
            ),
        ],
      ),
    );
  }
}
