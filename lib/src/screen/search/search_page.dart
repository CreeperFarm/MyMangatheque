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
    getClientStream();
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  getClientStream() async {
    var data = await FirebaseFirestore.instance.collection('manga').orderBy('manga').get();

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

    if (_searchController.text != "") {
      for (var clientSnapshot in _allResults) {
        var name = clientSnapshot['manga'].toString().toLowerCase();
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
    _searchController.removeListener(() { });
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getClientStream();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = ref.watch(themeTextColorProvider);
    final bgColor = ref.watch(themeBgColorProvider);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 85,
        title: Column(
          children: [
            CupertinoSearchTextField(
              controller: _searchController,
              placeholderStyle: TextStyle(
                color: textColor,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _resultsList.length,
        itemBuilder: (context, index) {
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
                            _resultsList[index]['author'],
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "2022",
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
            MyLine(width: MediaQuery.of(context).size.width, vertical: 0,),
          ],
        );
        },
      ),
    );
  }
}
