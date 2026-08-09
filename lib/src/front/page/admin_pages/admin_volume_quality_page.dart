import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_form_helpers.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class AdminVolumeQualityPage extends StatefulWidget {
  const AdminVolumeQualityPage({super.key});

  @override
  State<AdminVolumeQualityPage> createState() => _AdminVolumeQualityPageState();
}

class _AdminVolumeQualityPageState extends State<AdminVolumeQualityPage> {
  final AdminConnector _admin = AdminConnector();

  AdminVolumeIssuePage? _result;
  AdminVolumeIssueType? _typeFilter;
  AdminVolumeIssueStatus _statusFilter = AdminVolumeIssueStatus.open;
  Object? _error;
  String? _busyIssueId;
  String? _busyVolumeId;
  int _page = 1;
  bool _initialized = false;
  bool _loading = false;
  bool _scanning = false;

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
    });
    if (_admin.isLoggedIn()) await _loadIssues();
  }

  Future<void> _loadIssues({int? page}) async {
    final requestedPage = page ?? _page;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _admin.getVolumeQualityIssues(
        type: _typeFilter,
        status: _statusFilter,
        page: requestedPage,
      );
      if (!mounted) return;
      setState(() {
        _page = result.page;
        _result = result;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _scanIssues() async {
    setState(() {
      _scanning = true;
    });

    try {
      final issueCount = await _admin.scanVolumeQualityIssues();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.localized(
              en: '$issueCount open issue(s) detected.',
              fr: '$issueCount anomalie(s) ouverte(s) détectée(s).',
            ),
          ),
        ),
      );
      await _loadIssues(page: 1);
    } catch (error) {
      if (!mounted) return;
      _showApiError(error);
    } finally {
      if (mounted) {
        setState(() {
          _scanning = false;
        });
      }
    }
  }

  Future<void> _resolveIssue(AdminVolumeIssue issue) async {
    final noteController = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          context.localized(
            en: 'Mark as resolved',
            fr: 'Marquer comme résolue',
          ),
        ),
        content: TextField(
          controller: noteController,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.localized(
              en: 'Resolution note',
              fr: 'Note de résolution',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.localized(en: 'Cancel', fr: 'Annuler')),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(noteController.text),
            child: Text(context.localized(en: 'Resolve', fr: 'Résoudre')),
          ),
        ],
      ),
    );
    noteController.dispose();
    if (note == null || !mounted) return;

    await _runIssueAction(
      issue.id,
      () => _admin.resolveVolumeQualityIssue(issue.id, note: note),
      context.localized(
        en: 'Issue marked as resolved.',
        fr: 'Anomalie marquée comme résolue.',
      ),
    );
  }

  Future<void> _reopenIssue(AdminVolumeIssue issue) {
    return _runIssueAction(
      issue.id,
      () => _admin.reopenVolumeQualityIssue(issue.id),
      context.localized(en: 'Issue reopened.', fr: 'Anomalie rouverte.'),
    );
  }

  Future<void> _editVolume(
    AdminVolumeIssue issue,
    AdminIssueVolume volume,
  ) async {
    final result = await showDialog<_VolumeQualityEditResult>(
      context: context,
      builder: (context) => _EditVolumeQualityDialog(
        issue: issue,
        volume: volume,
      ),
    );
    if (result == null || !mounted) return;

    setState(() => _busyVolumeId = volume.id);
    try {
      await _admin.updateVolumeQualityData(
        volume.id,
        tomeNumber: result.tomeNumber,
        subSeriesId: result.subSeriesId,
      );
      await _admin.scanVolumeQualityIssues();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.localized(
              en: 'Volume corrected and issues scanned again.',
              fr: 'Volume corrigé et anomalies analysées à nouveau.',
            ),
          ),
        ),
      );
      await _loadIssues(page: 1);
    } catch (error) {
      if (!mounted) return;
      _showApiError(error);
    } finally {
      if (mounted) setState(() => _busyVolumeId = null);
    }
  }

  Future<void> _runIssueAction(
    String issueId,
    Future<void> Function() action,
    String successMessage,
  ) async {
    setState(() {
      _busyIssueId = issueId;
    });
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
      await _loadIssues();
    } catch (error) {
      if (!mounted) return;
      _showApiError(error);
    } finally {
      if (mounted) {
        setState(() {
          _busyIssueId = null;
        });
      }
    }
  }

  void _showApiError(Object error) {
    final message = error is AdminApiException && error.statusCode == 403
        ? context.localized(
            en: 'This key does not have the required permission.',
            fr: 'Cette clé ne possède pas la permission nécessaire.',
          )
        : redactSensitiveText(error);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_admin.isLoggedIn()) {
      return AdminPageScaffold(
        title: context.localized(
          en: 'Volume quality',
          fr: 'Qualité des volumes',
        ),
        maxWidth: 680,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminPageHeader(
              icon: Icons.fact_check_outlined,
              title: context.localized(
                en: 'Catalogue control',
                fr: 'Contrôle du catalogue',
              ),
              description: context.localized(
                en: 'An authorized key is required to view issues.',
                fr: 'Une clé autorisée est nécessaire pour consulter les anomalies.',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => pushOrGo(context, '/admin/admin_login'),
              icon: const Icon(Icons.login_rounded),
              label: Text(
                context.localized(
                  en: 'Sign in as admin or moderator',
                  fr: 'Se connecter en admin ou modérateur',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AdminPageScaffold(
      title: context.localized(en: 'Volume quality', fr: 'Qualité des volumes'),
      scrollable: false,
      actions: [
        IconButton(
          onPressed: _loading || _scanning ? null : _scanIssues,
          tooltip: context.localized(
            en: 'Detect issues',
            fr: 'Détecter les anomalies',
          ),
          icon: _scanning
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.fact_check_outlined),
        ),
        IconButton(
          onPressed: _loading ? null : _loadIssues,
          tooltip: context.localized(en: 'Refresh', fr: 'Actualiser'),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminPageHeader(
                  icon: Icons.fact_check_outlined,
                  title: context.localized(
                    en: 'Catalogue control',
                    fr: 'Contrôle du catalogue',
                  ),
                  description: context.localized(
                    en: 'Find zero numbers and duplicates within a sub-series.',
                    fr: 'Repérez les numéros à zéro et les doublons au sein d’une sous-série.',
                  ),
                ),
                const SizedBox(height: 16),
                AdminSectionTitle(
                  title: context.localized(en: 'Issues', fr: 'Anomalies'),
                  trailing: _result == null
                      ? null
                      : Text(
                          context.localized(
                            en: '${_result!.totalItems} result(s)',
                            fr: '${_result!.totalItems} résultat(s)',
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                ),
                const SizedBox(height: 10),
                _buildFilters(),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading && _result == null
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildError()
                : _buildIssueList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: constraints.maxWidth < 540 ? constraints.maxWidth : 260,
              child: DropdownButtonFormField<AdminVolumeIssueType?>(
                key: ValueKey<AdminVolumeIssueType?>(_typeFilter),
                initialValue: _typeFilter,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: context.localized(
                    en: 'Issue type',
                    fr: 'Type d’anomalie',
                  ),
                  isDense: true,
                  prefixIcon: Icon(Icons.filter_list_rounded),
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      context.localized(en: 'All types', fr: 'Tous les types'),
                    ),
                  ),
                  DropdownMenuItem(
                    value: AdminVolumeIssueType.zeroTomeNumber,
                    child: Text(
                      context.localized(
                        en: 'Number equals 0',
                        fr: 'Numéro égal à 0',
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: AdminVolumeIssueType.duplicateTomeNumber,
                    child: Text(
                      context.localized(
                        en: 'Duplicate number',
                        fr: 'Numéro en double',
                      ),
                    ),
                  ),
                ],
                onChanged: _loading
                    ? null
                    : (value) {
                        setState(() {
                          _typeFilter = value;
                        });
                        _loadIssues(page: 1);
                      },
              ),
            ),
            SegmentedButton<AdminVolumeIssueStatus>(
              segments: [
                ButtonSegment(
                  value: AdminVolumeIssueStatus.open,
                  icon: Icon(Icons.error_outline_rounded),
                  label: Text(context.localized(en: 'Open', fr: 'Ouvertes')),
                ),
                ButtonSegment(
                  value: AdminVolumeIssueStatus.resolved,
                  icon: Icon(Icons.task_alt_rounded),
                  label: Text(
                    context.localized(en: 'Resolved', fr: 'Résolues'),
                  ),
                ),
              ],
              selected: <AdminVolumeIssueStatus>{_statusFilter},
              onSelectionChanged: _loading
                  ? null
                  : (selection) {
                      setState(() {
                        _statusFilter = selection.first;
                      });
                      _loadIssues(page: 1);
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    final error = _error;
    final permissionDenied =
        error is AdminApiException && error.statusCode == 403;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AdminStatusBanner(
            icon: permissionDenied
                ? Icons.lock_outline_rounded
                : Icons.cloud_off_outlined,
            title: permissionDenied
                ? context.localized(
                    en: 'Permission required',
                    fr: 'Permission requise',
                  )
                : context.localized(
                    en: 'Unable to load',
                    fr: 'Chargement impossible',
                  ),
            message: permissionDenied
                ? context.localized(
                    en: 'The volume_quality.read permission is required.',
                    fr: 'La permission volume_quality.read est nécessaire.',
                  )
                : redactSensitiveText(error),
            tone: AdminBannerTone.error,
            trailing: IconButton(
              onPressed: _loadIssues,
              tooltip: context.localized(en: 'Retry', fr: 'Réessayer'),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIssueList() {
    final result = _result;
    final issues = result?.issues ?? const <AdminVolumeIssue>[];
    if (issues.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AdminStatusBanner(
            icon: Icons.check_circle_outline_rounded,
            title: context.localized(
              en: 'Everything is in order',
              fr: 'Tout est en ordre',
            ),
            message: context.localized(
              en: 'No issue matches the selected filters.',
              fr: 'Aucune anomalie ne correspond aux filtres sélectionnés.',
            ),
            tone: AdminBannerTone.success,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: issues.length + 1,
      itemBuilder: (context, index) {
        if (index == issues.length) return _buildPagination(result!);
        return _VolumeIssueCard(
          issue: issues[index],
          isBusy: _busyIssueId == issues[index].id,
          busyVolumeId: _busyVolumeId,
          onResolve: () => _resolveIssue(issues[index]),
          onReopen: () => _reopenIssue(issues[index]),
          onEditVolume: (volume) => _editVolume(issues[index], volume),
        );
      },
    );
  }

  Widget _buildPagination(AdminVolumeIssuePage result) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _loading || result.page <= 1
                ? null
                : () => _loadIssues(page: result.page - 1),
            tooltip: context.localized(
              en: 'Previous page',
              fr: 'Page précédente',
            ),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text('${result.page} / ${result.totalPages} · ${result.totalItems}'),
          IconButton(
            onPressed: _loading || result.page >= result.totalPages
                ? null
                : () => _loadIssues(page: result.page + 1),
            tooltip: context.localized(en: 'Next page', fr: 'Page suivante'),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _VolumeIssueCard extends StatelessWidget {
  const _VolumeIssueCard({
    required this.issue,
    required this.isBusy,
    required this.busyVolumeId,
    required this.onResolve,
    required this.onReopen,
    required this.onEditVolume,
  });

  final AdminVolumeIssue issue;
  final bool isBusy;
  final String? busyVolumeId;
  final VoidCallback onResolve;
  final VoidCallback onReopen;
  final ValueChanged<AdminIssueVolume> onEditVolume;

  @override
  Widget build(BuildContext context) {
    final isResolved = issue.status == AdminVolumeIssueStatus.resolved;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        (isResolved
                                ? const Color(0xFF26834A)
                                : colorScheme.error)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isResolved
                        ? Icons.task_alt_rounded
                        : Icons.warning_amber_rounded,
                    color: isResolved
                        ? const Color(0xFF26834A)
                        : colorScheme.error,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _issueTitle(context, issue.type),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        issue.subSeriesTitle.isNotEmpty
                            ? issue.subSeriesTitle
                            : issue.subSeriesId.isNotEmpty
                            ? context.localized(
                                en: 'Sub-series ${issue.subSeriesId}',
                                fr: 'Sous-série ${issue.subSeriesId}',
                              )
                            : context.localized(
                                en: 'Sub-series not specified',
                                fr: 'Sous-série non renseignée',
                              ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  backgroundColor:
                      (isResolved ? const Color(0xFF26834A) : colorScheme.error)
                          .withValues(alpha: 0.09),
                  side: BorderSide.none,
                  label: Text(
                    isResolved
                        ? context.localized(en: 'Resolved', fr: 'Résolue')
                        : context.localized(en: 'Open', fr: 'Ouverte'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _IssueMetadata(
                  icon: Icons.numbers_rounded,
                  label: context.localized(
                    en: 'Volume ${_formatNumber(issue.tomeNumber)}',
                    fr: 'Tome ${_formatNumber(issue.tomeNumber)}',
                  ),
                ),
                _IssueMetadata(
                  icon: Icons.menu_book_outlined,
                  label: context.localized(
                    en: '${issue.volumes.length} volume(s)',
                    fr: '${issue.volumes.length} volume(s)',
                  ),
                ),
                if (!issue.isCurrentlyPresent)
                  _IssueMetadata(
                    icon: Icons.visibility_off_outlined,
                    label: context.localized(
                      en: 'Missing from the latest scan',
                      fr: 'Absente au dernier contrôle',
                    ),
                  ),
                if (issue.lastDetectedAt != null)
                  _IssueMetadata(
                    icon: Icons.schedule_rounded,
                    label: context.localized(
                      en: 'Detected ${_formatDate(context, issue.lastDetectedAt!)}',
                      fr: 'Détectée ${_formatDate(context, issue.lastDetectedAt!)}',
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            for (var index = 0; index < issue.volumes.length; index++) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SafeNetworkImage(
                    imageUrl: issue.volumes[index].coverUrl,
                    width: 42,
                    height: 58,
                  ),
                ),
                title: Text(
                  issue.volumes[index].title.isEmpty
                      ? context.localized(
                          en: 'Volume ${issue.volumes[index].id}',
                          fr: 'Volume ${issue.volumes[index].id}',
                        )
                      : issue.volumes[index].title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${context.localized(
                    en: 'Volume ${_formatNumber(issue.volumes[index].tomeNumber)}',
                    fr: 'Tome ${_formatNumber(issue.volumes[index].tomeNumber)}',
                  )}${issue.volumes[index].ean.isEmpty ? '' : ' · EAN ${issue.volumes[index].ean}'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed:
                          issue.volumes[index].id.isEmpty ||
                              busyVolumeId != null
                          ? null
                          : () => onEditVolume(issue.volumes[index]),
                      tooltip: context.localized(
                        en: 'Correct volume',
                        fr: 'Corriger le volume',
                      ),
                      icon: busyVolumeId == issue.volumes[index].id
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      onPressed: issue.volumes[index].id.isEmpty
                          ? null
                          : () => pushOrGo(
                              context,
                              '/volume/${issue.volumes[index].id}',
                            ),
                      tooltip: context.localized(
                        en: 'Open volume',
                        fr: 'Ouvrir le volume',
                      ),
                      icon: const Icon(Icons.open_in_new_rounded),
                    ),
                  ],
                ),
              ),
              if (index < issue.volumes.length - 1)
                const Divider(height: 1, indent: 54),
            ],
            if ((issue.resolutionNote ?? '').isNotEmpty) ...[
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.localized(
                        en: 'Resolution note',
                        fr: 'Note de résolution',
                      ),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(issue.resolutionNote!),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: isResolved
                  ? OutlinedButton.icon(
                      onPressed: isBusy ? null : onReopen,
                      icon: const Icon(Icons.undo_rounded),
                      label: Text(
                        context.localized(en: 'Reopen', fr: 'Rouvrir'),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: isBusy ? null : onResolve,
                      icon: isBusy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.task_alt_rounded),
                      label: Text(
                        context.localized(
                          en: 'Mark as resolved',
                          fr: 'Marquer résolue',
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _issueTitle(BuildContext context, AdminVolumeIssueType type) {
    return switch (type) {
      AdminVolumeIssueType.zeroTomeNumber => context.localized(
        en: 'Volume number equals 0',
        fr: 'Numéro de tome égal à 0',
      ),
      AdminVolumeIssueType.duplicateTomeNumber => context.localized(
        en: 'Volume number used multiple times',
        fr: 'Numéro de tome utilisé plusieurs fois',
      ),
      AdminVolumeIssueType.unknown => context.localized(
        en: 'Volume issue',
        fr: 'Anomalie de volume',
      ),
    };
  }

  String _formatNumber(num? value) {
    if (value == null) return '-';
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  String _formatDate(BuildContext context, DateTime value) {
    return MaterialLocalizations.of(context).formatMediumDate(value.toLocal());
  }
}

class _VolumeQualityEditResult {
  const _VolumeQualityEditResult({
    required this.tomeNumber,
    required this.subSeriesId,
  });

  final num? tomeNumber;
  final String? subSeriesId;
}

class _EditVolumeQualityDialog extends StatefulWidget {
  const _EditVolumeQualityDialog({required this.issue, required this.volume});

  final AdminVolumeIssue issue;
  final AdminIssueVolume volume;

  @override
  State<_EditVolumeQualityDialog> createState() =>
      _EditVolumeQualityDialogState();
}

class _EditVolumeQualityDialogState extends State<_EditVolumeQualityDialog> {
  late final TextEditingController _tomeController;
  AdminRelationOption? _subSeries;
  String? _error;

  @override
  void initState() {
    super.initState();
    final tomeNumber = widget.volume.tomeNumber;
    _tomeController = TextEditingController(
      text: tomeNumber == null
          ? ''
          : tomeNumber == tomeNumber.roundToDouble()
          ? tomeNumber.toInt().toString()
          : tomeNumber.toString(),
    );
    if (widget.issue.subSeriesId.isNotEmpty) {
      _subSeries = AdminRelationOption(
        id: widget.issue.subSeriesId,
        label: widget.issue.subSeriesTitle.isEmpty
            ? widget.issue.subSeriesId
            : widget.issue.subSeriesTitle,
        detail: '',
        resource: AdminRelationResource.subSeries,
      );
    }
  }

  @override
  void dispose() {
    _tomeController.dispose();
    super.dispose();
  }

  void _submit() {
    final tomeNumber = num.tryParse(
      _tomeController.text.trim().replaceAll(',', '.'),
    );
    if (tomeNumber == null || !tomeNumber.isFinite || tomeNumber < 0) {
      setState(
        () => _error = context.localized(
          en: 'Enter a positive or zero volume number.',
          fr: 'Saisissez un numéro de tome positif ou nul.',
        ),
      );
      return;
    }

    final tomeChanged = tomeNumber != widget.volume.tomeNumber;
    final selectedSubSeriesId = _subSeries?.id;
    final subSeriesChanged =
        selectedSubSeriesId != null &&
        selectedSubSeriesId != widget.issue.subSeriesId;
    if (!tomeChanged && !subSeriesChanged) {
      setState(
        () => _error = context.localized(
          en: 'Change at least one value before saving.',
          fr: 'Modifiez au moins une valeur avant d’enregistrer.',
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      _VolumeQualityEditResult(
        tomeNumber: tomeChanged ? tomeNumber : null,
        subSeriesId: subSeriesChanged ? selectedSubSeriesId : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.volume.title.isEmpty
            ? context.localized(en: 'Correct volume', fr: 'Corriger le volume')
            : context.localized(
                en: 'Correct ${widget.volume.title}',
                fr: 'Corriger ${widget.volume.title}',
              ),
      ),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tomeController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: context.localized(
                    en: 'Volume number',
                    fr: 'Numéro de tome',
                  ),
                  prefixIcon: Icon(Icons.numbers_rounded),
                ),
              ),
              const SizedBox(height: 14),
              AdminRelationPickerField(
                label: context.localized(en: 'Sub-series', fr: 'Sous-série'),
                resource: AdminRelationResource.subSeries,
                selected: <AdminRelationOption>[
                  if (_subSeries != null) _subSeries!,
                ],
                helperText: context.localized(
                  en: 'Search for the sub-series by title instead of its ID.',
                  fr: 'Recherchez la sous-série par son titre plutôt que par son ID.',
                ),
                onChanged: (value) => setState(
                  () => _subSeries = value.isEmpty ? null : value.first,
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
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.localized(en: 'Cancel', fr: 'Annuler')),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save_outlined),
          label: Text(context.localized(en: 'Save', fr: 'Enregistrer')),
        ),
      ],
    );
  }
}

class _IssueMetadata extends StatelessWidget {
  const _IssueMetadata({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
