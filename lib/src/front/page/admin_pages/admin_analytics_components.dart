import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

Map<String, dynamic>? adminAnalyticsMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

Map<String, dynamic> adminAnalyticsData(Map<String, dynamic> response) {
  return adminAnalyticsMap(response['data']) ?? response;
}

Map<String, dynamic> adminAnalyticsPrevious(Map<String, dynamic> data) {
  final comparison = adminAnalyticsMap(data['comparison']);
  return adminAnalyticsMap(data['previous']) ??
      adminAnalyticsMap(data['previousPeriod']) ??
      adminAnalyticsMap(comparison?['previous']) ??
      const <String, dynamic>{};
}

dynamic adminAnalyticsValue(Map<String, dynamic> data, String path) {
  dynamic current = data;
  for (final part in path.split('.')) {
    final map = adminAnalyticsMap(current);
    if (map == null || !map.containsKey(part)) return null;
    current = map[part];
  }
  return current;
}

num? adminAnalyticsNumber(
  Map<String, dynamic> data,
  Iterable<String> paths,
) {
  for (final path in paths) {
    final value = adminAnalyticsValue(data, path);
    if (value is num) return value;
    final parsed = num.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return null;
}

List<Map<String, dynamic>> adminAnalyticsRecords(
  Map<String, dynamic> data,
  Iterable<String> paths,
) {
  for (final path in paths) {
    final value = adminAnalyticsValue(data, path);
    if (value is List) {
      return value
          .map(adminAnalyticsMap)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
  }
  return const <Map<String, dynamic>>[];
}

Map<String, num> adminAnalyticsNumericMap(
  Map<String, dynamic> data,
  Iterable<String> paths,
) {
  for (final path in paths) {
    final value = adminAnalyticsMap(adminAnalyticsValue(data, path));
    if (value == null) continue;
    return <String, num>{
      for (final entry in value.entries)
        if (entry.value is num)
          entry.key: entry.value as num
        else if (num.tryParse(entry.value?.toString() ?? '') case final parsed?)
          entry.key: parsed,
    };
  }
  return const <String, num>{};
}

String adminAnalyticsFormat(num? value, {bool percentage = false}) {
  if (value == null) return '—';
  final text = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
  return percentage ? '$text %' : text;
}

String? adminAnalyticsTrend(
  BuildContext context,
  num? current,
  num? previous,
) {
  if (current == null || previous == null) return null;
  if (previous == 0) {
    if (current == 0) {
      return context.localized(
        en: 'Stable vs previous period',
        fr: 'Stable par rapport à la période précédente',
      );
    }
    return context.localized(
      en: 'New in this period',
      fr: 'Nouveau sur cette période',
    );
  }
  final delta = (current - previous) / previous.abs() * 100;
  final prefix = delta > 0 ? '+' : '';
  return context.localized(
    en: '$prefix${delta.toStringAsFixed(1)}% vs previous period',
    fr: '$prefix${delta.toStringAsFixed(1)} % par rapport à la période précédente',
  );
}

class AdminAnalyticsMetric {
  const AdminAnalyticsMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.description,
    this.warning = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? description;
  final bool warning;
}

class AdminAnalyticsMetricGrid extends StatelessWidget {
  const AdminAnalyticsMetricGrid({required this.metrics, super.key});

  final List<AdminAnalyticsMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 950
            ? 4
            : constraints.maxWidth >= 620
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
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            metric.icon,
                            color: metric.warning
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  metric.value,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(metric.label),
                                if (metric.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    metric.description!,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
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

class AdminAnalyticsPeriodSelector extends StatelessWidget {
  const AdminAnalyticsPeriodSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          context.localized(en: 'Period', fr: 'Période'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        for (final days in const <int>[7, 30, 90, 365])
          ChoiceChip(
            label: Text(
              context.localized(en: '$days days', fr: '$days jours'),
            ),
            selected: days == value,
            onSelected: (_) => onChanged(days),
          ),
      ],
    );
  }
}

class AdminAnalyticsBreakdownCard extends StatelessWidget {
  const AdminAnalyticsBreakdownCard({
    required this.title,
    required this.values,
    this.percentage = false,
    super.key,
  });

  final String title;
  final Map<String, num> values;
  final bool percentage;

  @override
  Widget build(BuildContext context) {
    final entries = values.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maximum = entries.isEmpty
        ? 0.0
        : entries
              .map((entry) => entry.value.toDouble())
              .reduce(
                (left, right) => left > right ? left : right,
              );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            if (entries.isEmpty)
              Text(
                context.localized(
                  en: 'No data available.',
                  fr: 'Aucune donnée disponible.',
                ),
              )
            else
              for (final entry in entries.take(12)) ...[
                Row(
                  children: [
                    Expanded(child: Text(_humanizeAnalyticsLabel(entry.key))),
                    Text(
                      adminAnalyticsFormat(
                        entry.value,
                        percentage: percentage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: maximum <= 0 ? 0 : entry.value / maximum,
                ),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

class AdminAnalyticsError extends StatelessWidget {
  const AdminAnalyticsError({
    required this.error,
    required this.onRetry,
    this.permission = 'analytics.read',
    this.missingEndpointMessage,
    super.key,
  });

  final Object error;
  final VoidCallback onRetry;
  final String permission;
  final String? missingEndpointMessage;

  @override
  Widget build(BuildContext context) {
    final apiError = error is AdminApiException
        ? error as AdminApiException
        : null;
    final authenticationError =
        apiError?.statusCode == 401 || apiError?.statusCode == 403;
    final missingEndpoint = apiError?.statusCode == 404;
    return AdminStatusBanner(
      icon: authenticationError
          ? Icons.lock_outline_rounded
          : missingEndpoint
          ? Icons.power_off_outlined
          : Icons.cloud_off_outlined,
      title: authenticationError
          ? context.localized(
              en: '$permission permission required',
              fr: 'Permission $permission requise',
            )
          : missingEndpoint
          ? context.localized(
              en: 'API route not deployed yet',
              fr: 'Route API pas encore déployée',
            )
          : context.localized(
              en: 'Unable to load',
              fr: 'Chargement impossible',
            ),
      message: authenticationError
          ? context.localized(
              en: 'Connect an administrator key with $permission.',
              fr: 'Connectez une clé administrateur possédant $permission.',
            )
          : missingEndpoint
          ? missingEndpointMessage ??
                context.localized(
                  en: 'The frontend is ready, but this aggregation must be added to the API.',
                  fr: 'Le frontend est prêt, mais cette agrégation doit être ajoutée à l’API.',
                )
          : redactSensitiveText(error),
      tone: AdminBannerTone.error,
      trailing: IconButton(
        onPressed: authenticationError
            ? () => pushOrGo(context, '/admin/admin_login')
            : onRetry,
        tooltip: authenticationError
            ? context.localized(en: 'Change key', fr: 'Changer de clé')
            : context.localized(en: 'Retry', fr: 'Réessayer'),
        icon: Icon(
          authenticationError ? Icons.key_rounded : Icons.refresh_rounded,
        ),
      ),
    );
  }
}

String _humanizeAnalyticsLabel(String value) {
  final spaced = value
      .replaceAll('_', ' ')
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match[1]} ${match[2]}',
      );
  if (spaced.isEmpty) return value;
  return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}
