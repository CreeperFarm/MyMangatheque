import 'package:flutter/material.dart';

class MyLine extends StatelessWidget {
  final dynamic width;
  final double vertical;
  final double? horizontal;

  const MyLine({
    required this.width,
    required this.vertical,
    this.horizontal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal != null ? horizontal! : 10.0,
        vertical: vertical,
      ),
      child: Container(height: 1.0, width: width, color: Colors.grey),
    );
  }
}
