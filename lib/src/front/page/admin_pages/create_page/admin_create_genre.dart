import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/pocketbaseadmin.dart';
import 'package:mymangatheque/src/front/components/my_button.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_textfield.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';

class AdminCreateGenrePage extends StatefulWidget {
  const AdminCreateGenrePage({super.key});

  @override
  State<AdminCreateGenrePage> createState() => _AdminCreateGenrePageState();
}

class _AdminCreateGenrePageState extends State<AdminCreateGenrePage> {
  final TextEditingController genreController = TextEditingController();

  @override
  void dispose() {
    genreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    PocketBaseAdminConnector connector = PocketBaseAdminConnector();
    return MyScrollColumn(
      scrollPadding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            localizations.createGenre,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Form(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: MyTextField(
                  controller: genreController,
                  labelText: localizations.genreName,
                  errorMessage: localizations.provideGenreName,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: MyButton(
                  text: localizations.genreAdd,
                  onTap: () async {
                    final data = jsonDecode(
                      (await connector.getCollectionFullList(
                        'genres',
                      )).toString(),
                    );
                    var genreAlreadyExists = false;
                    data.forEach((element) {
                      if (element['name'] == genreController.text) {
                        setState(() {
                          genreAlreadyExists = true;
                        });
                      }
                    });
                    if (!genreAlreadyExists) {
                      connector.createGenre(genreController.text);
                      showMessage(localizations.genreAddSuccess, context);
                    } else {
                      showMessage(localizations.genreDuplicate, context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
