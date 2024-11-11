import 'package:flutter/material.dart';

void showMessage(String message, context) {
  showDialog(
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
      });
}
