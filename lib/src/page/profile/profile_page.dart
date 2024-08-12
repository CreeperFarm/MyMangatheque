import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/get_data/get_user_information.dart';
import 'package:mymangatheque/src/components/my_line.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  dynamic savedThemeMode;
  dynamic theme;

  final user = FirebaseAuth.instance.currentUser!;

  // Modify the profile picture of the user
  void modifyImg(image) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'imageUrl': image}).then((query) {
      setState(() {});
    }).catchError((e) => print(e));
  }

  // Sign Out a Connected User
  void signUserOut() {
    FirebaseAuth.instance.signOut();
    context.go('/profile/signin');
  }

  // Select an image to change profile picture image
  void pickUploadImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 75,
    );

    Reference ref = FirebaseStorage.instance.ref().child('images/pdp/pdp-${user.uid}.jpg');

    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) => {modifyImg(value)});
  }

  // Get the theme
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Page de profile et de réglage'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    pickUploadImage();
                  },
                  child: GetUserProfilePicture(documentId: user.uid),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 25)),
                MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SingleChildScrollView(
                        child: GetUserInfo(
                            documentId: user.uid,
                            beforeText: "L'email est : ",
                            dataWanted: 'email',
                            afterText: ''))),
                MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                      child: GetUserInfo(
                          documentId: user.uid,
                          beforeText: 'Votre pseudo est : ',
                          dataWanted: 'pseudo',
                          afterText: '')),
                ),
                MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                      child: GetUserInfo(
                          documentId: user.uid,
                          beforeText: 'Compte créer le : ',
                          dataWanted: 'createdOn',
                          afterText: '')),
                ),
                /*MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                      child: GetUserInfo(documentId: user.uid, beforeText: 'Nombre de tome de manga possédé : ', dataWanted: 'createdOn', afterText: ' tomes') //TODO: Set the number of manga owned
                  ),
                ),
                MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                      child: GetUserInfo(documentId: user.uid, beforeText: 'Nombre de tome de manga en favoris : ', dataWanted: 'createdOn', afterText: ' tomes') //TODO: Set the number of manga fav
                  ),
                ),*/
                MyLine(
                    width: MediaQuery.of(context).size.width,
                    vertical: 10), // Drop Down Menu du DarkMode
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField(
                      items: [
                        DropdownMenuItem(
                          value: 'light',
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/theme/light-icon.png',
                                width: 20,
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(right: 10)),
                              const Text('Thème clair')
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'dark',
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/theme/dark-icon.png',
                                width: 20,
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(right: 10)),
                              const Text('Thème sombre')
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'system',
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/theme/auto-icon.png',
                                width: 20,
                              ),
                              const Padding(padding: EdgeInsets.only(right: 10)),
                              const Text('Thème du système')
                            ],
                          ),
                        ),
                      ],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      value: theme,
                      onChanged: (value) {
                        if (value == 'light') {
                          AdaptiveTheme.of(context).setLight();
                          setState(() {
                            savedThemeMode = AdaptiveThemeMode.light;
                          });
                        } else if (value == 'dark') {
                          AdaptiveTheme.of(context).setDark();
                          setState(() {
                            savedThemeMode = AdaptiveThemeMode.dark;
                          });
                        } else if (value == 'system') {
                          AdaptiveTheme.of(context).setSystem();
                          setState(() {
                            savedThemeMode = AdaptiveThemeMode.system;
                          });
                        } else {
                          AdaptiveTheme.of(context).setLight();
                          setState(() {
                            savedThemeMode = AdaptiveThemeMode.light;
                          });
                        }
                      }),
                ),
                MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () =>
                        GoRouter.of(context).go('/profile/modify_password'),
                    child: Row(
                      children: [
                        const Padding(padding: EdgeInsets.only(right: 16)),
                        OwnIcon(iconColor: Theme.of(context).colorScheme.primary, iconName: 'lock'),
                        const Padding(padding: EdgeInsets.only(right: 9)),
                        const Text('Changer de mot de passe'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                  child: Container(
                    height: 1.0,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 18.0),
                  child: TextButton.icon(
                    onPressed: signUserOut,
                    icon: OwnIcon(
                      iconColor: Colors.red,
                      iconName: 'logout'),
                    label: Text(
                      'Se déconnecter',
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
