import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/pocketbaseadmin.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_login_page.dart';

class AdminCreatePage extends StatelessWidget {
  const AdminCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    PocketBaseAdminConnector connector = PocketBaseAdminConnector();
    if (connector.isLoggedIn()) {
      return Scaffold(
        body: Center(
          child: Text("Admin Create Page"),
        ),
      );
    } else {
      return AdminLoginPage();
    }
  }
}
