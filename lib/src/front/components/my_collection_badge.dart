import 'package:flutter/material.dart';

import 'package:mymangatheque/l10n/app_localizations.dart';

class MyCollectionBadge extends StatelessWidget {
  AppLocalizations localizations;
  MyCollectionBadge({required this.localizations, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1780A3),
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5.0,
          vertical: 2.0,
        ),
        child: Row(
          children: [
            Icon(
              Icons.check,
              color: Colors.white,
              size: 18,
            ),
            Text(
              localizations.owned,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
