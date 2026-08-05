import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final AdminConnector _admin = AdminConnector();

  Future<_StatisticsData>? _dataFuture;
  bool _initialized = false;
  int _periodDays = 30;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _admin.init();
    if (!mounted) return;
    setState(() {
      _initialized = true;
      if (_admin.isLoggedIn()) _dataFuture = _loadData();
    });
  }

  Future<_StatisticsData> _loadData() async {
    final results = await Future.wait<_StatisticsSection>([
      _capture(_admin.getSummary(days: _periodDays)),
      _capture(_admin.getMostAddedVolumes(days: _periodDays, limit: 10)),
    ]);
    return _StatisticsData(
      summary: results[0],
      volumes: results[1],
      loadedAt: DateTime.now(),
    );
  }

  Future<_StatisticsSection> _capture(
    Future<Map<String, dynamic>> request,
  ) async {
    try {
      return _StatisticsSection(data: await request);
    } catch (error) {
      return _StatisticsSection(error: error);
    }
  }

  void _refresh() => setState(() => _dataFuture = _loadData());

  void _changePeriod(int days) {
    if (_periodDays == days) return;
    setState(() {
      _periodDays = days;
      _dataFuture = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_admin.isLoggedIn()) {
      return AdminPageScaffold(
        title: 'Statistiques',
        maxWidth: 680,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AdminPageHeader(
              icon: Icons.query_stats_rounded,
              title: 'Statistiques du catalogue',
              description:
                  'Une clé autorisée est nécessaire pour consulter ces données.',
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => pushOrGo(context, '/admin/admin_login'),
              icon: const Icon(Icons.login_rounded),
              label: const Text('Se connecter en admin'),
            ),
          ],
        ),
      );
    }

    return AdminPageScaffold(
      title: 'Statistiques',
      actions: [
        IconButton(
          onPressed: _refresh,
          tooltip: 'Actualiser',
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: FutureBuilder<_StatisticsData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _FatalStatisticsError(
              message: snapshot.error?.toString() ?? 'Réponse vide.',
              onRetry: _refresh,
            );
          }
          return _StatisticsContent(
            data: snapshot.data!,
            periodDays: _periodDays,
            onPeriodChanged: _changePeriod,
            onRetry: _refresh,
          );
        },
      ),
    );
  }
}

class _StatisticsData {
  const _StatisticsData({
    required this.summary,
    required this.volumes,
    required this.loadedAt,
  });

  final _StatisticsSection summary;
  final _StatisticsSection volumes;
  final DateTime loadedAt;
}

class _StatisticsSection {
  const _StatisticsSection({this.data = const <String, dynamic>{}, this.error});

  final Map<String, dynamic> data;
  final Object? error;

  bool get hasError => error != null;
}

class _FatalStatisticsError extends StatelessWidget {
  const _FatalStatisticsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AdminPageHeader(
          icon: Icons.query_stats_rounded,
          title: 'Statistiques du catalogue',
          description: 'Les indicateurs n’ont pas pu être chargés.',
        ),
        const SizedBox(height: 20),
        AdminStatusBanner(
          icon: Icons.cloud_off_outlined,
          title: 'Chargement impossible',
          message: message,
          tone: AdminBannerTone.error,
          trailing: IconButton(
            onPressed: onRetry,
            tooltip: 'Réessayer',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
      ],
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({
    required this.data,
    required this.periodDays,
    required this.onPeriodChanged,
    required this.onRetry,
  });

  final _StatisticsData data;
  final int periodDays;
  final ValueChanged<int> onPeriodChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final summaryResponse =
        _asMap(data.summary.data['data']) ?? data.summary.data;
    final metrics = _collectMetrics(
      summaryResponse,
    ).where((metric) => !metric.key.startsWith('period.')).take(24).toList();
    final volumesResponse =
        _asMap(data.volumes.data['data']) ?? data.volumes.data;
    final rawVolumes = volumesResponse['volumes'] ?? volumesResponse['items'];
    final topVolumes = rawVolumes is List
        ? rawVolumes.map(_asMap).whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
    final insights = _buildInsights(metrics, topVolumes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminPageHeader(
          icon: Icons.query_stats_rounded,
          title: 'Statistiques du catalogue',
          description:
              'Vue détaillée du catalogue et de l’activité. Actualisé à '
              '${DateFormat('HH:mm').format(data.loadedAt)}.',
        ),
        const SizedBox(height: 24),
        _PeriodSelector(value: periodDays, onChanged: onPeriodChanged),
        const SizedBox(height: 28),
        const AdminSectionTitle(title: 'Vue d’ensemble'),
        const SizedBox(height: 12),
        if (data.summary.hasError)
          _SectionError(
            title: 'Résumé indisponible',
            error: data.summary.error!,
            onRetry: onRetry,
          )
        else if (metrics.isEmpty)
          const AdminStatusBanner(
            icon: Icons.info_outline_rounded,
            title: 'Aucun indicateur disponible',
            message: 'Le résumé analytics ne contient aucune valeur numérique.',
          )
        else
          _MetricGrid(metrics: metrics),
        if (insights.isNotEmpty) ...[
          const SizedBox(height: 28),
          const AdminSectionTitle(title: 'Indicateurs utiles'),
          const SizedBox(height: 12),
          _InsightGrid(insights: insights),
        ],
        const SizedBox(height: 28),
        AdminSectionTitle(
          title: 'Volumes les plus ajoutés',
          trailing: Text(
            '$periodDays derniers jours',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 12),
        if (data.volumes.hasError)
          _SectionError(
            title: 'Classement indisponible',
            error: data.volumes.error!,
            onRetry: onRetry,
          )
        else if (topVolumes.isEmpty)
          const AdminStatusBanner(
            icon: Icons.inbox_outlined,
            title: 'Aucune donnée',
            message:
                'Aucun ajout de volume n’est disponible pour cette période.',
          )
        else
          _TopVolumesCard(volumes: topVolumes),
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Text(
          'Période d’analyse',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        for (final days in const <int>[7, 30, 90])
          ChoiceChip(
            label: Text('$days jours'),
            selected: value == days,
            onSelected: (_) => onChanged(days),
          ),
      ],
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({
    required this.title,
    required this.error,
    required this.onRetry,
  });

  final String title;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AdminStatusBanner(
      icon: Icons.warning_amber_rounded,
      title: title,
      message:
          '${error.toString()} Les autres indicateurs restent utilisables.',
      tone: AdminBannerTone.warning,
      trailing: IconButton(
        onPressed: onRetry,
        tooltip: 'Réessayer',
        icon: const Icon(Icons.refresh_rounded),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<MapEntry<String, num>> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 12)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: _MetricCard(
                    label: _metricLabel(metric.key),
                    value: _formatMetric(metric.value),
                    icon: _metricIcon(metric.key),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: colors.tertiaryFixed),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Insight {
  const _Insight(this.label, this.value, this.description, this.icon);

  final String label;
  final String value;
  final String description;
  final IconData icon;
}

class _InsightGrid extends StatelessWidget {
  const _InsightGrid({required this.insights});

  final List<_Insight> insights;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 3 : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 12)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: insights
              .map(
                (insight) => SizedBox(
                  width: width,
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(insight.icon),
                      title: Text('${insight.value} · ${insight.label}'),
                      subtitle: Text(insight.description),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _TopVolumesCard extends StatelessWidget {
  const _TopVolumesCard({required this.volumes});

  final List<Map<String, dynamic>> volumes;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (var index = 0; index < volumes.length; index++) ...[
            _TopVolumeTile(rank: index + 1, data: volumes[index]),
            if (index < volumes.length - 1)
              const Divider(height: 1, indent: 68),
          ],
        ],
      ),
    );
  }
}

class _TopVolumeTile extends StatelessWidget {
  const _TopVolumeTile({required this.rank, required this.data});

  final int rank;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final volume = _asMap(data['volume']) ?? data;
    final title =
        (volume['titleFr'] ?? volume['title'] ?? data['title'] ?? 'Volume')
            .toString();
    final tomeNumber =
        volume['tomeNumber'] ?? volume['tome_number'] ?? data['tomeNumber'];
    final additions = _volumeAdditions(data);
    final details = <String>[
      if (tomeNumber != null) 'Tome $tomeNumber',
      if (additions != null) '${_formatMetric(additions)} ajout(s)',
    ];
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('$rank', style: Theme.of(context).textTheme.titleSmall),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: details.isEmpty ? null : Text(details.join(' · ')),
    );
  }
}

List<MapEntry<String, num>> _collectMetrics(
  Map<String, dynamic> data, [
  String prefix = '',
]) {
  final values = <MapEntry<String, num>>[];
  for (final entry in data.entries) {
    final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
    if (entry.value is num) {
      values.add(MapEntry(key, entry.value as num));
    } else if (entry.value is Map) {
      values.addAll(_collectMetrics(_asMap(entry.value)!, key));
    }
  }
  return values;
}

List<_Insight> _buildInsights(
  List<MapEntry<String, num>> metrics,
  List<Map<String, dynamic>> volumes,
) {
  final insights = <_Insight>[];
  final totalVolumes = _findMetric(metrics, const ['totalVolumes', 'volumes']);
  final totalSubSeries = _findMetric(metrics, const [
    'totalSubSeries',
    'subSeries',
  ]);
  final totalSeries = _findMetric(metrics, const ['totalSeries', 'series']);
  if (totalVolumes != null && totalSubSeries != null && totalSubSeries > 0) {
    insights.add(
      _Insight(
        'volumes par sous-série',
        (totalVolumes / totalSubSeries).toStringAsFixed(1),
        'Densité moyenne du catalogue.',
        Icons.auto_stories_outlined,
      ),
    );
  }
  if (totalSubSeries != null && totalSeries != null && totalSeries > 0) {
    insights.add(
      _Insight(
        'sous-séries par série',
        (totalSubSeries / totalSeries).toStringAsFixed(1),
        'Profondeur éditoriale moyenne.',
        Icons.account_tree_outlined,
      ),
    );
  }
  final additions = volumes.map(_volumeAdditions).whereType<num>().toList();
  if (additions.isNotEmpty) {
    final total = additions.fold<num>(0, (sum, value) => sum + value);
    final leaderShare = total > 0 ? additions.first / total * 100 : 0;
    insights.add(
      _Insight(
        'ajouts dans le top ${additions.length}',
        _formatMetric(total),
        'Le premier représente ${leaderShare.toStringAsFixed(1)} % du top.',
        Icons.trending_up_rounded,
      ),
    );
  }
  return insights;
}

num? _findMetric(List<MapEntry<String, num>> metrics, List<String> names) {
  for (final name in names) {
    for (final metric in metrics) {
      final leaf = metric.key.split('.').last.toLowerCase();
      if (leaf == name.toLowerCase()) return metric.value;
    }
  }
  return null;
}

num? _volumeAdditions(Map<String, dynamic> data) {
  final value =
      data['count'] ?? data['additions'] ?? data['total'] ?? data['ownedCount'];
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '');
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String _formatMetric(num value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _metricLabel(String key) {
  const labels = <String, String>{
    'users': 'Utilisateurs',
    'totalUsers': 'Utilisateurs',
    'activeUsers': 'Utilisateurs actifs',
    'newUsers': 'Nouveaux utilisateurs',
    'volumes': 'Volumes',
    'totalVolumes': 'Volumes',
    'series': 'Séries',
    'totalSeries': 'Séries',
    'subSeries': 'Sous-séries',
    'totalSubSeries': 'Sous-séries',
    'authors': 'Auteurs',
    'totalAuthors': 'Auteurs',
    'editors': 'Éditeurs',
    'totalEditors': 'Éditeurs',
    'genres': 'Genres',
    'totalGenres': 'Genres',
    'ownedVolumes': 'Volumes possédés',
    'newOwnedVolumes': 'Nouveaux volumes possédés',
    'reviews': 'Avis',
    'totalReviews': 'Avis',
    'orphanVolumes': 'Volumes orphelins',
    'missingCovers': 'Couvertures manquantes',
    'missingRelations': 'Relations manquantes',
    'invalidEans': 'EAN invalides',
    'duplicateEans': 'EAN en doublon',
    'openVolumeIssues': 'Anomalies ouvertes',
  };
  final leaf = key.split('.').last;
  final base = labels[leaf] ?? _humanize(leaf);
  if (!key.contains('.')) return base;
  final group = _humanize(key.split('.').first);
  return '$base · $group';
}

String _humanize(String value) {
  final spaced = value
      .replaceAll('_', ' ')
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
  return spaced.isEmpty
      ? value
      : '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}

IconData _metricIcon(String key) {
  final normalized = key.toLowerCase();
  if (normalized.contains('user')) return Icons.people_outline_rounded;
  if (normalized.contains('review')) return Icons.rate_review_outlined;
  if (normalized.contains('author')) return Icons.draw_outlined;
  if (normalized.contains('editor')) return Icons.business_outlined;
  if (normalized.contains('genre')) return Icons.sell_outlined;
  if (normalized.contains('missing') ||
      normalized.contains('invalid') ||
      normalized.contains('orphan') ||
      normalized.contains('duplicate') ||
      normalized.contains('issue')) {
    return Icons.warning_amber_rounded;
  }
  if (normalized.contains('serie')) return Icons.collections_bookmark_outlined;
  if (normalized.contains('volume')) return Icons.menu_book_outlined;
  return Icons.analytics_outlined;
}
