import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/back/provider/search_order_provider.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_tab_bar_item.dart';
import 'package:mymangatheque/src/front/page/auth/signin_page.dart';
import 'package:mymangatheque/src/front/page/library/tab_page/collection_tab.dart';
import 'package:mymangatheque/src/front/page/library/tab_page/complete_lib_tab.dart';
import 'package:mymangatheque/src/front/page/library/tab_page/envy_tab.dart';
import 'package:mymangatheque/src/front/page/library/tab_page/read_pile_tab.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final connector = AppwriteConnector();
  final TextEditingController _searchController = TextEditingController();

  void changeOrder(String filter) {
    ref.read(searchOrderProvider.notifier).changeSearchOrder(filter);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> initData() async {
    try {
      final user = connector.getConnectedUser();
      await ref.read(mangaOwnedProvider.notifier).initData(user!).then((value) {
        if (!mounted) return;
        if (value) {
          setState(() {});
        } else {
          showMessage(
            AppLocalizations.of(
              context,
            )!.errorInitializing(AppLocalizations.of(context)!.dataUndercase),
            context,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint(e.toString());
      showMessage(AppLocalizations.of(context)!.errorOccurred, context);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    ref.read(searchOrderProvider);
    ref.read(mangaOwnedProvider);

    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!connector.isLoggedIn()) {
      return const SignInPage();
    }
    final selectedOrder = ref.watch(searchOrderProvider);
    final searchQuery = _searchController.text;

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
                  placeholder: localizations.search,
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
                  icon: OwnIcon(
                    iconColor: Theme.of(context).colorScheme.primary,
                    iconSrc: Assets.icons.filterRight,
                  ),
                  onSelected: (String result) {
                    setState(() {
                      changeOrder(result);
                    });
                  },
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withValues(alpha: 0.5),
                  color: Theme.of(context).colorScheme.surface,
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'manga',
                      child: SizedBox(
                        width: 175,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (selectedOrder == 'manga')
                              const Icon(Icons.check)
                            else
                              const Padding(
                                padding: EdgeInsets.only(right: 0),
                              ),
                            Text(
                              localizations.alphabeticalOrder,
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
                            if (selectedOrder == 'releaseDate')
                              const Icon(Icons.check)
                            else
                              const Padding(
                                padding: EdgeInsets.only(right: 0),
                              ),
                            Text(
                              localizations.lastRelease,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Center(
              child: TabBar(
                mouseCursor: SystemMouseCursors.click,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 0,
                ),
                indicatorWeight: 1,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(360),
                  color: Theme.of(context).colorScheme.primary,
                ),
                isScrollable: true,
                splashBorderRadius: BorderRadius.circular(360),
                tabAlignment: TabAlignment.center,
                tabs: [
                  Tab(
                    child: MyTabBarItem(
                      tabText: localizations.readPile,
                      colorIn: Theme.of(context).colorScheme.surface,
                      colorOut: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Tab(
                    child: MyTabBarItem(
                      tabText: localizations.collection,
                      colorIn: Theme.of(context).colorScheme.surface,
                      colorOut: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Tab(
                    child: MyTabBarItem(
                      tabText: localizations.completeLibrary,
                      colorIn: Theme.of(context).colorScheme.surface,
                      colorOut: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Tab(
                    child: MyTabBarItem(
                      tabText: localizations.desiredLibrary,
                      colorIn: Theme.of(context).colorScheme.surface,
                      colorOut: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ReadPileTab(searchQuery: searchQuery, order: selectedOrder),
            CollectionTab(searchQuery: searchQuery, order: selectedOrder),
            CompleteLibTab(searchQuery: searchQuery, order: selectedOrder),
            EnvyTab(searchQuery: searchQuery, order: selectedOrder),
          ],
        ),
      ),
    );
  }
}
