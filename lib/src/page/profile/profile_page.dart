import 'package:google_fonts/google_fonts.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/get_data/get_user_information.dart';
import 'package:mymangatheque/src/services/pocketbase.dart';
import 'package:mymangatheque/src/components/my_line.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  dynamic savedThemeMode;
  dynamic theme;

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

    connector.updateAvatar(
        'users',
        connector.getConnectedUser()!.id,
        image!.name,
        image.path,
        context
    ).then((value) async {
      await connector.updateUserData(connector.getConnectedUser()!.email);
      setState(() {});
    });
  }

  Map month = {
    '01': 'Janvier',
    '02': 'Février',
    '03': 'Mars',
    '04': 'Avril',
    '05': 'Mai',
    '06': 'Juin',
    '07': 'Billet',
    '08': 'Août',
    '09': 'Septembre',
    '10': 'Octobre',
    '11': 'Novembre',
    '12': 'Décembre',
  };

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
                  child: GetUserProfilePicture(file: user!.avatar!),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 25)),
                MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                    child: GetUserInfo(
                      beforeText: "L'email est : ",
                      afterText: user.email
                    )
                  )
                ),
                MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                    child: GetUserInfo(
                      beforeText: 'Votre pseudo est : ',
                      afterText: user.username
                    )
                  ),
                ),
                MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                    child: GetUserInfo(
                      beforeText: 'Compte créer le : ',
                      afterText: '${user.updated} / ${month[user.created?.month]} ${user.created?.year}'
                    )
                  ),
                ),
                MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                    child: GetUserInfo(
                      beforeText: 'Nombre de tome de manga possédé : ',
                      afterText: ' tomes'
                    ) //TODO: Set the number of manga owned
                  ),
                ),
                MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                    child: GetUserInfo(
                      beforeText: 'Nombre de tome de manga en favoris : ',
                      afterText: ' tomes'
                    ), //TODO: Set the number of manga fav
                  ),
                ),
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
