import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';

List<String> parseAdminList(String value) {
  return value
      .split(RegExp(r'[,;\n]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

Map<String, String> parseAdminMetadata(String value) {
  final result = <String, String>{};
  for (final rawLine in value.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    final separator = line.indexOf('=');
    if (separator <= 0 || separator == line.length - 1) {
      throw AdminInputException(
        RuntimeLocalization.text(
          en: 'Each item must use the key=value format.',
          fr: 'Chaque information doit respecter le format clé=valeur.',
        ),
      );
    }
    result[line.substring(0, separator).trim()] = line
        .substring(separator + 1)
        .trim();
  }
  return result;
}

class AdminRelationPickerField extends StatelessWidget {
  const AdminRelationPickerField({
    required this.label,
    required this.resource,
    required this.selected,
    required this.onChanged,
    this.allowMultiple = false,
    this.required = false,
    this.helperText,
    super.key,
  });

  final String label;
  final AdminRelationResource resource;
  final List<AdminRelationOption> selected;
  final ValueChanged<List<AdminRelationOption>> onChanged;
  final bool allowMultiple;
  final bool required;
  final String? helperText;

  Future<void> _openSearch(BuildContext context) async {
    final option = await showDialog<AdminRelationOption>(
      context: context,
      builder: (context) => _AdminRelationSearchDialog(resource: resource),
    );
    if (option == null) return;
    if (allowMultiple) {
      if (selected.any((item) => item.id == option.id)) return;
      onChanged(<AdminRelationOption>[...selected, option]);
    } else {
      onChanged(<AdminRelationOption>[option]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$label${required ? ' *' : ''}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              TextButton.icon(
                onPressed: () => _openSearch(context),
                icon: const Icon(Icons.search_rounded),
                label: Text(
                  selected.isEmpty
                      ? context.localized(en: 'Search', fr: 'Rechercher')
                      : context.localized(en: 'Change', fr: 'Changer'),
                ),
              ),
            ],
          ),
          if (helperText != null) ...[
            const SizedBox(height: 2),
            Text(helperText!, style: Theme.of(context).textTheme.bodySmall),
          ],
          if (selected.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              context.localized(en: 'No selection', fr: 'Aucune sélection'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selected
                  .map(
                    (option) => InputChip(
                      label: Text(option.label),
                      tooltip: '${option.label}\n${option.id}',
                      onDeleted: () => onChanged(
                        selected.where((item) => item.id != option.id).toList(),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _AdminRelationSearchDialog extends StatefulWidget {
  const _AdminRelationSearchDialog({required this.resource});

  final AdminRelationResource resource;

  @override
  State<_AdminRelationSearchDialog> createState() =>
      _AdminRelationSearchDialogState();
}

class _AdminRelationSearchDialogState
    extends State<_AdminRelationSearchDialog> {
  final AdminConnector _admin = AdminConnector();
  final TextEditingController _queryController = TextEditingController();

  List<AdminRelationOption> _results = const <AdminRelationOption>[];
  Object? _error;
  bool _loading = false;
  bool _searched = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.length < 2) {
      setState(() {
        _error = context.localized(
          en: 'Enter at least two characters.',
          fr: 'Saisissez au moins deux caractères.',
        );
        _searched = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await _admin.searchRelations(widget.resource, query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searched = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _results = const <AdminRelationOption>[];
        _searched = true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        context.localized(
          en: 'Search · ${widget.resource.localizedLabel('en')}',
          fr: 'Rechercher · ${widget.resource.localizedLabel('fr')}',
        ),
      ),
      content: SizedBox(
        width: 620,
        height: 430,
        child: Column(
          children: [
            TextField(
              controller: _queryController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _loading ? null : _search(),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: context.localized(
                  en: 'Title, name or related information',
                  fr: 'Titre, nom ou information associée',
                ),
                hintText: widget.resource == AdminRelationResource.volumes
                    ? context.localized(
                        en: 'Title, volume number, summary or sub-series',
                        fr: 'Titre, tome, résumé ou sous-série',
                      )
                    : context.localized(
                        en: 'Enter at least two characters',
                        fr: 'Saisissez au moins deux caractères',
                      ),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  onPressed: _loading ? null : _search,
                  tooltip: context.localized(en: 'Search', fr: 'Rechercher'),
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                redactSensitiveText(_error),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: !_searched
                  ? Center(
                      child: Text(
                        context.localized(
                          en: 'Start a search to display IDs.',
                          fr: 'Lancez une recherche pour afficher les IDs.',
                        ),
                      ),
                    )
                  : _results.isEmpty
                  ? Center(
                      child: Text(
                        context.localized(
                          en: 'No results.',
                          fr: 'Aucun résultat.',
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final option = _results[index];
                        return ListTile(
                          leading: const Icon(Icons.tag_rounded),
                          title: Text(option.label),
                          subtitle: Text(
                            <String>[
                              if (option.detail.isNotEmpty) option.detail,
                              context.localized(
                                en: 'ID: ${option.id}',
                                fr: 'ID : ${option.id}',
                              ),
                            ].join('\n'),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.localized(en: 'Close', fr: 'Fermer')),
        ),
      ],
    );
  }
}

class AdminResponsiveFields extends StatelessWidget {
  const AdminResponsiveFields({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(height: 12),
                children[index],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) const SizedBox(width: 12),
              Expanded(child: children[index]),
            ],
          ],
        );
      },
    );
  }
}

class AdminDateField extends StatelessWidget {
  const AdminDateField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey<DateTime?>(value),
      readOnly: true,
      initialValue: value == null
          ? ''
          : DateFormat('dd/MM/yyyy').format(value!),
      onTap: () async {
        final now = DateTime.now();
        final selected = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(1900),
          lastDate: DateTime(now.year + 20, 12, 31),
        );
        if (selected != null) onChanged(selected);
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        prefixIcon: const Icon(Icons.event_outlined),
        suffixIcon: value == null
            ? null
            : IconButton(
                onPressed: () => onChanged(null),
                tooltip: context.localized(
                  en: 'Clear date',
                  fr: 'Effacer la date',
                ),
                icon: const Icon(Icons.clear_rounded),
              ),
      ),
    );
  }
}

class AdminAdultContentField extends StatelessWidget {
  const AdminAdultContentField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        title: Text(
          context.localized(
            en: 'Adult-only content',
            fr: 'Contenu réservé aux adultes',
          ),
        ),
        subtitle: Text(
          context.localized(
            en: 'Hidden when adult content is disabled.',
            fr: 'Masqué lorsque le contenu adulte est désactivé.',
          ),
        ),
        secondary: const Icon(Icons.no_adult_content_outlined),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
