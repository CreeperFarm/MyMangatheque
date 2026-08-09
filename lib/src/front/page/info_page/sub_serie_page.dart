import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/front/components/my_author_tile.dart';
import 'package:mymangatheque/src/front/components/my_editor_show.dart';
import 'package:mymangatheque/src/front/components/my_genres_show.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_picture_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_volume_tile.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/safe_expand_reader.dart';

class SubSeriePage extends StatefulWidget {
  final String serieId;
  final String initRoute;

  const SubSeriePage({
    required this.serieId,
    required this.initRoute,
    super.key,
  });

  @override
  State<SubSeriePage> createState() => _SubSeriePageState();
}

class _SubSeriePageState extends State<SubSeriePage> {
  bool isSubSeriesFollowed = false;
  Set<String> _ownedVolumeIds = <String>{};
  final AppwriteConnector connector = AppwriteConnector();

  String? _connectedUserId() => connector.getConnectedUser()?.id;

  void _checkSubSeriesFollowing() async {
    final userId = _connectedUserId();
    if (userId != null) {
      bool owned = await connector.isSubSeriesFollowed(userId, widget.serieId);
      if (!mounted) return;
      setState(() {
        isSubSeriesFollowed = owned;
      });
    } else {
      if (!mounted) return;
      setState(() {
        isSubSeriesFollowed = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkSubSeriesFollowing();
    _loadOwnedVolumeIds();
  }

  Future<void> _loadOwnedVolumeIds() async {
    final userId = _connectedUserId();
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _ownedVolumeIds = <String>{};
      });
      return;
    }

    try {
      final owned = await connector.getCollectionFullList('owned');
      final ids = owned
          .map((entry) => entry.data['volume']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      if (!mounted) return;
      setState(() {
        _ownedVolumeIds = ids;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ownedVolumeIds = <String>{};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final connectedUserId = _connectedUserId();

    return FutureBuilder<List<RecordModel>>(
      future: AppwriteConnector().getOneExpand(
        'sub_series',
        widget.serieId,
        'authors,volumes,series.genres,editors',
      ),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: Center(child: Text(localizations.noConnection)),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: Center(child: Text(localizations.errorOccurred)),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // ? Define variables
          final data = snapshot.data!.isNotEmpty
              ? Map<String, dynamic>.from(snapshot.data!.first.data)
              : <String, dynamic>{};
          final expand = SafeExpandReader.asMap(data['expand']);
          // Normalize expanded values to typed lists so we can safely sort and access elements.
          final rawVolumes = expand['volumes'];
          final List<Map<String, dynamic>> volumes = (rawVolumes is List)
              ? rawVolumes
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

          Map<String, dynamic> extractMap(dynamic value) {
            if (value == null) return <String, dynamic>{};
            if (value is Map<String, dynamic>) return value;
            if (value is Map) return Map<String, dynamic>.from(value);
            if (value is List && value.isNotEmpty) {
              final first = value.first;
              if (first is Map<String, dynamic>) return first;
              if (first is Map) return Map<String, dynamic>.from(first);
            }
            return <String, dynamic>{};
          }

          final series = extractMap(expand['series'] ?? expand['serie']);
          final editor = extractMap(expand['editor'] ?? expand['editors']);
          final seriesExpand = SafeExpandReader.asMap(series['expand']);

          // Normalize genres to a non-null list so calls like `genres.length` are safe.
          final rawGenres = seriesExpand['genres'] ?? expand['genres'];
          final List<dynamic> genres = (rawGenres is List)
              ? List<dynamic>.from(rawGenres)
              : <dynamic>[];
          final title =
              data['title']?.toString() ?? data['titleFr']?.toString() ?? '';
          final cover =
              data['image']?.toString() ?? data['coverUrl']?.toString();

          // Sort sub-series by title (falling back to French title field) in a stable and null-safe way.
          volumes.sort((a, b) {
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

          // ? Sort volumes
          volumes.sort((a, b) {
            final tomeA =
                num.tryParse(a['tomeNumber']?.toString() ?? '') ?? 1e9;
            final tomeB =
                num.tryParse(b['tomeNumber']?.toString() ?? '') ?? 1e9;
            return tomeA.compareTo(tomeB);
          });

          // ? Display on screen
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                ),
              ),
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
                      (data['support'] == null || data['support'] == "manga")
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                localizations.supportIs(
                                  data['support'].toString(),
                                ),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 32 * 5 / 6 + 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            decoration: BoxDecoration(color: Colors.green),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: (!isSubSeriesFollowed)
                                      ? WidgetStateProperty.all<Color>(
                                          Theme.of(context).colorScheme.surface,
                                        )
                                      : WidgetStateProperty.all<Color>(
                                          Colors.green,
                                        ),
                                  iconColor: (!isSubSeriesFollowed)
                                      ? WidgetStateProperty.all<Color>(
                                          Theme.of(context).colorScheme.primary,
                                        )
                                      : WidgetStateProperty.all<Color>(
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                        ),
                                  elevation: WidgetStateProperty.all<double>(0),
                                ),
                                onPressed: () async {
                                  final userId = _connectedUserId();
                                  if (userId != null) {
                                    if (!isSubSeriesFollowed) {
                                      connector.addSubSeriesToFollowed(
                                        userId,
                                        widget.serieId.toString(),
                                      );
                                      setState(() {
                                        isSubSeriesFollowed = true;
                                      });
                                    } else {
                                      connector.removeSubSeriesToFollowed(
                                        userId,
                                        widget.serieId.toString(),
                                      );
                                      setState(() {
                                        isSubSeriesFollowed = false;
                                      });
                                    }
                                  } else {
                                    pushOrGo(context, '/profile/signin');
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    (!isSubSeriesFollowed)
                                        ? const Icon(Icons.bookmark_border)
                                        : const Icon(Icons.bookmark),
                                    Text(
                                      (!isSubSeriesFollowed)
                                          ? localizations.follow
                                          : localizations.followed,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: (!isSubSeriesFollowed)
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
                        vertical: 10.0,
                        horizontal: 0.0,
                      ),
                      (authors.isEmpty)
                          ? const SizedBox()
                          : (authors.length == 1)
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                '${localizations.author} :',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                '${localizations.authors} :',
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
                      (editor.isEmpty)
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyLine(
                                    width: MediaQuery.of(context).size.width,
                                    vertical: 5,
                                    horizontal: 0,
                                  ),
                                  Text(
                                    '${localizations.editor} :',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  MyEditorShow(
                                    editor: editor,
                                    initRoute: widget.initRoute,
                                  ),
                                ],
                              ),
                            ),
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10.0,
                        horizontal: 0.0,
                      ),
                      (volumes.isEmpty)
                          ? const SizedBox()
                          : (volumes.length == 1)
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                '${localizations.volume} :',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                '${localizations.volumes} :',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      for (var i = 0; i < volumes.length; i += 1)
                        Column(
                          children: [
                            MyVolumeTile(
                              volumeData: volumes[i],
                              subSerieData: data,
                              isVolumeOwned:
                                  connectedUserId != null &&
                                  _ownedVolumeIds.contains(
                                    volumes[i]['id']?.toString() ?? '',
                                  ),
                              initRoute: widget.initRoute,
                            ),
                            (i != volumes.length - 1 && volumes.length > 1)
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
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: Center(child: Text(localizations.subSeriesDoesNotExist)),
          );
        }
      },
    );
  }
}
