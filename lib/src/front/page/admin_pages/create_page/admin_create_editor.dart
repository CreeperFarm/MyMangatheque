import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';

class AdminCreateEditorPage extends StatefulWidget {
  const AdminCreateEditorPage({super.key});

  @override
  State<AdminCreateEditorPage> createState() => _AdminCreateEditorPageState();
}

class _AdminCreateEditorPageState extends State<AdminCreateEditorPage> {
  final AdminConnector _admin = AdminConnector();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _coverController = TextEditingController();
  bool _loading = false;
  bool _messageIsError = false;
  String _message = '';

  @override
  void dispose() {
    _nameController.dispose();
    _coverController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _message = '';
    });
    try {
      await _admin.createEditor(
        name: _nameController.text,
        coverUrl: _coverController.text,
      );
      if (!mounted) return;
      _nameController.clear();
      _coverController.clear();
      setState(() {
        _loading = false;
        _messageIsError = false;
        _message = 'Éditeur créé avec succès.';
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
          icon: Icons.business_outlined,
          title: 'Nouvel éditeur',
          description: 'Ajoutez une maison d’édition et son identité visuelle.',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          maxLength: 200,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Nom *',
            prefixIcon: Icon(Icons.business_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _coverController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'URL HTTPS du logo',
            prefixIcon: Icon(Icons.image_outlined),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _submit,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Créer l’éditeur'),
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
