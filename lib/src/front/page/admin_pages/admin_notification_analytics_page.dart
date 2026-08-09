import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_analytics_components.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class AdminNotificationAnalyticsPage extends StatefulWidget {
  const AdminNotificationAnalyticsPage({super.key});

  @override
  State<AdminNotificationAnalyticsPage> createState() =>
      _AdminNotificationAnalyticsPageState();
}

class _AdminNotificationAnalyticsPageState
    extends State<AdminNotificationAnalyticsPage> {
  final AdminConnector _admin = AdminConnector();

  Future<Map<String, dynamic>>? _future;
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

  Future<Map<String, dynamic>> _load() {
    return _admin.getNotificationAnalytics(days: _days);
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
        title: context.localized(en: 'Notifications', fr: 'Notifications'),
        maxWidth: 680,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminPageHeader(
              icon: Icons.notifications_active_outlined,
              title: context.localized(
                en: 'Notification analytics',
                fr: 'Statistiques des notifications',
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
      title: context.localized(en: 'Notifications', fr: 'Notifications'),
      actions: [
        const AdminExportButton(resource: 'analytics-notifications'),
        IconButton(
          onPressed: _refresh,
          tooltip: context.localized(en: 'Refresh', fr: 'Actualiser'),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminPageHeader(
                  icon: Icons.notifications_active_outlined,
                  title: context.localized(
                    en: 'Notification analytics',
                    fr: 'Statistiques des notifications',
                  ),
                  description: context.localized(
                    en: 'Monitor notification sends, deliveries and opens.',
                    fr: 'Suivez l’envoi, la livraison et l’ouverture des notifications.',
                  ),
                ),
                const SizedBox(height: 20),
                AdminAnalyticsError(
                  error:
                      snapshot.error ??
                      context.localized(
                        en: 'Empty response.',
                        fr: 'Réponse vide.',
                      ),
                  onRetry: _refresh,
                ),
              ],
            );
          }
          return _NotificationAnalyticsContent(
            response: snapshot.data!,
            days: _days,
            onPeriodChanged: _changePeriod,
          );
        },
      ),
    );
  }
}

class _NotificationAnalyticsContent extends StatelessWidget {
  const _NotificationAnalyticsContent({
    required this.response,
    required this.days,
    required this.onPeriodChanged,
  });

  final Map<String, dynamic> response;
  final int days;
  final ValueChanged<int> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final data = adminAnalyticsData(response);
    final previous = adminAnalyticsPrevious(data);
    final scheduled = _metric(data, 'scheduled');
    final sent = _metric(data, 'sent');
    final delivered = _metric(data, 'delivered');
    final failed = _metric(data, 'failed');
    final opened = _metric(data, 'opened');
    final converted = _metric(data, 'converted');
    final deliveryRate =
        adminAnalyticsNumber(data, const ['rates.delivery', 'deliveryRate']) ??
        _percentage(delivered, sent);
    final openRate =
        adminAnalyticsNumber(data, const ['rates.open', 'openRate']) ??
        _percentage(opened, delivered);
    final failureRate =
        adminAnalyticsNumber(data, const ['rates.failure', 'failureRate']) ??
        _percentage(failed, sent);
    final conversionRate =
        adminAnalyticsNumber(data, const [
          'rates.conversion',
          'conversionRate',
        ]) ??
        _percentage(converted, delivered);
    final latency = _openLatency(data);
    final platforms = adminAnalyticsNumericMap(data, const [
      'breakdowns.platform',
      'byPlatform',
    ]);
    final campaigns = adminAnalyticsRecords(data, const [
      'campaigns',
      'topCampaigns',
    ]);
    num? previousMetric(String name) => adminAnalyticsNumber(
      previous,
      <String>['counts.$name', 'summary.$name', name],
    );

    String? metricDescription(String base, num? current, String name) {
      final trend = adminAnalyticsTrend(
        context,
        current,
        previousMetric(name),
      );
      return trend == null ? base : '$base · $trend';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminPageHeader(
          icon: Icons.notifications_active_outlined,
          title: context.localized(
            en: 'Notification analytics',
            fr: 'Statistiques des notifications',
          ),
          description: context.localized(
            en: 'Measure the complete journey from scheduling to opening and conversion.',
            fr: 'Mesurez le parcours complet, de la planification à l’ouverture puis à la conversion.',
          ),
        ),
        const SizedBox(height: 12),
        AdminStatusBanner(
          icon: Icons.privacy_tip_outlined,
          title: context.localized(
            en: 'Privacy-conscious measurement',
            fr: 'Mesure respectueuse de la vie privée',
          ),
          message: context.localized(
            en: 'Events must be deduplicated and aggregated. Administrator dashboards must never expose push tokens.',
            fr: 'Les événements doivent être dédupliqués et agrégés. Les tableaux administrateur ne doivent jamais exposer les tokens push.',
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
              label: context.localized(en: 'Scheduled', fr: 'Planifiées'),
              value: adminAnalyticsFormat(scheduled),
              icon: Icons.schedule_send_outlined,
              description: adminAnalyticsTrend(
                context,
                scheduled,
                previousMetric('scheduled'),
              ),
            ),
            AdminAnalyticsMetric(
              label: context.localized(en: 'Sent', fr: 'Envoyées'),
              value: adminAnalyticsFormat(sent),
              icon: Icons.send_outlined,
              description: adminAnalyticsTrend(
                context,
                sent,
                previousMetric('sent'),
              ),
            ),
            AdminAnalyticsMetric(
              label: context.localized(en: 'Delivered', fr: 'Délivrées'),
              value: adminAnalyticsFormat(delivered),
              icon: Icons.mark_email_read_outlined,
              description: metricDescription(
                context.localized(
                  en: '${adminAnalyticsFormat(deliveryRate, percentage: true)} of sends',
                  fr: '${adminAnalyticsFormat(deliveryRate, percentage: true)} des envois',
                ),
                delivered,
                'delivered',
              ),
            ),
            AdminAnalyticsMetric(
              label: context.localized(en: 'Failed', fr: 'Échouées'),
              value: adminAnalyticsFormat(failed),
              icon: Icons.error_outline_rounded,
              description: metricDescription(
                context.localized(
                  en: '${adminAnalyticsFormat(failureRate, percentage: true)} of sends',
                  fr: '${adminAnalyticsFormat(failureRate, percentage: true)} des envois',
                ),
                failed,
                'failed',
              ),
              warning: (failed ?? 0) > 0,
            ),
            AdminAnalyticsMetric(
              label: context.localized(en: 'Opened', fr: 'Ouvertes'),
              value: adminAnalyticsFormat(opened),
              icon: Icons.drafts_outlined,
              description: metricDescription(
                context.localized(
                  en: '${adminAnalyticsFormat(openRate, percentage: true)} of delivered notifications',
                  fr: '${adminAnalyticsFormat(openRate, percentage: true)} des notifications délivrées',
                ),
                opened,
                'opened',
              ),
            ),
            AdminAnalyticsMetric(
              label: context.localized(en: 'Conversions', fr: 'Conversions'),
              value: adminAnalyticsFormat(converted),
              icon: Icons.ads_click_outlined,
              description: metricDescription(
                context.localized(
                  en: '${adminAnalyticsFormat(conversionRate, percentage: true)} of delivered notifications',
                  fr: '${adminAnalyticsFormat(conversionRate, percentage: true)} des notifications délivrées',
                ),
                converted,
                'converted',
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        AdminSectionTitle(
          title: context.localized(
            en: 'Cumulative opening delay',
            fr: 'Délai d’ouverture cumulé',
          ),
        ),
        const SizedBox(height: 12),
        AdminAnalyticsBreakdownCard(
          title: context.localized(
            en: 'Percentage opened after delivery',
            fr: 'Pourcentage ouvert après la délivrance',
          ),
          values: latency,
          percentage: true,
        ),
        const SizedBox(height: 28),
        AdminSectionTitle(
          title: context.localized(en: 'Breakdown', fr: 'Répartition'),
        ),
        const SizedBox(height: 12),
        AdminAnalyticsBreakdownCard(
          title: context.localized(
            en: 'Notifications delivered by platform',
            fr: 'Notifications délivrées par plateforme',
          ),
          values: platforms,
        ),
        const SizedBox(height: 28),
        AdminSectionTitle(
          title: context.localized(en: 'Campaigns', fr: 'Campagnes'),
        ),
        const SizedBox(height: 12),
        _CampaignTable(campaigns: campaigns),
      ],
    );
  }

  num? _metric(Map<String, dynamic> data, String name) {
    return adminAnalyticsNumber(data, <String>[
      'counts.$name',
      'summary.$name',
      name,
    ]);
  }

  num? _percentage(num? numerator, num? denominator) {
    if (numerator == null || denominator == null || denominator <= 0) {
      return null;
    }
    return numerator / denominator * 100;
  }

  Map<String, num> _openLatency(Map<String, dynamic> data) {
    final raw = adminAnalyticsNumericMap(data, const [
      'openLatencyCumulative',
      'openingLatency',
      'rates.openByDelay',
    ]);
    const aliases = <String, List<String>>{
      'T+1 min': ['1m', 't1m', '1min'],
      'T+5 min': ['5m', 't5m', '5min'],
      'T+15 min': ['15m', 't15m', '15min'],
      'T+30 min': ['30m', 't30m', '30min'],
      'T+1 h': ['1h', 't1h', '60m'],
      'T+6 h': ['6h', 't6h', '360m'],
      'T+24 h': ['24h', 't24h', '1d'],
      'T+7 j': ['7d', 't7d', '7j'],
    };
    return <String, num>{
      for (final entry in aliases.entries)
        if (_firstValue(raw, entry.value) case final value?) entry.key: value,
    };
  }

  num? _firstValue(Map<String, num> values, Iterable<String> keys) {
    for (final key in keys) {
      if (values[key] case final value?) return value;
    }
    return null;
  }
}

class _CampaignTable extends StatelessWidget {
  const _CampaignTable({required this.campaigns});

  final List<Map<String, dynamic>> campaigns;

  @override
  Widget build(BuildContext context) {
    if (campaigns.isEmpty) {
      return AdminStatusBanner(
        icon: Icons.campaign_outlined,
        title: context.localized(
          en: 'No measured campaigns',
          fr: 'Aucune campagne mesurée',
        ),
        message: context.localized(
          en: 'Campaigns will appear here when events are associated with a campaignId.',
          fr: 'Les campagnes apparaîtront ici lorsque les événements seront associés à un campaignId.',
        ),
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(
              label: Text(context.localized(en: 'Campaign', fr: 'Campagne')),
            ),
            DataColumn(
              label: Text(context.localized(en: 'Sent', fr: 'Envoyées')),
              numeric: true,
            ),
            DataColumn(
              label: Text(context.localized(en: 'Delivered', fr: 'Délivrées')),
              numeric: true,
            ),
            DataColumn(
              label: Text(context.localized(en: 'Opened', fr: 'Ouvertes')),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                context.localized(en: 'Open rate', fr: 'Taux d’ouverture'),
              ),
              numeric: true,
            ),
          ],
          rows: campaigns.take(25).map((campaign) {
            final name =
                campaign['name'] ?? campaign['title'] ?? campaign['id'] ?? '—';
            final sent = _number(campaign['sent']);
            final delivered = _number(campaign['delivered']);
            final opened = _number(campaign['opened']);
            final rate =
                _number(campaign['openRate']) ??
                (opened != null && delivered != null && delivered > 0
                    ? opened / delivered * 100
                    : null);
            return DataRow(
              cells: [
                DataCell(Text(name.toString())),
                DataCell(Text(adminAnalyticsFormat(sent))),
                DataCell(Text(adminAnalyticsFormat(delivered))),
                DataCell(Text(adminAnalyticsFormat(opened))),
                DataCell(
                  Text(adminAnalyticsFormat(rate, percentage: true)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  num? _number(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '');
  }
}
