import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/back/provider/search_filter_provider.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  List _allResults = [];
  List _resultsList = [];
  final TextEditingController _searchController = TextEditingController();

  getClientStream() async {
    var data = await PocketBaseConnector().getCollectionFullListOrder('series', 'title');
    /*var data = await FirebaseFirestore.instance
        .collection('manga')
        .orderBy(ref.watch(searchFilterProvider))
        .get();*/
    setState(() {
      _allResults = data;
    });
  }

  Future<String> getAuthorName(String authorId) async {
    var author = await PocketBaseConnector().getOne('authors', authorId);
    return json.decode(author[0].toString())['name'].toString();
  }

  Future<String> getAllAuthorsName(List authorsId) async {
    var authors = [];
    for (var authorId in authorsId) {
      authors.add(await getAuthorName(authorId));
    }
    return authors.join(" et ");
  }

  _onSearchChanged() {
    searchResultsList();
  }

  String textLength(text, length) {
    if (text.length > length) {
      return text.substring(0, length) + "...";
    } else {
      return text;
    }
  }

  searchResultsList() {
    var showResults = [];
    //var filter = ref.watch(searchFilterProvider); // TODO: Create searchFilterProvider

    if (_searchController.text != "") {
      for (var clientSnapshot in _allResults) {
        var name = json.decode(clientSnapshot.toString())["title"].toString().toLowerCase();
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

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(searchFilterProvider);

    searchResultsList();

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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            PopupMenuButton<String>(
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
              shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
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
            ),
          ],
        ),
      ),
      body: (_searchController.text.toLowerCase() == 'bad apple')
          ? Center(
              child: Text('Bad Apple'),
            ) // TODO: Add the bad apple video
          : (_resultsList.isEmpty)
              ? Center(
                  child: Text(
                  'Aucun résultat',
                  style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary),
                ))
              : ListView.builder(
                  itemCount: _resultsList.length,
                  itemBuilder: (context, index) {
                    if (selectedFilter == 'manga') {
                      final manga = json.decode(_resultsList[index].toString());
                      return FutureBuilder(
                        future: getAllAuthorsName(manga['authors']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error'),
                            );
                          } else {
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
                                              child: Image.network(
                                                'https://api.mymangatheque.com/api/files/utbujxtz8wtq0ar/${manga['id'].toString()}/${manga['image'].toString()}',
                                                width: 50,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                textLength(manga['title'], 30),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                              // manga['author'].toString()

                                              Text(
                                                textLength(snapshot.data, 35),
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                DateTime.parse(manga['first_publication']).year.toString(),
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontSize: 14,
                                                ),
                                              )
                                            ],
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
                                    context.go('/search/series/${manga['id']}');
                                  },
                                ),
                                MyLine(
                                  width: MediaQuery.of(context).size.width,
                                  vertical: 0,
                                ),
                              ],
                            );
                          }
                        },
                      );
                    } else if (selectedFilter == 'author') {
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
                                      child: Image.network(
                                        //TODO: Change the URL just after the 'api/files/' part to match with the real one
                                        'https://api.mymangatheque.com/api/files/utbujxtz8wtq0ar/${json.decode(_resultsList[index].toString())['id'].toString()}/${json.decode(_resultsList[index].toString())['image'].toString()}',
                                        width: 50,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          textLength(json.decode(_resultsList[index].toString())['author'], 27),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        Text(
                                          textLength(json.decode(_resultsList[index].toString())['manga'], 40),
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
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
                              context.go('/search/author/${json.decode(_resultsList[index].toString())['author']}');
                            },
                          ),
                          MyLine(
                            width: MediaQuery.of(context).size.width,
                            vertical: 0,
                          ),
                        ],
                      );
                    } else {
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
                                      child: Image.network(
                                        //TODO: Change the URL just after the 'api/files/' part to match with the real one
                                        'https://api.mymangatheque.com/api/files/utbujxtz8wtq0ar/${json.decode(_resultsList[index].toString())['id'].toString()}/${json.decode(_resultsList[index].toString())['image'].toString()}',
                                        width: 50,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          textLength(json.decode(_resultsList[index].toString())['editor'], 27),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        Text(
                                          textLength(json.decode(_resultsList[index].toString())['author'], 40),
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
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
                              context.go('/search/editor/${json.decode(_resultsList[index].toString())['editor']}');
                            },
                          ),
                          MyLine(
                            width: MediaQuery.of(context).size.width,
                            vertical: 0,
                          ),
                        ],
                      );
                    }
                  },
                ),
    );
  }
}
