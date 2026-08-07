import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/safe_expand_reader.dart';

class MySubSeriesTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String initRoute;

  const MySubSeriesTile({required this.data, required this.initRoute, super.key});

  @override
  Widget build(BuildContext context) {
    final volumes = SafeExpandReader.asMapList(data['expand'][0]['volumes'])
      ..sort((a, b) {
        final tomeA = num.tryParse(a['tomeNumber']?.toString() ?? '') ?? 1e9;
        final tomeB = num.tryParse(b['tomeNumber']?.toString() ?? '') ?? 1e9;
        return tomeA.compareTo(tomeB);
      });

    final editor = data["expand"][0]["editors"][0];

    final title = data['title']?.toString() ?? data['titleFr']?.toString() ?? '';
    final subtitle = editor["name"] == null ? title : '$title • ${editor["name"]}';

    final routePrefix = initRoute == "/" ? "" : initRoute;
    final id = data['id']?.toString() ?? '';
    if (id.isEmpty) return const SizedBox.shrink();

    return InkWell(
      onTap: () {
        pushOrGo(context, '$routePrefix/sub_serie/$id');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right + 44),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                    bottom: 10,
                    right: 5,
                    left: 5,
                  ),
                  child: Text(
                    subtitle,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 65,
                    child: Stack(
                      children: [
                        for (var i = 0; i < min(12, volumes.length); i += 1)
                          (i == 0)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: SafeNetworkImage(
                                    imageUrl: volumes[i]['coverUrl']?.toString(),
                                    height: 90,
                                  ),
                                )
                              : Positioned(
                                  left: i * 25.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: SafeNetworkImage(
                                        imageUrl: volumes[i]['coverUrl']?.toString(),
                                        height: 90,
                                      ),
                                    ),
                                  ),
                                ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          OwnIcon(iconColor: Theme.of(context).colorScheme.primary, iconSrc: Assets.icons.arrowRight),
        ],
      ),
    );
  }
}
