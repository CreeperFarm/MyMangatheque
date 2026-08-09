import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_sub_series_tile.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';

class EditorPage extends StatefulWidget {
  final String editorId;
  final String initRoute;

  const EditorPage({
    required this.editorId,
    required this.initRoute,
    super.key,
  });

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final AppwriteConnector connector = AppwriteConnector();

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<List<RecordModel>>(
      future: connector.getOneExpand(
        'editors',
        widget.editorId,
        'subSeries.editors',
      ),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState == ConnectionState.none) {
          return Center(child: Text(localizations.noConnection));
        }
        if (snapshot.hasError) {
          RuntimeLocalization.debug(
            en: 'Unable to load the publisher page: ${snapshot.error}',
            fr: 'Impossible de charger la page de l’éditeur : ${snapshot.error}',
          );
          return Center(child: Text(localizations.errorOccurred));
        }
        if (snapshot.hasData && snapshot.data != null) {
          // ? Define variables
          final data = snapshot.data!.isNotEmpty
              ? Map<String, dynamic>.from(snapshot.data!.first.data)
              : <String, dynamic>{};
          final expand = data['expand'] is Map<String, dynamic>
              ? data['expand'] as Map<String, dynamic>
              : <String, dynamic>{};
          final subSeries = List<Map<String, dynamic>>.from(
            (expand['subSeries'] as List<dynamic>? ?? const <dynamic>[])
                .whereType<Map<String, dynamic>>(),
          );
          final editorName = data['name']?.toString() ?? '';
          final logoUrl =
              data['logo']?.toString() ??
              data['image']?.toString() ??
              data['coverUrl']?.toString();

          // ? Building the widget
          return Scaffold(
            appBar: AppBar(
              title: Text(
                editorName,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
            body: MyScrollColumn(
              columnMainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 275,
                    maxWidth: MediaQuery.of(context).size.width,
                  ),
                  child: SafeNetworkImage(imageUrl: logoUrl, fit: BoxFit.fill),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        editorName,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      MyLine(
                        width: MediaQuery.of(context).size.width,
                        vertical: 10,
                        horizontal: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.subSeriesCount(subSeries.length),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            ListView(
                              shrinkWrap: true,
                              children: [
                                for (var i = 0; i < subSeries.length; i += 1)
                                  Column(
                                    children: [
                                      MySubSeriesTile(
                                        data: subSeries[i],
                                        initRoute: widget.initRoute,
                                      ),
                                      if (i != subSeries.length - 1)
                                        MyLine(
                                          width: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          vertical: 0,
                                          horizontal: 10,
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: Text(localizations.editorDoesNotExist)),
            body: Center(child: Text(localizations.editorDoesNotExist)),
          );
        }
      },
    );
  }
}
