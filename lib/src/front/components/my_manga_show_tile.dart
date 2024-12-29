import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyMangaShowTile extends StatelessWidget {
  final Map<String, dynamic> mangaData;
  final String initRoute;
  final double width;
  final double height;

  const MyMangaShowTile({
    required this.mangaData,
    required this.initRoute,
    required this.width,
    required this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 10.0,
        bottom: 10.0,
      ),
      child: InkWell(
        onTap: () {
          context.push('${(initRoute == "/") ? "" : initRoute}/volume/${mangaData['id']}');
        },
        child: Container(
          constraints: BoxConstraints(
            maxWidth: width,
            maxHeight: height,
            minWidth: width,
            minHeight: height,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: OverflowBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                      ),
                      child: SizedBox(
                        height: height * 0.79,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            'https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${mangaData['id']}/${mangaData['image']}',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    child: Text(
                      mangaData['title'].toString().replaceAll(' - Tome ${mangaData['tome_number']}', ""),
                      style: TextStyle(
                        fontSize: 17,
                      ),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 10.0,
                      left: 10.0,
                      bottom: 10.0,
                    ),
                    child: Text(
                      'Tome ${mangaData['tome_number']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
