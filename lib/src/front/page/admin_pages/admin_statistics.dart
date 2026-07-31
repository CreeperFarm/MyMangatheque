import 'package:flutter/material.dart';
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

  Future<Map<String, dynamic>>? _dataFuture;
  bool _initialized = false;

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

  Future<Map<String, dynamic>> _loadData() async {
    final results = await Future.wait<Map<String, dynamic>>([
      _admin.getSummary(),
      _admin.getMostAddedVolumes(),
    ]);
    return <String, dynamic>{'summary': results[0], 'volumes': results[1]};
  }

  void _refresh() {
    setState(() {
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
      child: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
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
                  message: snapshot.error.toString(),
                  tone: AdminBannerTone.error,
                  trailing: IconButton(
                    onPressed: _refresh,
                    tooltip: 'Réessayer',
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ),
              ],
            );
          }

          return _StatisticsContent(data: snapshot.data ?? const {});
        },
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final summaryResponse = _asMap(data['summary']) ?? const {};
    final summaryData = _asMap(summaryResponse['data']) ?? summaryResponse;
    final metrics = summaryData.entries
        .where((entry) => entry.value is num)
        .take(8)
        .toList();

    final volumesResponse = _asMap(data['volumes']) ?? const {};
    final volumesData = _asMap(volumesResponse['data']) ?? volumesResponse;
    final rawVolumes = volumesData['volumes'];
    final topVolumes = rawVolumes is List
        ? rawVolumes.map(_asMap).whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AdminPageHeader(
          icon: Icons.query_stats_rounded,
          title: 'Statistiques du catalogue',
          description:
              'Vue synthétique de l’activité et des volumes les plus ajoutés.',
        ),
        const SizedBox(height: 28),
        const AdminSectionTitle(title: 'Vue d’ensemble'),
        const SizedBox(height: 12),
        if (metrics.isEmpty)
          const AdminStatusBanner(
            icon: Icons.info_outline_rounded,
            title: 'Aucun indicateur disponible',
            message: 'Le résumé analytics ne contient aucune valeur numérique.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 560
                  ? 2
                  : 1;
              final cardWidth =
                  (constraints.maxWidth - ((columns - 1) * 12)) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: metrics
                    .map(
                      (metric) => SizedBox(
                        width: cardWidth,
                        child: _MetricCard(
                          label: _metricLabel(metric.key),
                          value: _formatMetric(metric.value as num),
                          icon: _metricIcon(metric.key),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        const SizedBox(height: 28),
        AdminSectionTitle(
          title: 'Volumes les plus ajoutés',
          trailing: Text(
            '30 derniers jours',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 12),
        if (topVolumes.isEmpty)
          const AdminStatusBanner(
            icon: Icons.inbox_outlined,
            title: 'Aucune donnée',
            message:
                'Aucun ajout de volume n’est disponible pour cette période.',
          )
        else
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                for (var index = 0; index < topVolumes.length; index++) ...[
                  _TopVolumeTile(rank: index + 1, data: topVolumes[index]),
                  if (index < topVolumes.length - 1)
                    const Divider(height: 1, indent: 68),
                ],
              ],
            ),
          ),
      ],
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
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.tertiaryFixed),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
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
    final additions =
        data['count'] ??
        data['additions'] ??
        data['total'] ??
        data['ownedCount'];
    final details = <String>[
      if (tomeNumber != null) 'Tome $tomeNumber',
      if (additions != null) '$additions ajout(s)',
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
        child: Text(
          '$rank',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: details.isEmpty ? null : Text(details.join(' · ')),
    );
  }
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
    'volumes': 'Volumes',
    'totalVolumes': 'Volumes',
    'series': 'Séries',
    'totalSeries': 'Séries',
    'subSeries': 'Sous-séries',
    'ownedVolumes': 'Volumes possédés',
    'reviews': 'Avis',
    'totalReviews': 'Avis',
  };
  if (labels[key] case final label?) return label;
  final spaced = key
      .replaceAll('_', ' ')
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match[1]} ${match[2]}',
      );
  return spaced.isEmpty
      ? key
      : '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}

IconData _metricIcon(String key) {
  final normalized = key.toLowerCase();
  if (normalized.contains('user')) return Icons.people_outline_rounded;
  if (normalized.contains('review')) return Icons.rate_review_outlined;
  if (normalized.contains('serie')) return Icons.collections_bookmark_outlined;
  if (normalized.contains('volume')) return Icons.menu_book_outlined;
  return Icons.analytics_outlined;
}
