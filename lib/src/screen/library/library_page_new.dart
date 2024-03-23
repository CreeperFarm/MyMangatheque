import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/provider/search_order_provider.dart';
import 'package:mymangatheque/src/provider/theme_color_provider.dart';
import 'package:mymangatheque/src/components/my_tab_bar_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class LibraryPageNew extends ConsumerStatefulWidget {
  const LibraryPageNew({super.key});

  @override
  ConsumerState<LibraryPageNew> createState() => _LibraryPageNewState();
}

class _LibraryPageNewState extends ConsumerState<LibraryPageNew> {

  List _allResults = [];
  List _resultsList = [];
  final TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    ref.read(themeBgColorProvider);
    ref.read(themeTextColorProvider);
    ref.read(searchOrderProvider);
    _searchController.addListener(_onSearchChanged);
  }

  void changeOrder(String filter) {
    ref.read(searchOrderProvider.notifier).changeSearchOrder(filter);
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
    var order = ref.watch(searchOrderProvider);

    if (_searchController.text != "") {
      for (var clientSnapshot in _allResults) {
        var name = clientSnapshot['manga'].toString().toLowerCase();

        if (order == 'manga') {
          if (name.contains(_searchController.text.toLowerCase())) {
            showResults.add(clientSnapshot);
          }
        } else if (order == 'editor') {
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
  Widget build(BuildContext context) {

    final bgColor = ref.watch(themeBgColorProvider);
    final textColor = ref.watch(themeTextColorProvider);
    final selectedOrder = ref.watch(searchOrderProvider);

    return DefaultTabController(
      initialIndex: 1,
      length: 4,
      child: Scaffold(
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
              PopupMenuButton(
                icon: OwnIcon(iconColor: textColor, iconName: "filter_right"),
                onSelected: (String result) {
                  setState(() {
                    changeOrder(result);
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
                    value: 'order_alpha',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (selectedOrder == 'order_alpha') const Icon(Icons.check) else const Padding(padding: EdgeInsets.only(right: 0)),
                        const Text('Ordre Alphabétique'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                      value: 'last_out',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (selectedOrder == 'last_out') const Icon(Icons.check) else const Padding(padding: EdgeInsets.only(right: 0)),
                          const Text('Dernière Sortie'),
                        ],
                      )
                  ),
                ],
              ),
            ],
          ),
          bottom: TabBar(
            mouseCursor: SystemMouseCursors.click,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
            indicatorWeight: 1,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(360),
              color: textColor,
            ),
            isScrollable: true,
            splashBorderRadius: BorderRadius.circular(360),
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(
                child: MyTabBarItem(
                  tabText: "Pile à lire",
                  colorIn: bgColor,
                  colorOut: textColor,
                ),
              ),
              Tab(
                child: MyTabBarItem(
                  tabText: "Collection",
                  colorIn: bgColor,
                  colorOut: textColor,
                ),
              ),
              Tab(
                child: MyTabBarItem(
                  tabText: "Compléter",
                  colorIn: bgColor,
                  colorOut: textColor,
                ),
              ),
              Tab(
                child: MyTabBarItem(
                  tabText: "Envies",
                  colorIn: bgColor,
                  colorOut: textColor,
                ),
              ),
            ]
          ),
        ),
        body: const Center(
          child: TabBarView(
            children: [
              Column(
                children: [
                  Text('Tab1'),
                  Text('data'),
                ],
              ),
              Column(
                children: [
                  Text('Tab2'),
                  Text('data'),
                ],
              ),
              Column(
                children: [
                  Text('Tab3'),
                  Text('data'),
                ],
              ),
              Column(
                children: [
                  Text('Tab4'),
                  Text('data'),
                ],
              ),
            ],
          )
        )
      ),
    );
  }
}
