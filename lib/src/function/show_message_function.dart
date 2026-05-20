import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';

void showMessage(String message, BuildContext context) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }
  final localizations = AppLocalizations.of(context);

  final SnackBar snackBar = SnackBar(
    backgroundColor: Theme.of(context).colorScheme.onPrimary,
    clipBehavior: Clip.none,
    dismissDirection: DismissDirection.down,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    duration: const Duration(seconds: 3),
    elevation: 10,
    content: Text(
      message,
      style: TextStyle(color: Theme.of(context).colorScheme.primary),
    ),
    action: SnackBarAction(
      textColor: Theme.of(context).colorScheme.primary,
      label: localizations?.ok ?? 'OK',
      onPressed: () {
        messenger.hideCurrentSnackBar();
      },
    ),
  );
  messenger.showSnackBar(snackBar);
  /*showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      });*/
}
