import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_form_helpers.dart';

class AdminCreateSubSeriesPage extends StatefulWidget {
  const AdminCreateSubSeriesPage({super.key});

  @override
  State<AdminCreateSubSeriesPage> createState() =>
      _AdminCreateSubSeriesPageState();
}

class _AdminCreateSubSeriesPageState extends State<AdminCreateSubSeriesPage> {
  final AdminConnector _admin = AdminConnector();
  final _titleFr = TextEditingController();
  final _titleJp = TextEditingController();
  final _titleEn = TextEditingController();
  final _cover = TextEditingController();

  AdminRelationOption? _series;
  AdminRelationOption? _editor;
  List<AdminRelationOption> _authors = const <AdminRelationOption>[];
  List<AdminRelationOption> _genres = const <AdminRelationOption>[];

  DateTime? _firstPublicationDate;
  String _support = 'manga';
  String _status = 'OnGoing';
  bool _over18 = false;
  bool _loading = false;
  bool _messageIsError = false;
  String _message = '';

  static const _supports = <String>[
    'manga',
    'artbook',
    'roman',
    'lightNovel',
    'novel',
    'boxSet',
    'other',
  ];
  static const _statuses = <String>[
    'OnGoing',
    'Completed',
    'Hyatus',
    'Canceled',
    'CommingSoon',
    'Unknown',
  ];

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _titleFr,
      _titleJp,
      _titleEn,
      _cover,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _message = '';
    });
    try {
      await _admin.createSubSeries(
        titleFr: _titleFr.text,
        titleJp: _titleJp.text,
        titleEn: _titleEn.text,
        coverUrl: _cover.text,
        seriesId: _series?.id ?? '',
        authorIds: _authors.map((item) => item.id).toList(),
        editorId: _editor?.id,
        genreIds: _genres.map((item) => item.id).toList(),
        support: _support,
        status: _status,
        firstPublicationDate: _firstPublicationDate,
        over18: _over18,
      );
      if (!mounted) return;
      for (final controller in <TextEditingController>[
        _titleFr,
        _titleJp,
        _titleEn,
        _cover,
      ]) {
        controller.clear();
      }
      setState(() {
        _firstPublicationDate = null;
        _series = null;
        _editor = null;
        _authors = const <AdminRelationOption>[];
        _genres = const <AdminRelationOption>[];
        _support = 'manga';
        _status = 'OnGoing';
        _over18 = false;
        _loading = false;
        _messageIsError = false;
        _message = context.localized(
          en: 'Sub-series created successfully.',
          fr: 'Sous-série créée avec succès.',
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _messageIsError = true;
        _message = redactSensitiveText(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormView(
      children: [
        AdminPageHeader(
          icon: Icons.account_tree_outlined,
          title: context.localized(
            en: 'New sub-series',
            fr: 'Nouvelle sous-série',
          ),
          description: context.localized(
            en: 'Create an edition or collection linked to a series.',
            fr: 'Créez une édition ou collection rattachée à une série.',
          ),
        ),
        const SizedBox(height: 20),
        AdminResponsiveFields(
          children: [
            _textField(
              _titleFr,
              context.localized(en: 'French title *', fr: 'Titre français *'),
              Icons.title_rounded,
            ),
            _textField(
              _titleEn,
              context.localized(en: 'English title', fr: 'Titre anglais'),
              Icons.translate_rounded,
            ),
            _textField(
              _titleJp,
              context.localized(en: 'Japanese title', fr: 'Titre japonais'),
              Icons.translate_rounded,
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cover,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.localized(
              en: 'HTTPS cover URL',
              fr: 'URL HTTPS de la couverture',
            ),
            prefixIcon: Icon(Icons.image_outlined),
          ),
        ),
        const SizedBox(height: 12),
        AdminResponsiveFields(
          children: [
            AdminRelationPickerField(
              label: context.localized(
                en: 'Parent series',
                fr: 'Série parente',
              ),
              resource: AdminRelationResource.series,
              selected: <AdminRelationOption>[
                if (_series != null) _series!,
              ],
              required: true,
              onChanged: (value) => setState(
                () => _series = value.isEmpty ? null : value.first,
              ),
            ),
            AdminRelationPickerField(
              label: context.localized(en: 'Publisher', fr: 'Éditeur'),
              resource: AdminRelationResource.editors,
              selected: <AdminRelationOption>[
                if (_editor != null) _editor!,
              ],
              onChanged: (value) => setState(
                () => _editor = value.isEmpty ? null : value.first,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AdminResponsiveFields(
          children: [
            AdminRelationPickerField(
              label: context.localized(en: 'Authors', fr: 'Auteurs'),
              resource: AdminRelationResource.authors,
              selected: _authors,
              allowMultiple: true,
              onChanged: (value) => setState(() => _authors = value),
            ),
            AdminRelationPickerField(
              label: context.localized(en: 'Genres', fr: 'Genres'),
              resource: AdminRelationResource.genres,
              selected: _genres,
              allowMultiple: true,
              onChanged: (value) => setState(() => _genres = value),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AdminResponsiveFields(
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey<String>(_support),
              initialValue: _support,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: context.localized(en: 'Format *', fr: 'Support *'),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _supports
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(_localizedSupport(context, value)),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _support = value ?? _support),
            ),
            DropdownButtonFormField<String>(
              key: ValueKey<String>(_status),
              initialValue: _status,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: context.localized(en: 'Status *', fr: 'Statut *'),
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: _statuses
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(_localizedStatus(context, value)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AdminDateField(
          label: context.localized(
            en: 'First publication',
            fr: 'Première publication',
          ),
          value: _firstPublicationDate,
          onChanged: (value) => setState(() => _firstPublicationDate = value),
        ),
        const SizedBox(height: 12),
        AdminAdultContentField(
          value: _over18,
          onChanged: (value) => setState(() => _over18 = value),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _submit,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            context.localized(
              en: 'Create sub-series',
              fr: 'Créer la sous-série',
            ),
          ),
        ),
        if (_loading) ...[
          const SizedBox(height: 14),
          const LinearProgressIndicator(),
        ] else if (_message.isNotEmpty) ...[
          const SizedBox(height: 14),
          AdminFeedback(message: _message, isError: _messageIsError),
        ],
      ],
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      maxLength: 200,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

String _localizedSupport(BuildContext context, String value) {
  const english = <String, String>{
    'manga': 'Manga',
    'artbook': 'Art book',
    'roman': 'Book',
    'lightNovel': 'Light novel',
    'novel': 'Novel',
    'boxSet': 'Box set',
    'other': 'Other',
  };
  const french = <String, String>{
    'manga': 'Manga',
    'artbook': 'Artbook',
    'roman': 'Roman',
    'lightNovel': 'Light novel',
    'novel': 'Nouvelle',
    'boxSet': 'Coffret',
    'other': 'Autre',
  };
  return context.localized(
    en: english[value] ?? value,
    fr: french[value] ?? value,
  );
}

String _localizedStatus(BuildContext context, String value) {
  const english = <String, String>{
    'OnGoing': 'Ongoing',
    'Completed': 'Completed',
    'Hyatus': 'Hiatus',
    'Canceled': 'Cancelled',
    'CommingSoon': 'Coming soon',
    'Unknown': 'Unknown',
  };
  const french = <String, String>{
    'OnGoing': 'En cours',
    'Completed': 'Terminée',
    'Hyatus': 'En pause',
    'Canceled': 'Annulée',
    'CommingSoon': 'À venir',
    'Unknown': 'Inconnu',
  };
  return context.localized(
    en: english[value] ?? value,
    fr: french[value] ?? value,
  );
}
