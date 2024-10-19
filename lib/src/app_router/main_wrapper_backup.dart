import 'package:flutter/material.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:go_router/go_router.dart';

class MainWrapper extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({
    required this.navigationShell,
    super.key,
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final int selectedItemColor = 0xFF1783a5;

  int selectedIndex = 0;

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // This is to change color when starting the app
    /*Timer(const Duration(milliseconds: 50), () {
      if (AdaptiveTheme.of(context).mode.isSystem) {
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        if (brightness == Brightness.dark) {
          changeThemeColor(darkTheme.of(context).colorScheme.onPrimary, darkTheme.of(context).colorScheme.primary, ref);
        } else {
          changeThemeColor(lightTheme.of(context).colorScheme.onPrimary, lightTheme.of(context).colorScheme.primary, ref);
        }
      } else if (AdaptiveTheme.of(context).mode.isDark) {
        changeThemeColor(darkTheme.of(context).colorScheme.onPrimary, darkTheme.of(context).colorScheme.primary, ref);
      } else {
        changeThemeColor(lightTheme.of(context).colorScheme.onPrimary, lightTheme.of(context).colorScheme.primary, ref);
      }
    });*/
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: widget.navigationShell,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        selectedItemColor: const Color(0xFF1783a5),
        unselectedItemColor: Theme.of(context).colorScheme.primary,
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _goBranch,
        items: [
          BottomNavigationBarItem(
            icon: OwnIcon(
                iconColor: widget.navigationShell.currentIndex == 0 ? const Color(0xFF1783a5) : Theme.of(context).colorScheme.primary,
                iconName: "home"
            ),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: OwnIcon(
                iconColor: widget.navigationShell.currentIndex == 1 ? const Color(0xFF1783a5) : Theme.of(context).colorScheme.primary,
                iconName: "collection"
            ),
            label: "Collection",
          ),
          BottomNavigationBarItem(
            icon: OwnIcon(
                iconColor: widget.navigationShell.currentIndex == 2 ? const Color(0xFF1783a5) : Theme.of(context).colorScheme.primary,
                iconName: "search",
            ),
            label: "Recherche",
          ),
          BottomNavigationBarItem(
            icon: OwnIcon(
                iconColor: widget.navigationShell.currentIndex == 3 ? const Color(0xFF1783a5) : Theme.of(context).colorScheme.primary,
                iconName: "calendar"
            ),
            label: "Planning",
          ),
          BottomNavigationBarItem(
            icon: OwnIcon(
                iconColor: widget.navigationShell.currentIndex == 4 ? const Color(0xFF1783a5) : Theme.of(context).colorScheme.primary,
                iconName: "user"
            ),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
