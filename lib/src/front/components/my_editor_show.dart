import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/const/own_icon.dart';

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
        context.push('${(initRoute == "/") ? "" : initRoute}/editor/${editor['id'].toString()}');
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
                    child: Image.network(
                      "https://api.mymangatheque.com/api/files/whwwobw02cwbhtj/${editor['id'].toString()}/${editor['logo'].toString()}",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  editor['name'].toString(),
                  style: const TextStyle(
                    fontSize: 18,
                  ),
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
