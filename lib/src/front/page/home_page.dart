import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/back/services/recommendations/recommendation_preferences_service.dart';
import 'package:mymangatheque/src/back/services/recommendations/recommendation_ranking_service.dart';
import 'package:mymangatheque/src/front/components/my_manga_show_tile.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';

typedef HomeRecommendationLoader =
    Future<RecordPage> Function({required int page, required int limit});
typedef HomeRecommendationCacheLoader =
    Future<RecordPage?> Function({required int page, required int limit});

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    this.recommendationLoader,
    this.cacheLoader,
  });

  final String title;
  final HomeRecommendationLoader? recommendationLoader;
  final HomeRecommendationCacheLoader? cacheLoader;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends ConsumerState<MyHomePage> {
  static const int _pageSize = 30;

  final AppwriteConnector _connector = AppwriteConnector();
  final RecommendationPreferencesService _recommendations =
      RecommendationPreferencesService();
  final RecommendationRankingService _ranking = RecommendationRankingService();
  final ScrollController _scrollController = ScrollController();

  final List<RecordModel> _loadedRecords = <RecordModel>[];
  final List<Map<String, dynamic>> _visibleVolumes = <Map<String, dynamic>>[];

  StreamSubscription<User?>? _userSubscription;

  bool _initialLoading = true;
  bool _loadingMore = false;
  String? _error;
  String? _lastUserId;
  Set<String> _hiddenVolumeIds = <String>{};
  RecommendationProfile _recommendationProfile = const RecommendationProfile();

  int _currentPage = 0;
  int _totalPages = 1;
  int _loadGeneration = 0;
  int _profileGeneration = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    RecommendationPreferencesService.preferencesRevisionNotifier.addListener(
      _onRecommendationPreferencesChanged,
    );

    _lastUserId = _connector.getConnectedUser()?.id;
    unawaited(_loadHiddenRecommendations());
    unawaited(_loadRecommendationProfile());
    unawaited(LocalStorage().getDisplayDensity());
    unawaited(LocalStorage().getHomeRecommendationOrder());
    if (widget.recommendationLoader != null && widget.cacheLoader == null) {
      unawaited(_reload(showInitialLoader: true));
    } else {
      unawaited(_bootstrap());
    }
    _userSubscription = _connector.listenToUserChanges().listen((user) {
      if (!mounted) return;
      final userId = user?.id;
      if (userId == _lastUserId) return;
      _lastUserId = userId;
      setState(() {
        _hiddenVolumeIds = <String>{};
        _recommendationProfile = const RecommendationProfile();
      });
      unawaited(_loadHiddenRecommendations());
      unawaited(_loadRecommendationProfile());
      unawaited(_reload(clearExisting: true, forceRefresh: true));
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    RecommendationPreferencesService.preferencesRevisionNotifier.removeListener(
      _onRecommendationPreferencesChanged,
    );
    _scrollController.dispose();
    _userSubscription?.cancel();
    super.dispose();
  }

  bool get _hasMorePages => _currentPage < _totalPages;

  void _onRecommendationPreferencesChanged() {
    unawaited(_loadRecommendationProfile());
  }

  Future<void> _loadHiddenRecommendations() async {
    final hidden = await _recommendations.hiddenVolumeIds();
    if (!mounted) return;
    setState(() {
      _hiddenVolumeIds = hidden;
      _visibleVolumes.removeWhere(
        (volume) => hidden.contains((volume['id'] ?? '').toString()),
      );
      _loadedRecords.removeWhere((record) => hidden.contains(record.id));
    });
  }

  Future<void> _loadRecommendationProfile() async {
    final generation = ++_profileGeneration;
    final profile = await _ranking.buildProfile();
    if (!mounted || generation != _profileGeneration) return;
    setState(() => _recommendationProfile = profile);
  }

  Future<void> _bootstrap() async {
    RecordPage? cached;
    try {
      cached = widget.cacheLoader != null
          ? await widget.cacheLoader!(page: 1, limit: _pageSize)
          : await _connector.getCachedHomeRecommendationsPage(
              page: 1,
              limit: _pageSize,
            );
    } on Object {
      cached = null;
    }

    if (!mounted) return;
    if (cached != null && cached.items.isNotEmpty) {
      setState(() {
        _replaceWithPage(cached!);
        _initialLoading = false;
      });
    }
    await _reload(
      showInitialLoader: cached == null || cached.items.isEmpty,
      forceRefresh: true,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 800) {
      _loadNextPage();
    }
  }

  Future<void> _reload({
    bool showInitialLoader = false,
    bool clearExisting = false,
    bool forceRefresh = false,
  }) async {
    final generation = ++_loadGeneration;
    setState(() {
      if (clearExisting) {
        _loadedRecords.clear();
        _visibleVolumes.clear();
      }
      _initialLoading = showInitialLoader || _visibleVolumes.isEmpty;
      _error = null;
      _currentPage = 0;
      _totalPages = 1;
    });

    await _loadNextPage(
      reset: true,
      generation: generation,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _loadNextPage({
    bool reset = false,
    int? generation,
    bool forceRefresh = false,
  }) async {
    if (_loadingMore && !reset) return;
    if (!reset && !_hasMorePages) return;

    final loadGeneration = generation ?? _loadGeneration;
    final nextPage = reset ? 1 : (_currentPage + 1);

    setState(() {
      _loadingMore = true;
      _error = null;
    });

    try {
      final loader = widget.recommendationLoader;
      final page = loader != null
          ? await loader(page: nextPage, limit: _pageSize)
          : await _connector.getHomeRecommendationsPage(
              page: nextPage,
              limit: _pageSize,
              forceRefresh: forceRefresh,
            );
      if (!mounted || loadGeneration != _loadGeneration) return;

      setState(() {
        if (reset) {
          _replaceWithPage(page);
        } else {
          _appendPage(page);
        }
      });
    } catch (e) {
      if (!mounted || loadGeneration != _loadGeneration) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted && loadGeneration == _loadGeneration) {
        setState(() {
          _initialLoading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _replaceWithPage(RecordPage page) {
    _loadedRecords.clear();
    _visibleVolumes.clear();
    _appendPage(page);
  }

  void _appendPage(RecordPage page) {
    final existingIds = _loadedRecords.map((record) => record.id).toSet();
    for (final record in page.items) {
      if (!existingIds.add(record.id)) continue;
      if (_hiddenVolumeIds.contains(record.id)) continue;
      _loadedRecords.add(record);
      _visibleVolumes.add(Map<String, dynamic>.from(record.data));
    }
    _currentPage = page.page;
    _totalPages = page.totalPages;
  }

  Future<void> _recordFeedback(
    Map<String, dynamic> volume,
    RecommendationFeedbackAction action,
  ) async {
    final volumeId = (volume['id'] ?? '').toString();
    if (volumeId.isEmpty) return;
    setState(() {
      _hiddenVolumeIds.add(volumeId);
      _visibleVolumes.removeWhere(
        (candidate) => (candidate['id'] ?? '').toString() == volumeId,
      );
      _loadedRecords.removeWhere((candidate) => candidate.id == volumeId);
    });
    unawaited(_recommendations.recordFeedback(volumeId, action));
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null || Scaffold.maybeOf(context) == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          action == RecommendationFeedbackAction.irrelevant
              ? context.localized(
                  en: 'Feedback saved. This suggestion was hidden.',
                  fr: 'Retour enregistré. Cette suggestion a été masquée.',
                )
              : context.localized(
                  en: 'Recommendation hidden.',
                  fr: 'Recommandation masquée.',
                ),
        ),
        action: SnackBarAction(
          label: context.localized(en: 'Undo', fr: 'Annuler'),
          onPressed: () async {
            await _recommendations.restore(volumeId);
            if (!mounted) return;
            _hiddenVolumeIds.remove(volumeId);
            await _reload(forceRefresh: false);
          },
        ),
      ),
    );
  }

  int _crossAxisCountForWidth(double width, AppDisplayDensity density) {
    final comfortable = switch (width) {
      >= 1600 => 6,
      >= 1200 => 5,
      >= 800 => 4,
      >= 560 => 3,
      _ => 2,
    };
    return density == AppDisplayDensity.compact
        ? (comfortable + 1).clamp(2, 7)
        : comfortable;
  }

  List<Map<String, dynamic>> _orderedVolumes(HomeRecommendationOrder order) {
    final volumes = List<Map<String, dynamic>>.from(_visibleVolumes);
    switch (order) {
      case HomeRecommendationOrder.recommended:
        return _ranking.rerank(volumes, _recommendationProfile);
      case HomeRecommendationOrder.newestFirst:
        DateTime releaseDate(Map<String, dynamic> volume) {
          return DateTime.tryParse(
                (volume['release'] ?? volume['publicationDate'])?.toString() ??
                    '',
              ) ??
              DateTime.fromMillisecondsSinceEpoch(0);
        }

        volumes.sort((a, b) => releaseDate(b).compareTo(releaseDate(a)));
        return volumes;
      case HomeRecommendationOrder.title:
        String title(Map<String, dynamic> volume) {
          return (volume['title'] ?? volume['titleFr'] ?? '')
              .toString()
              .toLowerCase();
        }

        volumes.sort((a, b) => title(a).compareTo(title(b)));
        return volumes;
    }
  }

  Widget _buildFooter(AppLocalizations localizations) {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: TextButton(
            onPressed: _loadNextPage,
            child: Text(localizations.tryAgain),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_initialLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations.loading)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _visibleVolumes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations.errorOccurred)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(localizations.errorOccurred, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _reload,
                  child: Text(localizations.tryAgain),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_visibleVolumes.isEmpty) {
      return RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          key: const PageStorageKey<String>('home-empty'),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 160),
            Center(child: Text(localizations.noResults)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ValueListenableBuilder<HomeRecommendationOrder>(
            valueListenable: LocalStorage.homeRecommendationOrderNotifier,
            builder: (context, order, _) =>
                ValueListenableBuilder<AppDisplayDensity>(
                  valueListenable: LocalStorage.displayDensityNotifier,
                  builder: (context, density, _) {
                    final visibleVolumes = _orderedVolumes(order);
                    final crossAxisCount = _crossAxisCountForWidth(
                      constraints.maxWidth,
                      density,
                    );
                    final tileWidth =
                        (constraints.maxWidth / crossAxisCount) - 30;
                    final tileHeight = tileWidth * 1.5 + 10;
                    final hasFooter = _loadingMore || _error != null;
                    final itemCount =
                        visibleVolumes.length + (hasFooter ? 1 : 0);

                    return GridView.builder(
                      key: const PageStorageKey<String>(
                        'home-recommendations',
                      ),
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      cacheExtent: density == AppDisplayDensity.compact
                          ? 700
                          : 1000,
                      padding: const EdgeInsets.only(
                        top: 50,
                        left: 10,
                        right: 10,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: density == AppDisplayDensity.compact
                            ? 0.66
                            : 0.7,
                      ),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (index >= visibleVolumes.length) {
                          return _buildFooter(localizations);
                        }

                        final volume = visibleVolumes[index];
                        final volumeId = (volume['id'] ?? index).toString();
                        return RepaintBoundary(
                          key: ValueKey<String>('home-volume-$volumeId'),
                          child: MyMangaShowTile(
                            key: ValueKey<String>(
                              'home-volume-tile-$volumeId',
                            ),
                            mangaData: volume,
                            initRoute: '/',
                            width: tileWidth,
                            height: tileHeight,
                            recommendationReason: _recommendations.explanation(
                              volume,
                            ),
                            onRecommendationFeedback: (action) =>
                                _recordFeedback(volume, action),
                          ),
                        );
                      },
                    );
                  },
                ),
          );
        },
      ),
    );
  }
}
