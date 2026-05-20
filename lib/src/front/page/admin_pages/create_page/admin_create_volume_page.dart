import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';

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
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          TextField(
            controller: _titleFrController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Titre FR *',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tomeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Tome number *',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Prix *',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _eanController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'EAN *',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _language,
            items: _languages
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _language = value;
              });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Language *',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _support,
            items: _supports
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
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
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subSeriesController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'SubSeries ID',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _coverController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Cover URL',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _genderJpController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Gender JP (shonen/seinen/shojo/josei)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _resumeController,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Résumé',
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Over18'),
            value: _over18,
            onChanged: (value) {
              setState(() {
                _over18 = value;
              });
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: const Text('Créer volume'),
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_message.isNotEmpty)
            Text(_message),
        ],
      ),
    );
  }
}
