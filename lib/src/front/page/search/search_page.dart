import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/back/services/search_service.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:video_player/video_player.dart';

typedef SearchPageLoader =
    Future<RecordPage> Function(
      String mode,
      String? query,
      int page,
      int limit,
    );
typedef SearchSuggestionLoader =
    Future<List<RecordModel>> Function(String mode, String query, int limit);

class SearchPage extends StatefulWidget {
  const SearchPage({
    this.pageLoader,
    this.suggestionLoader,
    this.debounceDuration = const Duration(milliseconds: 200),
    super.key,
  });

  final SearchPageLoader? pageLoader;
  final SearchSuggestionLoader? suggestionLoader;
  final Duration debounceDuration;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const int _pageSize = 30;
  static const Map<String, String> _accentMap = <String, String>{
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'å': 'a',
    'ç': 'c',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ñ': 'n',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ý': 'y',
    'ÿ': 'y',
    'œ': 'oe',
    'æ': 'ae',
  };

  static const List<String> _searchModes = <String>[
    'series',
    'authors',
    'editors',
  ];

  final AppwriteConnector _connector = AppwriteConnector();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<RecordModel> _loadedRecords = <RecordModel>[];
  List<RecordModel> _filteredResults = <RecordModel>[];

  String _selectedMode = 'series';
  int _currentPage = 0;
  bool _reachedEnd = false;
  int _loadGeneration = 0;
  int _suggestionGeneration = 0;
  bool _loading = false;
  String? _error;
  String? _activeSearchQuery;

  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoFuture;

  Timer? _debounceTimer;
  List<RecordModel> _realtimeSuggestions = <RecordModel>[];
  bool _usingRealtimeSuggestions = false;
  bool _performingFullSearch = false;
  bool _loadingRealtime = false;

  bool get _hasMorePages => !_reachedEnd;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _reload();
  }

  @override
  void dispose() {
    _loadGeneration += 1;
    _suggestionGeneration += 1;
    _debounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_usingRealtimeSuggestions) {
      return; // do not paginate while showing realtime suggestions
    }
    if (_scrollController.position.extentAfter < 600) {
      _loadNextPage();
    }
  }

  void _onModeChanged(String? value) {
    if (value == null || value == _selectedMode) return;
    _debounceTimer?.cancel();
    _suggestionGeneration += 1;
    setState(() {
      _selectedMode = value;
      _usingRealtimeSuggestions = false;
      _realtimeSuggestions = <RecordModel>[];
      _loadingRealtime = false;
      _performingFullSearch = false;
      _activeSearchQuery = null;
      _performingFullSearch = false;
    });
    unawaited(
      _reload().then((_) {
        if (mounted) _onSearchChanged();
      }),
    );
  }

  Future<void> _reload() async {
    _debounceTimer?.cancel();
    _suggestionGeneration += 1;
    _loadGeneration++;
    final generation = _loadGeneration;
    setState(() {
      _loadedRecords.clear();
      _filteredResults = <RecordModel>[];
      _currentPage = 0;
      _reachedEnd = false;
      _error = null;
      _usingRealtimeSuggestions = false;
      _realtimeSuggestions = <RecordModel>[];
      _loadingRealtime = false;
    });
    await _loadNextPage(generation: generation, force: true);
  }

  Future<void> _loadNextPage({int? generation, bool force = false}) async {
    final activeGeneration = generation ?? _loadGeneration;
    if (_loading && !force) return;
    if (!force && _loadedRecords.isNotEmpty && !_hasMorePages) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final nextPage = _currentPage + 1;
      final activeQuery = _activeSearchQuery?.trim();
      final pageLoader = widget.pageLoader;
      final page = pageLoader != null
          ? await pageLoader(
              _selectedMode,
              activeQuery,
              nextPage,
              _pageSize,
            )
          : (activeQuery == null || activeQuery.isEmpty)
          ? await _connector.getCollectionPage(
              _selectedMode,
              page: nextPage,
              limit: _pageSize,
            )
          : await _connector.searchCollectionPage(
              _selectedMode,
              query: activeQuery,
              page: nextPage,
              limit: _pageSize,
            );
      if (!mounted || activeGeneration != _loadGeneration) return;

      setState(() {
        final existingIds = _loadedRecords.map((record) => record.id).toSet();
        var addedCount = 0;
        for (final record in page.items) {
          if (existingIds.add(record.id)) {
            _loadedRecords.add(record);
            addedCount += 1;
          }
        }
        _currentPage = page.page;
        // Do not trust backend total counters alone during migration;
        // keep loading until a short/empty page is returned.
        _reachedEnd =
            page.items.isEmpty ||
            addedCount == 0 ||
            page.items.length < _pageSize;
        _filteredResults = _computeFilteredResults();
      });
    } catch (e) {
      if (!mounted || activeGeneration != _loadGeneration) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted && activeGeneration == _loadGeneration) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    // keep local filtering behavior for empty queries
    final text = _searchController.text.trim();
    final suggestionGeneration = ++_suggestionGeneration;
    if (_performingFullSearch) {
      _loadGeneration += 1;
      _performingFullSearch = false;
    }
    if (text.length < 2) {
      _debounceTimer?.cancel();
      final shouldResetToBrowse = text.isEmpty && _activeSearchQuery != null;
      setState(() {
        _usingRealtimeSuggestions = false;
        _realtimeSuggestions = <RecordModel>[];
        _loadingRealtime = false;
        if (!shouldResetToBrowse) {
          _filteredResults = _computeFilteredResults();
        }
      });
      if (shouldResetToBrowse) {
        _activeSearchQuery = null;
        _reload();
      }
      return;
    }

    // Debounce realtime suggestions between 150-250ms; use 200ms default.
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () async {
      final q = text;
      final mode = _selectedMode;
      if (!mounted || suggestionGeneration != _suggestionGeneration) return;
      try {
        setState(() => _loadingRealtime = true);
        final suggestionLoader = widget.suggestionLoader;
        final suggestions = suggestionLoader != null
            ? await suggestionLoader(mode, q, 8)
            : await searchRealtime(mode, q: q, limit: 8);
        if (!mounted ||
            suggestionGeneration != _suggestionGeneration ||
            mode != _selectedMode ||
            q != _searchController.text.trim()) {
          return;
        }
        setState(() {
          _usingRealtimeSuggestions = true;
          _realtimeSuggestions = suggestions;
          _filteredResults = List<RecordModel>.from(_realtimeSuggestions);
        });
      } catch (e) {
        if (!mounted || suggestionGeneration != _suggestionGeneration) return;
        setState(() {
          _usingRealtimeSuggestions = false;
          _realtimeSuggestions = <RecordModel>[];
          _filteredResults = _computeFilteredResults();
          // Realtime suggestions are an enhancement: retain the paged/local
          // results instead of replacing the entire page with an error.
        });
      } finally {
        if (mounted && suggestionGeneration == _suggestionGeneration) {
          setState(() {
            _loadingRealtime = false;
          });
        }
      }
    });

    // also update UI for small local filtering while waiting
    setState(() {
      _filteredResults = _computeFilteredResults();
    });
  }

  Future<void> _performFullSearch(String query) async {
    // Called on submit/enter. Use server-side paged search endpoint.
    _debounceTimer?.cancel();
    _suggestionGeneration += 1;
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      _activeSearchQuery = null;
      await _reload();
      return;
    }

    final generation = ++_loadGeneration;
    final mode = _selectedMode;
    setState(() {
      _performingFullSearch = true;
      _loading = false;
      _usingRealtimeSuggestions = false;
      _reachedEnd = false;
      _loadedRecords.clear();
      _filteredResults = <RecordModel>[];
      _currentPage = 0;
      _error = null;
      _loadingRealtime = false;
      _activeSearchQuery = normalizedQuery;
    });

    try {
      final pageLoader = widget.pageLoader;
      final page = pageLoader != null
          ? await pageLoader(mode, normalizedQuery, 1, _pageSize)
          : await _connector.searchCollectionPage(
              mode,
              query: normalizedQuery,
              page: 1,
              limit: _pageSize,
            );
      if (!mounted ||
          generation != _loadGeneration ||
          mode != _selectedMode ||
          normalizedQuery != _activeSearchQuery) {
        return;
      }
      setState(() {
        final ids = <String>{};
        _loadedRecords.addAll(page.items.where((record) => ids.add(record.id)));
        _currentPage = page.page;
        _reachedEnd = !page.hasMore || page.items.length < _pageSize;
        _filteredResults = _computeFilteredResults();
      });
    } catch (e) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted && generation == _loadGeneration) {
        setState(() => _performingFullSearch = false);
      }
    }
  }

  List<RecordModel> _computeFilteredResults() {
    // When using realtime suggestions prefer them over local filtering
    if (_usingRealtimeSuggestions) {
      return List<RecordModel>.from(_realtimeSuggestions);
    }

    final query = _normalizeText(_searchController.text.trim());
    final source = List<RecordModel>.from(_loadedRecords);
    source.sort((a, b) => _recordLabel(a).compareTo(_recordLabel(b)));

    if (query.isEmpty) {
      return source;
    }

    final filtered = source
        .where((record) => _recordSearchText(record).contains(query))
        .toList();

    filtered.sort((a, b) {
      final aText = _recordSearchText(a);
      final bText = _recordSearchText(b);
      final aStarts = aText.startsWith(query);
      final bStarts = bText.startsWith(query);
      if (aStarts != bStarts) return aStarts ? -1 : 1;
      return _recordLabel(a).compareTo(_recordLabel(b));
    });

    return filtered;
  }

  Widget _buildBadApplePlayer() {
    if (_videoController == null) {
      _videoController = VideoPlayerController.asset(Assets.videos.badApple);
      _initializeVideoFuture = _videoController!.initialize().then((_) {
        _videoController!.setLooping(true);
        _videoController!.play();
        if (mounted) setState(() {});
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
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  String _recordLabel(RecordModel record) {
    switch (record.collectionId) {
      case 'series':
        return (record.data['title'] ?? record.data['titleFr'] ?? '')
            .toString()
            .toLowerCase();
      case 'authors':
      case 'editors':
        return (record.data['name'] ?? '').toString().toLowerCase();
      default:
        return '';
    }
  }

  String _recordSearchText(RecordModel record) {
    final data = record.data;
    final tokens = <String>[];

    void collect(dynamic value, {int depth = 0}) {
      if (depth > 3 || value == null) return;
      if (value is String) {
        final text = value.trim();
        if (text.isEmpty) return;
        if (text.startsWith('http://') || text.startsWith('https://')) return;
        tokens.add(text);
        return;
      }
      if (value is num || value is bool) {
        tokens.add(value.toString());
        return;
      }
      if (value is List) {
        for (final entry in value) {
          collect(entry, depth: depth + 1);
        }
        return;
      }
      if (value is Map) {
        for (final entry in value.entries) {
          final key = entry.key.toString();
          if (key == 'id' ||
              key == r'$id' ||
              key == 'created' ||
              key == 'updated' ||
              key == r'$createdAt' ||
              key == r'$updatedAt' ||
              key == 'image' ||
              key == 'coverUrl' ||
              key == 'logo') {
            continue;
          }
          collect(entry.value, depth: depth + 1);
        }
      }
    }

    collect(data);
    return _normalizeText(tokens.join(' '));
  }

  String _searchModeLabel(AppLocalizations localizations, String mode) {
    switch (mode) {
      case 'series':
        return localizations.series;
      case 'authors':
        return localizations.authors;
      case 'editors':
        return localizations.editors;
      default:
        return mode;
    }
  }

  String _normalizeText(String input) {
    var output = input.toLowerCase();
    _accentMap.forEach((key, value) {
      output = output.replaceAll(key, value);
    });
    output = output.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    output = output.replaceAll(RegExp(r'\s+'), ' ').trim();
    return output;
  }

  String _recordRoute(RecordModel record) {
    switch (record.collectionId) {
      case 'series':
        return '/search/serie/${record.id}';
      case 'authors':
        return '/search/author/${record.id}';
      case 'editors':
        return '/search/editor/${record.id}';
      default:
        return '/search';
    }
  }

  String _recordSubtitle(RecordModel record, AppLocalizations localizations) {
    if (record.collectionId == 'series') return localizations.series;
    if (record.collectionId == 'authors') return localizations.author;
    if (record.collectionId == 'editors') return localizations.editor;
    return '';
  }

  Widget _buildResultTile(
    RecordModel record,
    AppLocalizations localizations,
    AppDisplayDensity density,
  ) {
    final data = record.data;
    final title =
        record.collectionId == 'authors' || record.collectionId == 'editors'
        ? (data['name'] ?? '').toString()
        : (data['title'] ?? data['titleFr'] ?? '').toString();

    final imageUrl =
        (data['image'] ??
                data['coverUrl'] ??
                data['logo'] ??
                data['imageUrl'] ??
                '')
            .toString();

    return ListTile(
      key: ValueKey<String>(
        'search-result-${record.collectionId}-${record.id}',
      ),
      visualDensity: density == AppDisplayDensity.compact
          ? VisualDensity.compact
          : VisualDensity.standard,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        // Prefer authors list for series when available in expand
        record.collectionId == 'series'
            ? (() {
                final expand = data['expand'];
                if (expand is Map && expand['authors'] is List) {
                  final names = (expand['authors'] as List)
                      .whereType<Map<String, dynamic>>()
                      .map((a) => (a['name'] ?? a['pseudo'] ?? '').toString())
                      .where((s) => s.isNotEmpty)
                      .join(', ');
                  if (names.isNotEmpty) return names;
                }
                return _recordSubtitle(record, localizations);
              })()
            : _recordSubtitle(record, localizations),
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: density == AppDisplayDensity.compact ? 38 : 45,
          height: density == AppDisplayDensity.compact ? 57 : 68,
          child: SafeNetworkImage(
            imageUrl: imageUrl,
            width: density == AppDisplayDensity.compact ? 38 : 45,
            height: density == AppDisplayDensity.compact ? 57 : 68,
          ),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => pushOrGo(context, _recordRoute(record)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase().trim();
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: _searchController,
                placeholder: localizations.search,
                onSubmitted: (value) => _performFullSearch(value.trim()),
                placeholderStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                cursorColor: Theme.of(context).colorScheme.primary,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                prefix: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: Icon(
                    CupertinoIcons.search,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                suffixMode: OverlayVisibilityMode.editing,
                suffix: GestureDetector(
                  onTap: () {
                    _debounceTimer?.cancel();
                    _searchController.clear();
                  },
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: OwnIcon(
                      iconColor: Theme.of(context).colorScheme.primary,
                      iconSrc: Assets.icons.cross,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: localizations.search,
              icon: OwnIcon(
                iconColor: Theme.of(context).colorScheme.primary,
                iconSrc: Assets.icons.filterRight,
              ),
              onSelected: (value) {
                _onModeChanged(value);
              },
              itemBuilder: (context) {
                return _searchModes.map((mode) {
                  final selected = mode == _selectedMode;
                  return PopupMenuItem<String>(
                    value: mode,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_searchModeLabel(localizations, mode)),
                        ),
                        if (selected) const Icon(Icons.check, size: 16),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
      ),
      body: _performingFullSearch
          ? const Center(child: CircularProgressIndicator())
          : query == 'bad apple'
          ? Center(child: _buildBadApplePlayer())
          : RefreshIndicator(
              onRefresh: _reload,
              child: _filteredResults.isEmpty && _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredResults.isEmpty && _error != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(child: Text(localizations.errorOccurred)),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: _reload,
                            child: Text(localizations.tryAgain),
                          ),
                        ),
                      ],
                    )
                  : _loadingRealtime && _filteredResults.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : _filteredResults.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 120),
                        Center(child: Text(localizations.noResults)),
                      ],
                    )
                  : ValueListenableBuilder<AppDisplayDensity>(
                      valueListenable: LocalStorage.displayDensityNotifier,
                      builder: (context, density, _) => ListView.builder(
                        key: const PageStorageKey<String>('search-results'),
                        controller: _scrollController,
                        cacheExtent: density == AppDisplayDensity.compact
                            ? 650
                            : 900,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _filteredResults.length + 1,
                        itemBuilder: (context, index) {
                          if (index >= _filteredResults.length) {
                            if (_loading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 18),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (_error != null) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Center(
                                  child: TextButton(
                                    onPressed: _loadNextPage,
                                    child: Text(localizations.tryAgain),
                                  ),
                                ),
                              );
                            }

                            return const SizedBox(height: 80);
                          }

                          return RepaintBoundary(
                            child: _buildResultTile(
                              _filteredResults[index],
                              localizations,
                              density,
                            ),
                          );
                        },
                      ),
                    ),
            ),
    );
  }
}
