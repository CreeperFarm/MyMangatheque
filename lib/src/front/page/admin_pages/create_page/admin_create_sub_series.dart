import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
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
  final _series = TextEditingController();
  final _authors = TextEditingController();
  final _editor = TextEditingController();
  final _genres = TextEditingController();

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
      _series,
      _authors,
      _editor,
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
      await _admin.createSubSeries(
        titleFr: _titleFr.text,
        titleJp: _titleJp.text,
        titleEn: _titleEn.text,
        coverUrl: _cover.text,
        seriesId: _series.text,
        authorIds: parseAdminList(_authors.text),
        editorId: _editor.text,
        genreIds: parseAdminList(_genres.text),
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
        _series,
        _authors,
        _editor,
        _genres,
      ]) {
        controller.clear();
      }
      setState(() {
        _firstPublicationDate = null;
        _support = 'manga';
        _status = 'OnGoing';
        _over18 = false;
        _loading = false;
        _messageIsError = false;
        _message = 'Sous-série créée avec succès.';
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
          icon: Icons.account_tree_outlined,
          title: 'Nouvelle sous-série',
          description: 'Créez une édition ou collection rattachée à une série.',
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
            _relationField(
              _series,
              'ID série parente *',
              Icons.collections_bookmark_outlined,
            ),
            _relationField(_editor, 'ID éditeur', Icons.business_outlined),
          ],
        ),
        const SizedBox(height: 12),
        AdminResponsiveFields(
          children: [
            _relationField(_authors, 'IDs auteurs', Icons.people_outline),
            _relationField(_genres, 'IDs genres', Icons.sell_outlined),
          ],
        ),
        const SizedBox(height: 12),
        AdminResponsiveFields(
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey<String>(_support),
              initialValue: _support,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Support *',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _supports
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _support = value ?? _support),
            ),
            DropdownButtonFormField<String>(
              key: ValueKey<String>(_status),
              initialValue: _status,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Statut *',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: _statuses
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
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
          label: const Text('Créer la sous-série'),
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
        helperText: label.startsWith('IDs') ? 'Virgule ou ligne' : null,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
