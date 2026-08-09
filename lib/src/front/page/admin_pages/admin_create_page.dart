import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_author.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_editor.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_genre.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_series.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_sub_series.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_volume_page.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class AdminCreatePage extends StatefulWidget {
  const AdminCreatePage({super.key});

  @override
  State<AdminCreatePage> createState() => _AdminCreatePageState();
}

class _AdminCreatePageState extends State<AdminCreatePage>
    with TickerProviderStateMixin {
  final AdminConnector _admin = AdminConnector();
  late final TabController _tabController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _admin.init().then((_) {
      if (!mounted) return;
      setState(() {
        _initialized = true;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_admin.isLoggedIn()) {
      return AdminPageScaffold(
        title: context.localized(
          en: 'Data creation',
          fr: 'Création de données',
        ),
        child: Center(
          child: FilledButton.icon(
            onPressed: () => pushOrGo(context, '/admin/admin_login'),
            icon: const Icon(Icons.login_rounded),
            label: Text(
              context.localized(
                en: 'Sign in as admin',
                fr: 'Se connecter en admin',
              ),
            ),
          ),
        ),
      );
    }

    return AdminPageScaffold(
      title: context.localized(en: 'Data creation', fr: 'Création de données'),
      scrollable: false,
      maxWidth: 1080,
      appBarBottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: [
          Tab(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            text: context.localized(en: 'Author', fr: 'Auteur'),
          ),
          Tab(
            icon: const Icon(Icons.sell_outlined),
            text: context.localized(en: 'Genre', fr: 'Genre'),
          ),
          Tab(
            icon: const Icon(Icons.business_outlined),
            text: context.localized(en: 'Publisher', fr: 'Éditeur'),
          ),
          Tab(
            icon: const Icon(Icons.collections_bookmark_outlined),
            text: context.localized(en: 'Series', fr: 'Série'),
          ),
          Tab(
            icon: const Icon(Icons.account_tree_outlined),
            text: context.localized(en: 'Sub-series', fr: 'Sous-série'),
          ),
          Tab(
            icon: const Icon(Icons.menu_book_outlined),
            text: context.localized(en: 'Volume', fr: 'Volume'),
          ),
        ],
      ),
      child: TabBarView(
        controller: _tabController,
        children: const [
          AdminCreateAuthorPage(),
          AdminCreateGenrePage(),
          AdminCreateEditorPage(),
          AdminCreateSeriesPage(),
          AdminCreateSubSeriesPage(),
          AdminCreateVolumePage(),
        ],
      ),
    );
  }
}
