import 'package:flutter/material.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';

class MyEditorShow extends StatelessWidget {
  final Map<String, dynamic> editor;
  final String initRoute;

  const MyEditorShow({
    required this.editor,
    required this.initRoute,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        pushOrGo(
          context,
          '${(initRoute == "/") ? "" : initRoute}/editor/${editor['id'].toString()}',
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 50,
                      maxWidth: MediaQuery.of(context).size.width / 4,
                    ),
                    child: SafeNetworkImage(
                      imageUrl: (editor['coverUrl'] ?? '').toString(),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  editor['name'].toString(),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          OwnIcon(
            iconColor: Theme.of(context).colorScheme.primary,
            iconSrc: Assets.icons.arrowRight,
          ),
        ],
      ),
    );
  }
}
