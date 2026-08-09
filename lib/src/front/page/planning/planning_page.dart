import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/back/services/cache/persistent_cache_store.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';

typedef PlanningLoader =
    Future<List<RecordModel>> Function(DateTime start, DateTime end);

class PlanningPage extends StatefulWidget {
  const PlanningPage({
    this.loader,
    this.clock,
    this.cacheStore,
    super.key,
  });

  final PlanningLoader? loader;
  final DateTime Function()? clock;
  final PersistentCacheStore? cacheStore;

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  final AppwriteConnector _connector = AppwriteConnector();

  late final PersistentCacheStore _cache =
      widget.cacheStore ?? PersistentCacheStore();
  late DateTime _visibleMonth;
  List<RecordModel> _volumes = <RecordModel>[];
  bool _loading = true;
  bool _showingCachedData = false;
  bool _loadFailed = false;
  int _loadGeneration = 0;

  DateTime get _now => (widget.clock?.call() ?? DateTime.now()).toLocal();

  @override
  void initState() {
    super.initState();
    final now = _now;
    _visibleMonth = DateTime(now.year, now.month);
    unawaited(_loadMonth());
  }

  ({DateTime start, DateTime end}) _monthRange() {
    final start = DateTime(_visibleMonth.year, _visibleMonth.month);
    final end = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    return (start: start, end: end);
  }

  String _cacheNamespace(DateTime start) {
    return 'planning.${start.year}.${start.month.toString().padLeft(2, '0')}';
  }

  Future<void> _loadMonth({bool forceRefresh = false}) async {
    final generation = ++_loadGeneration;
    final range = _monthRange();
    final namespace = _cacheNamespace(range.start);
    final cached = await _cache.read(
      namespace,
      maxStale: const Duration(days: 30),
    );
    final cachedRecords = _recordsFromCache(cached?.data);

    if (!mounted || generation != _loadGeneration) return;
    if (cachedRecords.isNotEmpty) {
      setState(() {
        _volumes = cachedRecords;
        _loading = false;
        _showingCachedData = true;
        _loadFailed = false;
      });
      if (!forceRefresh && cached?.isFresh == true) {
        // Stale-while-revalidate still refreshes silently below.
      }
    } else {
      setState(() {
        _loading = true;
        _loadFailed = false;
      });
    }

    try {
      final records =
          await (widget.loader?.call(range.start, range.end) ??
              _loadFromApi(range.start, range.end));
      if (!mounted || generation != _loadGeneration) return;
      final normalized =
          records.where((record) {
            final release = _releaseDate(record.data);
            return release != null &&
                !release.isBefore(range.start) &&
                release.isBefore(range.end);
          }).toList()..sort((a, b) {
            return _releaseDate(a.data)!.compareTo(_releaseDate(b.data)!);
          });
      await _cache.write(
        namespace,
        _recordsToCache(normalized),
        ttl: const Duration(hours: 6),
      );
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _volumes = normalized;
        _loading = false;
        _showingCachedData = false;
        _loadFailed = false;
      });
    } on Object catch (error) {
      RuntimeLocalization.debug(
        en: 'Unable to load the release calendar: $error',
        fr: 'Impossible de charger le calendrier des sorties : $error',
      );
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _loading = false;
        _loadFailed = cachedRecords.isEmpty;
        _showingCachedData = cachedRecords.isNotEmpty;
      });
    }
  }

  Future<List<RecordModel>> _loadFromApi(DateTime start, DateTime end) {
    final startUtc = start.toUtc().toIso8601String();
    final endUtc = end.toUtc().toIso8601String();
    return _connector.getCollectionFullDataWithFilter(
      'volumes',
      'release?>="$startUtc"&&release?<="$endUtc"',
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + delta,
      );
      _volumes = <RecordModel>[];
    });
    unawaited(_loadMonth());
  }

  DateTime? _releaseDate(Map<String, dynamic> data) {
    return DateTime.tryParse(
      (data['release'] ?? data['publicationDate'])?.toString() ?? '',
    )?.toLocal();
  }

  String _title(Map<String, dynamic> data) {
    return (data['title'] ?? data['titleFr'] ?? '').toString().trim();
  }

  List<Map<String, dynamic>> _recordsToCache(Iterable<RecordModel> records) {
    return records
        .map(
          (record) => <String, dynamic>{
            'id': record.id,
            'collectionId': record.collectionId,
            'data': record.data,
          },
        )
        .toList();
  }

  List<RecordModel> _recordsFromCache(Object? raw) {
    if (raw is! List) return <RecordModel>[];
    try {
      return raw.whereType<Map>().map((item) {
        final map = Map<String, dynamic>.from(item);
        return RecordModel(
          id: map['id'].toString(),
          collectionId: map['collectionId']?.toString() ?? 'volumes',
          data: Map<String, dynamic>.from(map['data'] as Map),
        );
      }).toList()..sort((a, b) {
        final aDate = _releaseDate(a.data);
        final bDate = _releaseDate(b.data);
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });
    } on Object {
      return <RecordModel>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final monthTitle = DateFormat.yMMMM(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(_visibleMonth);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.localized(
            en: 'Release calendar',
            fr: 'Calendrier des sorties',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: context.localized(
                  en: 'Previous month',
                  fr: 'Mois précédent',
                ),
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              SizedBox(
                width: 190,
                child: Text(
                  monthTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: context.localized(
                  en: 'Next month',
                  fr: 'Mois suivant',
                ),
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (_loading && _volumes.isNotEmpty)
            const LinearProgressIndicator(minHeight: 2),
          if (_showingCachedData)
            MaterialBanner(
              content: Text(
                context.localized(
                  en: 'Offline data is displayed while the calendar refreshes.',
                  fr: 'Les données hors ligne sont affichées pendant l’actualisation du calendrier.',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => _loadMonth(forceRefresh: true),
                  child: Text(localizations.tryAgain),
                ),
              ],
            ),
          Expanded(child: _buildBody(localizations)),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations localizations) {
    if (_loading && _volumes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadFailed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.errorOccurred),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _loadMonth(forceRefresh: true),
              child: Text(localizations.tryAgain),
            ),
          ],
        ),
      );
    }
    if (_volumes.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadMonth(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 180),
            Center(
              child: Text(
                context.localized(
                  en: 'No release is listed for this month.',
                  fr: 'Aucune sortie n’est répertoriée pour ce mois.',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadMonth(forceRefresh: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ValueListenableBuilder<AppDisplayDensity>(
            valueListenable: LocalStorage.displayDensityNotifier,
            builder: (context, density, _) {
              final baseColumns = constraints.maxWidth >= 1100
                  ? 3
                  : constraints.maxWidth >= 650
                  ? 2
                  : 1;
              final columns =
                  density == AppDisplayDensity.compact &&
                      constraints.maxWidth >= 500
                  ? baseColumns + 1
                  : baseColumns;
              return GridView.builder(
                key: PageStorageKey<String>(
                  'planning-${_visibleMonth.year}-${_visibleMonth.month}',
                ),
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 110),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: density == AppDisplayDensity.compact
                      ? 112
                      : 132,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _volumes.length,
                itemBuilder: (context, index) =>
                    _releaseCard(_volumes[index], density),
              );
            },
          );
        },
      ),
    );
  }

  Widget _releaseCard(RecordModel record, AppDisplayDensity density) {
    final data = record.data;
    final release = _releaseDate(data)!;
    final title = _title(data);
    final tome = data['tome_number'] ?? data['tomeNumber'];
    final isUpcoming = release.isAfter(_now);
    final date = DateFormat.yMMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(release);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => pushOrGo(context, '/planning/volume/${record.id}'),
        child: Padding(
          padding: EdgeInsets.all(
            density == AppDisplayDensity.compact ? 8 : 10,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SafeNetworkImage(
                  imageUrl: (data['coverUrl'] ?? data['image'])?.toString(),
                  width: density == AppDisplayDensity.compact ? 60 : 72,
                  height: density == AppDisplayDensity.compact ? 90 : 108,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title.isEmpty
                          ? context.localized(
                              en: 'Untitled volume',
                              fr: 'Tome sans titre',
                            )
                          : title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (tome != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        context.localized(
                          en: 'Volume $tome',
                          fr: 'Tome $tome',
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isUpcoming
                              ? Icons.schedule_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 17,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            date,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
