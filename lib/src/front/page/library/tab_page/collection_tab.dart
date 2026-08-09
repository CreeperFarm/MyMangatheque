import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/front/page/library/library_tab_data.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';

class CollectionTab extends ConsumerStatefulWidget {
  const CollectionTab({this.searchQuery = '', this.order = 'manga', super.key});

  final String searchQuery;
  final String order;

  @override
  ConsumerState<CollectionTab> createState() => _CollectionTabState();
}

class _CollectionTabState extends ConsumerState<CollectionTab> {
  List<SubSerieForCollection> _visibleSubSeries(
    Iterable<SubSerieForCollection> subSeries,
  ) {
    return filterLibrarySubSeries(
      subSeries,
      searchQuery: widget.searchQuery,
      order: widget.order,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final subSeries = ref.watch(mangaOwnedProvider);
    final visibleSubSeries = _visibleSubSeries(subSeries);

    return ValueListenableBuilder<AppDisplayDensity>(
      valueListenable: LocalStorage.displayDensityNotifier,
      builder: (context, density, _) => CustomScrollView(
        key: const PageStorageKey<String>('owned-collection'),
        cacheExtent: density == AppDisplayDensity.compact ? 500 : 700,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTomeNumberShow(
                    tomeTotal: ownedLibraryVolumeCount(subSeries).toString(),
                    editionTotal: subSeries.length.toString(),
                    localizations: localizations,
                  ),
                  if (subSeries.isEmpty)
                    Text(localizations.noVolumeOwned)
                  else if (visibleSubSeries.isEmpty)
                    Text(localizations.noResults),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            sliver: SliverList.builder(
              itemCount: visibleSubSeries.length,
              itemBuilder: (context, index) {
                final subSerie = visibleSubSeries[index];
                return RepaintBoundary(
                  key: ValueKey<String>('collection-${subSerie.id}'),
                  child: _CollectionSubSeriesRow(
                    subSerie: subSerie,
                    localizations: localizations,
                    density: density,
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 92)),
        ],
      ),
    );
  }
}

class _CollectionSubSeriesRow extends StatelessWidget {
  const _CollectionSubSeriesRow({
    required this.subSerie,
    required this.localizations,
    required this.density,
  });

  final SubSerieForCollection subSerie;
  final AppLocalizations localizations;
  final AppDisplayDensity density;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            pushOrGo(context, '/library/sub_serie/${subSerie.id}');
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subSerie.title.replaceAll(
                          ' - Edition Standard',
                          '',
                        ),
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: density == AppDisplayDensity.compact
                              ? 16
                              : 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                          width: double.infinity,
                          height: subSerie.volumes.isEmpty
                              ? 0
                              : density == AppDisplayDensity.compact
                              ? 82
                              : 100,
                          child: Stack(
                            children: [
                              for (
                                var i = 0;
                                i < min(9, subSerie.volumes.length);
                                i++
                              )
                                Positioned(
                                  left:
                                      i *
                                      (density == AppDisplayDensity.compact
                                          ? 38.0
                                          : 45.0),
                                  child: DecoratedBox(
                                    decoration: i == 0
                                        ? const BoxDecoration()
                                        : BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary
                                                    .withValues(alpha: 0.9),
                                                spreadRadius: 1,
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SafeNetworkImage(
                                        imageUrl: subSerie.volumes[i].image,
                                        width:
                                            density == AppDisplayDensity.compact
                                            ? 54
                                            : 65,
                                        height:
                                            density == AppDisplayDensity.compact
                                            ? 82
                                            : 100,
                                      ),
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
              OwnIcon(
                iconColor: Theme.of(context).colorScheme.primary,
                iconSrc: Assets.icons.arrowRight,
              ),
            ],
          ),
        ),
        MyLine(
          width: MediaQuery.sizeOf(context).width,
          vertical: 10,
          horizontal: 0,
        ),
      ],
    );
  }
}
