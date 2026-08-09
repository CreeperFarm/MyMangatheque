import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';

class AdminCreateAuthorPage extends StatefulWidget {
  const AdminCreateAuthorPage({super.key});

  @override
  State<AdminCreateAuthorPage> createState() => _AdminCreateAuthorPageState();
}

class _AdminCreateAuthorPageState extends State<AdminCreateAuthorPage> {
  final AdminConnector _admin = AdminConnector();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobsController = TextEditingController();
  final TextEditingController _coverController = TextEditingController();
  bool _loading = false;
  bool _messageIsError = false;
  String _message = '';

  @override
  void dispose() {
    _nameController.dispose();
    _jobsController.dispose();
    _coverController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _message = context.localized(
          en: 'Name is required.',
          fr: 'Le nom est obligatoire.',
        );
        _messageIsError = true;
      });
      return;
    }

    final jobs = _jobsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    setState(() {
      _loading = true;
      _message = '';
      _messageIsError = false;
    });

    try {
      await _admin.createAuthor(
        name: _nameController.text.trim(),
        jobs: jobs,
        coverUrl: _coverController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = context.localized(
          en: 'Author created successfully.',
          fr: 'Auteur créé avec succès.',
        );
        _messageIsError = false;
      });
      _nameController.clear();
      _jobsController.clear();
      _coverController.clear();
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
          icon: Icons.person_add_alt_1_outlined,
          title: context.localized(en: 'New author', fr: 'Nouvel auteur'),
          description: context.localized(
            en: 'Add a person and their roles to the catalogue.',
            fr: 'Ajoutez une personne et ses métiers dans le catalogue.',
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          maxLength: 200,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.localized(en: 'Name *', fr: 'Nom *'),
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _jobsController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.localized(
              en: 'Roles (comma separated)',
              fr: 'Métiers (séparés par des virgules)',
            ),
            prefixIcon: Icon(Icons.work_outline_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _coverController,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.localized(
              en: 'HTTPS image URL',
              fr: 'URL HTTPS de l’image',
            ),
            prefixIcon: Icon(Icons.image_outlined),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _submit,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            context.localized(en: 'Create author', fr: 'Créer l’auteur'),
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
