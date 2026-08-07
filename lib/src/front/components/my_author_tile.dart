import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';

class MyAuthorTile extends StatelessWidget {
  final Map<String, dynamic> authorData;
  final String initRoute;

  const MyAuthorTile({
    required this.authorData,
    required this.initRoute,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final job = authorData['job']?.toString() ?? '';
    final jobs = job.isEmpty ? const <String>[] : job.split(', ');
    final imageUrl =
        authorData['image']?.toString() ?? authorData['coverUrl']?.toString();

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () => pushOrGo(
          context,
          '${(initRoute == "/") ? "" : initRoute}/author/${authorData['id']}',
        ),
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
                    child: SafeNetworkImage(
                      imageUrl: imageUrl,
                      height: 50,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorData['name'].toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < jobs.length; i++)
                            Text(
                              localizations.jobsName(jobs[i]) +
                                  (i != jobs.length - 1 ? ", " : ""),
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontSize: 13),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ],
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
      ),
    );
  }
}
