import 'package:mymangatheque/src/provider/theme_color_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/const/theme.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class MainWrapper extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({
    required this.navigationShell,
    super.key,
  });

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

List<String> navIcons = [
  "home",
  "collection",
  "search",
  "calendar",
  "user"
];

List<String> navTitle = [
  "Accueil",
  "Collection",
  "Recherche",
  "Planning",
  "Profil"
];

class _MainWrapperState extends ConsumerState<MainWrapper> {

  int selectedIndex = 0;

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  void initState() {
    super.initState();
    ref.read(themeTextColorProvider);
  }

  // Change the color of the app
  void changeThemeColor(Color colorBg, Color colorText, WidgetRef ref) {
    ref.read(themeTextColorProvider.notifier).changeThemeTextColor(colorText);
  }

  @override
  Widget build(BuildContext context) {
    // This is to change color when starting the app
    Timer(const Duration(milliseconds: 50), () {
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
    });

    final textColor = ref.watch(themeTextColorProvider);

    return Scaffold(
      body: Stack(
        children: [
          widget.navigationShell,
          Align(
            alignment: Alignment.bottomCenter,
            child: navBar(textColor),
          ),
        ],
      ),
    );
  }

  Widget navBar(unSelectedColor) {
    Color? selectedColor = Colors.cyanAccent;
    if (unSelectedColor == const Color(0xFF1c1b1f)) {
      selectedColor = Colors.blueAccent[700];
    } else {
      selectedColor = Colors.cyanAccent;
    }
    return GlassContainer.clearGlass(
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.1),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      height: 60,
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      borderColor: Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      shadowColor: Colors.black.withOpacity(0.2),
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
                      iconColor: isSelected
                          ? selectedColor
                          : unSelectedColor,
                    ),
                  ),
                  Text(
                    navTitle[index],
                    style: TextStyle(
                      color: isSelected
                          ? selectedColor
                          : unSelectedColor,
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
