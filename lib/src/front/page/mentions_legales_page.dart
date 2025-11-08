import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';

class MentionsLegalesPage extends StatelessWidget {
  const MentionsLegalesPage({super.key});

  header(text) {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.only(top: 10)),
        Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  part(text) {
    return Column(children: [
      const Padding(padding: EdgeInsets.only(top: 10)),
      SizedBox(
        width: double.infinity,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    ]);
  }

  subPart(text) {
    return Column(children: [
      const Padding(padding: EdgeInsets.only(top: 10)),
      SizedBox(
        width: double.infinity,
        child: Text(
          '      $text',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.justify,
        ),
      )
    ]);
  }

  paragraph(text) {
    return Column(children: [
      const Padding(padding: EdgeInsets.only(top: 10)),
      SizedBox(
        width: double.infinity,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
          ),
          textAlign: TextAlign.justify,
        ),
      )
    ]);
  }

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

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.legalNotice),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(children: [
              header(localizations.legalNotice),
              part('${localizations.preamble} :'),
              paragraph(localizations.preambleLane1),
              paragraph(localizations.preambleLane2),
              paragraph(localizations.preambleLane3),
              paragraph(localizations.preambleLane4),
              paragraph(localizations.preambleLane5),
              paragraph(localizations.preambleLane6),
              part('I - ${localizations.intellectualProperty} :'),
              subPart("1 - ${localizations.authorRights} :"),
              paragraph(localizations.authorRightsLane1),
              subPart("2 - ${localizations.thirdPartyContent} :"),
              paragraph(localizations.thirdPartyContentLane1),
              part('II - ${localizations.personalData} :'),
              subPart("1 - ${localizations.userContent} :"),
              paragraph(localizations.userContentLane1),
              paragraph(localizations.userContentLane2),
              paragraph(localizations.userContentLane3),
              part("III - ${localizations.protectionOfPersonalData} :"),
              paragraph(localizations.protectionOfPersonalDataLane1),
              subPart("1 - ${localizations.cookieUsage} :"),
              paragraph(localizations.cookieUsageLane1),
              paragraph(localizations.cookieUsageLane2),
              part("IV - ${localizations.externalLinks} :"),
              paragraph(localizations.externalLinksLane1),
              part("V - ${localizations.contactRightsAndUpdateDate} :"),
              subPart("1 - ${localizations.contact} :"),
              paragraph(localizations.contactLane1),
              subPart("2 - ${localizations.applicableLawAndCompetentJurisdiction} :"),
              paragraph(localizations.applicableLawAndCompetentJurisdictionLane1),
              subPart("${localizations.lastUpdateDate} : ${DateFormat.yMMMMd(localizations.localeName).format(DateTime.utc(2023, 12, 13))}"),
            ]),
          ),
        ),
      ),
    );
  }
}
