import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/last_ean.dart';
import 'package:mymangatheque/src/back/services/pocketbaseadmin.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_login_page.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    var lastEAN = ref.watch(lastEANProvider);

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
                  ElevatedButton(
                    child: Text(localizations.scanEAN),
                    onPressed: () => pushOrGo(context, '/library/scan'),
                  ),
                  ElevatedButton(
                    child: Text('Copy last EAN: $lastEAN'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: lastEAN));
                      // copied successfully
                    },
                  ),
                  ElevatedButton(
                    child: Text("Stats"),
                    onPressed: () => pushOrGo(context, '/admin/static_page'),
                  ),
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
