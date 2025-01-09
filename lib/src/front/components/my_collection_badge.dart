import 'package:flutter/material.dart';

class MyCollectionBadge extends StatelessWidget {
  const MyCollectionBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1780A3),
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5.0,
          vertical: 2.0,
        ),
        child: Row(
          children: [
            Icon(
              Icons.check,
              color: Colors.white,
              size: 18,
            ),
            Text(
              'Possédé',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
