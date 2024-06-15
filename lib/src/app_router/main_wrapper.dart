import 'package:flutter/material.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/provider/theme_color_provider.dart';
import 'package:mymangatheque/src/const/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:go_router/go_router.dart';
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

class _MainWrapperState extends ConsumerState<MainWrapper> {
  final int selectedItemColor = 0xFF1783a5;

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
    ref.read(themeBgColorProvider);
    ref.read(themeTextColorProvider);
  }

  // Change the color of the app
  void changeThemeColor(Color colorBg, Color colorText, WidgetRef ref) {
    ref.read(themeBgColorProvider.notifier).changeThemeBgColor(colorBg);
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

    final bgColor = ref.watch(themeBgColorProvider);
    final textColor = ref.watch(themeTextColorProvider);

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: widget.navigationShell,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: bgColor,
        selectedItemColor: const Color(0xFF1783a5),
        unselectedItemColor: textColor,
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _goBranch,
        items: [
          BottomNavigationBarItem(
            icon: OwnIcon(
                iconColor: widget.navigationShell.currentIndex == 0 ? const Color(0xFF1783a5) : textColor,
                iconName: "home"
            ),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: OwnIcon(
                iconColor: widget.navigationShell.currentIndex == 1 ? const Color(0xFF1783a5) : textColor,
                iconName: "collection"
            ),
            label: "Collection",
          ),
          BottomNavigationBarItem(
            icon: OwnIcon(
                iconColor: widget.navigationShell.currentIndex == 2 ? const Color(0xFF1783a5) : textColor,
                iconName: "search",
            ),
            label: "Recherche",
          ),
          BottomNavigationBarItem(
            icon: OwnIcon(
                iconColor: widget.navigationShell.currentIndex == 3 ? const Color(0xFF1783a5) : textColor,
                iconName: "calendar"
            ),
            label: "Planning",
          ),
          BottomNavigationBarItem(
            icon: OwnIcon(
                iconColor: widget.navigationShell.currentIndex == 4 ? const Color(0xFF1783a5) : textColor,
                iconName: "user"
            ),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
