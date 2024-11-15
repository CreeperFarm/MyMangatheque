import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/back/services/pocketbaseadmin.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_login_page.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (PocketBaseAdminConnector().isLoggedIn()) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Admin Home Page",
          ),
        ),
        body: MyScrollColumn(
          children: [
            Center(
              child: Column(
                children: [
                  Text("Admin Home Page"),
                  ElevatedButton(onPressed: () => context.go('/admin/create'), child: Text("Go to Admin Create Page")),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return AdminLoginPage();
    }
  }
}
