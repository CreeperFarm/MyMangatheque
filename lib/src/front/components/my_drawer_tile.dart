import 'package:flutter/material.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class MyDrawerTile extends StatelessWidget {
  final String title;
  final String icon;
  final String goTo;
  final bool pop;

  MyDrawerTile({required this.title, required this.icon, required this.goTo, required this.pop, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: OwnIcon(
        iconName: icon,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
      onTap: () {
        if (pop) {
          Navigator.pop(context);
        } else {}
        pushOrGo(context, goTo);
      },
    );
  }
}
