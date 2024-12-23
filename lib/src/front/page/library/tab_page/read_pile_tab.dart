import 'package:flutter/material.dart';

class ReadPileTab extends StatefulWidget {
  const ReadPileTab({super.key});

  @override
  State<ReadPileTab> createState() => _ReadPileTabState();
}

class _ReadPileTabState extends State<ReadPileTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text('Tab1'),
          Text('data'),
        ],
      ),
    );
  }
}
