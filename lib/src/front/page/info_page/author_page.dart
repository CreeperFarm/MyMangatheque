import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_series_tile.dart';

class AuthorPage extends StatefulWidget {
  final String authorName;
  final String initRoute;

  const AuthorPage({
    required this.authorName,
    required this.initRoute,
    super.key,
  });

  @override
  State<AuthorPage> createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final AppwriteConnector connector = AppwriteConnector();
    return FutureBuilder<List<RecordModel>>(
      future: connector.getOneExpand(
        'authors',
        widget.authorName,
        'series.editors',
      ),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(localizations.loading)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            appBar: AppBar(title: Text(localizations.noConnection)),
            body: Center(child: Text(localizations.noConnection)),
          );
        }
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return Scaffold(
            appBar: AppBar(title: Text(localizations.errorOccurred)),
            body: Center(child: Text(localizations.errorOccurred)),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // ? Declaring variables
          final data = snapshot.data!.isNotEmpty ? Map<String, dynamic>.from(snapshot.data!.first.data) : <String, dynamic>{};
          final expand = data['expand'] is Map<String, dynamic> ? data['expand'] as Map<String, dynamic> : <String, dynamic>{};
          final height = (MediaQuery.of(context).size.width > 500)
              ? 500.0
              : (MediaQuery.of(context).size.width < 275)
              ? 275.0
              : MediaQuery.of(context).size.width;
          final pictureUrl = data['image']?.toString() ?? data['coverUrl']?.toString();
          final series = List<Map<String, dynamic>>.from(
            (expand['series'] as List<dynamic>? ?? const <dynamic>[]).whereType<Map<String, dynamic>>(),
          );
          final jobsRaw = data['job']?.toString() ?? '';
          final jobs = jobsRaw.isEmpty ? const <String>[] : jobsRaw.split(', ');
          final authorName = data['name']?.toString() ?? '';
          // ? Return Scaffold
          return Scaffold(
            appBar: AppBar(title: Text(authorName)),
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
                                  offset: Offset(
                                    0,
                                    -MediaQuery.of(context).size.width / 2,
                                  ),
                                  child: SafeNetworkImage(
                                    imageUrl: pictureUrl,
                                    scale: 1 / height,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 5,
                                    sigmaY: 5,
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    color: Colors.grey.withValues(alpha: 0.4),
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
                            child: SafeNetworkImage(
                              imageUrl: pictureUrl,
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
                        authorName,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SingleChildScrollView(
                        child: Row(
                          children: [
                            for (var i = 0; i < jobs.length; i++)
                              Text(
                                localizations.jobsName(jobs[i]) + (i != jobs.length - 1 ? ", " : ""),
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                (series.isEmpty)
                    ? const SizedBox()
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
                            ListView(
                              shrinkWrap: true,
                              children: [
                                for (var i = 0; i < series.length; i += 1)
                                  Column(
                                    children: [
                                      MySeriesTile(
                                        seriesData: series[i],
                                        initRoute: widget.initRoute,
                                      ),
                                      if (i != series.length - 1)
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
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: Text(localizations.authorDoesNotExist)),
            body: Center(child: Text(localizations.authorDoesNotExist)),
          );
        }
      },
    );
  }
}
