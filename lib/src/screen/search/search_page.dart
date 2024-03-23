import 'package:mymangatheque/src/provider/search_filter_provider.dart';
import 'package:mymangatheque/src/provider/theme_color_provider.dart';
import 'package:mymangatheque/src/components/my_line.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
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

  void changeFilter(String filter) {
    ref.read(searchFilterProvider.notifier).changeSearchFilter(filter);
  }

  getClientStream() async {
    var data = await FirebaseFirestore.instance
        .collection('manga')
        .orderBy(ref.watch(searchFilterProvider))
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
    getClientStream();
    var showResults = [];
    var filter = ref.watch(searchFilterProvider);

    if (_searchController.text != "") {
      for (var clientSnapshot in _allResults) {
        var name = clientSnapshot[filter].toString().toLowerCase();

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
    ref.read(themeTextColorProvider);
    ref.read(themeBgColorProvider);
    ref.read(searchFilterProvider);
    getClientStream();
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final selectedFilter = ref.watch(searchFilterProvider);
    final textColor = ref.watch(themeTextColorProvider);
    final bgColor = ref.watch(themeBgColorProvider);

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
                  color: textColor,
                ),
                style: TextStyle(
                  color: textColor,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: OwnIcon(iconColor: textColor, iconName: "filter_right"),
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
                                _resultsList[index]['releaseDate'],
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
                    context.go('/search/series/${_resultsList[index]['manga']}');
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
                    context.go('/search/author/${_resultsList[index]['author']}');
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
                    context.go('/search/editor/${_resultsList[index]['editor']}');
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
