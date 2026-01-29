import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/pocketbaseadmin.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/front/components/my_button.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_textfield.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';

class AdminCreateAuthorPage extends StatefulWidget {
  const AdminCreateAuthorPage({super.key});

  @override
  State<AdminCreateAuthorPage> createState() => _AdminCreateAuthorPageState();
}

class _AdminCreateAuthorPageState extends State<AdminCreateAuthorPage> {
  final TextEditingController authorNameController = TextEditingController();
  final TextEditingController authorJobController = TextEditingController();
  final TextEditingController imagePathAuthorController = TextEditingController();
  final TextEditingController imageNameAuthorController = TextEditingController();
  final TextEditingController seriesIdController = TextEditingController();

  void uploadImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 75,
    );

    imagePathAuthorController.text = image!.path;
    imageNameAuthorController.text = image.name;
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    authorNameController.dispose();
    authorJobController.dispose();
    imagePathAuthorController.dispose();
    imageNameAuthorController.dispose();
    super.dispose();
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

    PocketBaseAdminConnector connector = PocketBaseAdminConnector();
    return MyScrollColumn(
      scrollPadding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            localizations.createAuthor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Form(
          child: Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      uploadImage();
                    },
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.asset(
                          imagePathAuthorController.text != "" ? imagePathAuthorController.text : Assets.images.unknown,
                          width: MediaQuery.of(context).size.width * 0.4,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: MediaQuery.of(context).size.width * 0.15,
                    bottom: 0,
                    child: IconButton(
                      onPressed: () {
                        imagePathAuthorController.text = "";
                        imageNameAuthorController.text = "";
                        setState(() {});
                      },
                      icon: Icon(CupertinoIcons.delete_left_fill),
                    ),
                  ),
                ],
              ),
              MyTextField(
                verticalPadding: 5,
                controller: authorNameController,
                labelText: localizations.authorName,
                errorMessage: localizations.provideAuthorName,
              ),
              MyTextField(
                verticalPadding: 5,
                controller: authorJobController,
                labelText: localizations.authorJobs,
                errorMessage: localizations.provideAuthorJobs,
              ),
              MyTextField(
                verticalPadding: 5,
                controller: seriesIdController,
                skipEmptyVerification: true,
                labelText: localizations.seriesIdOfAuthor,
                errorMessage: localizations.provideSeriesIdOfAuthor,
              ),
            ],
          ),
        ),
        MyButton(
          verticalPadding: 5,
          text: localizations.authorAdd,
          onTap: () async {
            final data = jsonDecode((await connector.getCollectionFullList('authors')).toString());
            var authorAlreadyExists = false;
            data.forEach((element) {
              if (element['name'] == authorNameController.text) {
                setState(() {
                  authorAlreadyExists = true;
                });
              }
            });
            if (!authorAlreadyExists) {
              final body = {
                "name": authorNameController.text,
                "job": authorJobController.text,
                "series": jsonDecode(seriesIdController.text),
              };
              connector.createAuthor(body, imageNameAuthorController.text, imagePathAuthorController.text);
              showMessage(localizations.authorAddSuccess, context);
            } else {
              showMessage(localizations.authorDuplicate, context);
            }
          },
        ),
      ],
    );
  }
}
