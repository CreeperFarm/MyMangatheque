import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AdminConnector _admin = AdminConnector();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _admin.init().then((_) {
      if (!mounted) return;
      setState(() {
        _initialized = true;
      });
    });
  }

  Future<void> _logout() async {
    await _admin.logout();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isLoggedIn = _admin.isLoggedIn();
    return AdminPageScaffold(
      title: 'Administration',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdminPageHeader(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Espace de gestion',
            description:
                'Gérez le catalogue, suivez son activité et corrigez les anomalies de données.',
          ),
          const SizedBox(height: 24),
          AdminStatusBanner(
            icon: isLoggedIn
                ? Icons.verified_user_outlined
                : Icons.lock_outline_rounded,
            title: isLoggedIn ? 'Session active' : 'Accès protégé',
            message: isLoggedIn
                ? 'Clé utilisée : ${_admin.maskedKey}'
                : 'Connectez une clé administrateur ou modérateur autorisée.',
            tone: isLoggedIn
                ? AdminBannerTone.success
                : AdminBannerTone.warning,
            trailing: isLoggedIn
                ? null
                : FilledButton.icon(
                    onPressed: () => pushOrGo(context, '/admin/admin_login'),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Connexion'),
                  ),
          ),
          if (isLoggedIn) ...[
            const SizedBox(height: 28),
            const AdminSectionTitle(title: 'Outils'),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth >= 720
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.add_box_outlined,
                        title: 'Création de données',
                        description:
                            'Ajoutez auteurs, genres, éditeurs, séries, sous-séries et volumes.',
                        onTap: () => pushOrGo(context, '/admin/create'),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.query_stats_rounded,
                        title: 'Statistiques',
                        description:
                            'Consultez les indicateurs et les volumes les plus ajoutés.',
                        onTap: () => pushOrGo(context, '/admin/static_page'),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.fact_check_outlined,
                        title: 'Qualité des volumes',
                        description:
                            'Détectez et traitez les numéros de tome incohérents.',
                        onTap: () => pushOrGo(context, '/admin/volume-quality'),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            const AdminSectionTitle(title: 'Session'),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Déconnexion'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
