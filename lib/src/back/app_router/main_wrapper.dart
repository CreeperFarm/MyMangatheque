import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_detection/keyboard_detection.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/layout.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_drawer.dart';
import 'package:mymangatheque/src/front/components/my_drawer_tile.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/models/get_user_information.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:url_launcher/link.dart';

class MainWrapper extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({required this.navigationShell, super.key});

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
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
    keyboardDetectionController.registerCallback((state) {
      return false;
    });

    // Looped callback
    keyboardDetectionController.registerCallback((state) {
      return true;
    });

    // Looped with future callback
    keyboardDetectionController.registerCallback((state) async {
      await Future.delayed(const Duration(milliseconds: 100));
      RuntimeLocalization.debug(
        en: 'Keyboard visibility state changed.',
        fr: 'L’état de visibilité du clavier a changé.',
      );

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<String> navIconsSrc = [
      Assets.icons.home,
      Assets.icons.collection,
      Assets.icons.calendar,
      Assets.icons.search,
      Assets.icons.user,
    ];
    final List<String> navIconsActive = [
      Assets.icons.homeActive,
      Assets.icons.collectionActive,
      Assets.icons.calendarActive,
      Assets.icons.searchActive,
      Assets.icons.userActive,
    ];
    final List<String> navTitle = [
      localizations.home,
      localizations.collection,
      context.localized(en: 'Releases', fr: 'Sorties'),
      localizations.search,
      localizations.profile,
    ];
    const List<String> navRoute = [
      '/',
      '/library',
      '/planning',
      '/search',
      '/profile',
    ];

    return KeyboardDetection(
      controller: keyboardDetectionController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1200) {
            return _buildDesktopLayout(navIconsSrc, navTitle, navRoute);
          }
          if (constraints.maxWidth > phoneNavigationMaxWidth) {
            return _buildTabletLayout(
              navIconsSrc,
              navTitle,
              navRoute,
              localizations,
            );
          }
          if (keyboardActive) {
            return Scaffold(body: Stack(children: [widget.navigationShell]));
          }
          return ValueListenableBuilder<AppNavigationLabelMode>(
            valueListenable: LocalStorage.navigationLabelModeNotifier,
            builder: (context, labelMode, _) => _buildPhoneLayout(
              navIconsSrc,
              navIconsActive,
              navTitle,
              labelMode,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(
    List<String> navIconsSrc,
    List<String> navTitle,
    List<String> navRoute,
  ) {
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
                        onTap: () => context.go('/'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 25,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    Assets.logo.blueToneAndWhiteSquare,
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                const Text(
                                  'MyMangathèque',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: navIconsSrc.map((iconSrc) {
                          final int index = navIconsSrc.indexOf(iconSrc);
                          if (iconSrc == Assets.icons.user) {
                            return const Padding(padding: EdgeInsets.zero);
                          }
                          return MyDrawerTile(
                            title: navTitle[index],
                            iconSrc: iconSrc,
                            goTo: navRoute[index],
                            pop: false,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => pushOrGo(context, '/profile'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 25,
                          ),
                          child: _buildDesktopProfileArea(),
                        ),
                      ),
                      Link(
                        uri: Uri.parse(
                          'https://mymangatheque.com/legal_notice',
                        ),
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
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: widget.navigationShell),
        ],
      ),
    );
  }

  Widget _buildDesktopProfileArea() {
    return StreamBuilder(
      stream: AppwriteConnector().listenToUserChanges(),
      builder: (context, snapshot) {
        final isLoggedIn = AppwriteConnector().isLoggedIn();
        if (isLoggedIn) {
          final user = AppwriteConnector().getConnectedUser();
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
                      Assets.icons.user,
                      width: 30,
                      height: 30,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
              Text(
                user?.username ?? '',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(
              Assets.icons.user,
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.logIn,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabletLayout(
    List<String> navIconsSrc,
    List<String> navTitle,
    List<String> navRoute,
    AppLocalizations localizations,
  ) {
    return Scaffold(
      appBar: AppBar(),
      drawer: MyDrawer(
        navIcons: navIconsSrc,
        navTitle: navTitle,
        navRoute: navRoute,
        profileText: localizations.profile,
        logInText: localizations.logIn,
      ),
      body: widget.navigationShell,
    );
  }

  Widget _buildPhoneLayout(
    List<String> navIconsSrc,
    List<String> navIconsActive,
    List<String> navTitle,
    AppNavigationLabelMode labelMode,
  ) {
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
              height: phoneBottomNavigationBarHeight,
              margin: const EdgeInsets.only(
                bottom: phoneBottomNavigationBarBottomMargin,
                left: 16,
                right: 16,
              ),
              borderColor: Colors.transparent,
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              shadowColor: Colors.black.withAlpha(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: navIconsSrc.map((iconName) {
                  final int index = navIconsSrc.indexOf(iconName);
                  final bool isSelected =
                      widget.navigationShell.currentIndex == index;
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: navTitle[index],
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: () {
                          _goBranch(index);
                        },
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(
                                top: 10,
                                bottom: 0,
                                right: 12,
                                left: 12,
                              ),
                              child: OwnIcon(
                                iconSrc: _iconPath(
                                  iconName,
                                  navIconsSrc,
                                  navIconsActive,
                                  active: isSelected,
                                ),
                                iconColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                              child: ExcludeSemantics(
                                child: Text(
                                  labelMode == AppNavigationLabelMode.always ||
                                          isSelected
                                      ? navTitle[index]
                                      : '',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  String _iconPath(
    String imageSrc,
    List<String> navIconsSrc,
    List<String> navIconsActive, {
    bool active = false,
  }) {
    if (!active) {
      return imageSrc;
    }
    final int index = navIconsSrc.indexOf(imageSrc);
    return navIconsActive[index];
  }
}
