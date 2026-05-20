import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AdminConnector _admin = AdminConnector();

  @override
  void initState() {
    super.initState();
    _admin.init().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _logout() async {
    await _admin.logout();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _admin.isLoggedIn();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              isLoggedIn
                  ? 'Connecté avec ${_admin.maskedKey}'
                  : 'Tu dois te connecter avec une clé API admin.',
            ),
            const SizedBox(height: 16),
            if (!isLoggedIn)
              ElevatedButton(
                onPressed: () => pushOrGo(context, '/admin/admin_login'),
                child: const Text('Se connecter'),
              ),
            if (isLoggedIn)
              ElevatedButton(
                onPressed: () => pushOrGo(context, '/admin/create'),
                child: const Text('Création de données'),
              ),
            if (isLoggedIn)
              ElevatedButton(
                onPressed: () => pushOrGo(context, '/admin/static_page'),
                child: const Text('Statistiques'),
              ),
            if (isLoggedIn)
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Déconnexion admin'),
              ),
          ],
        ),
      ),
    );
  }
}
