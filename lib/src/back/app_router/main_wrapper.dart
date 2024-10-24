import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_detection/keyboard_detection.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/const/theme/light_mode.dart';
import 'package:mymangatheque/src/front/components/my_drawer.dart';
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

List<String> navIcons = ["home", "collection", "search", "calendar", "user"];

List<String> navTitle = [
  "Accueil",
  "Collection",
  "Recherche",
  "Planning",
  "Profil"
];

List<String> navRoute = ["/", "/library", "/search", "/planning", "/profile"];

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyDrawer(
                  navIcons: navIcons,
                  navTitle: navTitle,
                  navRoute: navRoute,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.navigationShell,
                      SizedBox(
                        height: 25,
                        child: Link(
                            uri: Uri.parse(
                                "https://mymangatheque.com/mentions_legales"),
                            builder: (context, link) {
                              return InkWell(
                                onTap: link,
                                child: Text(
                                  "Mentions légales",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width:
                      0, // This sized box  make you set the content of the page centered
                )
              ],
            ));
          } else if (constraints.maxWidth > 600) {
            return Scaffold(
                appBar: AppBar(),
                drawer: MyDrawer(
                  navIcons: navIcons,
                  navTitle: navTitle,
                  navRoute: navRoute,
                ),
                body: Stack(
                  children: [
                    widget.navigationShell,
                  ],
                ));
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
                    child: navBar(Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  //TODO: Hide this when the keyboard is activated on mobile
  Widget navBar(unSelectedColor) {
    Color? selectedColor = Colors.cyanAccent;
    if (unSelectedColor == lightMode.colorScheme.primary) {
      selectedColor = Colors.blueAccent[700];
    } else {
      selectedColor = Colors.cyanAccent;
    }
    return GlassContainer.clearGlass(
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
                      iconName: iconName,
                      iconColor: isSelected ? selectedColor : unSelectedColor,
                    ),
                  ),
                  Text(
                    navTitle[index],
                    style: TextStyle(
                      color: isSelected ? selectedColor : unSelectedColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
