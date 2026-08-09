import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/import/collection_import_models.dart';
import 'package:mymangatheque/src/back/services/import/collection_import_service.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';

class CollectionImportPage extends StatefulWidget {
  const CollectionImportPage({super.key, this.service});

  final CollectionImportService? service;

  @override
  State<CollectionImportPage> createState() => _CollectionImportPageState();
}

class _CollectionImportPageState extends State<CollectionImportPage> {
  late final CollectionImportService _service =
      widget.service ?? CollectionImportService();
  final TextEditingController _contentController = TextEditingController();
  CollectionImportSource _source = CollectionImportSource.mangacollec;
  CollectionImportPreview? _preview;
  List<CollectionImportHistoryEntry> _history =
      const <CollectionImportHistoryEntry>[];
  CollectionImportCancellationToken? _cancellation;
  bool _busy = false;
  int _completed = 0;
  int _total = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadHistory());
  }

  @override
  void dispose() {
    _cancellation?.cancel();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await _service.history();
    if (!mounted) return;
    setState(() => _history = history);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['csv', 'json', 'txt'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() {
        _error = context.localized(
          en: 'The selected file could not be read.',
          fr: 'Le fichier sélectionné n’a pas pu être lu.',
        );
      });
      return;
    }
    final extension = (file.extension ?? '').toLowerCase();
    setState(() {
      _source = extension == 'json'
          ? CollectionImportSource.json
          : extension == 'csv'
          ? CollectionImportSource.csv
          : CollectionImportSource.text;
      _contentController.text = utf8.decode(bytes, allowMalformed: true);
      _error = null;
    });
  }

  Future<void> _preparePreview() async {
    if (_busy) return;
    final cancellation = CollectionImportCancellationToken();
    setState(() {
      _busy = true;
      _error = null;
      _completed = 0;
      _total = 0;
      _cancellation = cancellation;
    });
    try {
      final entries = _source == CollectionImportSource.mangacollec
          ? await _service.loadMangacollecProfile(_contentController.text)
          : _service.parse(_source, _contentController.text);
      if (!mounted || cancellation.isCancelled) return;
      setState(() => _total = entries.length);
      final preview = await _service.buildPreview(
        _source,
        entries,
        cancellation: cancellation,
        onProgress: (completed, total, _) {
          if (!mounted) return;
          setState(() {
            _completed = completed;
            _total = total;
          });
        },
      );
      if (!mounted || cancellation.isCancelled) return;
      setState(() => _preview = preview);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = redactSensitiveText(error));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _cancellation = null;
        });
      }
    }
  }

  Future<void> _executeImport() async {
    final preview = _preview;
    if (_busy || preview == null) return;
    final importable = preview.items.where((item) => item.canImport).length;
    if (importable == 0) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.localized(
            en: 'Import $importable volumes?',
            fr: 'Importer $importable tomes ?',
          ),
        ),
        content: Text(
          context.localized(
            en: 'Only matched, non-duplicate volumes will be added. Nothing will be removed.',
            fr: 'Seuls les tomes reconnus et non dupliqués seront ajoutés. Aucun élément ne sera supprimé.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.localized(en: 'Cancel', fr: 'Annuler')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.localized(en: 'Import', fr: 'Importer')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final cancellation = CollectionImportCancellationToken();
    setState(() {
      _busy = true;
      _completed = 0;
      _total = importable;
      _error = null;
      _cancellation = cancellation;
    });
    try {
      final result = await _service.execute(
        preview,
        cancellation: cancellation,
        onProgress: (completed, total, _) {
          if (!mounted) return;
          setState(() {
            _completed = completed;
            _total = total;
          });
        },
      );
      if (!mounted) return;
      setState(() => _preview = result.preview);
      await _loadHistory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.cancelled
                ? context.localized(
                    en: 'Import stopped. ${result.importedVolumeIds.length} volumes were added before cancellation.',
                    fr: 'Import arrêté. ${result.importedVolumeIds.length} tomes ont été ajoutés avant l’annulation.',
                  )
                : context.localized(
                    en: '${result.importedVolumeIds.length} volumes imported.',
                    fr: '${result.importedVolumeIds.length} tomes importés.',
                  ),
          ),
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _error = redactSensitiveText(error));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _cancellation = null;
        });
      }
    }
  }

  Future<void> _chooseCandidate(int itemIndex) async {
    final preview = _preview;
    if (preview == null) return;
    final item = preview.items[itemIndex];
    final selected = await showDialog<CollectionImportCandidate>(
      context: context,
      builder: (context) => _CandidateDialog(
        service: _service,
        initialItem: item,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _preview = _service.replaceCandidate(preview, itemIndex, selected);
    });
  }

  Future<void> _undo(CollectionImportHistoryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.localized(en: 'Undo import?', fr: 'Annuler l’import ?'),
        ),
        content: Text(
          context.localized(
            en: 'Only the ${entry.importedVolumeIds.length} volumes added by this import will be removed.',
            fr: 'Seuls les ${entry.importedVolumeIds.length} tomes ajoutés par cet import seront retirés.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.localized(en: 'Keep', fr: 'Conserver')),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.localized(en: 'Undo', fr: 'Annuler l’import')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _completed = 0;
      _total = entry.importedVolumeIds.length;
    });
    try {
      await _service.undo(
        entry,
        onProgress: (completed, total) {
          if (!mounted) return;
          setState(() {
            _completed = completed;
            _total = total;
          });
        },
      );
      await _loadHistory();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.localized(
            en: 'Import a collection',
            fr: 'Importer une collection',
          ),
        ),
        actions: [
          if (_busy)
            IconButton(
              onPressed: _cancellation?.cancel,
              tooltip: context.localized(en: 'Stop', fr: 'Arrêter'),
              icon: const Icon(Icons.stop_circle_outlined),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSourceCard(),
          if (_busy) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _total <= 0 ? null : _completed / _total,
            ),
            const SizedBox(height: 6),
            Text('$_completed / $_total', textAlign: TextAlign.center),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!),
              ),
            ),
          ],
          if (preview != null) ...[
            const SizedBox(height: 20),
            _buildPreview(preview),
          ],
          const SizedBox(height: 24),
          _buildHistory(),
        ],
      ),
    );
  }

  Widget _buildSourceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.localized(
                en: 'Choose an import source',
                fr: 'Choisissez une source d’import',
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              context.localized(
                en: 'A preview is always shown before any volume is added.',
                fr: 'Une prévisualisation est toujours affichée avant le moindre ajout.',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CollectionImportSource>(
              initialValue: _source,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: context.localized(en: 'Source', fr: 'Source'),
              ),
              items: CollectionImportSource.values
                  .map(
                    (source) => DropdownMenuItem(
                      value: source,
                      child: Text(_sourceLabel(source)),
                    ),
                  )
                  .toList(),
              onChanged: _busy
                  ? null
                  : (source) {
                      if (source == null) return;
                      setState(() {
                        _source = source;
                        _preview = null;
                        _error = null;
                      });
                    },
            ),
            const SizedBox(height: 12),
            if (_source == CollectionImportSource.csv ||
                _source == CollectionImportSource.json)
              OutlinedButton.icon(
                onPressed: _busy ? null : _pickFile,
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(
                  context.localized(
                    en: 'Choose a CSV, JSON or Mangacollec export',
                    fr: 'Choisir un CSV, JSON ou export Mangacollec',
                  ),
                ),
              ),
            TextField(
              controller: _contentController,
              enabled: !_busy,
              minLines: _source == CollectionImportSource.mangacollec ? 1 : 5,
              maxLines: _source == CollectionImportSource.mangacollec ? 1 : 12,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: _inputLabel(),
                hintText: _inputHint(),
                helperText: _source == CollectionImportSource.mangacollec
                    ? context.localized(
                        en: 'No Mangacollec password is requested or stored.',
                        fr: 'Aucun mot de passe Mangacollec n’est demandé ou stocké.',
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _busy ? null : _preparePreview,
              icon: const Icon(Icons.preview_outlined),
              label: Text(
                context.localized(
                  en: 'Analyse and preview',
                  fr: 'Analyser et prévisualiser',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(CollectionImportPreview preview) {
    final ready = preview.items.where((item) => item.canImport).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.localized(en: 'Preview', fr: 'Prévisualisation'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _countChip(Icons.check_circle_outline, ready, 'Ready', 'Prêts'),
            _countChip(
              Icons.copy_outlined,
              preview.count(CollectionImportItemStatus.duplicate),
              'Duplicates',
              'Doublons',
            ),
            _countChip(
              Icons.help_outline,
              preview.count(CollectionImportItemStatus.unmatched),
              'Unmatched',
              'Introuvables',
            ),
            _countChip(
              Icons.error_outline,
              preview.count(CollectionImportItemStatus.failed),
              'Errors',
              'Erreurs',
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < preview.items.length; index += 1)
          _buildPreviewItem(index, preview.items[index]),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _busy || ready == 0 ? null : _executeImport,
          icon: const Icon(Icons.library_add_outlined),
          label: Text(
            context.localized(
              en: 'Import $ready matched volumes',
              fr: 'Importer les $ready tomes reconnus',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewItem(int index, CollectionImportItem item) {
    final candidate = item.candidate;
    final sourceText = <String>[
      if (item.entry.title.isNotEmpty) item.entry.title,
      if (item.entry.volumeNumber != null) 'T. ${item.entry.volumeNumber}',
      if (item.entry.ean.isNotEmpty) item.entry.ean,
    ].join(' · ');
    return Card(
      child: ListTile(
        leading: candidate?.coverUrl.isNotEmpty == true
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SafeNetworkImage(
                  imageUrl: candidate!.coverUrl,
                  width: 42,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(_statusIcon(item.status)),
        title: Text(
          candidate?.title.isNotEmpty == true ? candidate!.title : sourceText,
        ),
        subtitle: Text(
          <String>[
            if (candidate != null && sourceText.isNotEmpty) sourceText,
            if (candidate?.volumeNumber != null)
              'T. ${candidate!.volumeNumber}',
            if (item.message.isNotEmpty) item.message,
          ].join('\n'),
        ),
        isThreeLine: item.message.isNotEmpty,
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'match') unawaited(_chooseCandidate(index));
            if (action == 'skip' && _preview != null) {
              setState(() {
                _preview = _service.skipItem(_preview!, index);
              });
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'match',
              child: Text(
                context.localized(
                  en: 'Change catalogue match',
                  fr: 'Modifier la correspondance',
                ),
              ),
            ),
            PopupMenuItem(
              value: 'skip',
              child: Text(context.localized(en: 'Skip', fr: 'Ignorer')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        context.localized(en: 'Import history', fr: 'Historique des imports'),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      subtitle: Text(
        context.localized(
          en: 'Only volumes added by an import can be undone.',
          fr: 'Seuls les tomes ajoutés par un import peuvent être annulés.',
        ),
      ),
      children: _history.isEmpty
          ? [
              ListTile(
                title: Text(
                  context.localized(en: 'No import yet.', fr: 'Aucun import.'),
                ),
              ),
            ]
          : _history
                .map(
                  (entry) => ListTile(
                    leading: const Icon(Icons.history_rounded),
                    title: Text(
                      '${_sourceLabel(entry.source)} · ${entry.importedVolumeIds.length}',
                    ),
                    subtitle: Text(
                      DateFormat.yMMMd(
                        Localizations.localeOf(context).languageCode,
                      ).add_Hm().format(entry.createdAt.toLocal()),
                    ),
                    trailing: entry.canUndo
                        ? TextButton(
                            onPressed: _busy ? null : () => _undo(entry),
                            child: Text(
                              context.localized(en: 'Undo', fr: 'Annuler'),
                            ),
                          )
                        : Icon(
                            Icons.check_rounded,
                            semanticLabel: context.localized(
                              en: 'Already undone',
                              fr: 'Déjà annulé',
                            ),
                          ),
                  ),
                )
                .toList(),
    );
  }

  Widget _countChip(IconData icon, int count, String en, String fr) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text('${context.localized(en: en, fr: fr)}: $count'),
    );
  }

  String _sourceLabel(CollectionImportSource source) => switch (source) {
    CollectionImportSource.mangacollec => 'Mangacollec',
    CollectionImportSource.csv => 'CSV',
    CollectionImportSource.json => 'JSON',
    CollectionImportSource.ean => 'EAN / ISBN',
    CollectionImportSource.text => context.localized(
      en: 'Text list',
      fr: 'Liste textuelle',
    ),
  };

  String _inputLabel() => switch (_source) {
    CollectionImportSource.mangacollec => context.localized(
      en: 'Mangacollec username or profile URL',
      fr: 'Pseudo ou URL du profil Mangacollec',
    ),
    CollectionImportSource.ean => 'EAN / ISBN',
    CollectionImportSource.csv => context.localized(
      en: 'CSV content',
      fr: 'Contenu CSV',
    ),
    CollectionImportSource.json => context.localized(
      en: 'JSON content',
      fr: 'Contenu JSON',
    ),
    CollectionImportSource.text => context.localized(
      en: 'One title per line',
      fr: 'Un titre par ligne',
    ),
  };

  String _inputHint() => switch (_source) {
    CollectionImportSource.mangacollec => 'https://www.mangacollec.com/...',
    CollectionImportSource.ean => '9781234567890\n9780987654321',
    CollectionImportSource.csv => 'title,tome,ean\nBerserk,1,978...',
    CollectionImportSource.json => '[{"title":"Berserk","volume":1}]',
    CollectionImportSource.text => context.localized(
      en: 'Berserk volume 1 to 12',
      fr: 'Berserk tome 1 à 12',
    ),
  };

  IconData _statusIcon(CollectionImportItemStatus status) => switch (status) {
    CollectionImportItemStatus.ready => Icons.check_circle_outline,
    CollectionImportItemStatus.duplicate => Icons.copy_outlined,
    CollectionImportItemStatus.unmatched => Icons.help_outline,
    CollectionImportItemStatus.imported => Icons.library_add_check_outlined,
    CollectionImportItemStatus.failed ||
    CollectionImportItemStatus.invalid => Icons.error_outline,
    CollectionImportItemStatus.skipped => Icons.skip_next_outlined,
    CollectionImportItemStatus.pending => Icons.hourglass_empty,
  };
}

class _CandidateDialog extends StatefulWidget {
  const _CandidateDialog({required this.service, required this.initialItem});

  final CollectionImportService service;
  final CollectionImportItem initialItem;

  @override
  State<_CandidateDialog> createState() => _CandidateDialogState();
}

class _CandidateDialogState extends State<_CandidateDialog> {
  late final TextEditingController _query = TextEditingController(
    text: widget.initialItem.entry.title,
  );
  late List<CollectionImportCandidate> _results = <CollectionImportCandidate>[
    if (widget.initialItem.candidate != null) widget.initialItem.candidate!,
    ...widget.initialItem.alternatives,
  ];
  bool _loading = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    try {
      final results = await widget.service.findCandidates(
        CollectionImportEntry(sourceIndex: 0, title: _query.text),
      );
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        context.localized(
          en: 'Choose the matching volume',
          fr: 'Choisir le tome correspondant',
        ),
      ),
      content: SizedBox(
        width: 620,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _query,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: context.localized(
                  en: 'Title, tome, summary or sub-series',
                  fr: 'Titre, tome, résumé ou sous-série',
                ),
                suffixIcon: IconButton(
                  onPressed: _loading ? null : _search,
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final candidate = _results[index];
                  return ListTile(
                    title: Text(candidate.title),
                    subtitle: Text(
                      <String>[
                        if (candidate.volumeNumber != null)
                          'T. ${candidate.volumeNumber}',
                        if (candidate.ean.isNotEmpty) candidate.ean,
                        if (candidate.subSeries.isNotEmpty) candidate.subSeries,
                      ].join(' · '),
                    ),
                    onTap: () => Navigator.pop(context, candidate),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.localized(en: 'Cancel', fr: 'Annuler')),
        ),
      ],
    );
  }
}
