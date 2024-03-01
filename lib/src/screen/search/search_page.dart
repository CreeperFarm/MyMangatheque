import 'package:mymangatheque/src/provider/search_filter_provider.dart';
import 'package:mymangatheque/src/provider/theme_color_provider.dart';
import 'package:mymangatheque/src/components/my_line.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  List _allResults = [];
  List _resultsList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    ref.read(themeTextColorProvider);
    ref.read(themeBgColorProvider);
    ref.read(searchFilterProvider);
    getClientStreamManga();
    getClientStreamEditor();
    getClientStreamAuthor();
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  void changeFilter(String filter) {
    ref.read(searchFilterProvider.notifier).changeSearchFilter(filter);
  }

  getClientStreamManga() async {
    var data = await FirebaseFirestore.instance
        .collection('manga')
        .orderBy('manga')
        .get();

    setState(() {
      _allResults = data.docs;
    });
  }

  getClientStreamEditor() async {
    var data = await FirebaseFirestore.instance
        .collection('manga')
        .orderBy('editor')
        .get();

    setState(() {
      _allResults = data.docs;
    });
  }

  getClientStreamAuthor() async {
    var data = await FirebaseFirestore.instance
        .collection('manga')
        .orderBy('author')
        .get();

    setState(() {
      _allResults = data.docs;
    });
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
    var filter = ref.watch(searchFilterProvider);

    if (_searchController.text != "") {
      for (var clientSnapshot in _allResults) {
        var name = clientSnapshot['manga'].toString().toLowerCase();

        if (filter == 'manga') {
          if (name.contains(_searchController.text.toLowerCase())) {
            showResults.add(clientSnapshot);
          }
        } else if (filter == 'editor') {
          if (name.contains(_searchController.text.toLowerCase())) {
            showResults.add(clientSnapshot);
          }
        } else {
          if (name.contains(_searchController.text.toLowerCase())) {
            showResults.add(clientSnapshot);
          }
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
    getClientStreamManga();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    final textColor = ref.watch(themeTextColorProvider);
    final bgColor = ref.watch(themeBgColorProvider);
    final selectedFilter = ref.watch(searchFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Recherche',
                placeholderStyle: TextStyle(
                  color: textColor,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.filter_list,
                color: textColor,
              ),
              onSelected: (String result) {
                setState(() {
                  changeFilter(result);
                });
              },
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: textColor.withOpacity(0.5),
              color: bgColor,
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
                    )
                ),
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
      body: ListView.builder(
        itemCount: _resultsList.length,
        itemBuilder: (context, index) {
          if (selectedFilter == 'manga') {
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
                              'https://cdn.statically.io/gh/CreeperFarm/AppManga/main/${_resultsList[index]['img']}.jpg',
                              width: 50,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                textLength(_resultsList[index]['manga'], 33),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                textLength(_resultsList[index]['author'], 40),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "2022", //Todo: change to date
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: textColor,
                      ),
                    ],
                  ),
                  onTap: () {
                    context.go('search/series/${_resultsList[index]['manga']}');
                  },
                ),
                MyLine(
                  width: MediaQuery.of(context).size.width,
                  vertical: 0,
                ),
              ],
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
                              'https://cdn.statically.io/gh/CreeperFarm/AppManga/main/author/${_resultsList[index]['author']}.jpg',
                              width: 50,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                textLength(_resultsList[index]['author'], 33),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                textLength(_resultsList[index]['manga'], 40),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: textColor,
                      ),
                    ],
                  ),
                  onTap: () {
                    context.go('search/author/${_resultsList[index]['author']}');
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
                              'https://cdn.statically.io/gh/CreeperFarm/AppManga/main/${_resultsList[index]['img']}.jpg',
                              width: 50,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                textLength(_resultsList[index]['editor'], 33),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                textLength(_resultsList[index]['author'], 40),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: textColor,
                      ),
                    ],
                  ),
                  onTap: () {
                    context.go('search/editor/${_resultsList[index]['editor']}');
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
