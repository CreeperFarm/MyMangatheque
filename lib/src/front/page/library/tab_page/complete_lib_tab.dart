import 'package:flutter/material.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';

class CompleteLibTab extends StatefulWidget {
  const CompleteLibTab({super.key});

  @override
  State<CompleteLibTab> createState() => _CompleteLibTabState();
}

class _CompleteLibTabState extends State<CompleteLibTab> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          MyTomeNumberShow(tomeTotal: "10", editionTotal: "5"),
          Text('Tab3'),
          Text('data'),
        ],
      ),
    );
  }
}
