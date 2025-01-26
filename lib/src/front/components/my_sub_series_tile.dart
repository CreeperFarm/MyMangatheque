import 'package:flutter/material.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class MySubSeriesTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String initRoute;

  const MySubSeriesTile({required this.data, required this.initRoute, super.key});

  @override
  Widget build(BuildContext context) {
    final volumes = data['expand']['volumes'];
    volumes.sort((a, b) {
      if (a['tome_number'] < b['tome_number']) {
        return -1;
      } else if (a['tome_number'] > b['tome_number']) {
        return 1;
      } else {
        return 0;
      }
    });
    return InkWell(
      onTap: () {
        pushOrGo(context, '${(initRoute == "/") ? "" : initRoute}/sub_serie/${data['id'].toString()}');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right),
                    child: Text(
                      '${data['title'].toString().replaceFirst(data['title'] + ' - ', '')} • ${data['expand']['editor']['name'].toString()}',
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < volumes.length; i += 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${volumes[i]['id'].toString()}/${volumes[i]['image'].toString()}",
                            height: 90,
                          ),
                        ),
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
    );
  }
}
