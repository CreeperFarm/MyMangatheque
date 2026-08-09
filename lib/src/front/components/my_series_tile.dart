import 'package:flutter/material.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/safe_expand_reader.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';

class MySeriesTile extends StatelessWidget {
  final Map<String, dynamic> seriesData;
  final String initRoute;

  const MySeriesTile({
    required this.seriesData,
    required this.initRoute,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final expand = SafeExpandReader.asMap(seriesData['expand']);
    final names =
        SafeExpandReader.asMapList(
              expand['editors'],
            )
            .map((item) => item['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
    final editorNames = names.isEmpty ? '' : '• ${names.join(', ')}';

    final title =
        seriesData['title']?.toString() ??
        seriesData['titleFr']?.toString() ??
        '';
    final imageUrl =
        seriesData['image']?.toString() ?? seriesData['coverUrl']?.toString();

    final id = seriesData['id']?.toString() ?? '';
    if (id.isEmpty) return const SizedBox.shrink();

    final routePrefix = initRoute == "/" ? "" : initRoute;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: OwnIcon(
        iconColor: Theme.of(context).colorScheme.primary,
        iconSrc: Assets.icons.arrowRight,
      ),
      subtitle: editorNames.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                children: [
                  Text(editorNames, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: SafeNetworkImage(imageUrl: imageUrl),
      ),
      onTap: () {
        pushOrGo(context, '$routePrefix/serie/$id');
      },
    );
  }
}
