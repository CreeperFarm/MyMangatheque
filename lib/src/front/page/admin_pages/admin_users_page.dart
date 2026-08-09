import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final AdminConnector _admin = AdminConnector();
  final TextEditingController _searchController = TextEditingController();

  AdminUserOrderBy _orderBy = AdminUserOrderBy.createdAt;
  AdminSortDirection _direction = AdminSortDirection.descending;
  AdminUserPage? _result;
  Object? _error;
  bool _initialized = false;
  bool _loading = false;
  String? _busyUserId;
  int _page = 1;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _admin.init();
    if (!mounted) return;
    setState(() => _initialized = true);
    if (_admin.isLoggedIn()) await _loadUsers();
  }

  Future<void> _loadUsers({int? page}) async {
    final requestedPage = page ?? _page;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _admin.getUsers(
        orderBy: _orderBy,
        direction: _direction,
        page: requestedPage,
        query: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _page = result.page;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeRole(AdminUser user, String role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.localized(
            en: 'Confirm role change',
            fr: 'Confirmer le changement de rôle',
          ),
        ),
        content: Text(
          context.localized(
            en: 'Assign the “$role” role to ${user.pseudo}? This action will be recorded in the audit log.',
            fr: 'Attribuer le rôle « $role » à ${user.pseudo} ? Cette action sera inscrite dans le journal d’audit.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.localized(en: 'Cancel', fr: 'Annuler')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.localized(en: 'Confirm', fr: 'Confirmer')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busyUserId = user.id);
    try {
      await _admin.updateUserRole(user.id, role);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.localized(
              en: '${user.pseudo}’s role was updated.',
              fr: 'Rôle de ${user.pseudo} mis à jour.',
            ),
          ),
        ),
      );
      await _loadUsers();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(redactSensitiveText(error))));
    } finally {
      if (mounted) setState(() => _busyUserId = null);
    }
  }

  Future<void> _toggleSuspension(AdminUser user) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          user.suspended
              ? context.localized(
                  en: 'Reactivate account',
                  fr: 'Réactiver le compte',
                )
              : context.localized(
                  en: 'Suspend account',
                  fr: 'Suspendre le compte',
                ),
        ),
        content: TextField(
          controller: reasonController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: user.suspended
                ? context.localized(en: 'Note', fr: 'Note')
                : context.localized(
                    en: 'Suspension reason',
                    fr: 'Motif de suspension',
                  ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.localized(en: 'Cancel', fr: 'Annuler')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              user.suspended
                  ? context.localized(en: 'Reactivate', fr: 'Réactiver')
                  : context.localized(en: 'Suspend', fr: 'Suspendre'),
            ),
          ),
        ],
      ),
    );
    final reason = reasonController.text;
    reasonController.dispose();
    if (confirmed != true || !mounted) return;
    setState(() => _busyUserId = user.id);
    try {
      await _admin.suspendUser(
        user.id,
        suspended: !user.suspended,
        reason: reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user.suspended
                ? context.localized(
                    en: 'Account reactivated.',
                    fr: 'Compte réactivé.',
                  )
                : context.localized(
                    en: 'Account suspended.',
                    fr: 'Compte suspendu.',
                  ),
          ),
        ),
      );
      await _loadUsers();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(redactSensitiveText(error))));
    } finally {
      if (mounted) setState(() => _busyUserId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_admin.isLoggedIn()) {
      return AdminPageScaffold(
        title: context.localized(en: 'Users', fr: 'Utilisateurs'),
        maxWidth: 680,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminPageHeader(
              icon: Icons.manage_accounts_outlined,
              title: context.localized(
                en: 'User list',
                fr: 'Liste des utilisateurs',
              ),
              description: context.localized(
                en: 'An authorized administrator key is required to view this list.',
                fr: 'Une clé administrateur autorisée est nécessaire pour consulter cette liste.',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => pushOrGo(context, '/admin/admin_login'),
              icon: const Icon(Icons.login_rounded),
              label: Text(
                context.localized(
                  en: 'Sign in as admin',
                  fr: 'Se connecter en admin',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AdminPageScaffold(
      title: context.localized(en: 'Users', fr: 'Utilisateurs'),
      scrollable: false,
      actions: [
        IconButton(
          onPressed: _loading ? null : _loadUsers,
          tooltip: context.localized(en: 'Refresh', fr: 'Actualiser'),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminPageHeader(
                  icon: Icons.manage_accounts_outlined,
                  title: context.localized(
                    en: 'User list',
                    fr: 'Liste des utilisateurs',
                  ),
                  description: context.localized(
                    en: 'Review accounts and choose the field used by orderBy.',
                    fr: 'Consultez les comptes et choisissez le champ utilisé par orderBy.',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: context.localized(
                      en: 'Search by username, email or user ID',
                      fr: 'Rechercher par pseudo, e-mail ou identifiant',
                    ),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                              _loadUsers(page: 1);
                            },
                            icon: const Icon(Icons.clear_rounded),
                          ),
                  ),
                  onChanged: (_) {
                    setState(() {});
                    _searchDebounce?.cancel();
                    _searchDebounce = Timer(
                      const Duration(milliseconds: 350),
                      () => _loadUsers(page: 1),
                    );
                  },
                  onSubmitted: (_) => _loadUsers(page: 1),
                ),
                const SizedBox(height: 12),
                _buildSortControls(),
                const SizedBox(height: 12),
                AdminSectionTitle(
                  title: context.localized(en: 'Accounts', fr: 'Comptes'),
                  trailing: _result == null
                      ? null
                      : Text(
                          context.localized(
                            en: '${_result!.totalItems} user(s)',
                            fr: '${_result!.totalItems} utilisateur(s)',
                          ),
                        ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSortControls() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 620;
        final children = <Widget>[
          DropdownButtonFormField<AdminUserOrderBy>(
            key: ValueKey<AdminUserOrderBy>(_orderBy),
            initialValue: _orderBy,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'orderBy',
              prefixIcon: Icon(Icons.sort_by_alpha_rounded),
              isDense: true,
            ),
            items: AdminUserOrderBy.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.label),
                  ),
                )
                .toList(),
            onChanged: _loading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _orderBy = value);
                    _loadUsers(page: 1);
                  },
          ),
          SegmentedButton<AdminSortDirection>(
            segments: AdminSortDirection.values
                .map(
                  (value) => ButtonSegment(
                    value: value,
                    icon: Icon(
                      value == AdminSortDirection.ascending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                    ),
                    label: Text(value.label),
                  ),
                )
                .toList(),
            selected: <AdminSortDirection>{_direction},
            onSelectionChanged: _loading
                ? null
                : (selection) {
                    setState(() => _direction = selection.first);
                    _loadUsers(page: 1);
                  },
          ),
        ];
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              children.first,
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: children.last,
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: children.first),
            const SizedBox(width: 12),
            children.last,
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    if (_loading && _result == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      final permissionDenied =
          _error is AdminApiException &&
          (_error as AdminApiException).statusCode == 403;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AdminStatusBanner(
            icon: permissionDenied
                ? Icons.lock_outline_rounded
                : Icons.cloud_off_outlined,
            title: permissionDenied
                ? context.localized(
                    en: 'Permission required',
                    fr: 'Permission requise',
                  )
                : context.localized(
                    en: 'Unable to load',
                    fr: 'Chargement impossible',
                  ),
            message: permissionDenied
                ? context.localized(
                    en: 'User read permission is required.',
                    fr: 'La permission de lecture des utilisateurs est nécessaire.',
                  )
                : redactSensitiveText(_error),
            tone: AdminBannerTone.error,
            trailing: IconButton(
              onPressed: _loadUsers,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: context.localized(en: 'Retry', fr: 'Réessayer'),
            ),
          ),
        ),
      );
    }

    final result = _result;
    final users = result?.users ?? const <AdminUser>[];
    if (users.isEmpty) {
      return Center(
        child: Text(
          context.localized(
            en: 'No users to display.',
            fr: 'Aucun utilisateur à afficher.',
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: users.length + 1,
      itemBuilder: (context, index) {
        if (index == users.length) return _buildPagination(result!);
        return _AdminUserCard(
          user: users[index],
          busy: _busyUserId == users[index].id,
          onRoleChanged: (role) => _changeRole(users[index], role),
          onToggleSuspension: () => _toggleSuspension(users[index]),
        );
      },
    );
  }

  Widget _buildPagination(AdminUserPage result) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _loading || result.page <= 1
              ? null
              : () => _loadUsers(page: result.page - 1),
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: context.localized(
            en: 'Previous page',
            fr: 'Page précédente',
          ),
        ),
        Text('${result.page} / ${result.totalPages}'),
        IconButton(
          onPressed: _loading || result.page >= result.totalPages
              ? null
              : () => _loadUsers(page: result.page + 1),
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: context.localized(en: 'Next page', fr: 'Page suivante'),
        ),
      ],
    );
  }
}

class _AdminUserCard extends StatelessWidget {
  const _AdminUserCard({
    required this.user,
    required this.busy,
    required this.onRoleChanged,
    required this.onToggleSuspension,
  });

  final AdminUser user;
  final bool busy;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onToggleSuspension;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipOval(
              child: SafeNetworkImage(
                imageUrl: user.coverUrl,
                width: 48,
                height: 48,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.pseudo,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (user.email.isNotEmpty) Text(user.email),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Chip(label: Text(user.role)),
                      if (user.suspended)
                        Chip(
                          avatar: Icon(Icons.block_rounded, size: 18),
                          label: Text(
                            context.localized(en: 'Suspended', fr: 'Suspendu'),
                          ),
                        ),
                      if (user.createdAt != null)
                        Text(
                          context.localized(
                            en: 'Created on ${_formatDate(context, user.createdAt!)}',
                            fr: 'Créé le ${_formatDate(context, user.createdAt!)}',
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (user.updatedAt != null)
                        Text(
                          context.localized(
                            en: 'Updated on ${_formatDate(context, user.updatedAt!)}',
                            fr: 'Modifié le ${_formatDate(context, user.updatedAt!)}',
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              enabled: !busy,
              tooltip: context.localized(
                en: 'Account actions · ${user.id}',
                fr: 'Actions du compte · ${user.id}',
              ),
              onSelected: (action) {
                if (action == 'suspension') {
                  onToggleSuspension();
                } else {
                  onRoleChanged(action);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'user',
                  child: Text(
                    context.localized(
                      en: 'Role · User',
                      fr: 'Rôle · Utilisateur',
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'moderator',
                  child: Text(
                    context.localized(
                      en: 'Role · Moderator',
                      fr: 'Rôle · Modérateur',
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'admin',
                  child: Text(
                    context.localized(
                      en: 'Role · Administrator',
                      fr: 'Rôle · Administrateur',
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'suspension',
                  child: Text(
                    user.suspended
                        ? context.localized(
                            en: 'Reactivate account',
                            fr: 'Réactiver le compte',
                          )
                        : context.localized(en: 'Suspend', fr: 'Suspendre'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime value) {
    return MaterialLocalizations.of(context).formatMediumDate(value.toLocal());
  }
}
