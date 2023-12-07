import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymangatheque/get_data/get_user_information.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:mymangatheque/screen/auth/auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  dynamic savedThemeMode;
  dynamic theme;

  final user = FirebaseAuth.instance.currentUser!;

  void modifyImg(image) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid)
        .update({"imageUrl": image})
        .whenComplete(() => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthPageToProfile())
    )
    ).catchError((e) => print(e));
  }

  // Sign Out a Connected User
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  // Select an image to change profile picture image
  void pickUploadImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 75,
    );

    Reference ref = FirebaseStorage.instance.ref().child("images/pdp/pdp-${user.uid}.jpg");

    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) => {
      modifyImg(value)
    });
  }

  // Get the theme
  @override
  void initState() {
    super.initState();
    getCurrentTheme();
  }

  // Set a string to the current theme
  getCurrentTheme() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    setState(() {
      if (savedThemeMode == AdaptiveThemeMode.light) {
        theme = "light";
      } else if (savedThemeMode == AdaptiveThemeMode.dark) {
        theme = "dark";
      } else if (savedThemeMode == AdaptiveThemeMode.system) {
        theme = "system";
      } else {
        theme = "light";
      }
    });
  }

  Widget getWidget(userPhoneNumber) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text("Le numéro de téléphone est : $userPhoneNumber")
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:10.0, vertical: 10),
          child: Container(
            height: 1.0,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Page de profil et de réglage"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Bienvenue sur votre page de profile, uid : ${user.uid}, email : ${user.email}, display name : ${user.displayName}",textAlign: TextAlign.center),
                    ElevatedButton.icon(
                      onPressed: signUserOut,
                      icon: const Icon(Icons.logout),
                      label: const Text("Se déconnecter (Temporary)"),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: (){
                    pickUploadImage();
                  },
                  child: GetUserProfilePicture(documentId: user.uid),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10.0, vertical: 10),
                  child: Container(
                    height: 1.0,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: GetUserEmail(documentId: user.uid, beforeText: "L'email du compte est : ",)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10.0, vertical: 10),
                  child: Container(
                    height: 1.0,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: GetUserPseudo(documentId: user.uid, beforeText: "Votre pseudo est : "),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10.0, vertical: 10),
                  child: Container(
                    height: 1.0,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                  ),
                ),
                if (user.phoneNumber != null) getWidget(user.phoneNumber),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                    child: GetUserCreationDate(documentId: user.uid, beforeText: "Compte créer le : "),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10.0, vertical: 10),
                  child: Container(
                    height: 1.0,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                  ),
                ),
                // Drop Down Menu du DarkMode
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField(
                      items: [
                        DropdownMenuItem(
                          value: "light",
                          child: Row(
                            children:
                            [
                              Image.asset("assets/images/theme/light-icon.png", width: 20,),
                              const Padding(padding: EdgeInsets.only(right: 10)),
                              const Text("Thème clair")
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "dark",
                          child: Row(
                            children:
                            [
                              Image.asset("assets/images/theme/dark-icon.png", width: 20,),
                              const Padding(padding: EdgeInsets.only(right: 10)),
                              const Text("Thème sombre")
                            ],
                          ),
                        ),
                        const DropdownMenuItem(
                          value: "system",
                          child: Row(
                            children:
                            [
                              Icon(Icons.settings_suggest),
                              Padding(padding: EdgeInsets.only(right: 10)),
                              Text("Thème du système")
                            ],
                          ),
                        ),
                      ],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      value: theme,
                      onChanged: (value){
                        if (value == "light") {
                          AdaptiveTheme.of(context).setLight();
                          setState(() {
                            savedThemeMode = AdaptiveThemeMode.light;
                          });
                        } else if (value == "dark") {
                          AdaptiveTheme.of(context).setDark();
                          setState(() {
                            savedThemeMode = AdaptiveThemeMode.dark;
                          });
                        } else if (value == "system") {
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
                Padding(
                  padding: const EdgeInsets.only(left:10.0, right: 10.0, top: 10.0),
                  child: Container(
                    height: 1.0,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                  child: TextButton.icon(
                    onPressed: signUserOut,
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    label: Text(
                      "Se déconnecter",
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