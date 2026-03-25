import 'dart:convert';

import 'package:date_field/date_field.dart';
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
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class AdminCreateVolumePage extends StatefulWidget {
  const AdminCreateVolumePage({super.key});

  @override
  State<AdminCreateVolumePage> createState() => _AdminCreateVolumePageState();
}

class _AdminCreateVolumePageState extends State<AdminCreateVolumePage> {
  // A (*) Mean that the field is required

  final TextEditingController titleVolumeController =
      TextEditingController(); // Field (*) : title
  final TextEditingController numberVolumeController =
      TextEditingController(); // Field : tome_number
  final TextEditingController eanVolumeController =
      TextEditingController(); // Field (*) : ean
  final TextEditingController priceVolumeController =
      TextEditingController(); // Field (*) : price
  bool over18 = false; // Field (*) : over18
  final TextEditingController languageVolumeController =
      TextEditingController(); // Field (*) : language
  final TextEditingController supportVolumeController =
      TextEditingController(); // Field (*) : support
  final TextEditingController genreJapVolumeController =
      TextEditingController(); // Field : genre_jap
  final TextEditingController summaryVolumeController =
      TextEditingController(); // Field (*) : resume
  final TextEditingController imagePathVolumeController =
      TextEditingController(); // Field : image
  final TextEditingController imageNameVolumeController =
      TextEditingController(); // Field : image
  final TextEditingController bookLinkVolumeController =
      TextEditingController(); // Field (*) : book_link
  final TextEditingController infoVolumeController =
      TextEditingController(); // Field : info
  DateTime release = DateTime.now(); // Field : release

  // Correspond to id of the items connected
  final TextEditingController serieVolumeController =
      TextEditingController(); // Field (*) : series
  final TextEditingController subSerieVolumeController =
      TextEditingController(); // Field (*) : sub_series
  final TextEditingController authorsVolumeController =
      TextEditingController(); // Field (*) : authors
  final TextEditingController editorVolumeController =
      TextEditingController(); // Field (*) : editor
  final TextEditingController containsVolumeController =
      TextEditingController(); // Field : contain
  XFile? pickedImageVolume;

  void uploadImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 75,
    );

    pickedImageVolume = image;
    imagePathVolumeController.text = image!.path;
    imageNameVolumeController.text = image.name;

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void initState() {
    bookLinkVolumeController.text =
        '[{"available": "inStock","seller": "amazon", "url": ""},{"available": "En Stock","seller": "bdfugue", "url": "https://www.bdfugue.com/a/?ean=${eanVolumeController.text}&ref=W0WZrth4"}]';
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
    summaryVolumeController.dispose();
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
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final PocketBaseAdminConnector adminConnector = PocketBaseAdminConnector();
    return MyScrollColumn(
      scrollPadding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            localizations.createVolume,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                          imagePathVolumeController.text != ""
                              ? imagePathVolumeController.text
                              : Assets.images.unknown,
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
                      icon: const Icon(CupertinoIcons.delete_left_fill),
                    ),
                  ),
                ],
              ),
              MyTextField(
                controller: titleVolumeController,
                labelText: localizations.volumeTitle,
                errorMessage: localizations.provideVolumeTitle,
                verticalPadding: 5,
              ),
              MyTextField(
                controller: numberVolumeController,
                labelText: localizations.volumeNumber,
                errorMessage: localizations.provideVolumeNumber,
                verticalPadding: 5,
              ),
              Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: eanVolumeController,
                      labelText: localizations.volumeEAN,
                      keyboardType: TextInputType.number,
                      errorMessage: localizations.provideVolumeEAN,
                      verticalPadding: 5,
                      minLength: 13,
                      maxLength: 13,
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
                      if (!mounted) return;
                      setState(() {
                        if (res is String) {
                          eanVolumeController.text = res;
                        }
                      });
                    },
                    icon: const Icon(Icons.camera_alt),
                  ),
                ],
              ),
              MyTextField(
                controller: priceVolumeController,
                labelText: localizations.volumePrice,
                errorMessage: localizations.provideVolumePrice,
                verticalPadding: 5,
              ),
              MyTextField(
                controller: summaryVolumeController,
                labelText: localizations.volumeSummary,
                errorMessage: localizations.provideVolumeSummary,
                verticalPadding: 5,
              ),
              MyTextField(
                controller: bookLinkVolumeController,
                labelText: localizations.volumeLink,
                errorMessage: localizations.provideVolumeLink,
                verticalPadding: 5,
              ),
              MyTextField(
                controller: infoVolumeController,
                labelText: localizations.volumeInfo,
                errorMessage: localizations.provideVolumeInfo,
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
                      localizations.adultContent,
                      style: const TextStyle(fontSize: 16),
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
                      child: Text("🇫🇷 ${localizations.french}"),
                    ),
                    DropdownMenuItem(
                      value: "en",
                      child: Text("🇺🇸 ${localizations.english}"),
                    ),
                    DropdownMenuItem(
                      value: "sp",
                      child: Text("🇪🇸 ${localizations.spanish}"),
                    ),
                    DropdownMenuItem(
                      value: "de",
                      child: Text("🇩🇪 ${localizations.german}"),
                    ),
                    DropdownMenuItem(
                      value: "it",
                      child: Text("🇮🇹 ${localizations.italian}"),
                    ),
                    DropdownMenuItem(
                      value: "jp",
                      child: Text("🇯🇵 ${localizations.japanese}"),
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
                    hintText: localizations.volumeLanguage,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.chooseVolumeLanguage;
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
                      child: Text(localizations.manga),
                    ),
                    DropdownMenuItem(
                      value: "novel",
                      child: Text(localizations.novel),
                    ),
                    DropdownMenuItem(
                      value: "artbook",
                      child: Text(localizations.artbook),
                    ),
                    DropdownMenuItem(
                      value: "lightNovel",
                      child: Text(localizations.lightNovel),
                    ),
                    DropdownMenuItem(
                      value: "boxSet",
                      child: Text(localizations.boxSet),
                    ),
                    DropdownMenuItem(
                      value: "other",
                      child: Text(localizations.other),
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
                      ),
                    ),
                    filled: true,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    hintText: localizations.volumeSupport,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.chooseVolumeSupport;
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
                    DropdownMenuItem(value: "Shōjo", child: Text("Shōjo")),
                    DropdownMenuItem(value: "Shōnen", child: Text("Shōnen")),
                    DropdownMenuItem(value: "Seinen", child: Text("Seinen")),
                    DropdownMenuItem(value: "Josei", child: Text("Josei")),
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
                    hintText: localizations.genreName,
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
                    hintText: localizations.publicationDate,
                  ),
                  cupertinoDatePickerOptions: CupertinoDatePickerOptions(
                    modalTitleText: localizations.selectDate,
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
                      return localizations.pleaseSelectDate;
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
                labelText: localizations.volumeSeriesId,
                errorMessage: localizations.provideVolumeSeriesId,
                verticalPadding: 5,
                horizontalPadding: 0,
                customValidator: (value) async {
                  if (value == null || value.isEmpty) {
                    return localizations.provideVolumeSeriesId;
                  } else {
                    // Check if the id is a serie
                    if (await adminConnector.checkIfExist(
                      'series',
                      'id',
                      value,
                    )) {
                      return localizations.provideValidVolumeSeriesId;
                    } else {
                      return null;
                    }
                  }
                },
              ),
              MyTextField(
                controller: subSerieVolumeController,
                labelText: localizations.volumeSubSeriesId,
                errorMessage: localizations.provideVolumeSubSeriesId,
                verticalPadding: 5,
                horizontalPadding: 0,
                customValidator: (value) async {
                  if (value == null || value.isEmpty) {
                    return localizations.provideVolumeSubSeriesId;
                  } else {
                    // Check if the id is a serie
                    if (await adminConnector.checkIfExist(
                      'sub_series',
                      'id',
                      value,
                    )) {
                      return localizations.provideValidVolumeSubSeriesId;
                    } else {
                      return null;
                    }
                  }
                },
              ),
              MyTextField(
                controller: editorVolumeController,
                labelText: localizations.volumeEditorId,
                errorMessage: localizations.provideVolumeEditorId,
                verticalPadding: 5,
                horizontalPadding: 0,
                customValidator: (value) async {
                  if (value == null || value.isEmpty) {
                    return localizations.provideVolumeEditorId;
                  } else {
                    // Check if the id is a serie
                    if (await adminConnector.checkIfExist(
                      'editors',
                      'id',
                      value,
                    )) {
                      return localizations.provideValidVolumeEditorId;
                    } else {
                      return null;
                    }
                  }
                },
              ),
              MyTextField(
                controller: authorsVolumeController,
                labelText: localizations.volumeAuthorsIds,
                errorMessage: localizations.provideVolumeAuthorsIds,
                verticalPadding: 5,
                horizontalPadding: 0,
              ),
              MyTextField(
                controller: containsVolumeController,
                labelText: localizations.contentOfBoxSet,
                errorMessage: localizations.provideContentOfBoxSet,
                verticalPadding: 5,
                horizontalPadding: 0,
                customValidator: (value) {
                  if (supportVolumeController.text == "boxSet" &&
                      (value == null || value.isEmpty)) {
                    return localizations.provideContentOfBoxSet;
                  } else {
                    return null;
                  }
                },
              ),
              MyButton(
                text: localizations.volumeAdd,
                verticalPadding: 10,
                horizontalPadding: 0,
                onTap: () async {
                  if (Form.of(context).validate()) {
                    try {
                      List<int>? bytes;
                      if (pickedImageVolume != null) {
                        bytes = await pickedImageVolume!.readAsBytes();
                      }
                      await adminConnector.createVolume(
                        {
                          "title": titleVolumeController.text,
                          "tome_number": int.parse(numberVolumeController.text),
                          "price": priceVolumeController.text,
                          "over18": over18,
                          "resume": summaryVolumeController.text,
                          "book_link": jsonEncode(
                            bookLinkVolumeController.text,
                          ),
                          "release": release.toIso8601String(),
                          "ean": int.parse(eanVolumeController.text),
                          "language": (languageVolumeController.text != "")
                              ? languageVolumeController.text
                              : null,
                          "sub_series": subSerieVolumeController.text,
                          "series": serieVolumeController.text,
                          "authors": authorsVolumeController.text,
                          "contain": (containsVolumeController.text != "")
                              ? containsVolumeController.text
                              : null,
                          "info": (infoVolumeController.text != "")
                              ? jsonEncode(infoVolumeController.text)
                              : null,
                          "support": supportVolumeController.text,
                          "genre_jap": (genreJapVolumeController.text != "")
                              ? genreJapVolumeController.text
                              : null,
                        },
                        imageNameVolumeController.text,
                        bytes,
                      );
                      if (!mounted) return;
                      showMessage(localizations.volumeAddSuccess, context);
                    } catch (e) {
                      if (!mounted) return;
                      showMessage(localizations.volumeAddError, context);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
