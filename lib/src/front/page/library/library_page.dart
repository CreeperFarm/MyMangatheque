import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
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
  dynamic _ownedSubscription;
  StreamSubscription<User?>? _userSubscription;
  User? _currentUser;
  String? _lastUserId;
  bool _authResolved = false;
  bool _loadingOwned = false;
  int _ownedLoadGeneration = 0;
  String _searchQuery = '';
  Timer? _searchDebounce;
  Timer? _realtimeRefreshDebounce;

  void changeOrder(String filter) {
    ref.read(searchOrderProvider.notifier).changeSearchOrder(filter);
  }

  void _onSearchChanged() {
    final nextQuery = _searchController.text;
    _searchDebounce?.cancel();
    if (nextQuery.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        setState(() => _searchQuery = '');
      }
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 120), () {
      if (!mounted || _searchQuery == nextQuery) return;
      setState(() => _searchQuery = nextQuery);
    });
  }

  Future<void> initData({User? user, bool forceRefresh = false}) async {
    final resolvedUser = user ?? _currentUser ?? connector.getConnectedUser();
    if (resolvedUser == null) return;
    final loadGeneration = ++_ownedLoadGeneration;

    try {
      if (mounted) {
        setState(() {
          _loadingOwned = true;
        });
      }

      final value = await ref
          .read(mangaOwnedProvider.notifier)
          .initData(resolvedUser, forceRefresh: forceRefresh);

      if (!mounted || loadGeneration != _ownedLoadGeneration) return;
      if (!value) {
        showMessage(
          AppLocalizations.of(
            context,
          )!.errorInitializing(AppLocalizations.of(context)!.dataUndercase),
          context,
        );
      }
    } catch (e) {
      if (!mounted || loadGeneration != _ownedLoadGeneration) return;
      RuntimeLocalization.debug(
        en: 'Unable to initialize the library: $e',
        fr: 'Impossible d’initialiser la bibliothèque : $e',
      );
      showMessage(AppLocalizations.of(context)!.errorOccurred, context);
    } finally {
      if (mounted && loadGeneration == _ownedLoadGeneration) {
        setState(() {
          _loadingOwned = false;
        });
      }
    }
  }

  void _setupRealtime() {
    if (_ownedSubscription != null || _currentUser == null) return;
    try {
      _ownedSubscription = connector.connector().collection('owned').subscribe(
        '*',
        (_) {
          _realtimeRefreshDebounce?.cancel();
          _realtimeRefreshDebounce = Timer(
            const Duration(milliseconds: 350),
            () {
              if (mounted) {
                unawaited(initData(forceRefresh: true));
              }
            },
          );
        },
      );
    } catch (e) {
      RuntimeLocalization.debug(
        en: 'Owned collection realtime subscription failed: $e',
        fr: 'L’abonnement temps réel de la collection possédée a échoué : $e',
      );
    }
  }

  void _cancelOwnedRealtime() {
    _realtimeRefreshDebounce?.cancel();
    try {
      _ownedSubscription?.unsubscribe();
    } catch (_) {
      // Ignore realtime teardown failures.
    }
    _ownedSubscription = null;
  }

  void _handleUserChange(User? user, {bool forceRefresh = false}) {
    if (!mounted) return;

    final userId = user?.id;
    final userChanged = userId != _lastUserId;
    _lastUserId = userId;

    if (userChanged) {
      _ownedLoadGeneration += 1;
      _cancelOwnedRealtime();
    }
    ref.read(mangaOwnedProvider.notifier).handleUserChanged(userId);

    setState(() {
      _currentUser = user;
      _authResolved = true;
      if (user == null) {
        _loadingOwned = false;
      }
    });

    if (user == null) {
      _cancelOwnedRealtime();
      return;
    }

    _setupRealtime();
    unawaited(initData(user: user, forceRefresh: forceRefresh || userChanged));
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _realtimeRefreshDebounce?.cancel();
    _userSubscription?.cancel();
    _cancelOwnedRealtime();
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
    _currentUser = connector.getConnectedUser();
    _lastUserId = _currentUser?.id;

    _userSubscription = connector.listenToUserChanges().listen((user) {
      _handleUserChange(user);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = connector.getConnectedUser();
      if (user != null) {
        _handleUserChange(user);
        return;
      }

      unawaited(
        connector.refresh().then((_) {
          if (!mounted) return;
          _handleUserChange(connector.getConnectedUser());
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final connectedUser = _currentUser ?? connector.getConnectedUser();
    if (!_authResolved && connectedUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (connectedUser == null) {
      return const SignInPage();
    }
    final selectedOrder = ref.watch(searchOrderProvider);
    final searchQuery = _searchQuery;

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
                    changeOrder(result);
                  },
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withValues(alpha: 0.5),
                  color: Theme.of(context).colorScheme.surface,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
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
        body: Stack(
          children: [
            TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ReadPileTab(searchQuery: searchQuery, order: selectedOrder),
                CollectionTab(searchQuery: searchQuery, order: selectedOrder),
                CompleteLibTab(searchQuery: searchQuery, order: selectedOrder),
                EnvyTab(searchQuery: searchQuery, order: selectedOrder),
              ],
            ),
            if (_loadingOwned)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
      ),
    );
  }
}
