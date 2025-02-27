import 'package:flutter/material.dart';
import 'package:mymangatheque/src/const/const_info.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

import 'my_collection_badge.dart';

class MyVolumeTile extends StatelessWidget {
  final Map<String, dynamic> volumeData;
  final Map<String, dynamic>? subSerieData;
  final String initRoute;
  final bool? isVolumeOwned;

  const MyVolumeTile({required this.volumeData, required this.subSerieData, required this.initRoute, this.isVolumeOwned, super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime release = DateTime.parse(volumeData['release']);
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () => pushOrGo(context, '$initRoute/volume/${volumeData['id'].toString()}'),
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
                      (!subSerieData!.containsKey(volumeData['sub_serie_id'].toString()) && isVolumeOwned != true)
                          ? SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 1.0),
                              child: MyCollectionBadge(),
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
