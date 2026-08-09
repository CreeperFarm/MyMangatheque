import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_analytics_components.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_form_helpers.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum AdminManagementSection {
  sponsorship('sponsorship', Icons.campaign_outlined),
  editorial('editorial', Icons.auto_awesome_outlined),
  revenue('revenue', Icons.payments_outlined),
  catalog('catalog-quality', Icons.fact_check_outlined),
  moderation('moderation', Icons.gavel_outlined),
  operations('operations', Icons.monitor_heart_outlined),
  audit('audit', Icons.policy_outlined)
  ;

  const AdminManagementSection(this.slug, this.icon);

  final String slug;
  final IconData icon;

  String get title => switch (this) {
    sponsorship => _t('Sponsorship', 'Sponsorisation'),
    editorial => _t('Editorial recommendations', 'Recommandations éditoriales'),
    revenue => _t('Revenue', 'Revenus'),
    catalog => _t('Catalogue quality', 'Catalogue et qualité'),
    moderation => _t('Users and moderation', 'Utilisateurs et modération'),
    operations => _t('Operations', 'Exploitation'),
    audit => _t('Security and audit', 'Sécurité et audit'),
  };

  String get description => switch (this) {
    sponsorship => _t(
      'Campaigns, targeting, costs and sponsored manga performance.',
      'Campagnes, ciblage, coûts et performances des mangas sponsorisés.',
    ),
    editorial => _t(
      'Manual selections clearly separated from personalized recommendations.',
      'Sélections manuelles clairement séparées des recommandations personnalisées.',
    ),
    revenue => _t(
      'Sponsor invoices, revenue, costs and payments.',
      'Factures sponsors, chiffre d’affaires, coûts et paiements.',
    ),
    catalog => _t(
      'Issues, missing data, duplicates, EANs, covers and relationships.',
      'Anomalies, données manquantes, doublons, EAN, couvertures et relations.',
    ),
    moderation => _t(
      'Reports, suspensions, roles and privacy requests.',
      'Signalements, suspensions, rôles et demandes RGPD.',
    ),
    operations => _t(
      'Deployments, jobs, caches, errors, quotas and feature flags.',
      'Déploiements, tâches, cache, erreurs, quotas et feature flags.',
    ),
    audit => _t(
      'Action history, exports and permission changes.',
      'Historique des actions, exports et changements de permissions.',
    ),
  };
}

String _t(String en, String fr) => RuntimeLocalization.text(en: en, fr: fr);

class AdminManagementPage extends StatefulWidget {
  const AdminManagementPage({required this.section, super.key});

  final AdminManagementSection section;

  @override
  State<AdminManagementPage> createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> {
  final AdminConnector _admin = AdminConnector();
  Future<Map<String, dynamic>>? _future;
  bool _initialized = false;
  bool _busy = false;
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

  Future<Map<String, dynamic>> _load() async {
    final response = await switch (widget.section) {
      AdminManagementSection.sponsorship => _admin.getSponsorshipDashboard(
        days: _days,
      ),
      AdminManagementSection.editorial => _admin.getEditorialRecommendations(),
      AdminManagementSection.revenue => _admin.getRevenueDashboard(days: _days),
      AdminManagementSection.catalog => _admin.getCatalogQualityDashboard(),
      AdminManagementSection.moderation => _admin.getModerationDashboard(),
      AdminManagementSection.operations => _admin.getOperationsDashboard(),
      AdminManagementSection.audit => _admin.getAuditEvents(),
    };
    if (widget.section != AdminManagementSection.operations) return response;
    final package = await PackageInfo.fromPlatform();
    final rawData = response['data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : Map<String, dynamic>.from(response);
    data['client'] = <String, dynamic>{
      'platform': ThemeData().platform.name,
      'version': package.version,
      'buildNumber': package.buildNumber,
      'packageName': package.packageName,
    };
    if (rawData is Map) {
      return <String, dynamic>{...response, 'data': data};
    }
    return data;
  }

  void _refresh() => setState(() => _future = _load());

  void _changePeriod(int days) {
    if (_days == days) return;
    setState(() {
      _days = days;
      _future = _load();
    });
  }

  Future<void> _run(
    Future<void> Function() action,
    String successMessage,
  ) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
      _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(redactSensitiveText(error))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createCampaign() async {
    final draft = await showDialog<_CampaignDraft>(
      context: context,
      builder: (_) => const _CampaignDialog(),
    );
    if (draft == null || !mounted) return;
    await _run(
      () => _admin.createSponsorshipCampaign(
        name: draft.name,
        mangaId: draft.mangaId,
        budget: draft.budget,
        startsAt: draft.startsAt,
        endsAt: draft.endsAt,
        placement: draft.placement,
        frequencyCap: draft.frequencyCap,
        platforms: draft.platforms,
        countries: draft.countries,
        languages: draft.languages,
      ),
      _t('Campaign created as a draft.', 'Campagne créée en brouillon.'),
    );
  }

  Future<void> _createEditorial() async {
    final draft = await showDialog<_EditorialDraft>(
      context: context,
      builder: (_) => const _EditorialDialog(),
    );
    if (draft == null || !mounted) return;
    await _run(
      () => _admin.createEditorialRecommendation(
        mangaId: draft.mangaId,
        placement: draft.placement,
        priority: draft.priority,
        startsAt: draft.startsAt,
        endsAt: draft.endsAt,
        note: draft.note,
      ),
      _t('Editorial feature created.', 'Mise en avant éditoriale créée.'),
    );
  }

  Future<void> _scanCatalog() {
    return _run(
      _admin.scanCatalogQuality,
      _t(
        'Full catalogue scan started.',
        'Analyse complète du catalogue démarrée.',
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final response = await _admin.requestAdminExport(
        resource: widget.section.slug,
      );
      if (!mounted) return;
      final data = adminAnalyticsData(response);
      final downloadUrl = _firstText(data, const ['downloadUrl', 'url']);
      if (downloadUrl.isNotEmpty) {
        await _openDownload(downloadUrl);
        return;
      }
      final message = _firstText(data, const ['message', 'id', 'exportId']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty
                ? _t(
                    'Export requested. It will appear in the audit log.',
                    'Export demandé. Il apparaîtra dans le journal d’audit.',
                  )
                : message,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(redactSensitiveText(error))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_admin.isLoggedIn()) {
      return AdminPageScaffold(
        title: widget.section.title,
        maxWidth: 680,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminPageHeader(
              icon: widget.section.icon,
              title: widget.section.title,
              description: _t(
                'An authorized administrator key is required.',
                'Une clé administrateur autorisée est nécessaire.',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => pushOrGo(context, '/admin/admin_login'),
              icon: const Icon(Icons.login_rounded),
              label: Text(_t('Sign in as admin', 'Se connecter en admin')),
            ),
          ],
        ),
      );
    }

    return AdminPageScaffold(
      title: widget.section.title,
      actions: [
        IconButton(
          onPressed: _busy ? null : _export,
          tooltip: _t('Request a CSV export', 'Demander un export CSV'),
          icon: const Icon(Icons.download_outlined),
        ),
        IconButton(
          onPressed: _busy ? null : _refresh,
          tooltip: _t('Refresh', 'Actualiser'),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminPageHeader(
            icon: widget.section.icon,
            title: widget.section.title,
            description: widget.section.description,
          ),
          const SizedBox(height: 18),
          _buildPrimaryActions(),
          if (_usesPeriod) ...[
            const SizedBox(height: 16),
            AdminAnalyticsPeriodSelector(
              value: _days,
              onChanged: _changePeriod,
            ),
          ],
          const SizedBox(height: 22),
          FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 280,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return AdminAnalyticsError(
                  error: snapshot.error!,
                  onRetry: _refresh,
                  permission: 'admin.${widget.section.slug}.read',
                  missingEndpointMessage: _t(
                    'Unable to load the ${widget.section.title.toLowerCase()} module. Check API availability and administrator key permissions.',
                    'Impossible de charger le module ${widget.section.title.toLowerCase()}. Vérifiez la disponibilité de l’API et les permissions de la clé administrateur.',
                  ),
                );
              }
              return _buildData(
                adminAnalyticsData(
                  snapshot.data ?? const <String, dynamic>{},
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool get _usesPeriod =>
      widget.section == AdminManagementSection.sponsorship ||
      widget.section == AdminManagementSection.revenue;

  Widget _buildPrimaryActions() {
    final buttons = <Widget>[
      if (widget.section == AdminManagementSection.sponsorship)
        FilledButton.icon(
          onPressed: _busy ? null : _createCampaign,
          icon: const Icon(Icons.add_rounded),
          label: Text(_t('Create campaign', 'Créer une campagne')),
        ),
      if (widget.section == AdminManagementSection.editorial)
        FilledButton.icon(
          onPressed: _busy ? null : _createEditorial,
          icon: const Icon(Icons.add_rounded),
          label: Text(_t('Add selection', 'Ajouter une sélection')),
        ),
      if (widget.section == AdminManagementSection.catalog)
        FilledButton.icon(
          onPressed: _busy ? null : _scanCatalog,
          icon: const Icon(Icons.radar_rounded),
          label: Text(_t('Scan catalogue', 'Analyser le catalogue')),
        ),
      if (widget.section == AdminManagementSection.moderation)
        OutlinedButton.icon(
          onPressed: () => pushOrGo(context, '/admin/users'),
          icon: const Icon(Icons.manage_accounts_outlined),
          label: Text(
            _t('Manage accounts and roles', 'Gérer les comptes et rôles'),
          ),
        ),
      if (widget.section == AdminManagementSection.catalog)
        OutlinedButton.icon(
          onPressed: () => pushOrGo(context, '/admin/volume-quality'),
          icon: const Icon(Icons.menu_book_outlined),
          label: Text(_t('Correct volumes', 'Corriger les volumes')),
        ),
    ];
    if (buttons.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 10, runSpacing: 10, children: buttons);
  }

  Widget _buildData(Map<String, dynamic> data) {
    final metrics = _metricDefinitions(widget.section)
        .map(
          (metric) => AdminAnalyticsMetric(
            label: metric.label,
            value: _formatMetric(
              adminAnalyticsNumber(data, metric.paths),
              money: metric.money,
              percentage: metric.percentage,
            ),
            icon: metric.icon,
          ),
        )
        .toList();
    final groups = _recordGroups(widget.section);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.section == AdminManagementSection.operations) ...[
          _buildOperationsContext(data),
          const SizedBox(height: 16),
        ],
        AdminAnalyticsMetricGrid(metrics: metrics),
        const SizedBox(height: 28),
        for (final group in groups) ...[
          AdminSectionTitle(title: group.title),
          const SizedBox(height: 10),
          _RecordGroupCard(
            group: group,
            records: adminAnalyticsRecords(data, group.paths),
            busy: _busy,
            onAction: _handleRecordAction,
          ),
          const SizedBox(height: 22),
        ],
      ],
    );
  }

  Widget _buildOperationsContext(Map<String, dynamic> data) {
    final client =
        adminAnalyticsMap(data['client']) ?? const <String, dynamic>{};
    final versions =
        adminAnalyticsMap(data['versions']) ??
        adminAnalyticsMap(data['applications']) ??
        const <String, dynamic>{};
    final health =
        adminAnalyticsMap(data['health']) ?? const <String, dynamic>{};
    final values = <String>[
      if (client.isNotEmpty)
        _t(
          'Current client: ${client['platform'] ?? 'unknown'} ${client['version'] ?? '—'}+${client['buildNumber'] ?? '—'}',
          'Client actuel : ${client['platform'] ?? 'inconnu'} ${client['version'] ?? '—'}+${client['buildNumber'] ?? '—'}',
        ),
      if (versions['web'] != null) 'Web: ${versions['web']}',
      if (versions['android'] != null) 'Android: ${versions['android']}',
      if (versions['ios'] != null) 'iOS: ${versions['ios']}',
      if (versions['api'] != null) 'API: ${versions['api']}',
      if (versions['appwrite'] != null) 'Appwrite: ${versions['appwrite']}',
      if (health['api'] != null) 'API health: ${health['api']}',
      if (health['appwrite'] != null) 'Appwrite health: ${health['appwrite']}',
      if (data['latencyMs'] != null) 'Latency: ${data['latencyMs']} ms',
    ];
    return AdminStatusBanner(
      icon: Icons.devices_other_outlined,
      title: _t('Application and services', 'Application et services'),
      message: values.isEmpty
          ? _t(
              'The API did not return version or health information.',
              'L’API n’a pas renvoyé les versions ou informations de santé.',
            )
          : values.join(' · '),
      tone: values.isEmpty ? AdminBannerTone.warning : AdminBannerTone.info,
    );
  }

  Future<void> _handleRecordAction(
    String group,
    String action,
    Map<String, dynamic> record,
  ) async {
    final id = _firstText(record, const [
      'id',
      r'$id',
      'campaignId',
      'invoiceId',
      'issueId',
      'caseId',
      'jobId',
      'userId',
      'key',
      'namespace',
    ]);
    if (id.isEmpty) return;
    switch ('$group:$action') {
      case 'campaigns:activate':
      case 'campaigns:pause':
        await _run(
          () => _admin.updateSponsorshipCampaignStatus(
            id,
            action == 'activate' ? 'active' : 'paused',
          ),
          action == 'activate'
              ? _t('Campaign activated.', 'Campagne activée.')
              : _t('Campaign paused.', 'Campagne suspendue.'),
        );
      case 'editorial:delete':
        if (!await _confirm(
          _t(
            'Remove this editorial feature?',
            'Retirer cette mise en avant éditoriale ?',
          ),
        )) {
          return;
        }
        await _run(
          () => _admin.deleteEditorialRecommendation(id),
          _t('Editorial feature removed.', 'Mise en avant retirée.'),
        );
      case 'invoices:paid':
        await _run(
          () => _admin.updateSponsorInvoicePayment(id, status: 'paid'),
          _t('Invoice marked as paid.', 'Facture marquée comme payée.'),
        );
      case 'quality:resolve':
        await _run(
          () => _admin.resolveCatalogQualityIssue(id),
          _t('Issue marked as resolved.', 'Anomalie marquée comme résolue.'),
        );
      case 'moderation:resolve':
        await _run(
          () => _admin.resolveModerationCase(id, resolution: 'resolved'),
          _t('Moderation case resolved.', 'Dossier de modération résolu.'),
        );
      case 'jobs:retry':
        await _run(
          () => _admin.retryQueueJob(id),
          _t('Job queued again.', 'Tâche remise en file.'),
        );
      case 'flags:toggle':
        final enabled = _boolValue(record['enabled']);
        await _run(
          () => _admin.updateFeatureFlag(id, !enabled),
          !enabled
              ? _t('Feature enabled.', 'Fonction activée.')
              : _t('Feature disabled.', 'Fonction désactivée.'),
        );
      case 'cache:invalidate':
        if (!await _confirm(
          _t(
            'Invalidating this cache may increase API load.',
            'Invalider ce cache peut augmenter la charge API.',
          ),
        )) {
          return;
        }
        await _run(
          () => _admin.invalidateCache(id),
          _t('Cache invalidated.', 'Cache invalidé.'),
        );
      case 'exports:download':
        final url = _firstText(record, const ['downloadUrl', 'url']);
        if (url.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _t(
                  'This export is not ready yet.',
                  'Cet export n’est pas encore prêt.',
                ),
              ),
            ),
          );
          return;
        }
        await _openDownload(url);
    }
  }

  Future<void> _openDownload(String rawUrl) async {
    final resolved = rawUrl.startsWith('/')
        ? 'https://api.mymangatheque.com$rawUrl'
        : rawUrl;
    final uri = parseSafeHttpsUri(
      resolved,
      allowedHosts: const <String>{'api.mymangatheque.com'},
    );
    if (uri == null) {
      throw AdminInputException(
        _t('Invalid download URL.', 'URL de téléchargement invalide.'),
      );
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw AdminInputException(
        _t(
          'Unable to open the export download.',
          'Impossible d’ouvrir le téléchargement de l’export.',
        ),
      );
    }
  }

  Future<bool> _confirm(String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_t('Confirm action', 'Confirmer l’action')),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(_t('Cancel', 'Annuler')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(_t('Confirm', 'Confirmer')),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _MetricDefinition {
  const _MetricDefinition(
    this.label,
    this.paths,
    this.icon, {
    this.money = false,
    this.percentage = false,
  });

  final String label;
  final List<String> paths;
  final IconData icon;
  final bool money;
  final bool percentage;
}

class _RecordGroup {
  const _RecordGroup(
    this.key,
    this.title,
    this.paths, {
    this.actions = const {},
  });

  final String key;
  final String title;
  final List<String> paths;
  final Map<String, String> actions;
}

List<_MetricDefinition> _metricDefinitions(AdminManagementSection section) {
  return switch (section) {
    AdminManagementSection.sponsorship => [
      _MetricDefinition(
        _t('Budget', 'Budget'),
        ['totals.budget', 'budget'],
        Icons.wallet_outlined,
        money: true,
      ),
      _MetricDefinition(_t('Impressions', 'Impressions'), [
        'totals.impressions',
        'impressions',
      ], Icons.visibility_outlined),
      _MetricDefinition(_t('Clicks', 'Clics'), [
        'totals.clicks',
        'clicks',
      ], Icons.ads_click_outlined),
      _MetricDefinition(_t('Conversions', 'Conversions'), [
        'totals.conversions',
        'conversions',
      ], Icons.check_circle_outline),
      _MetricDefinition(
        _t('Spend', 'Dépenses'),
        ['totals.spend', 'spend'],
        Icons.euro_outlined,
        money: true,
      ),
      _MetricDefinition(
        _t('CTR', 'CTR'),
        ['rates.ctr', 'ctr'],
        Icons.percent_rounded,
        percentage: true,
      ),
    ],
    AdminManagementSection.editorial => [
      _MetricDefinition(_t('Active selections', 'Sélections actives'), [
        'totals.active',
        'active',
      ], Icons.auto_awesome_outlined),
      _MetricDefinition(_t('Scheduled', 'Planifiées'), [
        'totals.scheduled',
        'scheduled',
      ], Icons.schedule_outlined),
      _MetricDefinition(_t('Impressions', 'Impressions'), [
        'totals.impressions',
        'impressions',
      ], Icons.visibility_outlined),
      _MetricDefinition(_t('Clicks', 'Clics'), [
        'totals.clicks',
        'clicks',
      ], Icons.ads_click_outlined),
    ],
    AdminManagementSection.revenue => [
      _MetricDefinition(
        _t('Revenue', 'Chiffre d’affaires'),
        ['totals.revenue', 'revenue'],
        Icons.payments_outlined,
        money: true,
      ),
      _MetricDefinition(
        _t('Outstanding', 'À encaisser'),
        ['totals.outstanding', 'outstanding'],
        Icons.pending_actions_outlined,
        money: true,
      ),
      _MetricDefinition(
        _t('CPM', 'CPM'),
        ['costs.cpm', 'cpm'],
        Icons.visibility_outlined,
        money: true,
      ),
      _MetricDefinition(
        _t('Cost / impression', 'Coût / impression'),
        ['costs.perImpression', 'costPerImpression'],
        Icons.remove_red_eye_outlined,
        money: true,
      ),
      _MetricDefinition(
        _t('CPC', 'CPC'),
        ['costs.cpc', 'cpc'],
        Icons.ads_click_outlined,
        money: true,
      ),
      _MetricDefinition(
        _t('CPA', 'CPA'),
        ['costs.cpa', 'cpa'],
        Icons.task_alt_outlined,
        money: true,
      ),
    ],
    AdminManagementSection.catalog => [
      _MetricDefinition(_t('Issues', 'Anomalies'), [
        'totals.issues',
        'issuesCount',
      ], Icons.warning_amber_rounded),
      _MetricDefinition(_t('Missing data', 'Données manquantes'), [
        'totals.missingData',
        'missingData',
      ], Icons.find_in_page_outlined),
      _MetricDefinition(_t('Duplicates', 'Doublons'), [
        'totals.duplicates',
        'duplicates',
      ], Icons.content_copy_outlined),
      _MetricDefinition(_t('Invalid EANs', 'EAN invalides'), [
        'totals.invalidEans',
        'invalidEans',
      ], Icons.qr_code_scanner_outlined),
      _MetricDefinition(_t('Missing covers', 'Couvertures absentes'), [
        'totals.missingCovers',
        'missingCovers',
      ], Icons.broken_image_outlined),
      _MetricDefinition(_t('Broken relationships', 'Relations cassées'), [
        'totals.brokenRelations',
        'brokenRelations',
      ], Icons.link_off_outlined),
    ],
    AdminManagementSection.moderation => [
      _MetricDefinition(_t('Open reports', 'Signalements ouverts'), [
        'totals.openReports',
        'openReports',
      ], Icons.flag_outlined),
      _MetricDefinition(_t('Suspended accounts', 'Comptes suspendus'), [
        'totals.suspendedUsers',
        'suspendedUsers',
      ], Icons.person_off_outlined),
      _MetricDefinition(_t('Privacy requests', 'Demandes RGPD'), [
        'totals.privacyRequests',
        'privacyRequests',
      ], Icons.privacy_tip_outlined),
      _MetricDefinition(_t('Overdue cases', 'Dossiers en retard'), [
        'totals.overdueCases',
        'overdueCases',
      ], Icons.timer_off_outlined),
    ],
    AdminManagementSection.operations => [
      _MetricDefinition(
        _t('Active deployments', 'Déploiements actifs'),
        [
          'totals.activeDeployments',
          'activeDeployments',
        ],
        Icons.rocket_launch_outlined,
      ),
      _MetricDefinition(_t('Queued jobs', 'Tâches en attente'), [
        'totals.queuedJobs',
        'queuedJobs',
      ], Icons.queue_outlined),
      _MetricDefinition(_t('Open errors', 'Erreurs ouvertes'), [
        'totals.openErrors',
        'openErrors',
      ], Icons.error_outline_rounded),
      _MetricDefinition(
        _t('Cache hit rate', 'Taux de succès du cache'),
        ['cache.hitRate', 'cacheHitRate'],
        Icons.cached_rounded,
        percentage: true,
      ),
      _MetricDefinition(_t('Critical quotas', 'Quotas critiques'), [
        'totals.criticalQuotas',
        'criticalQuotas',
      ], Icons.speed_outlined),
      _MetricDefinition(
        _t('Enabled feature flags', 'Feature flags actifs'),
        [
          'totals.enabledFlags',
          'enabledFlags',
        ],
        Icons.flag_circle_outlined,
      ),
    ],
    AdminManagementSection.audit => [
      _MetricDefinition(_t('Actions', 'Actions'), [
        'totals.actions',
        'actions',
      ], Icons.history_rounded),
      _MetricDefinition(_t('Exports', 'Exports'), [
        'totals.exports',
        'exports',
      ], Icons.download_outlined),
      _MetricDefinition(
        _t('Permission changes', 'Permissions modifiées'),
        [
          'totals.permissionChanges',
          'permissionChanges',
        ],
        Icons.admin_panel_settings_outlined,
      ),
      _MetricDefinition(_t('Sensitive actions', 'Actions sensibles'), [
        'totals.sensitiveActions',
        'sensitiveActions',
      ], Icons.security_outlined),
    ],
  };
}

List<_RecordGroup> _recordGroups(AdminManagementSection section) {
  return switch (section) {
    AdminManagementSection.sponsorship => [
      _RecordGroup(
        'campaigns',
        _t('Campaigns', 'Campagnes'),
        const ['campaigns'],
        actions: {
          'activate': _t('Activate', 'Activer'),
          'pause': _t('Pause', 'Suspendre'),
        },
      ),
    ],
    AdminManagementSection.editorial => [
      _RecordGroup(
        'editorial',
        _t('Editorial selections', 'Sélections éditoriales'),
        const ['recommendations', 'items'],
        actions: {'delete': _t('Remove', 'Retirer')},
      ),
    ],
    AdminManagementSection.revenue => [
      _RecordGroup(
        'invoices',
        _t('Sponsor invoices', 'Factures sponsors'),
        const ['invoices'],
        actions: {'paid': _t('Mark as paid', 'Marquer payée')},
      ),
      _RecordGroup(
        'payments',
        _t('Recent payments', 'Paiements récents'),
        const ['payments'],
      ),
    ],
    AdminManagementSection.catalog => [
      _RecordGroup(
        'quality',
        _t('Catalogue issues', 'Anomalies de catalogue'),
        const ['issues'],
        actions: {'resolve': _t('Resolve', 'Résoudre')},
      ),
    ],
    AdminManagementSection.moderation => [
      _RecordGroup(
        'moderation',
        _t('Reports', 'Signalements'),
        const ['reports'],
        actions: {'resolve': _t('Resolve', 'Résoudre')},
      ),
      _RecordGroup(
        'moderation',
        _t('Suspensions', 'Suspensions'),
        const ['suspensions'],
      ),
      _RecordGroup(
        'moderation',
        _t('Privacy requests', 'Demandes RGPD'),
        const ['privacyRequests'],
        actions: {'resolve': _t('Process', 'Traiter')},
      ),
    ],
    AdminManagementSection.operations => [
      _RecordGroup(
        'deployments',
        _t('Deployments', 'Déploiements'),
        const ['deployments'],
      ),
      _RecordGroup(
        'jobs',
        _t('Job queues', 'Files de tâches'),
        const ['jobs', 'queues.jobs'],
        actions: {'retry': _t('Retry', 'Relancer')},
      ),
      _RecordGroup(
        'cache',
        _t('Caches', 'Caches'),
        const ['caches', 'cache.namespaces'],
        actions: {'invalidate': _t('Invalidate', 'Invalider')},
      ),
      _RecordGroup('errors', _t('Errors', 'Erreurs'), const ['errors']),
      _RecordGroup('quotas', _t('Quotas', 'Quotas'), const ['quotas']),
      _RecordGroup(
        'flags',
        _t('Feature flags', 'Feature flags'),
        const ['featureFlags'],
        actions: {'toggle': _t('Toggle', 'Basculer')},
      ),
    ],
    AdminManagementSection.audit => [
      _RecordGroup(
        'audit',
        _t('Action history', 'Historique des actions'),
        const [
          'events',
          'auditEvents',
        ],
      ),
      _RecordGroup(
        'exports',
        _t('Exports', 'Exports'),
        const ['exports'],
        actions: {'download': _t('Download', 'Télécharger')},
      ),
      _RecordGroup(
        'permissions',
        _t('Permission changes', 'Changements de permissions'),
        const [
          'permissionChanges',
        ],
      ),
    ],
  };
}

class _RecordGroupCard extends StatelessWidget {
  const _RecordGroupCard({
    required this.group,
    required this.records,
    required this.busy,
    required this.onAction,
  });

  final _RecordGroup group;
  final List<Map<String, dynamic>> records;
  final bool busy;
  final Future<void> Function(String, String, Map<String, dynamic>) onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: records.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                _t('No data available.', 'Aucune donnée disponible.'),
              ),
            )
          : Column(
              children: [
                for (
                  var index = 0;
                  index < records.take(50).length;
                  index++
                ) ...[
                  _recordTile(context, records[index]),
                  if (index < records.take(50).length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
    );
  }

  Widget _recordTile(BuildContext context, Map<String, dynamic> record) {
    final title = _firstText(record, const [
      'name',
      'title',
      'mangaTitle',
      'sponsorName',
      'action',
      'key',
      'namespace',
      'id',
      r'$id',
    ]);
    final detail = _recordDetail(record);
    return ListTile(
      leading: CircleAvatar(child: Icon(_recordIcon(group.key))),
      title: Text(
        title.isEmpty ? _t('Untitled item', 'Élément sans titre') : title,
      ),
      subtitle: detail.isEmpty ? null : Text(detail, maxLines: 3),
      trailing: group.actions.isEmpty
          ? _statusChip(record)
          : PopupMenuButton<String>(
              enabled: !busy,
              tooltip: _t('Actions', 'Actions'),
              onSelected: (action) => onAction(group.key, action, record),
              itemBuilder: (_) => group.actions.entries
                  .map(
                    (entry) => PopupMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget? _statusChip(Map<String, dynamic> record) {
    final status = _firstText(record, const ['status', 'state', 'severity']);
    return status.isEmpty ? null : Chip(label: Text(status));
  }
}

IconData _recordIcon(String group) => switch (group) {
  'campaigns' => Icons.campaign_outlined,
  'editorial' => Icons.auto_awesome_outlined,
  'invoices' || 'payments' => Icons.receipt_long_outlined,
  'quality' => Icons.fact_check_outlined,
  'moderation' => Icons.gavel_outlined,
  'deployments' => Icons.rocket_launch_outlined,
  'jobs' => Icons.queue_outlined,
  'cache' => Icons.cached_rounded,
  'errors' => Icons.error_outline_rounded,
  'quotas' => Icons.speed_outlined,
  'flags' => Icons.flag_outlined,
  _ => Icons.history_rounded,
};

String _recordDetail(Map<String, dynamic> record) {
  final values = <String>[];
  void add(String label, List<String> paths) {
    final value = _firstText(record, paths);
    if (value.isNotEmpty) values.add('$label : $value');
  }

  add(_t('Status', 'Statut'), const ['status', 'state', 'severity']);
  add(_t('Manga', 'Manga'), const ['mangaTitle', 'manga.title', 'mangaId']);
  add(_t('Actor', 'Acteur'), const [
    'actorEmail',
    'actor.name',
    'userEmail',
    'userId',
  ]);
  add(_t('Period', 'Période'), const ['period', 'startsAt']);
  add(_t('Amount', 'Montant'), const ['amount', 'budget', 'revenue', 'spend']);
  add(_t('Impressions', 'Impressions'), const ['impressions']);
  add(_t('Clicks', 'Clics'), const ['clicks']);
  add(_t('Conversions', 'Conversions'), const ['conversions']);
  add(_t('Message', 'Message'), const ['message', 'reason', 'description']);
  return values.join(' · ');
}

String _firstText(Map<String, dynamic> data, List<String> paths) {
  for (final path in paths) {
    final value = adminAnalyticsValue(data, path);
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty && text != 'null') return text;
  }
  return '';
}

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

String _formatMetric(
  num? value, {
  bool money = false,
  bool percentage = false,
}) {
  if (value == null) return '—';
  final normalized = money ? value / 100 : value;
  final formatted = adminAnalyticsFormat(
    normalized,
    percentage: percentage,
  );
  return money ? '$formatted €' : formatted;
}

class _CampaignDraft {
  const _CampaignDraft({
    required this.name,
    required this.mangaId,
    required this.budget,
    required this.startsAt,
    required this.endsAt,
    required this.placement,
    required this.frequencyCap,
    required this.platforms,
    required this.countries,
    required this.languages,
  });

  final String name;
  final String mangaId;
  final num budget;
  final DateTime startsAt;
  final DateTime endsAt;
  final String placement;
  final int frequencyCap;
  final List<String> platforms;
  final List<String> countries;
  final List<String> languages;
}

class _CampaignDialog extends StatefulWidget {
  const _CampaignDialog();

  @override
  State<_CampaignDialog> createState() => _CampaignDialogState();
}

class _CampaignDialogState extends State<_CampaignDialog> {
  final _name = TextEditingController();
  final _budget = TextEditingController();
  final _frequency = TextEditingController(text: '3');
  final _platforms = TextEditingController(text: 'web, ios, android');
  final _countries = TextEditingController();
  final _languages = TextEditingController(text: 'fr');
  List<AdminRelationOption> _manga = const [];
  String _placement = 'home';
  DateTime? _startsAt;
  DateTime? _endsAt;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _budget.dispose();
    _frequency.dispose();
    _platforms.dispose();
    _countries.dispose();
    _languages.dispose();
    super.dispose();
  }

  void _submit() {
    final budget = num.tryParse(_budget.text.replaceAll(',', '.'));
    final cap = int.tryParse(_frequency.text);
    if (_name.text.trim().isEmpty ||
        _manga.isEmpty ||
        budget == null ||
        cap == null ||
        _startsAt == null ||
        _endsAt == null) {
      setState(
        () => _error = _t(
          'Complete all required fields.',
          'Complétez tous les champs obligatoires.',
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      _CampaignDraft(
        name: _name.text,
        mangaId: _manga.single.id,
        budget: budget,
        startsAt: _startsAt!,
        endsAt: _endsAt!,
        placement: _placement,
        frequencyCap: cap,
        platforms: parseAdminList(
          _platforms.text,
        ).map((value) => value.toLowerCase()).toList(),
        countries: parseAdminList(_countries.text),
        languages: parseAdminList(_languages.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _t('New sponsored campaign', 'Nouvelle campagne sponsorisée'),
      ),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: _t('Campaign name *', 'Nom de campagne *'),
                ),
              ),
              const SizedBox(height: 12),
              AdminRelationPickerField(
                label: _t('Sponsored manga', 'Manga sponsorisé'),
                resource: AdminRelationResource.subSeries,
                selected: _manga,
                onChanged: (value) => setState(() => _manga = value),
                required: true,
              ),
              const SizedBox(height: 12),
              AdminResponsiveFields(
                children: [
                  TextField(
                    controller: _budget,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: _t('Budget (€) *', 'Budget (€) *'),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _placement,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: _t('Placement', 'Emplacement'),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'home',
                        child: Text(_t('Home', 'Accueil')),
                      ),
                      DropdownMenuItem(
                        value: 'catalog',
                        child: Text(_t('Catalogue', 'Catalogue')),
                      ),
                      DropdownMenuItem(
                        value: 'search',
                        child: Text(_t('Search', 'Recherche')),
                      ),
                      DropdownMenuItem(
                        value: 'details',
                        child: Text(_t('Manga details', 'Fiche manga')),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _placement = value ?? 'home'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AdminResponsiveFields(
                children: [
                  AdminDateField(
                    label: _t('Start *', 'Début *'),
                    value: _startsAt,
                    onChanged: (value) => setState(() => _startsAt = value),
                  ),
                  AdminDateField(
                    label: _t('End *', 'Fin *'),
                    value: _endsAt,
                    onChanged: (value) => setState(() => _endsAt = value),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _frequency,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: _t(
                    'Maximum impressions per user',
                    'Impressions maximales par utilisateur',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AdminResponsiveFields(
                children: [
                  TextField(
                    controller: _platforms,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: _t('Platforms', 'Plateformes'),
                      helperText: 'web, ios, android, other',
                    ),
                  ),
                  TextField(
                    controller: _countries,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: _t('Countries', 'Pays'),
                      helperText: _t(
                        'ISO codes: FR, BE, CH…',
                        'Codes ISO : FR, BE, CH…',
                      ),
                    ),
                  ),
                  TextField(
                    controller: _languages,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: _t('Languages', 'Langues'),
                      helperText: 'fr, en…',
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_t('Cancel', 'Annuler')),
        ),
        FilledButton(onPressed: _submit, child: Text(_t('Create', 'Créer'))),
      ],
    );
  }
}

class _EditorialDraft {
  const _EditorialDraft({
    required this.mangaId,
    required this.placement,
    required this.priority,
    required this.startsAt,
    required this.endsAt,
    required this.note,
  });

  final String mangaId;
  final String placement;
  final int priority;
  final DateTime startsAt;
  final DateTime endsAt;
  final String note;
}

class _EditorialDialog extends StatefulWidget {
  const _EditorialDialog();

  @override
  State<_EditorialDialog> createState() => _EditorialDialogState();
}

class _EditorialDialogState extends State<_EditorialDialog> {
  final _priority = TextEditingController(text: '100');
  final _note = TextEditingController();
  List<AdminRelationOption> _manga = const [];
  String _placement = 'home';
  DateTime? _startsAt;
  DateTime? _endsAt;
  String? _error;

  @override
  void dispose() {
    _priority.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    final priority = int.tryParse(_priority.text);
    if (_manga.isEmpty ||
        priority == null ||
        _startsAt == null ||
        _endsAt == null) {
      setState(
        () => _error = _t(
          'Complete all required fields.',
          'Complétez tous les champs obligatoires.',
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      _EditorialDraft(
        mangaId: _manga.single.id,
        placement: _placement,
        priority: priority,
        startsAt: _startsAt!,
        endsAt: _endsAt!,
        note: _note.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _t(
          'New editorial recommendation',
          'Nouvelle recommandation éditoriale',
        ),
      ),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AdminStatusBanner(
                icon: Icons.info_outline_rounded,
                title: _t('Editorial selection', 'Sélection éditoriale'),
                message: _t(
                  'This feature remains separate from personalized ranking and must be identified as such publicly.',
                  'Cette mise en avant reste distincte du classement personnalisé et doit être identifiée comme telle côté public.',
                ),
              ),
              const SizedBox(height: 12),
              AdminRelationPickerField(
                label: _t('Manga', 'Manga'),
                resource: AdminRelationResource.subSeries,
                selected: _manga,
                onChanged: (value) => setState(() => _manga = value),
                required: true,
              ),
              const SizedBox(height: 12),
              AdminResponsiveFields(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _placement,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: _t('Placement', 'Emplacement'),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'home',
                        child: Text(_t('Home', 'Accueil')),
                      ),
                      DropdownMenuItem(
                        value: 'search',
                        child: Text(_t('Search', 'Recherche')),
                      ),
                      DropdownMenuItem(
                        value: 'catalog',
                        child: Text(_t('Catalogue', 'Catalogue')),
                      ),
                      DropdownMenuItem(
                        value: 'details',
                        child: Text(_t('Manga details', 'Fiche manga')),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _placement = value ?? 'home'),
                  ),
                  TextField(
                    controller: _priority,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: _t('Priority (0–100)', 'Priorité (0–100)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AdminResponsiveFields(
                children: [
                  AdminDateField(
                    label: _t('Start *', 'Début *'),
                    value: _startsAt,
                    onChanged: (value) => setState(() => _startsAt = value),
                  ),
                  AdminDateField(
                    label: _t('End *', 'Fin *'),
                    value: _endsAt,
                    onChanged: (value) => setState(() => _endsAt = value),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: _t(
                    'Editorial justification',
                    'Justification éditoriale',
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_t('Cancel', 'Annuler')),
        ),
        FilledButton(onPressed: _submit, child: Text(_t('Add', 'Ajouter'))),
      ],
    );
  }
}
