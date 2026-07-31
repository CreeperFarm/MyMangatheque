import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class MyTomeNumberShow extends StatelessWidget {
  final String tomeTotal;
  final String editionTotal;
  final AppLocalizations localizations;

  const MyTomeNumberShow({
    required this.tomeTotal,
    required this.editionTotal,
    required this.localizations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "$tomeTotal ${localizations.volume} • $editionTotal ${localizations.edition}",
          textAlign: TextAlign.start,
          style: GoogleFonts.adventPro(
            textStyle: const TextStyle(fontSize: 30),
          ),
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 20,
              height: 32 * 5 / 6 + 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.5),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Theme.of(context).colorScheme.surface,
                        ),
                        iconColor: WidgetStateProperty.all<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                        elevation: WidgetStateProperty.all<double>(0),
                      ),
                      onPressed: () => pushOrGo(context, '/library/scan'),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OwnIcon(
                            iconColor: Theme.of(context).colorScheme.primary,
                            iconSrc: Assets.icons.barcode,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            localizations.scanner,
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        MyLine(
          width: MediaQuery.of(context).size.width,
          vertical: 10,
          horizontal: 0,
        ),
      ],
    );
  }
}
