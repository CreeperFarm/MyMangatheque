import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class MyDrawerTile extends StatelessWidget {
  final String title;
  final String icon;
  final String goTo;
  const MyDrawerTile({required this.title, required this.icon, required this.goTo, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: OwnIcon(
        iconName: icon,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
      onTap: () {
        Navigator.pop(context);
        context.go(goTo);
      },
    );
  }
}
