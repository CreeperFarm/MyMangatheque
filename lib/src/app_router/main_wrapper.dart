import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/const/navbar_color.dart';
import 'package:mymangatheque/src/provider/theme_color_provider.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

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
    Timer(const Duration(milliseconds: 250), () {
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
      bottomNavigationBar: SlidingClippedNavBar(
        backgroundColor: bgColor,
        activeColor: textColor,
        inactiveColor: textColor,
        onButtonPressed: (index) {
          setState(() {
            selectedIndex = index;
          });
          _goBranch(selectedIndex);
        },
        iconSize: 30,
        selectedIndex: selectedIndex,
        barItems: [
          BarItem(
            icon: Icons.home,
            title: 'Acceuil',
          ),
          BarItem(
            icon: Icons.collections_bookmark,
            title: 'Mangathèque',
          ),
          BarItem(
            icon: Icons.account_circle,
            title: 'Profile',
          ),
        ],
      ),
    );
  }
}
