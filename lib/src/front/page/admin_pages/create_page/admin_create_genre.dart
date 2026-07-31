import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';

class AdminCreateGenrePage extends StatefulWidget {
  const AdminCreateGenrePage({super.key});

  @override
  State<AdminCreateGenrePage> createState() => _AdminCreateGenrePageState();
}

class _AdminCreateGenrePageState extends State<AdminCreateGenrePage> {
  final AdminConnector _admin = AdminConnector();
  final TextEditingController _nameController = TextEditingController();
  bool _loading = false;
  bool _messageIsError = false;
  String _message = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _message = 'Le nom est obligatoire.';
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
      await _admin.createGenre(name: _nameController.text.trim());
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = 'Genre créé avec succès.';
        _messageIsError = false;
      });
      _nameController.clear();
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
        const AdminPageHeader(
          icon: Icons.sell_outlined,
          title: 'Nouveau genre',
          description: 'Ajoutez un genre utilisable dans le catalogue.',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Nom *',
            prefixIcon: Icon(Icons.label_outline_rounded),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _submit,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Créer le genre'),
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
