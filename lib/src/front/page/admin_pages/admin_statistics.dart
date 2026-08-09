import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:package_info_plus/package_info_plus.dart';

String _statsT(String en, String fr) =>
    RuntimeLocalization.text(en: en, fr: fr);

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
      _capture(_admin.getAnalyticsHealth()),
      _capture(_admin.getSummary(days: _periodDays)),
      _capture(_admin.getMostAddedVolumes(days: _periodDays, limit: 10)),
      _capture(_admin.getMostWishlistedMangas(days: _periodDays, limit: 10)),
      _capture(_loadAppInformation()),
    ]);
    return _StatisticsData(
      health: results[0],
      summary: results[1],
      volumes: results[2],
      wishlist: results[3],
      appInformation: results[4],
      loadedAt: DateTime.now(),
    );
  }

  Future<Map<String, dynamic>> _loadAppInformation() async {
    final info = await PackageInfo.fromPlatform();
    return <String, dynamic>{
      'name': info.appName,
      'packageName': info.packageName,
      'version': info.version,
      'buildNumber': info.buildNumber,
    };
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
        title: _statsT('Analytics', 'Statistiques'),
        maxWidth: 680,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminPageHeader(
              icon: Icons.query_stats_rounded,
              title: _statsT(
                'Catalogue analytics',
                'Statistiques du catalogue',
              ),
              description: _statsT(
                'An authorized key is required to view this data.',
                'Une clé autorisée est nécessaire pour consulter ces données.',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => pushOrGo(context, '/admin/admin_login'),
              icon: const Icon(Icons.login_rounded),
              label: Text(_statsT('Sign in as admin', 'Se connecter en admin')),
            ),
          ],
        ),
      );
    }

    return AdminPageScaffold(
      title: _statsT('Overview', 'Vue générale'),
      actions: [
        const AdminExportButton(resource: 'analytics-summary'),
        IconButton(
          onPressed: _refresh,
          tooltip: _statsT('Refresh', 'Actualiser'),
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
              message: snapshot.error == null
                  ? _statsT('Empty response.', 'Réponse vide.')
                  : redactSensitiveText(snapshot.error),
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
    required this.health,
    required this.summary,
    required this.volumes,
    required this.wishlist,
    required this.appInformation,
    required this.loadedAt,
  });

  final _StatisticsSection health;
  final _StatisticsSection summary;
  final _StatisticsSection volumes;
  final _StatisticsSection wishlist;
  final _StatisticsSection appInformation;
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
        AdminPageHeader(
          icon: Icons.query_stats_rounded,
          title: _statsT('Catalogue analytics', 'Statistiques du catalogue'),
          description: _statsT(
            'Metrics could not be loaded.',
            'Les indicateurs n’ont pas pu être chargés.',
          ),
        ),
        const SizedBox(height: 20),
        AdminStatusBanner(
          icon: Icons.cloud_off_outlined,
          title: _statsT('Unable to load', 'Chargement impossible'),
          message: message,
          tone: AdminBannerTone.error,
          trailing: IconButton(
            onPressed: onRetry,
            tooltip: _statsT('Retry', 'Réessayer'),
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
    final wishlistResponse =
        _asMap(data.wishlist.data['data']) ?? data.wishlist.data;
    final rawWishlist = wishlistResponse['mangas'] ?? wishlistResponse['items'];
    final topWishlist = rawWishlist is List
        ? rawWishlist.map(_asMap).whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
    final insights = _buildInsights(metrics, topVolumes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminPageHeader(
          icon: Icons.query_stats_rounded,
          title: _statsT('General dashboard', 'Tableau de bord général'),
          description: _statsT(
            'Consolidated catalogue, activity and service view. Updated at ${DateFormat('HH:mm').format(data.loadedAt)}.',
            'Vue consolidée du catalogue, de l’activité et des services. Actualisé à ${DateFormat('HH:mm').format(data.loadedAt)}.',
          ),
        ),
        const SizedBox(height: 16),
        _ServiceStatusCard(data: data),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => pushOrGo(context, '/admin/analytics/product'),
              icon: const Icon(Icons.insights_outlined),
              label: Text(_statsT('Product usage', 'Usage produit')),
            ),
            OutlinedButton.icon(
              onPressed: () => pushOrGo(
                context,
                '/admin/analytics/notifications',
              ),
              icon: const Icon(Icons.notifications_active_outlined),
              label: Text(_statsT('Notifications', 'Notifications')),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _PeriodSelector(value: periodDays, onChanged: onPeriodChanged),
        const SizedBox(height: 28),
        AdminSectionTitle(title: _statsT('Overview', 'Vue d’ensemble')),
        const SizedBox(height: 12),
        if (data.summary.hasError)
          _SectionError(
            title: _statsT('Summary unavailable', 'Résumé indisponible'),
            error: data.summary.error!,
            onRetry: onRetry,
          )
        else if (metrics.isEmpty)
          AdminStatusBanner(
            icon: Icons.info_outline_rounded,
            title: _statsT(
              'No metrics available',
              'Aucun indicateur disponible',
            ),
            message: _statsT(
              'The analytics summary contains no numeric values.',
              'Le résumé analytics ne contient aucune valeur numérique.',
            ),
          )
        else
          _MetricGrid(metrics: metrics),
        if (insights.isNotEmpty) ...[
          const SizedBox(height: 28),
          AdminSectionTitle(
            title: _statsT('Useful metrics', 'Indicateurs utiles'),
          ),
          const SizedBox(height: 12),
          _InsightGrid(insights: insights),
        ],
        const SizedBox(height: 28),
        AdminSectionTitle(
          title: _statsT('Most added volumes', 'Volumes les plus ajoutés'),
          trailing: Text(
            _statsT('Last $periodDays days', '$periodDays derniers jours'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 12),
        if (data.volumes.hasError)
          _SectionError(
            title: _statsT('Ranking unavailable', 'Classement indisponible'),
            error: data.volumes.error!,
            onRetry: onRetry,
          )
        else if (topVolumes.isEmpty)
          AdminStatusBanner(
            icon: Icons.inbox_outlined,
            title: _statsT('No data', 'Aucune donnée'),
            message: _statsT(
              'No volume additions are available for this period.',
              'Aucun ajout de volume n’est disponible pour cette période.',
            ),
          )
        else
          _TopVolumesCard(volumes: topVolumes),
        const SizedBox(height: 28),
        AdminSectionTitle(
          title: _statsT(
            'Most wishlisted manga',
            'Mangas les plus ajoutés aux envies',
          ),
          trailing: Text(
            _statsT('Last $periodDays days', '$periodDays derniers jours'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 12),
        if (data.wishlist.hasError)
          _SectionError(
            title: _statsT(
              'Wish-list ranking unavailable',
              'Classement des envies indisponible',
            ),
            error: data.wishlist.error!,
            onRetry: onRetry,
          )
        else if (topWishlist.isEmpty)
          AdminStatusBanner(
            icon: Icons.bookmark_border_rounded,
            title: _statsT('No data', 'Aucune donnée'),
            message: _statsT(
              'No wish-list additions are available for this period.',
              'Aucun ajout à une liste d’envies n’est disponible pour cette période.',
            ),
          )
        else
          _TopWishlistCard(items: topWishlist),
      ],
    );
  }
}

class _ServiceStatusCard extends StatelessWidget {
  const _ServiceStatusCard({required this.data});

  final _StatisticsData data;

  @override
  Widget build(BuildContext context) {
    final healthData = _asMap(data.health.data['data']);
    final analytics = _asMap(healthData?['analytics']);
    final serviceHealthy = !data.health.hasError && analytics?['ok'] == true;
    final summaryError = data.summary.error;
    final permissionError =
        summaryError is AdminApiException &&
        (summaryError.statusCode == 401 || summaryError.statusCode == 403);
    final app = data.appInformation.data;
    final version = app['version']?.toString() ?? '';
    final build = app['buildNumber']?.toString() ?? '';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            _StatusItem(
              icon: serviceHealthy
                  ? Icons.cloud_done_outlined
                  : Icons.cloud_off_outlined,
              label: _statsT('Analytics service', 'Service analytics'),
              value: serviceHealthy
                  ? _statsT('Operational', 'Opérationnel')
                  : _statsT('Unavailable', 'Indisponible'),
              isError: !serviceHealthy,
            ),
            _StatusItem(
              icon: permissionError
                  ? Icons.lock_outline_rounded
                  : Icons.verified_user_outlined,
              label: _statsT('Data access', 'Accès aux données'),
              value: permissionError
                  ? _statsT(
                      'analytics.read permission required',
                      'Permission analytics.read requise',
                    )
                  : data.summary.hasError
                  ? _statsT('Read error', 'Erreur de lecture')
                  : _statsT('Authorized', 'Autorisé'),
              isError: data.summary.hasError,
            ),
            _StatusItem(
              icon: Icons.info_outline_rounded,
              label: _statsT('Displayed version', 'Version affichée'),
              value: version.isEmpty
                  ? _statsT('Unknown', 'Inconnue')
                  : '$version${build.isEmpty ? '' : ' ($build)'}',
              isError: data.appInformation.hasError,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isError,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 210),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isError ? colors.error : colors.primary),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
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
          _statsT('Analysis period', 'Période d’analyse'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        for (final days in const <int>[7, 30, 90])
          ChoiceChip(
            label: Text(_statsT('$days days', '$days jours')),
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
    final apiError = error is AdminApiException
        ? error as AdminApiException
        : null;
    final requiresAuthentication =
        apiError?.statusCode == 401 || apiError?.statusCode == 403;
    return AdminStatusBanner(
      icon: requiresAuthentication
          ? Icons.lock_outline_rounded
          : Icons.warning_amber_rounded,
      title: title,
      message: requiresAuthentication
          ? _statsT(
              '${redactSensitiveText(error)} Use a key explicitly containing the analytics.read permission.',
              '${redactSensitiveText(error)} Utilisez une clé contenant explicitement la permission analytics.read.',
            )
          : _statsT(
              '${redactSensitiveText(error)} Other metrics remain available.',
              '${redactSensitiveText(error)} Les autres indicateurs restent utilisables.',
            ),
      tone: AdminBannerTone.warning,
      trailing: IconButton(
        onPressed: requiresAuthentication
            ? () => pushOrGo(context, '/admin/admin_login')
            : onRetry,
        tooltip: requiresAuthentication
            ? _statsT('Change key', 'Changer de clé')
            : _statsT('Retry', 'Réessayer'),
        icon: Icon(
          requiresAuthentication ? Icons.key_rounded : Icons.refresh_rounded,
        ),
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

class _TopWishlistCard extends StatelessWidget {
  const _TopWishlistCard({required this.items});

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(
                (items[index]['mangaTitle'] ??
                        items[index]['title'] ??
                        items[index]['mangaId'] ??
                        _statsT('Manga', 'Manga'))
                    .toString(),
              ),
              subtitle: items[index]['mangaId'] == null
                  ? null
                  : Text(
                      _statsT(
                        'ID: ${items[index]['mangaId']}',
                        'ID : ${items[index]['mangaId']}',
                      ),
                    ),
              trailing: Text(
                _statsT(
                  '${_formatMetric(_volumeAdditions(items[index]) ?? 0)} addition(s)',
                  '${_formatMetric(_volumeAdditions(items[index]) ?? 0)} ajout(s)',
                ),
              ),
            ),
            if (index < items.length - 1) const Divider(height: 1),
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
        volume['tomeNumber'] ??
        volume['tome_number'] ??
        data['tomeNumber'] ??
        data['tome'];
    final additions = _volumeAdditions(data);
    final details = <String>[
      if (tomeNumber != null) _statsT('Volume $tomeNumber', 'Tome $tomeNumber'),
      if (additions != null)
        _statsT(
          '${_formatMetric(additions)} addition(s)',
          '${_formatMetric(additions)} ajout(s)',
        ),
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
        _statsT('volumes per sub-series', 'volumes par sous-série'),
        (totalVolumes / totalSubSeries).toStringAsFixed(1),
        _statsT('Average catalogue density.', 'Densité moyenne du catalogue.'),
        Icons.auto_stories_outlined,
      ),
    );
  }
  if (totalSubSeries != null && totalSeries != null && totalSeries > 0) {
    insights.add(
      _Insight(
        _statsT('sub-series per series', 'sous-séries par série'),
        (totalSubSeries / totalSeries).toStringAsFixed(1),
        _statsT('Average editorial depth.', 'Profondeur éditoriale moyenne.'),
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
        _statsT(
          'additions in the top ${additions.length}',
          'ajouts dans le top ${additions.length}',
        ),
        _formatMetric(total),
        _statsT(
          'The leader represents ${leaderShare.toStringAsFixed(1)}% of the top.',
          'Le premier représente ${leaderShare.toStringAsFixed(1)} % du top.',
        ),
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
  final labels = <String, String>{
    'users': _statsT('Users', 'Utilisateurs'),
    'totalUsers': _statsT('Users', 'Utilisateurs'),
    'activeUsers': _statsT('Active users', 'Utilisateurs actifs'),
    'newUsers': _statsT('New users', 'Nouveaux utilisateurs'),
    'volumes': _statsT('Volumes', 'Volumes'),
    'totalVolumes': _statsT('Volumes', 'Volumes'),
    'series': _statsT('Series', 'Séries'),
    'totalSeries': _statsT('Series', 'Séries'),
    'subSeries': _statsT('Sub-series', 'Sous-séries'),
    'totalSubSeries': _statsT('Sub-series', 'Sous-séries'),
    'authors': _statsT('Authors', 'Auteurs'),
    'totalAuthors': _statsT('Authors', 'Auteurs'),
    'editors': _statsT('Publishers', 'Éditeurs'),
    'totalEditors': _statsT('Publishers', 'Éditeurs'),
    'genres': _statsT('Genres', 'Genres'),
    'totalGenres': _statsT('Genres', 'Genres'),
    'ownedVolumes': _statsT('Owned volumes', 'Volumes possédés'),
    'newOwnedVolumes': _statsT(
      'New owned volumes',
      'Nouveaux volumes possédés',
    ),
    'reviews': _statsT('Reviews', 'Avis'),
    'totalReviews': _statsT('Reviews', 'Avis'),
    'orphanVolumes': _statsT('Orphan volumes', 'Volumes orphelins'),
    'missingCovers': _statsT('Missing covers', 'Couvertures manquantes'),
    'missingRelations': _statsT(
      'Missing relationships',
      'Relations manquantes',
    ),
    'invalidEans': _statsT('Invalid EANs', 'EAN invalides'),
    'duplicateEans': _statsT('Duplicate EANs', 'EAN en doublon'),
    'openVolumeIssues': _statsT('Open issues', 'Anomalies ouvertes'),
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
