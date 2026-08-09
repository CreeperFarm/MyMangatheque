import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_form_helpers.dart';

class AdminCreateVolumePage extends StatefulWidget {
  const AdminCreateVolumePage({super.key});

  @override
  State<AdminCreateVolumePage> createState() => _AdminCreateVolumePageState();
}

class _AdminCreateVolumePageState extends State<AdminCreateVolumePage> {
  final AdminConnector _admin = AdminConnector();

  final TextEditingController _titleFrController = TextEditingController();
  final TextEditingController _titleJpController = TextEditingController();
  final TextEditingController _titleEnController = TextEditingController();
  final TextEditingController _tomeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _eanController = TextEditingController();
  final TextEditingController _coverController = TextEditingController();
  final TextEditingController _resumeController = TextEditingController();
  final TextEditingController _bookLinksController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();

  AdminRelationOption? _subSeries;
  List<AdminRelationOption> _containedVolumes = const <AdminRelationOption>[];

  DateTime? _publicationDate;
  bool _over18 = false;
  bool _loading = false;
  bool _messageIsError = false;
  String _message = '';
  String _language = 'french';
  String _support = 'manga';
  String _genderJp = '';

  static const List<String> _languages = [
    'french',
    'english',
    'italian',
    'spanish',
    'german',
    'chinese',
    'japanese',
    'portugese',
  ];

  static const List<String> _supports = [
    'manga',
    'artbook',
    'roman',
    'lightNovel',
    'novel',
    'boxSet',
    'other',
  ];

  @override
  void dispose() {
    _titleFrController.dispose();
    _titleJpController.dispose();
    _titleEnController.dispose();
    _tomeController.dispose();
    _priceController.dispose();
    _eanController.dispose();
    _coverController.dispose();
    _resumeController.dispose();
    _bookLinksController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tomeNumber = num.tryParse(_tomeController.text.trim());
    final price = num.tryParse(_priceController.text.trim());
    final ean = int.tryParse(_eanController.text.trim());

    if (_titleFrController.text.trim().isEmpty ||
        tomeNumber == null ||
        price == null ||
        ean == null) {
      setState(() {
        _message = context.localized(
          en: 'Invalid required fields (title, volume number, price, EAN).',
          fr: 'Champs obligatoires invalides (titre, tome, prix, EAN).',
        );
        _messageIsError = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
      _messageIsError = false;
    });

    try {
      await _admin.createVolume(
        titleFr: _titleFrController.text.trim(),
        titleJp: _titleJpController.text.trim(),
        titleEn: _titleEnController.text.trim(),
        tomeNumber: tomeNumber,
        price: price,
        ean: ean,
        language: _language,
        support: _support,
        coverUrl: _coverController.text.trim(),
        resume: _resumeController.text.trim(),
        publicationDate: _publicationDate,
        subSeriesId: _subSeries?.id,
        genderJp: _genderJp,
        bookLinks: parseAdminList(_bookLinksController.text),
        containsIds: _containedVolumes.map((item) => item.id).toList(),
        info: parseAdminMetadata(_infoController.text),
        over18: _over18,
      );

      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = context.localized(
          en: 'Volume created successfully.',
          fr: 'Volume créé avec succès.',
        );
        _messageIsError = false;
      });
      _titleFrController.clear();
      _titleJpController.clear();
      _titleEnController.clear();
      _tomeController.clear();
      _priceController.clear();
      _eanController.clear();
      _coverController.clear();
      _resumeController.clear();
      _bookLinksController.clear();
      _infoController.clear();
      _publicationDate = null;
      _over18 = false;
      _language = 'french';
      _support = 'manga';
      _genderJp = '';
      _subSeries = null;
      _containedVolumes = const <AdminRelationOption>[];
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = e.toString();
        _messageIsError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormView(
      children: [
        AdminPageHeader(
          icon: Icons.menu_book_outlined,
          title: context.localized(en: 'New volume', fr: 'Nouveau volume'),
          description: context.localized(
            en: 'Enter publishing information and catalogue relationships.',
            fr: 'Renseignez les informations éditoriales et le rattachement au catalogue.',
          ),
        ),
        const SizedBox(height: 20),
        AdminResponsiveFields(
          children: [
            TextField(
              controller: _titleFrController,
              maxLength: 200,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: context.localized(
                  en: 'French title *',
                  fr: 'Titre français *',
                ),
                prefixIcon: Icon(Icons.title_rounded),
              ),
            ),
            TextField(
              controller: _titleEnController,
              maxLength: 200,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: context.localized(
                  en: 'English title',
                  fr: 'Titre anglais',
                ),
                prefixIcon: Icon(Icons.translate_rounded),
              ),
            ),
            TextField(
              controller: _titleJpController,
              maxLength: 200,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: context.localized(
                  en: 'Japanese title',
                  fr: 'Titre japonais',
                ),
                prefixIcon: Icon(Icons.translate_rounded),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AdminResponsiveFields(
          children: [
            TextField(
              controller: _tomeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: context.localized(
                  en: 'Volume number *',
                  fr: 'Numéro de tome *',
                ),
                prefixIcon: Icon(Icons.numbers_rounded),
              ),
            ),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: context.localized(en: 'Price *', fr: 'Prix *'),
                suffixText: '€',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            TextField(
              controller: _eanController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              maxLength: 13,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: context.localized(en: 'EAN-13 *', fr: 'EAN-13 *'),
                prefixIcon: Icon(Icons.qr_code_2_rounded),
                counterText: '',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AdminResponsiveFields(
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey<String>(_language),
              initialValue: _language,
              items: _languages
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(_localizedLanguage(context, item)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _language = value;
                });
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: context.localized(en: 'Language *', fr: 'Langue *'),
                prefixIcon: const Icon(Icons.language_rounded),
              ),
            ),
            DropdownButtonFormField<String>(
              key: ValueKey<String>(_support),
              initialValue: _support,
              items: _supports
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(_localizedSupport(context, item)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _support = value;
                });
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: context.localized(en: 'Format *', fr: 'Support *'),
                prefixIcon: const Icon(Icons.category_outlined),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AdminResponsiveFields(
          children: [
            AdminRelationPickerField(
              label: context.localized(en: 'Sub-series', fr: 'Sous-série'),
              resource: AdminRelationResource.subSeries,
              selected: <AdminRelationOption>[
                if (_subSeries != null) _subSeries!,
              ],
              onChanged: (value) => setState(
                () => _subSeries = value.isEmpty ? null : value.first,
              ),
            ),
            DropdownButtonFormField<String>(
              key: ValueKey<String>(_genderJp),
              initialValue: _genderJp,
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem(
                  value: '',
                  child: Text(
                    context.localized(en: 'Not specified', fr: 'Non renseigné'),
                  ),
                ),
                const DropdownMenuItem(value: 'shonen', child: Text('Shōnen')),
                const DropdownMenuItem(value: 'seinen', child: Text('Seinen')),
                const DropdownMenuItem(value: 'shojo', child: Text('Shōjo')),
                const DropdownMenuItem(value: 'josei', child: Text('Josei')),
              ],
              onChanged: (value) => setState(() => _genderJp = value ?? ''),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: context.localized(
                  en: 'Japanese demographic',
                  fr: 'Public japonais',
                ),
                prefixIcon: const Icon(Icons.groups_outlined),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _coverController,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
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
        AdminDateField(
          label: context.localized(
            en: 'Publication date',
            fr: 'Date de publication',
          ),
          value: _publicationDate,
          onChanged: (value) => setState(() => _publicationDate = value),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _resumeController,
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.localized(en: 'Summary', fr: 'Résumé'),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        AdminResponsiveFields(
          children: [
            TextField(
              controller: _bookLinksController,
              maxLines: 3,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: context.localized(
                  en: 'HTTPS purchase links',
                  fr: 'Liens d’achat HTTPS',
                ),
                helperText: context.localized(
                  en: 'One URL per line or comma separated.',
                  fr: 'Une URL par ligne ou séparées par des virgules.',
                ),
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
            AdminRelationPickerField(
              label: context.localized(
                en: 'Included volumes',
                fr: 'Volumes inclus',
              ),
              resource: AdminRelationResource.volumes,
              selected: _containedVolumes,
              allowMultiple: true,
              helperText: context.localized(
                en: 'For a box set or omnibus.',
                fr: 'Pour un coffret ou une intégrale.',
              ),
              onChanged: (value) => setState(() => _containedVolumes = value),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _infoController,
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.localized(
              en: 'Additional information',
              fr: 'Informations complémentaires',
            ),
            hintText: 'pages=192\nformat=Tankōbon',
            helperText: context.localized(
              en: 'One key=value pair per line, maximum 50.',
              fr: 'Une paire clé=valeur par ligne, 50 maximum.',
            ),
            prefixIcon: Icon(Icons.info_outline_rounded),
          ),
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
            context.localized(en: 'Create volume', fr: 'Créer le volume'),
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
}

String _localizedLanguage(BuildContext context, String value) {
  const english = <String, String>{
    'french': 'French',
    'english': 'English',
    'italian': 'Italian',
    'spanish': 'Spanish',
    'german': 'German',
    'chinese': 'Chinese',
    'japanese': 'Japanese',
    'portugese': 'Portuguese',
  };
  const french = <String, String>{
    'french': 'Français',
    'english': 'Anglais',
    'italian': 'Italien',
    'spanish': 'Espagnol',
    'german': 'Allemand',
    'chinese': 'Chinois',
    'japanese': 'Japonais',
    'portugese': 'Portugais',
  };
  return context.localized(
    en: english[value] ?? value,
    fr: french[value] ?? value,
  );
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
