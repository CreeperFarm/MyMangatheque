import 'package:flutter/material.dart';
import 'package:mymangatheque/src/const/own_icon.dart';

class MyIconTextLabel extends StatelessWidget {
  final Color? iconAndTextColor;
  final String iconName;
  final String text;

  const MyIconTextLabel({required this.iconName, required this.text, this.iconAndTextColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      OwnIcon(iconColor: (iconAndTextColor != null) ? iconAndTextColor! : Theme.of(context).colorScheme.primary, iconName: iconName),
      Text(
        " $text",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: (iconAndTextColor != null) ? iconAndTextColor! : Theme.of(context).colorScheme.primary,
        ),
      ),
    ]);
  }
}
