import 'package:flutter/material.dart';
import 'package:mymangatheque/src/const/own_icon.dart';

class MyIconTextLabel extends StatelessWidget {
  final Color? iconAndTextColor;
  final String iconSrc;
  final String text;
  final double? heightIcon;

  const MyIconTextLabel({
    required this.iconSrc,
    required this.text,
    this.iconAndTextColor,
    this.heightIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OwnIcon(
          iconColor: (iconAndTextColor != null)
              ? iconAndTextColor!
              : Theme.of(context).colorScheme.primary,
          iconSrc: iconSrc,
          height: heightIcon,
        ),
        Text(
          " $text",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: (iconAndTextColor != null)
                ? iconAndTextColor!
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
