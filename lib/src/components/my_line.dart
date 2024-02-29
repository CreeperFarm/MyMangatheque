import 'package:flutter/material.dart';

class MyLine extends StatelessWidget {
  dynamic width;
  final double vertical;
  MyLine({required this.width, required this.vertical, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal:10.0, vertical: vertical),
      child: Container(
        height: 1.0,
        width: width,
        color: Colors.grey,
      ),
    );
  }
}
