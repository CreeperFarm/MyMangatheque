import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_form_helpers.dart';

class AdminCreateSeriesPage extends StatefulWidget {
  const AdminCreateSeriesPage({super.key});

  @override
  State<AdminCreateSeriesPage> createState() => _AdminCreateSeriesPageState();
}

class _AdminCreateSeriesPageState extends State<AdminCreateSeriesPage> {
  final AdminConnector _admin = AdminConnector();
  final _titleFr = TextEditingController();
  final _titleJp = TextEditingController();
  final _titleEn = TextEditingController();
  final _altTitles = TextEditingController();
  final _cover = TextEditingController();

  List<AdminRelationOption> _authors = const <AdminRelationOption>[];
  List<AdminRelationOption> _editors = const <AdminRelationOption>[];
  List<AdminRelationOption> _genres = const <AdminRelationOption>[];

  DateTime? _firstPublicationDate;
  bool _over18 = false;
  bool _loading = false;
  bool _messageIsError = false;
  String _message = '';

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _titleFr,
      _titleJp,
      _titleEn,
      _altTitles,
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
      await _admin.createSeries(
        titleFr: _titleFr.text,
        titleJp: _titleJp.text,
        titleEn: _titleEn.text,
        altTitles: parseAdminList(_altTitles.text),
        coverUrl: _cover.text,
        authorIds: _authors.map((item) => item.id).toList(),
        editorIds: _editors.map((item) => item.id).toList(),
        genreIds: _genres.map((item) => item.id).toList(),
        firstPublicationDate: _firstPublicationDate,
        over18: _over18,
      );
      if (!mounted) return;
      for (final controller in <TextEditingController>[
        _titleFr,
        _titleJp,
        _titleEn,
        _altTitles,
        _cover,
      ]) {
        controller.clear();
      }
      setState(() {
        _firstPublicationDate = null;
        _over18 = false;
        _authors = const <AdminRelationOption>[];
        _editors = const <AdminRelationOption>[];
        _genres = const <AdminRelationOption>[];
        _loading = false;
        _messageIsError = false;
        _message = context.localized(
          en: 'Series created successfully.',
          fr: 'Série créée avec succès.',
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
          icon: Icons.collections_bookmark_outlined,
          title: context.localized(en: 'New series', fr: 'Nouvelle série'),
          description: context.localized(
            en: 'Create the main work and link its contributors.',
            fr: 'Créez l’œuvre principale et rattachez ses contributeurs.',
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
          controller: _altTitles,
          maxLines: 2,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.localized(
              en: 'Alternative titles',
              fr: 'Titres alternatifs',
            ),
            helperText: context.localized(
              en: 'Separate values with a comma or a new line.',
              fr: 'Séparer les valeurs par une virgule ou une ligne.',
            ),
            prefixIcon: Icon(Icons.format_list_bulleted_rounded),
          ),
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
              label: context.localized(en: 'Authors', fr: 'Auteurs'),
              resource: AdminRelationResource.authors,
              selected: _authors,
              allowMultiple: true,
              onChanged: (value) => setState(() => _authors = value),
            ),
            AdminRelationPickerField(
              label: context.localized(en: 'Publishers', fr: 'Éditeurs'),
              resource: AdminRelationResource.editors,
              selected: _editors,
              allowMultiple: true,
              onChanged: (value) => setState(() => _editors = value),
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
            context.localized(en: 'Create series', fr: 'Créer la série'),
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
