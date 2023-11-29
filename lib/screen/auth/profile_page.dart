import 'package:mymangatheque/get_data/get_user_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:io';

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
    await FirebaseDatabase.instance.ref('users/${user.uid}')
        .update({"imageUrl": image})
        .whenComplete(() => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage())
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
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(150.0),
                      child: Image.network(
                        GetUserInformation.getUserProfilePicture(user.uid) as String,
                        height: 175,
                        width: 175,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                    child: Text(
                      "useremail",
                    )
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
                    child: Text(
                        GetUserInformation.getUserPseudo(user.uid, "Votre pseudo est : ") as String
                    ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                    child: Text(
                      GetUserInformation.getUserCreationDate(user.uid, "Compte créer depuis le ") as String,
                    ),
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
                /*Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      const Text(
                        "In dev, it's normal if it don't work",
                        style: TextStyle(color: Colors.red),
                      ),
                      Row(
                        children: [
                          Text(
                            "DarkMode :",
                            style: GoogleFonts.poppins(),
                          ),
                          Switch(
                            value: !lightThemeOn,
                            onChanged: null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),*/
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
