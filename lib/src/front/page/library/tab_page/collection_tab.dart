import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/const/assets.dart';
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
  AppwriteConnector connector = AppwriteConnector();

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
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (ref.watch(mangaOwnedProvider).isEmpty) {
      ref.read(mangaOwnedProvider.notifier).initData().then((value) {
        if (value == false) {
          debugPrint("Error while loading data");
        } else {
          if (!mounted) return;
          setState(() {});
        }
      });
    }
    final subSeries = ref.watch(mangaOwnedProvider);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: MyScrollColumn(
        children: [
          MyTomeNumberShow(tomeTotal: getNumberVolume().toString(), editionTotal: subSeries.length.toString(), localizations: localizations),

          ...subSeries.map((subSerie) {
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    pushOrGo(context, '/library/sub_serie/${subSerie.id}');
                  },
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
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
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  localizations.volumeOwnedOverX(
                                    subSerie.numberOwnedVolumes,
                                    subSerie.numberOfVolumes,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width - 65,
                                    child: Stack(
                                      children: [
                                        for (var i = 0; i < min(9, subSerie.volumes.length); i++)
                                          (i == 0)
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  child: Image.network(subSerie.volumes[i].image, width: 65),
                                                )
                                              : Positioned(
                                                  left: i * 45.0,
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
                                                      child: Image.network(subSerie.volumes[i].image, width: 65),
                                                    ),
                                                  ),
                                                ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        OwnIcon(iconColor: Theme.of(context).colorScheme.primary, iconSrc: Assets.icons.arrowRight),
                      ],
                    ),
                  ),
                ),
                MyLine(width: MediaQuery.of(context).size.width, vertical: 10, horizontal: 0),
              ],
            );
          }),
        ],
      ),
    );
  }
}
