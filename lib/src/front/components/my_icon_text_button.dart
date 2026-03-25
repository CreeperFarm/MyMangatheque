import 'package:flutter/material.dart';
import 'package:mymangatheque/src/const/own_icon.dart';

class MyIconTextButton extends StatelessWidget {
  final Function() function;
  final Color color;
  final String iconSrc;
  final String text;

  const MyIconTextButton({
    required this.function,
    required this.color,
    required this.iconSrc,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 18.0),
      child: SingleChildScrollView(
        child: GestureDetector(
          onTap: function,
          child: Row(
            children: [
              const Padding(padding: EdgeInsets.only(right: 16)),
              OwnIcon(iconColor: color, iconSrc: iconSrc),
              const Padding(padding: EdgeInsets.only(right: 9)),
              Text(text, style: TextStyle(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
