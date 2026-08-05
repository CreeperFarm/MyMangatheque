import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
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
  final _authors = TextEditingController();
  final _editors = TextEditingController();
  final _genres = TextEditingController();

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
      _authors,
      _editors,
      _genres,
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
        authorIds: parseAdminList(_authors.text),
        editorIds: parseAdminList(_editors.text),
        genreIds: parseAdminList(_genres.text),
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
        _authors,
        _editors,
        _genres,
      ]) {
        controller.clear();
      }
      setState(() {
        _firstPublicationDate = null;
        _over18 = false;
        _loading = false;
        _messageIsError = false;
        _message = 'Série créée avec succès.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _messageIsError = true;
        _message = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormView(
      children: [
        const AdminPageHeader(
          icon: Icons.collections_bookmark_outlined,
          title: 'Nouvelle série',
          description:
              'Créez l’œuvre principale et rattachez ses contributeurs.',
        ),
        const SizedBox(height: 20),
        AdminResponsiveFields(
          children: [
            _textField(_titleFr, 'Titre français *', Icons.title_rounded),
            _textField(_titleEn, 'Titre anglais', Icons.translate_rounded),
            _textField(_titleJp, 'Titre japonais', Icons.translate_rounded),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _altTitles,
          maxLines: 2,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Titres alternatifs',
            helperText: 'Séparer les valeurs par une virgule ou une ligne.',
            prefixIcon: Icon(Icons.format_list_bulleted_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cover,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'URL HTTPS de la couverture',
            prefixIcon: Icon(Icons.image_outlined),
          ),
        ),
        const SizedBox(height: 12),
        AdminResponsiveFields(
          children: [
            _relationField(_authors, 'IDs auteurs', Icons.people_outline),
            _relationField(_editors, 'IDs éditeurs', Icons.business_outlined),
            _relationField(_genres, 'IDs genres', Icons.sell_outlined),
          ],
        ),
        const SizedBox(height: 12),
        AdminDateField(
          label: 'Première publication',
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
          label: const Text('Créer la série'),
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

  Widget _relationField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      maxLines: 2,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        helperText: 'Virgule ou ligne',
        prefixIcon: Icon(icon),
      ),
    );
  }
}
