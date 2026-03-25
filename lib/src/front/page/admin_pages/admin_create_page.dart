import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:mymangatheque/src/back/services/pocketbaseadmin.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_login_page.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_author.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_genre.dart';
import 'package:mymangatheque/src/front/page/admin_pages/create_page/admin_create_volume_page.dart';

class AdminCreatePage extends StatelessWidget {
  const AdminCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                Tab(text: localizations.series),
                Tab(text: localizations.subSeries),
                Tab(text: localizations.volume),
                Tab(text: localizations.author),
                Tab(text: localizations.editor),
                Tab(text: localizations.genre),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              //AdminCreateSeriePage(),
              //AdminCreateSubSeriePage(),
              AdminCreateVolumePage(),
              AdminCreateAuthorPage(),
              //AdminCreateEditorPage(),
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
