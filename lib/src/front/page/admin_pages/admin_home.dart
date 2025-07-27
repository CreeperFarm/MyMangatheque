import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/pocketbaseadmin.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_login_page.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (PocketBaseAdminConnector().isLoggedIn()) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            localizations.adminHomePage,
          ),
        ),
        body: MyScrollColumn(
          children: [
            Center(
              child: Column(
                children: [
                  Text(localizations.adminHomePage),
                  Text(localizations.adminHomePageDescription),
                  ElevatedButton(onPressed: () => pushOrGo(context, '/admin/create'), child: Text("Go to Admin Create Page")),
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
