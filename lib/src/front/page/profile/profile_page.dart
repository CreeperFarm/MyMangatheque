import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/language/language.dart';
import 'package:mymangatheque/src/back/language/language_repository.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_icon_text_button.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_text_divider.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';
import 'package:mymangatheque/src/models/get_user_information.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:mymangatheque/src/const/routes.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  dynamic savedThemeMode;
  dynamic theme;

  //String localLanguage = PlatformDispatcher.instance.locale.languageCode;
  int numberMangaOwned = 0;
  int numberSerieFav = 0;

  final connector = PocketBaseConnector();

  // Sign Out a Connected User
  void signUserOut({required String text}) async {
    connector.logOut();
    showMessage(text, context);
    pushOrGo(context, Routes.profile.signin);
  }

  // Select an image to change profile picture image
  void pickUploadImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 75,
    );

    List<int>? bytes;
    if (image != null) {
      bytes = await image.readAsBytes();
    }

    if (!mounted) return;
    await connector.updateAvatar(
      'users',
      connector.getConnectedUser()!.id,
      image!.name,
      bytes,
      context,
    );
    await connector.updateUserData(connector.getConnectedUser()!.email);
    if (!mounted) return;
    setState(() {});
  }

  // Get the number of owned manga
  Future<void> getNumberOfMangaOwned() async {
    try {
      int countMangaOwned = await connector.getNumberOwnedManga(
        connector.getConnectedUser()!.id,
      );
      if (!mounted) return;
      setState(() {
        numberMangaOwned = countMangaOwned;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Get the number of favorite series
  Future<void> getNumberOfSeriesFav() async {
    try {
      int countSerieFav = await connector.getNumberFavSerie(
        connector.getConnectedUser()!.id,
      );
      if (!mounted) return;
      setState(() {
        numberSerieFav = countSerieFav;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  DateTime selectedBDayDate = DateTime(
    DateTime.now().year - 7,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
    getNumberOfMangaOwned();
    getNumberOfSeriesFav();
  }

  @override
  Widget build(BuildContext context) {
    PocketBaseConnector connector = PocketBaseConnector();
    User? user = connector.getConnectedUser();

    if (user == null) {
      pushOrGo(context, Routes.profile.signin);
      return const SizedBox.shrink(); // Return empty widget while navigating
    }

    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (theme !=
        (AdaptiveTheme.of(context).mode.isSystem
            ? 'system'
            : AdaptiveTheme.of(context).mode.isDark
            ? 'dark'
            : 'light')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          theme = AdaptiveTheme.of(context).mode.isSystem
              ? 'system'
              : AdaptiveTheme.of(context).mode.isDark
              ? 'dark'
              : 'light';
        });
      });
    }

    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(elevation: 0, title: Text(localizations.profileSettings)),
      body: Center(
        child: MyScrollColumn(
          scrollPadding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            GestureDetector(
              onTap: () {
                pickUploadImage();
              },
              child: GetUserProfilePicture(file: user.avatar!),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 25)),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                child: Text(localizations.emailIs(user.email)),
              ),
            ),

            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                child: Text(localizations.usernameIs(user.username)),
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                child: Text(
                  localizations.accountCreatedOn(
                    DateFormat.yMMMMd(
                      Localizations.localeOf(context).languageCode,
                    ).format(connector.getConnectedUser()!.created),
                  ),
                ),
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                child: Text(
                  localizations.birthdayDateIs(
                    DateFormat.yMMMMd(
                      Localizations.localeOf(context).languageCode,
                    ).format(connector.getConnectedUser()!.birthday),
                  ),
                ),
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                child: Text(localizations.volumeOwnedNumber(numberMangaOwned)),
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                child: Text(localizations.favoriteSeriesNumber(numberSerieFav)),
              ),
            ),
            MyLine(
              width: MediaQuery.of(context).size.width,
              vertical: 10,
            ), // Drop Down Menu du DarkMode
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonFormField(
                items: [
                  DropdownMenuItem(
                    value: 'light',
                    child: Row(
                      children: [
                        Image.asset(Assets.images.theme.lightIcon, width: 20),
                        const Padding(padding: EdgeInsets.only(right: 10)),
                        Text(localizations.lightMode),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'dark',
                    child: Row(
                      children: [
                        Image.asset(Assets.images.theme.darkIcon, width: 20),
                        const Padding(padding: EdgeInsets.only(right: 10)),
                        Text(localizations.darkMode),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'system',
                    child: Row(
                      children: [
                        Image.asset(Assets.images.theme.autoIcon, width: 20),
                        const Padding(padding: EdgeInsets.only(right: 10)),
                        Text(localizations.systemMode),
                      ],
                    ),
                  ),
                ],
                decoration: const InputDecoration(border: OutlineInputBorder()),
                initialValue: theme,
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
                },
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonFormField<Language>(
                items: [
                  DropdownMenuItem(
                    value: Language.english,
                    child: Row(
                      children: [
                        Image.asset(Assets.images.us, width: 20),
                        const Padding(padding: EdgeInsets.only(right: 10)),
                        Text(localizations.english),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: Language.french,
                    child: Row(
                      children: [
                        Image.asset(Assets.images.fr, width: 20),
                        const Padding(padding: EdgeInsets.only(right: 10)),
                        Text(localizations.french),
                      ],
                    ),
                  ),
                ],
                decoration: const InputDecoration(border: OutlineInputBorder()),
                initialValue: language,
                onChanged: (Language? value) {
                  if (value == null) return;
                  ref.read(languageRepositoryProvider).setLanguage(value);
                  setState(() {});
                },
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  LocalStorage().deleteToken();
                  LocalStorage().deleteOwnedSubSerie();
                  LocalStorage().clearAllCache();
                  showMessage(localizations.clearCacheSuccess, context);
                },
                child: Row(
                  children: [
                    const Padding(padding: EdgeInsets.only(right: 16)),
                    OwnIcon(
                      iconColor: Theme.of(context).colorScheme.primary,
                      iconSrc: Assets.icons.trash,
                    ),
                    const Padding(padding: EdgeInsets.only(right: 9)),
                    Text(localizations.clearCache),
                  ],
                ),
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            SingleChildScrollView(
              child: GestureDetector(
                onTap: () => pushOrGo(context, Routes.profile.modifyPassword),
                child: Row(
                  children: [
                    const Padding(padding: EdgeInsets.only(right: 16)),
                    OwnIcon(
                      iconColor: Theme.of(context).colorScheme.primary,
                      iconSrc: Assets.icons.lock,
                    ),
                    const Padding(padding: EdgeInsets.only(right: 9)),
                    Text(localizations.modifyPassword),
                  ],
                ),
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10.0),
            MyIconTextButton(
              function: () => signUserOut(text: localizations.logOutSuccess),
              color: Colors.red,
              iconSrc: Assets.icons.logOut,
              text: localizations.logOut,
            ),
            MyTextDivider(text: localizations.dangerZone),
            MyIconTextButton(
              function: () => pushOrGo(context, Routes.deleteAccount),
              color: Colors.red,
              iconSrc: Assets.icons.delete,
              text: localizations.deleteAccount,
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GestureDetector(
                child: Text(localizations.legalNotice),
                onTap: () => pushOrGo(context, Routes.profile.legalNotice),
              ),
            ),
            GestureDetector(
              onDoubleTap: () {
                pushOrGo(context, '/admin');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FutureBuilder(
                  future: connector.appVersion,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final String appVersion = snapshot.data.toString();
                      return FutureBuilder(
                        future: connector.buildVersion,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            final String buildVersion = snapshot.data
                                .toString();
                            return Column(
                              children: [
                                Text(
                                  localizations.appVersionAndAppBuildVersion(
                                    appVersion,
                                    buildVersion,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return SizedBox();
                          }
                        },
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
