import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/pocketbaseadmin.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_login_page.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_author.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_genre.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_volume_page.dart';

class AdminCreatePage extends StatelessWidget {
  const AdminCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    PocketBaseAdminConnector connector = PocketBaseAdminConnector();
    if (connector.isLoggedIn()) {
      return DefaultTabController(
        length: 6,
        initialIndex: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: "Serie"),
                Tab(text: "SubSerie"),
                Tab(text: "Volume"),
                Tab(text: "Auteur"),
                Tab(text: "Éditeur"),
                Tab(text: "Genre"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              //AdminCreateSeriePage(),
              //AdminCreateSubSeriePage(),
              AdminCreateVolumePage(),
              AdminCreateAuthorPage(),
              //AdminCreateEditeurPage(),
              AdminCreateGenrePage(),
            ],
          ),
        ),
      );
    } else {
      return AdminLoginPage();
    }
  }
}
