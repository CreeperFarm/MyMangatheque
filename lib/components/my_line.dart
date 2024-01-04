import 'package:flutter/material.dart';

class MyLine extends StatelessWidget {
  dynamic width;
  MyLine({required this.width, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:10.0, vertical: 10),
      child: Container(
        height: 1.0,
        width: width,
        color: Colors.grey,
      ),
    );
  }
}
