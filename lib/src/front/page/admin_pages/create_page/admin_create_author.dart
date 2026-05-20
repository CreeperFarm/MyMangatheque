import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';

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
        _message = 'Le nom est obligatoire.';
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
        _message = 'Auteur créé avec succès.';
      });
      _nameController.clear();
      _jobsController.clear();
      _coverController.clear();
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
            controller: _nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Nom *',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _jobsController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Jobs (séparés par des virgules)',
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
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: const Text('Créer auteur'),
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
