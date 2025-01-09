import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/src/back/provider/search_filter_provider.dart';
import 'package:mymangatheque/src/back/provider/search_order_provider.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_tab_bar_item.dart';
import 'package:mymangatheque/src/front/page/library/tab_page/collection_tab.dart';
import 'package:mymangatheque/src/front/page/library/tab_page/complete_lib_tab.dart';
import 'package:mymangatheque/src/front/page/library/tab_page/envy_tab.dart';
import 'package:mymangatheque/src/front/page/library/tab_page/read_pile_tab.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  List _allResults = [];
  List _resultsList = [];
  final TextEditingController _searchController = TextEditingController();

  void changeOrder(String filter) {
    ref.read(searchFilterProvider.notifier).changeSearchFilter(filter);
  }

  getClientStream() async {
    var order = ref.watch(searchOrderProvider);
    /*var data = await FirebaseFirestore.instance
        .collection('manga')
        .orderBy(order, descending: order == 'releaseDate' ? true : false)
        .get();

    setState(() {
      _allResults = data.docs;
    });*/
  }

  _onSearchChanged() {
    searchResultsList();
  }

  searchResultsList() {
    var showResults = [];
    var order = ref.watch(searchOrderProvider);

    if (_searchController.text != "") {
      for (var clientSnapshot in _allResults) {
        var name = clientSnapshot[order].toString().toLowerCase();

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
  void didChangeDependencies() {
    getClientStream();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ref.read(searchOrderProvider);
    getClientStream();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  Widget build(BuildContext context) {
    final selectedOrder = ref.watch(searchOrderProvider);

    searchResultsList();

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
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(
                width: 50,
                child: PopupMenuButton(
                  icon: OwnIcon(iconColor: Theme.of(context).colorScheme.primary, iconName: "filter_right"),
                  onSelected: (String result) {
                    setState(() {
                      changeOrder(result);
                    });
                  },
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                  color: Theme.of(context).colorScheme.surface,
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'manga',
                      child: SizedBox(
                        width: 175,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (selectedOrder == 'manga') const Icon(Icons.check) else const Padding(padding: EdgeInsets.only(right: 0)),
                            const Text(
                              'Ordre Alphabétique',
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                        value: 'releaseDate',
                        child: SizedBox(
                          width: 175,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (selectedOrder == 'releaseDate') const Icon(Icons.check) else const Padding(padding: EdgeInsets.only(right: 0)),
                              const Text('Dernière Sortie'),
                            ],
                          ),
                        )),
                  ],
                ),
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
                color: Theme.of(context).colorScheme.primary,
              ),
              isScrollable: true,
              splashBorderRadius: BorderRadius.circular(360),
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(
                  child: MyTabBarItem(
                    tabText: "Pile à lire",
                    colorIn: Theme.of(context).colorScheme.surface,
                    colorOut: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Tab(
                  child: MyTabBarItem(
                    tabText: "Collection",
                    colorIn: Theme.of(context).colorScheme.surface,
                    colorOut: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Tab(
                  child: MyTabBarItem(
                    tabText: "Compléter",
                    colorIn: Theme.of(context).colorScheme.surface,
                    colorOut: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Tab(
                  child: MyTabBarItem(
                    tabText: "Envies",
                    colorIn: Theme.of(context).colorScheme.surface,
                    colorOut: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ]),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ReadPileTab(),
            CollectionTab(),
            CompleteLibTab(),
            EnvyTab(),
          ],
        ),
      ),
    );
  }
}
