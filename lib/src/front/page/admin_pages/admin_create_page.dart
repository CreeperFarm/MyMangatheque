import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_author.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_genre.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _admin.init().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_admin.isLoggedIn()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Create')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => pushOrGo(context, '/admin/admin_login'),
            child: const Text('Se connecter en admin'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Create'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Auteur'),
            Tab(text: 'Genre'),
            Tab(text: 'Volume'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminCreateAuthorPage(),
          AdminCreateGenrePage(),
          AdminCreateVolumePage(),
        ],
      ),
    );
  }
}
