import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';

class AdminCreateGenrePage extends StatefulWidget {
  const AdminCreateGenrePage({super.key});

  @override
  State<AdminCreateGenrePage> createState() => _AdminCreateGenrePageState();
}

class _AdminCreateGenrePageState extends State<AdminCreateGenrePage> {
  final AdminConnector _admin = AdminConnector();
  final TextEditingController _nameController = TextEditingController();
  bool _loading = false;
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
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      await _admin.createGenre(name: _nameController.text.trim());
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = 'Genre créé avec succès.';
      });
      _nameController.clear();
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
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: const Text('Créer genre'),
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
