import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/front/components/my_drawer_tile.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/models/get_user_information.dart';

class MyDrawer extends StatefulWidget {
  final List navIcons;
  final List navTitle;
  final List navRoute;
  String profileText;
  String logInText;

  MyDrawer({required this.navIcons, required this.navTitle, required this.navRoute, required this.profileText, required this.logInText, super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
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
                      pushOrGo(context, '/');
                    },
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset('assets/images/logo_app.png', width: 50, height: 50),
                              ),
                              const Text('MyMangathèque', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                  ),
                  Column(
                    children: (widget.navIcons).map((iconName) {
                      int index = widget.navIcons.indexOf(iconName);
                      if (widget.navTitle[index] == widget.profileText) {
                        return const Padding(padding: EdgeInsets.zero);
                      } else {
                        return MyDrawerTile(
                          title: widget.navTitle[index],
                          icon: iconName,
                          goTo: widget.navRoute[index],
                          pop: true,
                        );
                      }
                    }).toList(),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  pushOrGo(context, '/profile');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                  child: StreamBuilder(
                    stream: PocketBaseConnector().listenToUserChanges(),
                    builder: (context, snapshot) {
                      final isLoggedIn = PocketBaseConnector().isLoggedIn();
                      if (isLoggedIn) {
                        final user = PocketBaseConnector().getConnectedUser();
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            user?.avatar != null
                                ? GetUserProfilePicture(
                                    file: user!.avatar!,
                                    width: 30,
                                    height: 30,
                                  )
                                : SvgPicture.asset(
                                    'assets/icons/user.svg',
                                    width: 30,
                                    height: 30,
                                    colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn),
                                  ),
                            Text(
                              user?.username ?? '',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/user.svg',
                              width: 30,
                              height: 30,
                              colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn),
                            ),
                            Text(
                              widget.logInText,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
