import 'package:flutter/material.dart';

class MyGenresShow extends StatelessWidget {
  final Map<String, dynamic> data;

  const MyGenresShow({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Theme.of(context).colorScheme.onSecondary,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              data['name'].toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        ),
      ),
    );
  }
}
