import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_series_tile.dart';

class AuthorPage extends StatefulWidget {
  final String authorName;
  final String initRoute;

  const AuthorPage({required this.authorName, required this.initRoute, super.key});

  @override
  State<AuthorPage> createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final PocketBaseConnector connector = PocketBaseConnector();
    return FutureBuilder(
      future: connector.getOneExpand('authors', widget.authorName, 'series.editors'),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(localizations.loading),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            appBar: AppBar(
              title: Text(localizations.noConnection),
            ),
            body: Center(
              child: Text(localizations.noConnection),
            ),
          );
        }
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return Scaffold(
            appBar: AppBar(
              title: Text(localizations.errorOccurred),
            ),
            body: Center(
              child: Text(localizations.errorOccurred),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // ? Declaring variables
          Map<String, dynamic> data = json.decode(snapshot.data.toString())[0];
          final height = (MediaQuery.of(context).size.width > 500)
              ? 500.0
              : (MediaQuery.of(context).size.width < 275)
                  ? 275.0
                  : MediaQuery.of(context).size.width;
          final pictureUrl = 'https://api.mymangatheque.com/api/files/hper195bzhpmjp9/${data['id']}/${data['image']}';
          final series = data['expand']['series'];
          // ? Return Scaffold
          return Scaffold(
            appBar: AppBar(
              title: Text(data['name']),
            ),
            body: MyScrollColumn(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SizedBox(
                    height: height * .5,
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        // Image Background with blur effect
                        SizedBox(
                          height: height * .5,
                          child: ClipRRect(
                            child: Wrap(
                              children: [
                                Transform.translate(
                                  offset: Offset(0, -MediaQuery.of(context).size.width / 2),
                                  child: Image.network(
                                    scale: 1 / height,
                                    pictureUrl,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Container(
                                    alignment: Alignment.center,
                                    color: Colors.grey.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Image
                        SizedBox(
                          height: height * .5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              pictureUrl,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'],
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SingleChildScrollView(
                        child: Row(
                          children: [
                            for (var i = 0; i < data['job'].split(', ').length; i++)
                              Text(
                                localizations.jobsName(data['job'].split(', ')[i]) + (i != data['job'].split(', ').length - 1 ? ", " : ""),
                                textAlign: TextAlign.left,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                (series == null)
                    ? SizedBox()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${localizations.seriesCount(series.length)} :",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            ListView(shrinkWrap: true, children: [
                              for (var i = 0; i < series.length; i += 1)
                                Column(
                                  children: [
                                    MySeriesTile(
                                      seriesData: series[i],
                                      initRoute: widget.initRoute,
                                    ),
                                    if (i != series.length - 1) MyLine(width: MediaQuery.of(context).size.width, vertical: 0, horizontal: 10),
                                  ],
                                ),
                            ])
                          ],
                        ),
                      )
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(localizations.authorDoesNotExist),
            ),
            body: Center(
              child: Text(localizations.authorDoesNotExist),
            ),
          );
        }
      },
    );
  }
}
