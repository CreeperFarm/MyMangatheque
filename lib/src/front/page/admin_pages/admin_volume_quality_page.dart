import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
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
          content: Text('$issueCount anomalie(s) ouverte(s) détectée(s).'),
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
        title: const Text('Marquer comme résolue'),
        content: TextField(
          controller: noteController,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Note de résolution',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(noteController.text),
            child: const Text('Résoudre'),
          ),
        ],
      ),
    );
    noteController.dispose();
    if (note == null || !mounted) return;

    await _runIssueAction(
      issue.id,
      () => _admin.resolveVolumeQualityIssue(issue.id, note: note),
      'Anomalie marquée comme résolue.',
    );
  }

  Future<void> _reopenIssue(AdminVolumeIssue issue) {
    return _runIssueAction(
      issue.id,
      () => _admin.reopenVolumeQualityIssue(issue.id),
      'Anomalie rouverte.',
    );
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
        ? 'Cette clé ne possède pas la permission nécessaire.'
        : error.toString();
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
        title: 'Qualité des volumes',
        maxWidth: 680,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AdminPageHeader(
              icon: Icons.fact_check_outlined,
              title: 'Contrôle du catalogue',
              description:
                  'Une clé autorisée est nécessaire pour consulter les anomalies.',
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => pushOrGo(context, '/admin/admin_login'),
              icon: const Icon(Icons.login_rounded),
              label: const Text('Se connecter en admin ou modérateur'),
            ),
          ],
        ),
      );
    }

    return AdminPageScaffold(
      title: 'Qualité des volumes',
      scrollable: false,
      actions: [
        IconButton(
          onPressed: _loading || _scanning ? null : _scanIssues,
          tooltip: 'Détecter les anomalies',
          icon: _scanning
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.fact_check_outlined),
        ),
        IconButton(
          onPressed: _loading ? null : _loadIssues,
          tooltip: 'Actualiser',
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
                const AdminPageHeader(
                  icon: Icons.fact_check_outlined,
                  title: 'Contrôle du catalogue',
                  description:
                      'Repérez les numéros à zéro et les doublons au sein d’une sous-série.',
                ),
                const SizedBox(height: 16),
                AdminSectionTitle(
                  title: 'Anomalies',
                  trailing: _result == null
                      ? null
                      : Text(
                          '${_result!.totalItems} résultat(s)',
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
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Type d’anomalie',
                  isDense: true,
                  prefixIcon: Icon(Icons.filter_list_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tous les types')),
                  DropdownMenuItem(
                    value: AdminVolumeIssueType.zeroTomeNumber,
                    child: Text('Numéro égal à 0'),
                  ),
                  DropdownMenuItem(
                    value: AdminVolumeIssueType.duplicateTomeNumber,
                    child: Text('Numéro en double'),
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
              segments: const [
                ButtonSegment(
                  value: AdminVolumeIssueStatus.open,
                  icon: Icon(Icons.error_outline_rounded),
                  label: Text('Ouvertes'),
                ),
                ButtonSegment(
                  value: AdminVolumeIssueStatus.resolved,
                  icon: Icon(Icons.task_alt_rounded),
                  label: Text('Résolues'),
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
                ? 'Permission requise'
                : 'Chargement impossible',
            message: permissionDenied
                ? 'La permission volume_quality.read est nécessaire.'
                : error.toString(),
            tone: AdminBannerTone.error,
            trailing: IconButton(
              onPressed: _loadIssues,
              tooltip: 'Réessayer',
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
          child: const AdminStatusBanner(
            icon: Icons.check_circle_outline_rounded,
            title: 'Tout est en ordre',
            message: 'Aucune anomalie ne correspond aux filtres sélectionnés.',
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
          onResolve: () => _resolveIssue(issues[index]),
          onReopen: () => _reopenIssue(issues[index]),
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
            tooltip: 'Page précédente',
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text('${result.page} / ${result.totalPages} · ${result.totalItems}'),
          IconButton(
            onPressed: _loading || result.page >= result.totalPages
                ? null
                : () => _loadIssues(page: result.page + 1),
            tooltip: 'Page suivante',
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
    required this.onResolve,
    required this.onReopen,
  });

  final AdminVolumeIssue issue;
  final bool isBusy;
  final VoidCallback onResolve;
  final VoidCallback onReopen;

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
                        _issueTitle(issue.type),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        issue.subSeriesTitle.isNotEmpty
                            ? issue.subSeriesTitle
                            : issue.subSeriesId.isNotEmpty
                            ? 'Sous-série ${issue.subSeriesId}'
                            : 'Sous-série non renseignée',
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
                  label: Text(isResolved ? 'Résolue' : 'Ouverte'),
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
                  label: 'Tome ${_formatNumber(issue.tomeNumber)}',
                ),
                _IssueMetadata(
                  icon: Icons.menu_book_outlined,
                  label: '${issue.volumes.length} volume(s)',
                ),
                if (!issue.isCurrentlyPresent)
                  const _IssueMetadata(
                    icon: Icons.visibility_off_outlined,
                    label: 'Absente au dernier contrôle',
                  ),
                if (issue.lastDetectedAt != null)
                  _IssueMetadata(
                    icon: Icons.schedule_rounded,
                    label:
                        'Détectée ${_formatDate(context, issue.lastDetectedAt!)}',
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
                      ? 'Volume ${issue.volumes[index].id}'
                      : issue.volumes[index].title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Tome ${_formatNumber(issue.volumes[index].tomeNumber)}'
                  '${issue.volumes[index].ean.isEmpty ? '' : ' · EAN ${issue.volumes[index].ean}'}',
                ),
                trailing: IconButton(
                  onPressed: issue.volumes[index].id.isEmpty
                      ? null
                      : () => pushOrGo(
                          context,
                          '/volume/${issue.volumes[index].id}',
                        ),
                  tooltip: 'Ouvrir le volume',
                  icon: const Icon(Icons.open_in_new_rounded),
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
                      'Note de résolution',
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
                      label: const Text('Rouvrir'),
                    )
                  : FilledButton.icon(
                      onPressed: isBusy ? null : onResolve,
                      icon: isBusy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.task_alt_rounded),
                      label: const Text('Marquer résolue'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _issueTitle(AdminVolumeIssueType type) {
    return switch (type) {
      AdminVolumeIssueType.zeroTomeNumber => 'Numéro de tome égal à 0',
      AdminVolumeIssueType.duplicateTomeNumber =>
        'Numéro de tome utilisé plusieurs fois',
      AdminVolumeIssueType.unknown => 'Anomalie de volume',
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
