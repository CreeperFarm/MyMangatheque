import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';

class EnvyTab extends StatefulWidget {
  const EnvyTab({super.key});

  @override
  State<EnvyTab> createState() => _EnvyTabState();
}

class _EnvyTabState extends State<EnvyTab> {
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

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          MyTomeNumberShow(
            tomeTotal: "10",
            editionTotal: "5",
            localizations: localizations,
          ),
          Text('Tab4'),
          Text('data'),
        ],
      ),
    );
  }
}
