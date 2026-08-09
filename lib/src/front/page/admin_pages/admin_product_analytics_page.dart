import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_analytics_components.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class AdminProductAnalyticsPage extends StatefulWidget {
  const AdminProductAnalyticsPage({super.key});

  @override
  State<AdminProductAnalyticsPage> createState() =>
      _AdminProductAnalyticsPageState();
}

class _AdminProductAnalyticsPageState extends State<AdminProductAnalyticsPage> {
  final AdminConnector _admin = AdminConnector();

  Future<_ProductAnalyticsData>? _future;
  bool _initialized = false;
  int _days = 30;

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
      if (_admin.isLoggedIn()) _future = _load();
    });
  }

  Future<_ProductAnalyticsData> _load() async {
    final results = await Future.wait<_AnalyticsRequest>([
      _capture(_admin.getProductAnalytics(days: _days)),
      _capture(_admin.getSummary(days: _days)),
    ]);
    return _ProductAnalyticsData(product: results[0], summary: results[1]);
  }

  Future<_AnalyticsRequest> _capture(
    Future<Map<String, dynamic>> request,
  ) async {
    try {
      return _AnalyticsRequest(data: await request);
    } catch (error) {
      return _AnalyticsRequest(error: error);
    }
  }

  void _refresh() => setState(() => _future = _load());

  void _changePeriod(int days) {
    if (_days == days) return;
    setState(() {
      _days = days;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_admin.isLoggedIn()) {
      return AdminPageScaffold(
        title: context.localized(en: 'Product usage', fr: 'Usage produit'),
        maxWidth: 680,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminPageHeader(
              icon: Icons.insights_outlined,
              title: context.localized(
                en: 'Usage analytics',
                fr: 'Statistiques d’usage',
              ),
              description: context.localized(
                en: 'A key containing analytics.read is required.',
                fr: 'Une clé contenant analytics.read est nécessaire.',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => pushOrGo(context, '/admin/admin_login'),
              icon: const Icon(Icons.login_rounded),
              label: Text(
                context.localized(
                  en: 'Sign in as admin',
                  fr: 'Se connecter en admin',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AdminPageScaffold(
      title: context.localized(en: 'Product usage', fr: 'Usage produit'),
      actions: [
        const AdminExportButton(resource: 'analytics-product'),
        IconButton(
          onPressed: _refresh,
          tooltip: context.localized(en: 'Refresh', fr: 'Actualiser'),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: FutureBuilder<_ProductAnalyticsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return AdminAnalyticsError(
              error:
                  snapshot.error ??
                  context.localized(en: 'Empty response.', fr: 'Réponse vide.'),
              onRetry: _refresh,
            );
          }
          return _ProductAnalyticsContent(
            data: data,
            days: _days,
            onPeriodChanged: _changePeriod,
            onRetry: _refresh,
          );
        },
      ),
    );
  }
}

class _AnalyticsRequest {
  const _AnalyticsRequest({
    this.data = const <String, dynamic>{},
    this.error,
  });

  final Map<String, dynamic> data;
  final Object? error;
}

class _ProductAnalyticsData {
  const _ProductAnalyticsData({required this.product, required this.summary});

  final _AnalyticsRequest product;
  final _AnalyticsRequest summary;
}

class _ProductAnalyticsContent extends StatelessWidget {
  const _ProductAnalyticsContent({
    required this.data,
    required this.days,
    required this.onPeriodChanged,
    required this.onRetry,
  });

  final _ProductAnalyticsData data;
  final int days;
  final ValueChanged<int> onPeriodChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final product = adminAnalyticsData(data.product.data);
    final summary = adminAnalyticsData(data.summary.data);
    final previous = adminAnalyticsPrevious(product);
    num? metric(List<String> productPaths, List<String> summaryPaths) {
      return adminAnalyticsNumber(product, productPaths) ??
          adminAnalyticsNumber(summary, summaryPaths);
    }

    num? previousMetric(List<String> paths) {
      return adminAnalyticsNumber(previous, paths);
    }

    final activeUsers = metric(
      const ['users.active', 'activeUsers', 'activity.activeUsers'],
      const ['activity.activeUsers'],
    );
    final totalUsers = metric(
      const ['users.total', 'totalUsers', 'activity.totalUsers'],
      const ['activity.totalUsers'],
    );
    final eventCount = metric(
      const ['events.total', 'totalEvents', 'activity.totalEvents'],
      const ['activity.totalEvents'],
    );
    final sessions = metric(
      const ['sessions.total', 'totalSessions'],
      const <String>[],
    );
    final pageViews = metric(
      const ['pageViews', 'events.pageViews'],
      const <String>[],
    );
    final searches = metric(
      const ['searches', 'events.searches'],
      const <String>[],
    );
    final errorRate = metric(
      const ['rates.error', 'errorRate'],
      const <String>[],
    );
    final latency = metric(
      const ['performance.avgLatencyMs', 'avgLatencyMs'],
      const <String>[],
    );
    final retention = adminAnalyticsNumericMap(product, const [
      'retention',
      'retentionRates',
    ]);
    final events = adminAnalyticsNumericMap(product, const [
      'events.byName',
      'eventsByName',
    ]);
    final platforms = adminAnalyticsNumericMap(product, const [
      'users.byPlatform',
      'eventsBySource',
      'platforms',
    ]);
    final versions = adminAnalyticsNumericMap(product, const [
      'users.byVersion',
      'versions',
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminPageHeader(
          icon: Icons.insights_outlined,
          title: context.localized(
            en: 'Product usage analytics',
            fr: 'Statistiques d’usage produit',
          ),
          description: context.localized(
            en: 'Understand adoption, engagement, retention and experience quality without exposing personal data.',
            fr: 'Comprenez l’adoption, l’engagement, la rétention et la qualité d’expérience sans exposer de données personnelles.',
          ),
        ),
        const SizedBox(height: 20),
        AdminAnalyticsPeriodSelector(
          value: days,
          onChanged: onPeriodChanged,
        ),
        const SizedBox(height: 24),
        AdminAnalyticsMetricGrid(
          metrics: [
            AdminAnalyticsMetric(
              label: context.localized(
                en: 'Active users',
                fr: 'Utilisateurs actifs',
              ),
              value: adminAnalyticsFormat(activeUsers),
              icon: Icons.people_outline_rounded,
              description: adminAnalyticsTrend(
                context,
                activeUsers,
                previousMetric(const [
                  'users.active',
                  'activeUsers',
                  'activity.activeUsers',
                ]),
              ),
            ),
            AdminAnalyticsMetric(
              label: context.localized(
                en: 'Total users',
                fr: 'Utilisateurs totaux',
              ),
              value: adminAnalyticsFormat(totalUsers),
              icon: Icons.group_outlined,
              description: adminAnalyticsTrend(
                context,
                totalUsers,
                previousMetric(const [
                  'users.total',
                  'totalUsers',
                  'activity.totalUsers',
                ]),
              ),
            ),
            AdminAnalyticsMetric(
              label: context.localized(en: 'Sessions', fr: 'Sessions'),
              value: adminAnalyticsFormat(sessions),
              icon: Icons.timer_outlined,
              description: adminAnalyticsTrend(
                context,
                sessions,
                previousMetric(const ['sessions.total', 'totalSessions']),
              ),
            ),
            AdminAnalyticsMetric(
              label: context.localized(en: 'Events', fr: 'Événements'),
              value: adminAnalyticsFormat(eventCount),
              icon: Icons.bolt_outlined,
              description: adminAnalyticsTrend(
                context,
                eventCount,
                previousMetric(const [
                  'events.total',
                  'totalEvents',
                  'activity.totalEvents',
                ]),
              ),
            ),
            AdminAnalyticsMetric(
              label: context.localized(
                en: 'Page views',
                fr: 'Pages consultées',
              ),
              value: adminAnalyticsFormat(pageViews),
              icon: Icons.visibility_outlined,
              description: adminAnalyticsTrend(
                context,
                pageViews,
                previousMetric(const ['pageViews', 'events.pageViews']),
              ),
            ),
            AdminAnalyticsMetric(
              label: context.localized(en: 'Searches', fr: 'Recherches'),
              value: adminAnalyticsFormat(searches),
              icon: Icons.search_rounded,
              description: adminAnalyticsTrend(
                context,
                searches,
                previousMetric(const ['searches', 'events.searches']),
              ),
            ),
            AdminAnalyticsMetric(
              label: context.localized(en: 'Error rate', fr: 'Taux d’erreur'),
              value: adminAnalyticsFormat(errorRate, percentage: true),
              icon: Icons.error_outline_rounded,
              warning: (errorRate ?? 0) > 2,
            ),
            AdminAnalyticsMetric(
              label: context.localized(
                en: 'Average latency',
                fr: 'Latence moyenne',
              ),
              value: latency == null
                  ? '—'
                  : '${adminAnalyticsFormat(latency)} ms',
              icon: Icons.speed_rounded,
            ),
          ],
        ),
        if (data.product.error != null) ...[
          const SizedBox(height: 20),
          AdminAnalyticsError(error: data.product.error!, onRetry: onRetry),
        ],
        const SizedBox(height: 28),
        AdminSectionTitle(
          title: context.localized(en: 'Retention', fr: 'Rétention'),
        ),
        const SizedBox(height: 12),
        AdminAnalyticsBreakdownCard(
          title: context.localized(
            en: 'Users returning after their first use',
            fr: 'Utilisateurs revenus après leur première utilisation',
          ),
          values: retention,
          percentage: true,
        ),
        const SizedBox(height: 28),
        AdminSectionTitle(
          title: context.localized(
            en: 'Activity breakdown',
            fr: 'Répartition de l’activité',
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 760
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: width,
                  child: AdminAnalyticsBreakdownCard(
                    title: context.localized(
                      en: 'Top events',
                      fr: 'Événements principaux',
                    ),
                    values: events,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: AdminAnalyticsBreakdownCard(
                    title: context.localized(
                      en: 'Platforms',
                      fr: 'Plateformes',
                    ),
                    values: platforms,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: AdminAnalyticsBreakdownCard(
                    title: context.localized(
                      en: 'Application versions',
                      fr: 'Versions de l’application',
                    ),
                    values: versions,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
