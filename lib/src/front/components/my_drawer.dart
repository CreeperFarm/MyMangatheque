import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/front/components/my_drawer_tile.dart';

class MyDrawer extends StatelessWidget {
  final List navIcons;
  final List navTitle;
  final List navRoute;

  const MyDrawer(
      {required this.navIcons,
      required this.navTitle,
      required this.navRoute,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        child: SafeArea(
          right: false,
          left: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.go('/');
                    },
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 25),
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset('assets/images/logo_app.png',
                                    width: 50, height: 50),
                              ),
                              const Text('MyMangathèque',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                  ),
                  Column(
                    children: (navIcons).map((iconName) {
                      int index = navIcons.indexOf(iconName);
                      if (navTitle[index] == "Profil") {
                        return const Padding(padding: EdgeInsets.zero);
                      } else {
                        return MyDrawerTile(
                          title: navTitle[index],
                          icon: iconName,
                          goTo: navRoute[index],
                        );
                      }
                    }).toList(),
                  ),
                ],
              ),
              GestureDetector(
                  onTap: () {
                    context.go('/profile');
                  },
                  /*
                  TODO: Check if the user is connected,
                   if he is then show him his profile picture and the text 'Mon Compte',
                   else show him the icon of a user and the text 'Se connecter'.
              */
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset('assets/icons/user.svg',
                            width: 30,
                            height: 30,
                            colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.primary,
                                BlendMode.srcIn)),
                        Text('Se Connecter',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  )),
            ],
          ),
        ));
  }
}
