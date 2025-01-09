import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/const/own_icon.dart';

class MyAuthorTile extends StatelessWidget {
  final Map<String, dynamic> authorData;
  final String initRoute;

  const MyAuthorTile({required this.authorData, required this.initRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () => context.push('${(initRoute == "/") ? "" : initRoute}/author/${authorData['id']}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "https://api.mymangatheque.com/api/files/hper195bzhpmjp9/${authorData['id'].toString()}/${authorData['image'].toString()}",
                      height: 50,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorData['name'].toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        authorData['job'].toString(),
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            OwnIcon(
              iconColor: Theme.of(context).colorScheme.primary,
              iconName: 'arrow-right',
            ),
          ],
        ),
      ),
    );
  }
}
