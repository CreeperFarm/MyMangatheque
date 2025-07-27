import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_detection/keyboard_detection.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_drawer.dart';
import 'package:mymangatheque/src/front/components/my_drawer_tile.dart';
import 'package:url_launcher/link.dart';

class MainWrapper extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({
    required this.navigationShell,
    super.key,
  });

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  int selectedIndex = 0;

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  KeyboardState keyboardState = KeyboardState.unknown;
  late KeyboardDetectionController keyboardDetectionController;
  bool keyboardActive = false;

  @override
  void initState() {
    keyboardDetectionController = KeyboardDetectionController(
      onChanged: (value) {
        setState(() {
          keyboardActive = keyboardDetectionController.stateAsBool(true)!;
        });
      },
    );

    // One time callback
    keyboardDetectionController.addCallback((state) {
      return false;
    });

    // Looped callback
    keyboardDetectionController.addCallback((state) {
      return true;
    });

    // Looped with future callback
    keyboardDetectionController.addCallback((state) async {
      await Future.delayed(const Duration(milliseconds: 100));
      print('Listen to onChanged with looped future Callback: $state');

      // This callback will be looped
      return true;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // TODO : restore the planning page.
    //List<String> navIcons = ["home", "collection", "search", "calendar", "user"];
    const List<String> navIcons = ["home", "collection", "search", "user"];
    //List<String> navTitle = ["Accueil", "Collection", "Recherche", "Planning", "Profil"];
    List<String> navTitle = [localizations.home, localizations.collection, localizations.search, localizations.profile];
    //List<String> navRoute = ["/", "/library", "/search", "/planning", "/profile"];
    const List<String> navRoute = ["/", "/library", "/search", "/profile"];
    // This is to change color when starting the app
    /*Timer(const Duration(milliseconds: 50), () {
      if (AdaptiveTheme.of(context).mode.isSystem) {
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        if (brightness == Brightness.dark) {
          changeThemeColor(darkBgColor, darkTextColor, ref);
        } else {
          changeThemeColor(lightBgColor, lightTextColor, ref);
        }
      } else if (AdaptiveTheme.of(context).mode.isDark) {
        changeThemeColor(darkBgColor, darkTextColor, ref);
      } else {
        changeThemeColor(lightBgColor, lightTextColor, ref);
      }
    });*/
    return KeyboardDetection(
      controller: keyboardDetectionController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1200) {
            return Scaffold(
                body: Row(
              children: [
                Drawer(
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
                              children: (navIcons).map((iconName) {
                                int index = navIcons.indexOf(iconName);
                                if (navIcons[index] == "user") {
                                  return const Padding(padding: EdgeInsets.zero);
                                } else {
                                  return MyDrawerTile(title: navTitle[index], icon: iconName, goTo: navRoute[index], pop: false);
                                }
                              }).toList(),
                            ),
                          ],
                        ),
                        Column(
                          children: [
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
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SvgPicture.asset('assets/icons/user.svg',
                                        width: 30, height: 30, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn)),
                                    Text(AppLocalizations.of(context)!.logIn,
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                                  ],
                                ),
                              ),
                            ),
                            Link(
                              uri: Uri.parse("https://mymangatheque.com/mentions_legales"),
                              builder: (context, link) {
                                return InkWell(
                                  onTap: link,
                                  child: Text(
                                    AppLocalizations.of(context)!.legalNotice,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: widget.navigationShell,
                ),
              ],
            ));
          } else if (constraints.maxWidth > 600) {
            return Scaffold(
              appBar: AppBar(),
              drawer: MyDrawer(
                navIcons: navIcons,
                navTitle: navTitle,
                navRoute: navRoute,
                profileText: localizations.profile,
                logInText: localizations.logIn,
              ),
              body: widget.navigationShell,
            );
          } else if (constraints.maxWidth < 600 && keyboardActive) {
            return Scaffold(
              body: Stack(
                children: [
                  widget.navigationShell,
                ],
              ),
            );
          } else {
            return Scaffold(
              body: Stack(
                children: [
                  widget.navigationShell,
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GlassContainer.clearGlass(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withAlpha(10),
                          Theme.of(context).colorScheme.primary.withAlpha(10),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      height: 60,
                      margin: const EdgeInsets.only(bottom: 32, left: 16, right: 16),
                      borderColor: Colors.transparent,
                      borderRadius: const BorderRadius.all(Radius.circular(100)),
                      shadowColor: Colors.black.withAlpha(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: navIcons.map((iconName) {
                          int index = navIcons.indexOf(iconName);
                          bool isSelected = selectedIndex == index;
                          return Material(
                            color: Colors.transparent,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                  _goBranch(index);
                                });
                              },
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(
                                      top: 10,
                                      bottom: 0,
                                      right: 22,
                                      left: 22,
                                    ),
                                    child: OwnIcon(
                                      iconName: isSelected ? '$iconName-active' : iconName,
                                      iconColor: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    navTitle[index],
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
