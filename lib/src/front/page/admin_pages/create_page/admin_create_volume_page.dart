import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymangatheque/src/back/services/pocketbaseadmin.dart';
import 'package:mymangatheque/src/front/components/my_button.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_textfield.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class AdminCreateVolumePage extends StatefulWidget {
  const AdminCreateVolumePage({super.key});

  @override
  State<AdminCreateVolumePage> createState() => _AdminCreateVolumePageState();
}

class _AdminCreateVolumePageState extends State<AdminCreateVolumePage> {
  // A (*) Mean that the field is required

  final TextEditingController titleVolumeController = TextEditingController(); // Field (*) : title
  final TextEditingController numberVolumeController = TextEditingController(); // Field : tome_number
  final TextEditingController eanVolumeController = TextEditingController(); // Field (*) : ean
  final TextEditingController priceVolumeController = TextEditingController(); // Field (*) : price
  bool over18 = false; // Field (*) : over18
  final TextEditingController languageVolumeController = TextEditingController(); // Field (*) : language
  final TextEditingController supportVolumeController = TextEditingController(); // Field (*) : support
  final TextEditingController genreJapVolumeController = TextEditingController(); // Field : genre_jap
  final TextEditingController resumeVolumeController = TextEditingController(); // Field (*) : resume
  final TextEditingController imagePathVolumeController = TextEditingController(); // Field : image
  final TextEditingController imageNameVolumeController = TextEditingController(); // Field : image
  final TextEditingController bookLinkVolumeController = TextEditingController(); // Field (*) : book_link
  final TextEditingController infoVolumeController = TextEditingController(); // Field : info
  DateTime release = DateTime.now(); // Field : release

  // Correspond to id of the items connected
  final TextEditingController serieVolumeController = TextEditingController(); // Field (*) : series
  final TextEditingController subSerieVolumeController = TextEditingController(); // Field (*) : sub_series
  final TextEditingController authorsVolumeController = TextEditingController(); // Field (*) : authors
  final TextEditingController editorVolumeController = TextEditingController(); // Field (*) : editor
  final TextEditingController containsVolumeController = TextEditingController(); // Field : contain

  void uploadImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 75,
    );

    imagePathVolumeController.text = image!.path;
    imageNameVolumeController.text = image.name;

    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {});
    });
  }

  @override
  void initState() {
    bookLinkVolumeController.text =
        '[{"available": "En Stock","seller": "amazon", "url": ""},{"available": "En Stock","seller": "bdfugue", "url": "https://www.bdfugue.com/a/?ean=${eanVolumeController.text}&ref=W0WZrth4"}]';
    infoVolumeController.text = '{"pageNumber": }';
    super.initState();
  }

  @override
  void dispose() {
    titleVolumeController.dispose();
    numberVolumeController.dispose();
    eanVolumeController.dispose();
    priceVolumeController.dispose();
    languageVolumeController.dispose();
    supportVolumeController.dispose();
    genreJapVolumeController.dispose();
    resumeVolumeController.dispose();
    imagePathVolumeController.dispose();
    imageNameVolumeController.dispose();
    bookLinkVolumeController.dispose();
    infoVolumeController.dispose();
    serieVolumeController.dispose();
    subSerieVolumeController.dispose();
    authorsVolumeController.dispose();
    editorVolumeController.dispose();
    containsVolumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PocketBaseAdminConnector adminConnector = PocketBaseAdminConnector();
    return MyScrollColumn(
      scrollPadding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "Créer un Volume",
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
                          imagePathVolumeController.text != "" ? imagePathVolumeController.text : 'assets/images/unknown.webp',
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
                        imagePathVolumeController.text = "";
                        imageNameVolumeController.text = "";
                        setState(() {});
                      },
                      icon: Icon(CupertinoIcons.delete_left_fill),
                    ),
                  ),
                ],
              ),
              MyTextField(
                controller: titleVolumeController,
                labelText: "Nom du Volume",
                errorMessage: "Veuillez entrer le nom du volume!",
                verticalPadding: 5,
              ),
              MyTextField(
                controller: numberVolumeController,
                labelText: "Numéro du Volume",
                errorMessage: "Veuillez entrer le numéro du volume!",
                verticalPadding: 5,
              ),
              Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: eanVolumeController,
                      labelText: "EAN du Volume",
                      keyboardType: TextInputType.number,
                      errorMessage: "Veuillez entrer l'EAN du volume!",
                      verticalPadding: 5,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      var res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SimpleBarcodeScannerPage(
                            scanType: ScanType.barcode,
                            isShowFlashIcon: true,
                          ),
                        ),
                      );
                      setState(() {
                        if (res is String) {
                          eanVolumeController.text = res;
                        }
                      });
                    },
                    icon: Icon(Icons.camera_alt),
                  )
                ],
              ),
              MyTextField(
                controller: priceVolumeController,
                labelText: "Prix du Volume",
                errorMessage: "Veuillez entrer le prix du volume!",
                verticalPadding: 5,
              ),
              MyTextField(
                controller: resumeVolumeController,
                labelText: "Résumé du Volume",
                errorMessage: "Veuillez entrer le résumé du volume!",
                verticalPadding: 5,
              ),
              MyTextField(
                controller: bookLinkVolumeController,
                labelText: "Lien du Volume",
                errorMessage: "Veuillez entrer le lien du volume!",
                verticalPadding: 5,
              ),
              MyTextField(
                controller: infoVolumeController,
                labelText: "Informations du Volume",
                errorMessage: "Veuillez entrer les informations du volume!",
                verticalPadding: 5,
              ),
              Row(
                children: [
                  Switch(
                    value: over18,
                    onChanged: (value) {
                      setState(() {
                        over18 = value;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "Contenu pour adulte",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: DropdownButtonFormField(
                  items: [
                    DropdownMenuItem(
                      value: "fr",
                      child: const Text("🇫🇷 Français"),
                    ),
                    DropdownMenuItem(
                      value: "en",
                      child: Text("🇺🇸 Anglais"),
                    ),
                    DropdownMenuItem(
                      value: "sp",
                      child: Text("🇪🇸 Espagnol"),
                    ),
                    DropdownMenuItem(
                      value: "de",
                      child: Text("🇩🇪 Allemand"),
                    ),
                    DropdownMenuItem(
                      value: "it",
                      child: Text("🇮🇹 Italien"),
                    ),
                    DropdownMenuItem(
                      value: "ja",
                      child: Text("🇯🇵 Japonais"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      languageVolumeController.text = value.toString();
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    filled: true,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    hintText: "Langue du Volume",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer la langue du volume!";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: DropdownButtonFormField(
                  items: [
                    DropdownMenuItem(
                      value: "manga",
                      child: const Text("Manga"),
                    ),
                    DropdownMenuItem(
                      value: "Roman",
                      child: Text("Roman"),
                    ),
                    DropdownMenuItem(
                      value: "Artbook",
                      child: Text("ArtBook"),
                    ),
                    DropdownMenuItem(
                      value: "Light-Novel",
                      child: Text("Light Novel"),
                    ),
                    DropdownMenuItem(
                      value: "Coffret",
                      child: Text("Coffret"),
                    ),
                    DropdownMenuItem(
                      value: "autre",
                      child: Text("Autre"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      genreJapVolumeController.text = value.toString();
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    filled: true,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    hintText: "Support du Volume",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer le support du volume!";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: DropdownButtonFormField(
                  items: [
                    DropdownMenuItem(
                      value: "Shōjo",
                      child: Text("Shōjo"),
                    ),
                    DropdownMenuItem(
                      value: "Shōnen",
                      child: Text("Shōnen"),
                    ),
                    DropdownMenuItem(
                      value: "Seinen",
                      child: Text("Seinen"),
                    ),
                    DropdownMenuItem(
                      value: "Josei",
                      child: Text("Josei"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      supportVolumeController.text = value.toString();
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    )),
                    filled: true,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    hintText: "Genre du Volume",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: DateTimeFormField(
                  decoration: InputDecoration(
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    filled: true,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    hintText: "Date de publication",
                  ),
                  cupertinoDatePickerOptions: CupertinoDatePickerOptions(
                    modalTitleText: "Sélectionnez la date",
                    style: CupertinoDatePickerOptionsStyle(
                      modalTitle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  mode: DateTimeFieldPickerMode.date,
                  initialPickerDateTime: DateTime.now(),
                  validator: (value) {
                    if (value == null) {
                      return "Veuillez entrer la date de publication!";
                    }
                    return null;
                  },
                  onChanged: (DateTime? value) {
                    setState(() {
                      release = value!;
                    });
                  },
                ),
              ),
              MyTextField(
                controller: serieVolumeController,
                labelText: "Id de la série du Volume",
                errorMessage: "Veuillez entrer l'id série du volume!",
                verticalPadding: 5,
                horizontalPadding: 0,
                customValidator: (value) async {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer l'id de la série du volume!";
                  } else {
                    // Check if the id is a serie
                    if (await adminConnector.checkIfExist('series', 'id', value)) {
                      return "Veuillez entrer l'id de série valide!";
                    } else {
                      return null;
                    }
                  }
                },
              ),
              MyTextField(
                controller: subSerieVolumeController,
                labelText: "Id de la sous-série du Volume",
                errorMessage: "Veuillez entrer l'id sous-série du volume!",
                verticalPadding: 5,
                horizontalPadding: 0,
                customValidator: (value) async {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer l'id de la sous-série du volume!";
                  } else {
                    // Check if the id is a serie
                    if (await adminConnector.checkIfExist('sub_series', 'id', value)) {
                      return "Veuillez entrer l'id de sous-série valide!";
                    } else {
                      return null;
                    }
                  }
                },
              ),
              MyTextField(
                controller: editorVolumeController,
                labelText: "Id de l'éditeur du Volume",
                errorMessage: "Veuillez entrer l'id de l'éditeur du volume!",
                verticalPadding: 5,
                horizontalPadding: 0,
                customValidator: (value) async {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer l'id de l'éditeur du volume!";
                  } else {
                    // Check if the id is a serie
                    if (await adminConnector.checkIfExist('editors', 'id', value)) {
                      return "Veuillez entrer l'id de l'éditeur du volume!";
                    } else {
                      return null;
                    }
                  }
                },
              ),
              MyTextField(
                controller: authorsVolumeController,
                labelText: "Ids des auteurs du Volume",
                errorMessage: "Veuillez entrer au moins un id des auteurs du volume!",
                verticalPadding: 5,
                horizontalPadding: 0,
              ),
              MyTextField(
                controller: containsVolumeController,
                labelText: "Contenu du Volume",
                errorMessage: "Veuillez entrer le contenu du volume!",
                verticalPadding: 5,
                horizontalPadding: 0,
                customValidator: (value) {
                  if (genreJapVolumeController.text == "Coffret") {
                    return "Veuillez entrer le contenu du coffret !";
                  } else {
                    return null;
                  }
                },
              ),
              MyButton(
                text: "Créer le volume",
                verticalPadding: 10,
                horizontalPadding: 0,
                onTap: () {
                  if (Form.of(context).validate()) {
                    adminConnector.createVolume(
                      {
                        "title": titleVolumeController.text,
                        "tome_number": int.parse(numberVolumeController.text),
                        "price": priceVolumeController.text,
                        "over18": over18,
                        "resume": resumeVolumeController.text,
                        "book_link": jsonEncode(bookLinkVolumeController.text),
                        "release": release.toIso8601String(),
                        "ean": int.parse(eanVolumeController.text),
                        (languageVolumeController.text != "") ? "language" : languageVolumeController.text: null,
                        "sub_series": subSerieVolumeController.text,
                        "series": serieVolumeController.text,
                        "authors": authorsVolumeController.text,
                        (containsVolumeController.text != "") ? "contain" : containsVolumeController.text: null,
                        (infoVolumeController.text != "") ? "info" : jsonEncode(infoVolumeController.text): null,
                        "support": supportVolumeController.text,
                        (genreJapVolumeController.text != "") ? "genre_jap" : genreJapVolumeController.text: null,
                      },
                      imageNameVolumeController.text,
                      imagePathVolumeController.text,
                    );
                  }
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
