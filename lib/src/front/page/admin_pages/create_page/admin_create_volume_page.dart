import 'package:date_field/date_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_textfield.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class AdminCreateVolumePage extends StatefulWidget {
  const AdminCreateVolumePage({super.key});

  @override
  State<AdminCreateVolumePage> createState() => _AdminCreateVolumePageState();
}

class _AdminCreateVolumePageState extends State<AdminCreateVolumePage> {
  final TextEditingController titleVolumeController = TextEditingController();
  final TextEditingController numberVolumeController = TextEditingController();
  final TextEditingController eanVolumeController = TextEditingController();
  final TextEditingController priceVolumeController = TextEditingController();
  bool over18 = false;
  final TextEditingController languageVolumeController = TextEditingController();
  final TextEditingController supportVolumeController = TextEditingController();
  final TextEditingController genreJapVolumeController = TextEditingController();
  final TextEditingController resumeVolumeController = TextEditingController();
  final TextEditingController imagePathVolumeController = TextEditingController();
  final TextEditingController imageNameVolumeController = TextEditingController();
  final TextEditingController bookLinkVolumeController = TextEditingController();
  final TextEditingController infoVolumeController = TextEditingController();
  DateTime release = DateTime.now();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                keyboardType: TextInputType.number,
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
                      value: "roman",
                      child: Text("Roman"),
                    ),
                    DropdownMenuItem(
                      value: "artbook",
                      child: Text("ArtBook"),
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
            ],
          ),
        )
      ],
    );
  }
}
