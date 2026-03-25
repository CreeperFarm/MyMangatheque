import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/src/back/provider/search_filter_provider.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:video_player/video_player.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  List _allResults = [];
  List _resultsList = [];
  final TextEditingController _searchController = TextEditingController();
  final PocketBaseConnector connector = PocketBaseConnector();

  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoFuture;

  void getClientStream() async {
    var data = await connector.getCollectionFullListOrderExpanded(
      'series',
      'title',
      'authors',
    );
    /*var data = await FirebaseFirestore.instance
        .collection('manga')
        .orderBy(ref.watch(searchFilterProvider))
        .get();*/
    debugPrint(data.toString());
    setState(() {
      _allResults = data;
    });
  }

  String getAllAuthorsName(List authorsExpanded) {
    debugPrint(authorsExpanded.toString());
    var authors = [];
    for (var i = 0; i < authorsExpanded.length; i++) {
      authors.add(authorsExpanded[i]['name']);
    }
    return authors.join(" et ");
  }

  void _onSearchChanged() {
    searchResultsList();

    // Pause the Bad Apple video when the search is no longer 'bad apple',
    // and resume it when the search becomes 'bad apple' again.
    final query = _searchController.text.toLowerCase().trim();
    if (query != 'bad apple') {
      if (_videoController != null &&
          _videoController!.value.isInitialized &&
          _videoController!.value.isPlaying) {
        _videoController!.pause();
      }
    } else {
      if (_videoController != null &&
          _videoController!.value.isInitialized &&
          !_videoController!.value.isPlaying) {
        _videoController!.play();
      }
    }
  }

  String textLength(String text, int length) {
    if (text.length > length) {
      return "${text.substring(0, length)}...";
    } else {
      return text;
    }
  }

  void searchResultsList() {
    var showResults = [];
    //var filter = ref.watch(searchFilterProvider); // TODO: Create searchFilterProvider

    if (_searchController.text != "") {
      for (var clientSnapshot in _allResults) {
        var name = json
            .decode(clientSnapshot.toString())["title"]
            .toString()
            .toLowerCase();
        if (name.contains(_searchController.text.toLowerCase())) {
          showResults.add(clientSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }

    setState(() {
      _resultsList = showResults;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
    _searchController.dispose();
    if (_videoController != null) {
      _videoController!.pause();
      _videoController!.dispose();
      _videoController = null;
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getClientStream();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    ref.read(searchFilterProvider);
    getClientStream();
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  /// Construit un lecteur vidéo pour la vidéo locale « assets/videos/bad-apple.mp4 ».
  /// L'initialisation est faite paresseusement : le contrôleur est créé la première
  /// fois que cette méthode est appelée. La vidéo est lancée automatiquement et mise en
  /// boucle.
  Widget _buildBadApplePlayer() {
    if (_videoController == null) {
      _videoController = VideoPlayerController.asset(Assets.videos.badApple);
      _initializeVideoFuture = _videoController!.initialize().then((_) {
        _videoController!.setLooping(true);
        _videoController!.play();
        // Après l'initialisation on demande un rebuild pour que l'AspectRatio prenne la bonne taille
        setState(() {});
      });
    }

    return FutureBuilder<void>(
      future: _initializeVideoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _videoController != null) {
          final aspect = _videoController!.value.aspectRatio;
          return AspectRatio(
            aspectRatio: aspect > 0 ? aspect : 4 / 3,
            child: VideoPlayer(_videoController!),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(searchFilterProvider);

    searchResultsList();

    //TODO : Add the bad apple video from assets

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Recherche',
                placeholderStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            // TODO: Create searchFilterProvider and manage the selected filter
            /*PopupMenuButton<String>(
              icon: OwnIcon(iconColor: Theme.of(context).colorScheme.primary, iconName: "filter_right"),
              onSelected: (String result) {
                setState(() {
                  //changeFilter(result); // TODO: Create changeFilter function
                });
              },
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
              color: Theme.of(context).colorScheme.onPrimary,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'manga',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (selectedFilter == 'manga') const Icon(Icons.check) else const Padding(padding: EdgeInsets.only(right: 0)),
                      const Text('Manga'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                    value: 'editor',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (selectedFilter == 'editor') const Icon(Icons.check) else const Padding(padding: EdgeInsets.only(right: 0)),
                        const Text('Éditeur'),
                      ],
                    )),
                PopupMenuItem<String>(
                  value: 'author',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (selectedFilter == 'author') const Icon(Icons.check) else const Padding(padding: EdgeInsets.only(right: 0)),
                      const Text('Auteur'),
                    ],
                  ),
                ),
              ],
            ),*/
          ],
        ),
      ),
      body: (_searchController.text.toLowerCase() == 'bad apple')
          ? Center(
              child: _buildBadApplePlayer(),
            ) // TODO: Add the bad apple video
          : (_resultsList.isEmpty)
          ? Center(
              child: Text(
                'Aucun résultat',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _resultsList.length,
              itemBuilder: (context, index) {
                if (selectedFilter == 'manga') {
                  final manga = json.decode(_resultsList[index].toString());
                  return Column(
                    children: [
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: SizedBox(
                                    width: 50,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        'https://api.mymangatheque.com/api/files/utbujxtz8wtq0ar/${manga['id'].toString()}/${manga['image'].toString()}',
                                        width: 50,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width -
                                      (MediaQuery.of(context).padding.left +
                                          MediaQuery.of(context).padding.right +
                                          124),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        manga['title'],
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),

                                      // manga['author'].toString()
                                      Text(
                                        getAllAuthorsName(
                                          manga['expand']['authors'],
                                        ),
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        DateTime.parse(
                                          manga['first_publication'],
                                        ).year.toString(),
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        onTap: () {
                          pushOrGo(context, '/search/serie/${manga['id']}');
                        },
                      ),
                      (index != _resultsList.length - 1)
                          ? MyLine(
                              width: MediaQuery.of(context).size.width,
                              vertical: 0,
                            )
                          : const Padding(padding: EdgeInsets.only(bottom: 60)),
                    ],
                  );
                } else if (selectedFilter == 'author') {
                  return Text(
                    "Author"
                    "WIP",
                  );
                } else {
                  return Text(
                    "Editor"
                    "WIP",
                  );
                }
              },
            ),
    );
  }
}
