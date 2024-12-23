import 'package:flutter/material.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';

class EnvyTab extends StatefulWidget {
  const EnvyTab({super.key});

  @override
  State<EnvyTab> createState() => _EnvyTabState();
}

class _EnvyTabState extends State<EnvyTab> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          MyTomeNumberShow(tomeTotal: "10", editionTotal: "5"),
          Text('Tab4'),
          Text('data'),
        ],
      ),
    );
  }
}
