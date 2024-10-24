import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/models/get_user_information.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  dynamic savedThemeMode;
  dynamic theme;
  int numberMangaOwned = 0;
  int numberSerieFav = 0;

  final connector = PocketBaseConnector();

  // Sign Out a Connected User
  void signUserOut() {
    connector.logOut();
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

    connector.updateAvatar('users', connector.getConnectedUser()!.id, image!.name, image.path, context).then((value) async {
      await connector.updateUserData(connector.getConnectedUser()!.email);
      setState(() {});
    });
  }

  Map month = {
    '1': 'Janvier',
    '2': 'Février',
    '3': 'Mars',
    '4': 'Avril',
    '5': 'Mai',
    '6': 'Juin',
    '7': 'Billet',
    '8': 'Août',
    '9': 'Septembre',
    '10': 'Octobre',
    '11': 'Novembre',
    '12': 'Décembre',
  };

  // Get the number of owned manga
  getNumberOfMangaOwned() async {
    try {
      int countMangaOwned = await connector.getNumberOwnedManga();
      setState(() {
        numberMangaOwned = countMangaOwned;
      });
    } catch (e) {
      print(e);
    }
  }

  // Get the number of favorite series
  getNumberOfSeriesFav() async {
    try {
      int countSerieFav = await connector.getNumberFavSerie();
      setState(() {
        numberSerieFav = countSerieFav;
      });
    } catch (e) {
      print(e);
    }
  }

  DateTime selectedBDayDate = DateTime(DateTime.now().year - 7, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    getNumberOfMangaOwned();
    getNumberOfSeriesFav();
  }

  @override
  Widget build(BuildContext context) {
    PocketBaseConnector connector = PocketBaseConnector();
    User? user = connector.getConnectedUser();

    setState(() {
      theme = AdaptiveTheme.of(context).mode.isSystem
          ? 'system'
          : AdaptiveTheme.of(context).mode.isDark
              ? 'dark'
              : 'light';
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Page de profile et de réglage'),
      ),
      body: Center(
        child: MyScrollColumn(
          scrollPadding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            GestureDetector(
              onTap: () {
                pickUploadImage();
              },
              child: GetUserProfilePicture(file: user!.avatar!),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 25)),

            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SingleChildScrollView(child: GetUserInfo(beforeText: "L'email est : ", afterText: user.email))),

            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(child: GetUserInfo(beforeText: 'Votre pseudo est : ', afterText: user.username)),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: GestureDetector(
                  onTap: () {},
                  child: SingleChildScrollView(
                      child: GetUserInfo(
                          beforeText: 'Compte créer le : ',
                          afterText: '${user.created.day} ${month[user.created.month.toString()]} ${user.created.year}')),
                )),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SingleChildScrollView(
                    child: GetUserInfo(
                        beforeText: 'Date de naissance : ',
                        afterText: '${user.birthday.day} ${month[user.birthday.month.toString()]} ${user.birthday.year}'))),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                child: GetUserInfo(
                    beforeText: numberMangaOwned < 1 ? 'Nombre de tome de manga possédé : ' : 'Nombre de tomes de manga possédé : ',
                    afterText: numberMangaOwned < 1 ? '$numberMangaOwned tome' : '$numberMangaOwned tomes'),
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                child: GetUserInfo(
                    beforeText: numberSerieFav < 1 ? 'Nombre de série en favoris : ' : 'Nombre de séries en favoris : ',
                    afterText: numberSerieFav < 1 ? '$numberSerieFav série' : '$numberSerieFav séries'),
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10), // Drop Down Menu du DarkMode
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
                          const Padding(padding: EdgeInsets.only(right: 10)),
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
                          const Padding(padding: EdgeInsets.only(right: 10)),
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
                    } else {
                      AdaptiveTheme.of(context).setSystem();
                      setState(() {
                        savedThemeMode = AdaptiveThemeMode.system;
                      });
                    }
                  }),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            SingleChildScrollView(
              child: GestureDetector(
                onTap: () => GoRouter.of(context).go('/profile/modify_password'),
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
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
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
                icon: OwnIcon(iconColor: Colors.red, iconName: 'logout'),
                label: Text(
                  'Se déconnecter',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Zone de danger",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 18.0),
              child: TextButton.icon(
                onPressed: () => context.go('/delete_account'),
                icon: OwnIcon(iconColor: Colors.red, iconName: 'delete'),
                label: Text(
                  'Supprimer mon compte',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
