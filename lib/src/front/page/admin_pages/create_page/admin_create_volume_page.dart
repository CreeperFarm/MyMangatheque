import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';

class AdminCreateVolumePage extends StatefulWidget {
  const AdminCreateVolumePage({super.key});

  @override
  State<AdminCreateVolumePage> createState() => _AdminCreateVolumePageState();
}

class _AdminCreateVolumePageState extends State<AdminCreateVolumePage> {
  final AdminConnector _admin = AdminConnector();

  final TextEditingController _titleFrController = TextEditingController();
  final TextEditingController _tomeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _eanController = TextEditingController();
  final TextEditingController _coverController = TextEditingController();
  final TextEditingController _resumeController = TextEditingController();
  final TextEditingController _subSeriesController = TextEditingController();
  final TextEditingController _genderJpController = TextEditingController();

  bool _over18 = false;
  bool _loading = false;
  bool _messageIsError = false;
  String _message = '';
  String _language = 'french';
  String _support = 'manga';

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
    _tomeController.dispose();
    _priceController.dispose();
    _eanController.dispose();
    _coverController.dispose();
    _resumeController.dispose();
    _subSeriesController.dispose();
    _genderJpController.dispose();
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
        _message = 'Champs obligatoires invalides (titre, tome, prix, ean).';
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
        tomeNumber: tomeNumber,
        price: price,
        ean: ean,
        language: _language,
        support: _support,
        coverUrl: _coverController.text.trim(),
        resume: _resumeController.text.trim(),
        subSeriesId: _subSeriesController.text.trim(),
        genderJp: _genderJpController.text.trim(),
        over18: _over18,
      );

      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = 'Volume créé avec succès.';
        _messageIsError = false;
      });
      _titleFrController.clear();
      _tomeController.clear();
      _priceController.clear();
      _eanController.clear();
      _coverController.clear();
      _resumeController.clear();
      _subSeriesController.clear();
      _genderJpController.clear();
      _over18 = false;
      _language = 'french';
      _support = 'manga';
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
    final colorScheme = Theme.of(context).colorScheme;
    return AdminFormView(
      children: [
        const AdminPageHeader(
          icon: Icons.menu_book_outlined,
          title: 'Nouveau volume',
          description:
              'Renseignez les informations éditoriales et le rattachement au catalogue.',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _titleFrController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Titre français *',
            prefixIcon: Icon(Icons.title_rounded),
          ),
        ),
        const SizedBox(height: 12),
        _responsiveRow(
          [
            TextField(
              controller: _tomeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Numéro de tome *',
                prefixIcon: Icon(Icons.numbers_rounded),
              ),
            ),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Prix *',
                suffixText: '€',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            TextField(
              controller: _eanController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              maxLength: 13,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'EAN-13 *',
                prefixIcon: Icon(Icons.qr_code_2_rounded),
                counterText: '',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _responsiveRow(
          [
            DropdownButtonFormField<String>(
              key: ValueKey<String>(_language),
              initialValue: _language,
              items: _languages
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _language = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Langue *',
                prefixIcon: Icon(Icons.language_rounded),
              ),
            ),
            DropdownButtonFormField<String>(
              key: ValueKey<String>(_support),
              initialValue: _support,
              items: _supports
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _support = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Support *',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _responsiveRow(
          [
            TextField(
              controller: _subSeriesController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ID de sous-série',
                prefixIcon: Icon(Icons.account_tree_outlined),
              ),
            ),
            TextField(
              controller: _genderJpController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Public japonais',
                hintText: 'shonen, seinen, shojo…',
                prefixIcon: Icon(Icons.groups_outlined),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _coverController,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'URL de la couverture',
            prefixIcon: Icon(Icons.image_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _resumeController,
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Résumé',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SwitchListTile(
            title: const Text('Contenu réservé aux adultes'),
            subtitle: const Text(
              'Masqué lorsque le contenu adulte est désactivé.',
            ),
            secondary: const Icon(Icons.no_adult_content_outlined),
            value: _over18,
            onChanged: (value) {
              setState(() {
                _over18 = value;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _submit,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Créer le volume'),
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

  Widget _responsiveRow(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              for (var index = 0; index < fields.length; index++) ...[
                if (index > 0) const SizedBox(height: 12),
                fields[index],
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < fields.length; index++) ...[
              if (index > 0) const SizedBox(width: 12),
              Expanded(child: fields[index]),
            ],
          ],
        );
      },
    );
  }
}
