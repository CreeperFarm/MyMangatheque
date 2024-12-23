import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/const/const_info.dart';
import 'package:mymangatheque/src/const/own_icon.dart';

class MyTomeTile extends StatelessWidget {
  final Map<String, dynamic> volumeData;

  const MyTomeTile({required this.volumeData, super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime release = DateTime.parse(volumeData['release']);
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () => context.push('/search/volume/${volumeData.toString()}'),
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
                      "https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${volumeData['id'].toString()}/${volumeData['image'].toString()}",
                      height: 75,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tome ${volumeData['tome_number']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${release.day} ${month[release.month.toString()]} ${release.year}',
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
