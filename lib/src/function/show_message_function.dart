import 'package:flutter/material.dart';

void showMessage(String message, context) {
  final SnackBar snackBar = SnackBar(
    backgroundColor: Theme.of(context).colorScheme.onPrimary,
    clipBehavior: Clip.none,
    dismissDirection: DismissDirection.down,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    duration: Duration(seconds: 3),
    elevation: 10,
    content: Text(
      message,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    action: SnackBarAction(
      textColor: Theme.of(context).colorScheme.primary,
      label: 'Ok',
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
