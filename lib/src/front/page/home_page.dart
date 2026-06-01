import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/front/components/my_manga_show_tile.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends ConsumerState<MyHomePage> {
  static const int _pageSize = 30;

  final AppwriteConnector _connector = AppwriteConnector();
  final ScrollController _scrollController = ScrollController();

  final List<RecordModel> _loadedRecords = <RecordModel>[];
  List<Map<String, dynamic>> _visibleVolumes = <Map<String, dynamic>>[];

  StreamSubscription<User?>? _userSubscription;

  bool _initialLoading = true;
  bool _loadingMore = false;
  String? _error;

  int _currentPage = 0;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _reload();
    _userSubscription = _connector.listenToUserChanges().listen((_) {
      if (!mounted) return;
      _reload();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _userSubscription?.cancel();
    super.dispose();
  }

  bool get _hasMorePages => _currentPage < _totalPages;

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 800) {
      _loadNextPage();
    }
  }

  Future<void> _reload() async {
    setState(() {
      _initialLoading = true;
      _error = null;
      _currentPage = 0;
      _totalPages = 1;
      _loadedRecords.clear();
      _visibleVolumes = <Map<String, dynamic>>[];
    });

    await _loadNextPage(reset: true);
  }

  Future<void> _loadNextPage({bool reset = false}) async {
    if (_loadingMore) return;
    if (!reset && !_hasMorePages) return;

    final nextPage = reset ? 1 : (_currentPage + 1);

    setState(() {
      _loadingMore = true;
      _error = null;
    });

    try {
      final page = await _connector.getHomeRecommendationsPage(page: nextPage, limit: _pageSize);
      if (!mounted) return;

      setState(() {
        if (reset) {
          _loadedRecords.clear();
          _visibleVolumes.clear();
        }

        final existingIds = _loadedRecords.map((e) => e.id).toSet();
        for (final record in page.items) {
          if (existingIds.add(record.id)) {
            _loadedRecords.add(record);
            // append visible volume entry for newly added records only
            _visibleVolumes.add(Map<String, dynamic>.from(record.data));
          }
        }

        _currentPage = page.page;
        _totalPages = page.totalPages;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _initialLoading = false;
          _loadingMore = false;
        });
      }
    }
  }

  int _crossAxisCountForWidth(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    return 2;
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
          child: TextButton(onPressed: _loadNextPage, child: Text(localizations.tryAgain)),
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
                ElevatedButton(onPressed: _reload, child: Text(localizations.tryAgain)),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _crossAxisCountForWidth(constraints.maxWidth);
          final tileWidth = (constraints.maxWidth / crossAxisCount) - 30;
          final tileHeight = tileWidth * 1.5 + 10;
          final hasFooter = _loadingMore || _error != null;
          final itemCount = _visibleVolumes.length + (hasFooter ? 1 : 0);

          return GridView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, childAspectRatio: 0.7),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index >= _visibleVolumes.length) {
                return _buildFooter(localizations);
              }

              return MyMangaShowTile(mangaData: _visibleVolumes[index], initRoute: '/', width: tileWidth, height: tileHeight);
            },
          );
        },
      ),
    );
  }
}
