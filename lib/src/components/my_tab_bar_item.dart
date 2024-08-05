import 'package:flutter/material.dart';

class MyTabBarItem extends StatelessWidget {
  final String tabText;
  Color colorIn;
  Color colorOut;
  MyTabBarItem({required this.tabText, required this.colorIn, required this.colorOut, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Transform.translate(
        offset: const Offset(0, 0.5),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.transparent,
                width: 2.0
            ),
            borderRadius: BorderRadius.circular(360),
          ),
          child: Material(
            color: colorIn,
            borderRadius: BorderRadius.circular(360),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4),
              child: Transform.translate(
                offset: const Offset(0, 3.5),
                child: Text(
                  tabText,
                  style: TextStyle(
                    color: colorOut,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}