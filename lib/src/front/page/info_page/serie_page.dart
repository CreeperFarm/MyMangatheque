import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/front/components/my_author_tile.dart';
import 'package:mymangatheque/src/front/components/my_genres_show.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_picture_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_sub_series_tile.dart';
import 'package:mymangatheque/src/function/safe_expand_reader.dart';

class SeriePage extends StatefulWidget {
  final String serieId;
  final String initRoute;

  const SeriePage({required this.serieId, required this.initRoute, super.key});

  @override
  State<SeriePage> createState() => _SeriePageState();
}

class _SeriePageState extends State<SeriePage> {
  final AppwriteConnector connector = AppwriteConnector();

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<List<RecordModel>>(
      future: connector.getOneExpand(
        'series',
        widget.serieId,
        'subSeries.volumes,subSeries.editors,genres,authors',
      ),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState == ConnectionState.none) {
          return Center(child: Text(localizations.noConnection));
        }
        if (snapshot.hasError) {
          RuntimeLocalization.debug(
            en: 'Unable to load the series page: ${snapshot.error}',
            fr: 'Impossible de charger la page de la série : ${snapshot.error}',
          );
          return Center(child: Text(localizations.errorOccurred));
        }
        if (snapshot.hasData && snapshot.data != null) {
          // ? Define variables
          final data = snapshot.data!.isNotEmpty
              ? Map<String, dynamic>.from(snapshot.data!.first.data)
              : <String, dynamic>{};
          final expand = SafeExpandReader.asMap(data['expand']);
          // Normalize expanded values to typed lists so we can safely sort and access elements.
          final rawSubSeries = expand['subSeries'];
          final List<Map<String, dynamic>> subSeries = (rawSubSeries is List)
              ? rawSubSeries
                    .map<Map<String, dynamic>>(
                      (e) => (e is Map)
                          ? Map<String, dynamic>.from(e)
                          : <String, dynamic>{},
                    )
                    .toList()
              : <Map<String, dynamic>>[];

          final rawAuthors = expand['authors'];
          final List<Map<String, dynamic>> authors = (rawAuthors is List)
              ? rawAuthors
                    .map<Map<String, dynamic>>(
                      (e) => (e is Map)
                          ? Map<String, dynamic>.from(e)
                          : <String, dynamic>{},
                    )
                    .toList()
              : <Map<String, dynamic>>[];

          // Normalize genres to a non-null list so calls like `genres.length` are safe.
          final rawGenres = expand['genres'];
          final List<dynamic> genres = (rawGenres is List)
              ? List<dynamic>.from(rawGenres)
              : <dynamic>[];
          final title =
              data['title']?.toString() ?? data['titleFr']?.toString() ?? '';
          final titleEn = data['titleEn']?.toString() ?? '';
          final titleJp = data['titleJp']?.toString() ?? '';
          final cover =
              data['image']?.toString() ?? data['coverUrl']?.toString();

          // Sort sub-series by title (falling back to French title field) in a stable and null-safe way.
          subSeries.sort((a, b) {
            final aTitle =
                (a['title']?.toString() ?? a['titleFr']?.toString() ?? '')
                    .toLowerCase();
            final bTitle =
                (b['title']?.toString() ?? b['titleFr']?.toString() ?? '')
                    .toLowerCase();
            return aTitle.compareTo(bTitle);
          });

          // Sort authors by name in a null-safe way.
          authors.sort((a, b) {
            final aName = (a['name']?.toString() ?? '').toLowerCase();
            final bName = (b['name']?.toString() ?? '').toLowerCase();
            return aName.compareTo(bName);
          });

          // ? Building the widget
          return Scaffold(
            appBar: AppBar(
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
            body: MyScrollColumn(
              columnMainAxisAlignment: MainAxisAlignment.start,
              children: [
                MyPictureDisplay(pictureUrl: cover ?? ''),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      (titleEn != "" && titleJp != titleEn)
                          ? Text(
                              "${localizations.englishTitle}${(localizations.localeName == "fr") ? " " : ""}:  $titleEn",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            )
                          : SizedBox(),
                      (titleJp != "" && titleJp != titleEn)
                          ? Text(
                              "${localizations.japaneseTitle}${(localizations.localeName == "fr") ? " " : ""}: $titleJp",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            )
                          : SizedBox(),
                      (titleJp == titleEn && titleEn != "")
                          ? Text(
                              "${localizations.englishAndJapaneseTitle}${(localizations.localeName == "fr") ? " " : ""}: $titleJp",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            )
                          : SizedBox(),
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10,
                        horizontal: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${localizations.genres} :',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                child: Row(
                                  children: [
                                    for (var i = 0; i < genres.length; i += 1)
                                      MyGenresShow(data: genres[i]),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10,
                        horizontal: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: (subSeries.isEmpty)
                            ? const SizedBox()
                            : (subSeries.length == 1)
                            ? Text(
                                "${localizations.subSerie} :",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                "${localizations.subSeries} :",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      for (var i = 0; i < subSeries.length; i += 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MySubSeriesTile(
                              data: subSeries[i],
                              initRoute: widget.initRoute,
                            ),
                            if (i != subSeries.length - 1)
                              MyLine(
                                width: MediaQuery.of(context).size.width,
                                vertical: 10,
                                horizontal: 0,
                              ),
                          ],
                        ),
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10.0,
                        horizontal: 0.0,
                      ),
                      (authors.isEmpty)
                          ? const SizedBox()
                          : (authors.length == 1)
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                "${localizations.author} :",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                "${localizations.authors} :",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      for (var i = 0; i < authors.length; i += 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyAuthorTile(
                              authorData: authors[i],
                              initRoute: widget.initRoute,
                            ),
                            (i != authors.length - 1 && authors.length > 1)
                                ? MyLine(
                                    width: MediaQuery.of(context).size.width,
                                    vertical: 5,
                                    horizontal: 0,
                                  )
                                : const SizedBox(),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: Text(localizations.seriesDoesNotExist)),
            body: Center(child: Text(localizations.seriesDoesNotExist)),
          );
        }
      },
    );
  }
}
