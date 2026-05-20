import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final AdminConnector _admin = AdminConnector();
  final TextEditingController _apiKeyController = TextEditingController();
  bool _loading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _admin.init().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loginWithManualKey() async {
    if (_apiKeyController.text.trim().isEmpty) {
      setState(() {
        _message = 'Saisis une clé API admin.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
    });

    final ok = await _admin.loginAsAdmin(_apiKeyController.text.trim());
    if (!mounted) return;

    setState(() {
      _loading = false;
      _message = ok
          ? 'Connexion admin réussie.'
          : 'Clé API invalide ou non admin.';
    });

    if (ok) {
      pushOrGo(context, '/admin');
    }
  }

  Future<void> _loginWithSessionKey() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      final ok = await _admin.loginWithCurrentSessionKey();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = ok
            ? 'Connexion admin via session réussie.'
            : 'La session courante n’a pas les droits admin.';
      });

      if (ok) {
        pushOrGo(context, '/admin');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = 'Impossible d’utiliser la session courante: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Connexion admin',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'État: ${_admin.isLoggedIn() ? "connecté (${_admin.maskedKey})" : "non connecté"}',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              autocorrect: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Clé API admin',
                hintText: 'mmt_xxx...',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _loginWithManualKey,
              child: const Text('Connexion avec clé API'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loading ? null : _loginWithSessionKey,
              child: const Text('Utiliser la session courante'),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_message.isNotEmpty)
              Text(_message),
          ],
        ),
      ),
    );
  }
}
