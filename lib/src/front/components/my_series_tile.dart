import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MySeriesTile extends StatelessWidget {
  final Map<String, dynamic> seriesData;
  final String initRoute;

  const MySeriesTile({required this.seriesData, required this.initRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(seriesData['title']),
          subtitle: Text(seriesData['editors']),
          onTap: () {
            context.push('$initRoute/editor/${seriesData['id']}');
          },
        ),
      ],
    );
  }
}
