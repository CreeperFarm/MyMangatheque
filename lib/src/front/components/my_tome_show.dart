import 'package:flutter/material.dart';

class MyTomeShow extends StatelessWidget {
  final String title;
  final String authors;

  const MyTomeShow({required this.title, required this.authors, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /*Row(
          children: [],
        ),*/
        Text(title),
        Text(authors)
      ],
    );
  }
}
