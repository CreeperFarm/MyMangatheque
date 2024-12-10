import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
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
    PocketBaseAdminConnector connector = PocketBaseAdminConnector();
    return MyScrollColumn(
      scrollPadding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "Créer un genre",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Form(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: MyTextField(
                  controller: genreController,
                  labelText: "Nom du genre",
                  errorMessage: "Veuillez entrer le nom du genre",
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: MyButton(
                  text: "Créer",
                  onTap: () async {
                    final data = jsonDecode((await connector.getCollectionFullList('genres')).toString());
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
                      showMessage("Le genre à été créer", context);
                    } else {
                      showMessage('Ce genre existe déjà', context);
                    }
                    ;
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
