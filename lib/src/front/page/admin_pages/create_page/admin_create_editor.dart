import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
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
        _message = context.localized(
          en: 'Publisher created successfully.',
          fr: 'Éditeur créé avec succès.',
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
          icon: Icons.business_outlined,
          title: context.localized(en: 'New publisher', fr: 'Nouvel éditeur'),
          description: context.localized(
            en: 'Add a publisher and its visual identity.',
            fr: 'Ajoutez une maison d’édition et son identité visuelle.',
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          maxLength: 200,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.localized(en: 'Name *', fr: 'Nom *'),
            prefixIcon: Icon(Icons.business_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _coverController,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.localized(
              en: 'HTTPS logo URL',
              fr: 'URL HTTPS du logo',
            ),
            prefixIcon: Icon(Icons.image_outlined),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _submit,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            context.localized(en: 'Create publisher', fr: 'Créer l’éditeur'),
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
