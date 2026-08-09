import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
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
      title: context.localized(en: 'Administration', fr: 'Administration'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminPageHeader(
            icon: Icons.admin_panel_settings_outlined,
            title: context.localized(
              en: 'Management area',
              fr: 'Espace de gestion',
            ),
            description: context.localized(
              en: 'Manage the catalogue, monitor its activity and correct data issues.',
              fr: 'Gérez le catalogue, suivez son activité et corrigez les anomalies de données.',
            ),
          ),
          const SizedBox(height: 24),
          AdminStatusBanner(
            icon: isLoggedIn
                ? Icons.verified_user_outlined
                : Icons.lock_outline_rounded,
            title: isLoggedIn
                ? context.localized(en: 'Active session', fr: 'Session active')
                : context.localized(
                    en: 'Protected access',
                    fr: 'Accès protégé',
                  ),
            message: isLoggedIn
                ? context.localized(
                    en: 'Key in use: ${_admin.maskedKey}',
                    fr: 'Clé utilisée : ${_admin.maskedKey}',
                  )
                : context.localized(
                    en: 'Connect an authorized administrator or moderator key.',
                    fr: 'Connectez une clé administrateur ou modérateur autorisée.',
                  ),
            tone: isLoggedIn
                ? AdminBannerTone.success
                : AdminBannerTone.warning,
            trailing: isLoggedIn
                ? null
                : FilledButton.icon(
                    onPressed: () => pushOrGo(context, '/admin/admin_login'),
                    icon: const Icon(Icons.login_rounded),
                    label: Text(
                      context.localized(en: 'Sign in', fr: 'Connexion'),
                    ),
                  ),
          ),
          if (isLoggedIn) ...[
            const SizedBox(height: 28),
            AdminSectionTitle(
              title: context.localized(en: 'Tools', fr: 'Outils'),
            ),
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
                        title: context.localized(
                          en: 'Data creation',
                          fr: 'Création de données',
                        ),
                        description: context.localized(
                          en: 'Add authors, genres, publishers, series, sub-series and volumes.',
                          fr: 'Ajoutez auteurs, genres, éditeurs, séries, sous-séries et volumes.',
                        ),
                        onTap: () => pushOrGo(context, '/admin/create'),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.query_stats_rounded,
                        title: context.localized(
                          en: 'Overview',
                          fr: 'Vue générale',
                        ),
                        description: context.localized(
                          en: 'Review service health, catalogue data and popular content.',
                          fr: 'Consultez la santé, le catalogue et les contenus populaires.',
                        ),
                        onTap: () => pushOrGo(context, '/admin/statistics'),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.insights_outlined,
                        title: context.localized(
                          en: 'Product usage',
                          fr: 'Usage produit',
                        ),
                        description: context.localized(
                          en: 'Analyze activity, retention, platforms and versions.',
                          fr: 'Analysez activité, rétention, plateformes et versions.',
                        ),
                        onTap: () => pushOrGo(
                          context,
                          '/admin/analytics/product',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.notifications_active_outlined,
                        title: context.localized(
                          en: 'Notifications',
                          fr: 'Notifications',
                        ),
                        description: context.localized(
                          en: 'Track sends, deliveries, opens and delays.',
                          fr: 'Suivez envois, livraisons, ouvertures et délais.',
                        ),
                        onTap: () => pushOrGo(
                          context,
                          '/admin/analytics/notifications',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.manage_accounts_outlined,
                        title: context.localized(
                          en: 'Users',
                          fr: 'Utilisateurs',
                        ),
                        description: context.localized(
                          en: 'Review accounts and change their sorting order.',
                          fr: 'Consultez les comptes et modifiez leur ordre de tri.',
                        ),
                        onTap: () => pushOrGo(context, '/admin/users'),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.fact_check_outlined,
                        title: context.localized(
                          en: 'Volume quality',
                          fr: 'Qualité des volumes',
                        ),
                        description: context.localized(
                          en: 'Detect and resolve inconsistent volume numbers.',
                          fr: 'Détectez et traitez les numéros de tome incohérents.',
                        ),
                        onTap: () => pushOrGo(context, '/admin/volume-quality'),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.campaign_outlined,
                        title: context.localized(
                          en: 'Sponsorship',
                          fr: 'Sponsorisation',
                        ),
                        description: context.localized(
                          en: 'Create campaigns and monitor budgets, costs and conversions.',
                          fr: 'Créez des campagnes et suivez budgets, coûts et conversions.',
                        ),
                        onTap: () => pushOrGo(
                          context,
                          '/admin/management/sponsorship',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.auto_awesome_outlined,
                        title: context.localized(
                          en: 'Editorial selections',
                          fr: 'Sélections éditoriales',
                        ),
                        description: context.localized(
                          en: 'Feature manga manually, separately from personalization.',
                          fr: 'Mettez manuellement des mangas en avant hors personnalisation.',
                        ),
                        onTap: () => pushOrGo(
                          context,
                          '/admin/management/editorial',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.payments_outlined,
                        title: context.localized(en: 'Revenue', fr: 'Revenus'),
                        description: context.localized(
                          en: 'Monitor sponsor invoices, revenue and payments.',
                          fr: 'Suivez factures sponsors, chiffre d’affaires et paiements.',
                        ),
                        onTap: () => pushOrGo(
                          context,
                          '/admin/management/revenue',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.rule_folder_outlined,
                        title: context.localized(
                          en: 'Catalogue quality',
                          fr: 'Qualité du catalogue',
                        ),
                        description: context.localized(
                          en: 'Check missing data, duplicates, EANs and relationships.',
                          fr: 'Contrôlez données manquantes, doublons, EAN et relations.',
                        ),
                        onTap: () => pushOrGo(
                          context,
                          '/admin/management/catalog-quality',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.gavel_outlined,
                        title: context.localized(
                          en: 'Moderation and privacy',
                          fr: 'Modération et RGPD',
                        ),
                        description: context.localized(
                          en: 'Handle reports, suspensions and privacy requests.',
                          fr: 'Traitez signalements, suspensions et demandes de confidentialité.',
                        ),
                        onTap: () => pushOrGo(
                          context,
                          '/admin/management/moderation',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.monitor_heart_outlined,
                        title: context.localized(
                          en: 'Operations',
                          fr: 'Exploitation',
                        ),
                        description: context.localized(
                          en: 'Monitor deployments, jobs, caches, errors and quotas.',
                          fr: 'Surveillez déploiements, tâches, cache, erreurs et quotas.',
                        ),
                        onTap: () => pushOrGo(
                          context,
                          '/admin/management/operations',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminActionCard(
                        icon: Icons.policy_outlined,
                        title: context.localized(
                          en: 'Security and audit',
                          fr: 'Sécurité et audit',
                        ),
                        description: context.localized(
                          en: 'Review sensitive actions, exports and permissions.',
                          fr: 'Consultez actions sensibles, exports et permissions.',
                        ),
                        onTap: () => pushOrGo(
                          context,
                          '/admin/management/audit',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            AdminSectionTitle(
              title: context.localized(en: 'Session', fr: 'Session'),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                label: Text(
                  context.localized(en: 'Sign out', fr: 'Déconnexion'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
