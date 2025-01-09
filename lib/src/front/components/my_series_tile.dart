import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/const/own_icon.dart';

class MySeriesTile extends StatelessWidget {
  final Map<String, dynamic> seriesData;
  final String initRoute;

  const MySeriesTile({required this.seriesData, required this.initRoute, super.key});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> editors = seriesData['expand']['editors'];
    String editorNames = "• ";
    for (var i = 0; i < editors.length; i += 1) {
      editorNames = editorNames + editors[i]['name'] + ((i != editors.length - 1) ? ", " : "");
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      title: Text(
        seriesData['title'],
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: OwnIcon(
        iconColor: Theme.of(context).colorScheme.primary,
        iconName: 'arrow-right',
      ),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: [
            Text(
              editorNames,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(
          'https://api.mymangatheque.com/api/files/utbujxtz8wtq0ar/${seriesData['id']}/${seriesData['image']}',
        ),
      ),
      onTap: () {
        context.push('${(initRoute == "/") ? "" : initRoute}/serie/${seriesData['id']}');
      },
    );
  }
}
