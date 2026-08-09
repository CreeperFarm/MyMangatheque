import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/language/language.dart';
import 'package:mymangatheque/src/back/language/language_repository.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/back/services/notifications/notification_service.dart';
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
  bool _redirectScheduled = false;
  bool _adultContentEnabled = false;
  bool _scanPreviousVolumesSuggestionEnabled = true;
  AppDisplayDensity _displayDensity = AppDisplayDensity.comfortable;
  HomeRecommendationOrder _homeRecommendationOrder =
      HomeRecommendationOrder.recommended;
  AppNavigationLabelMode _navigationLabelMode = AppNavigationLabelMode.always;
  bool _reducedMotion = false;

  //String localLanguage = PlatformDispatcher.instance.locale.languageCode;
  int numberMangaOwned = 0;
  int numberSerieFav = 0;

  final connector = AppwriteConnector();

  // Sign Out a Connected User
  void signUserOut({required String text}) async {
    await connector.logOut();
    if (!mounted) return;
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

    if (image == null) return;

    final connectedUser = connector.getConnectedUser();
    if (connectedUser == null) return;

    final bytes = await image.readAsBytes();

    if (!mounted) return;
    final updated = await connector.updateAvatar(
      'users',
      connectedUser.id,
      image.name,
      bytes,
      context,
    );
    if (!updated) return;
    await connector.updateUserData(connectedUser.email);
    if (!mounted) return;
    setState(() {});
  }

  // Get the number of owned manga
  Future<void> getNumberOfMangaOwned() async {
    try {
      final connectedUser = connector.getConnectedUser();
      if (connectedUser == null) return;
      int countMangaOwned = await connector.getNumberOwnedManga(
        connectedUser.id,
      );
      if (!mounted) return;
      setState(() {
        numberMangaOwned = countMangaOwned;
      });
    } catch (e) {
      RuntimeLocalization.debug(
        en: 'Unable to select a profile image: $e',
        fr: 'Impossible de sélectionner une image de profil : $e',
      );
    }
  }

  // Get the number of favorite series
  Future<void> getNumberOfSeriesFav() async {
    try {
      final connectedUser = connector.getConnectedUser();
      if (connectedUser == null) return;
      int countSerieFav = await connector.getNumberFavSerie(connectedUser.id);
      if (!mounted) return;
      setState(() {
        numberSerieFav = countSerieFav;
      });
    } catch (e) {
      RuntimeLocalization.debug(
        en: 'Unable to update the profile image: $e',
        fr: 'Impossible de mettre à jour l’image de profil : $e',
      );
    }
  }

  DateTime selectedBDayDate = DateTime(
    DateTime.now().year - 7,
    DateTime.now().month,
    DateTime.now().day,
  );

  Future<void> _loadAdultContentPreference() async {
    final enabled = await LocalStorage().getAdultContentEnabled();
    if (!mounted) return;
    setState(() {
      _adultContentEnabled = enabled;
    });
  }

  Future<void> _setAdultContentPreference(bool enabled) async {
    await LocalStorage().setAdultContentEnabled(enabled);
    if (!mounted) return;
    setState(() {
      _adultContentEnabled = enabled;
    });
    showMessage(
      enabled
          ? AppLocalizations.of(context)!.adultContentEnabled
          : AppLocalizations.of(context)!.adultContentDisabled,
      context,
    );
  }

  Future<void> _loadScanPreviousVolumesSuggestionPreference() async {
    final enabled = await LocalStorage()
        .getScanPreviousVolumesSuggestionEnabled();
    if (!mounted) return;
    setState(() {
      _scanPreviousVolumesSuggestionEnabled = enabled;
    });
  }

  Future<void> _setScanPreviousVolumesSuggestionPreference(
    bool enabled,
  ) async {
    await LocalStorage().setScanPreviousVolumesSuggestionEnabled(enabled);
    if (!mounted) return;
    setState(() {
      _scanPreviousVolumesSuggestionEnabled = enabled;
    });
  }

  Future<void> _loadDisplayDensity() async {
    final density = await LocalStorage().getDisplayDensity();
    if (!mounted) return;
    setState(() => _displayDensity = density);
  }

  Future<void> _setDisplayDensity(AppDisplayDensity density) async {
    await LocalStorage().setDisplayDensity(density);
    if (!mounted) return;
    setState(() => _displayDensity = density);
  }

  Future<void> _loadInterfacePreferences() async {
    final storage = LocalStorage();
    final values = await Future.wait<Object?>([
      storage.getHomeRecommendationOrder(),
      storage.getNavigationLabelMode(),
      storage.getReducedMotion(),
    ]);
    if (!mounted) return;
    setState(() {
      _homeRecommendationOrder = values[0]! as HomeRecommendationOrder;
      _navigationLabelMode = values[1]! as AppNavigationLabelMode;
      _reducedMotion = values[2]! as bool;
    });
  }

  Future<void> _setHomeRecommendationOrder(
    HomeRecommendationOrder order,
  ) async {
    await LocalStorage().setHomeRecommendationOrder(order);
    if (!mounted) return;
    setState(() => _homeRecommendationOrder = order);
  }

  Future<void> _setNavigationLabelMode(AppNavigationLabelMode mode) async {
    await LocalStorage().setNavigationLabelMode(mode);
    if (!mounted) return;
    setState(() => _navigationLabelMode = mode);
  }

  Future<void> _setReducedMotion(bool reduced) async {
    await LocalStorage().setReducedMotion(reduced);
    if (!mounted) return;
    setState(() => _reducedMotion = reduced);
  }

  Future<void> _setPushNotifications(bool enabled) async {
    if (enabled) {
      final activated = await connector.enablePushNotifications();
      if (!mounted) return;
      final state = connector.pushNotificationState.value;
      showMessage(
        activated
            ? context.localized(
                en: 'Notifications are enabled on this device.',
                fr: 'Les notifications sont activées sur cet appareil.',
              )
            : state.authorization == PushAuthorizationState.denied
            ? context.localized(
                en: 'Notification permission was denied. Enable it in the browser or system settings.',
                fr: 'La permission de notification a été refusée. Activez-la dans les réglages du navigateur ou du système.',
              )
            : context.localized(
                en: 'Notifications could not be enabled. Check the application configuration and try again.',
                fr: 'Les notifications n’ont pas pu être activées. Vérifiez la configuration de l’application puis réessayez.',
              ),
        context,
      );
      return;
    }

    await connector.disablePushNotifications();
    if (!mounted) return;
    showMessage(
      context.localized(
        en: 'Notifications are disabled on this device.',
        fr: 'Les notifications sont désactivées sur cet appareil.',
      ),
      context,
    );
  }

  @override
  void initState() {
    super.initState();
    getNumberOfMangaOwned();
    getNumberOfSeriesFav();
    _loadAdultContentPreference();
    _loadScanPreviousVolumesSuggestionPreference();
    _loadDisplayDensity();
    _loadInterfacePreferences();
  }

  @override
  Widget build(BuildContext context) {
    AppwriteConnector connector = AppwriteConnector();
    User? user = connector.getConnectedUser();

    if (user == null) {
      if (!_redirectScheduled) {
        _redirectScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          pushOrGo(context, Routes.profile.signin);
        });
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _redirectScheduled = false;

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
              child: user.avatar != null
                  ? GetUserProfilePicture(file: user.avatar!)
                  : CircleAvatar(
                      radius: 87.5,
                      backgroundImage: AssetImage(Assets.images.unknown),
                    ),
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
                    ).format(user.created),
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
                    ).format(user.birthday),
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
              child: DropdownButtonFormField<HomeRecommendationOrder>(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: context.localized(
                    en: 'Home recommendation order',
                    fr: 'Ordre des recommandations d’accueil',
                  ),
                ),
                initialValue: _homeRecommendationOrder,
                items: [
                  DropdownMenuItem<HomeRecommendationOrder>(
                    value: HomeRecommendationOrder.recommended,
                    child: Text(
                      context.localized(
                        en: 'Recommended order',
                        fr: 'Ordre recommandé',
                      ),
                    ),
                  ),
                  DropdownMenuItem<HomeRecommendationOrder>(
                    value: HomeRecommendationOrder.newestFirst,
                    child: Text(
                      context.localized(
                        en: 'Newest releases first',
                        fr: 'Sorties récentes en premier',
                      ),
                    ),
                  ),
                  DropdownMenuItem<HomeRecommendationOrder>(
                    value: HomeRecommendationOrder.title,
                    child: Text(
                      context.localized(
                        en: 'Alphabetical order',
                        fr: 'Ordre alphabétique',
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    unawaited(_setHomeRecommendationOrder(value));
                  }
                },
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonFormField<AppNavigationLabelMode>(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: context.localized(
                    en: 'Navigation labels',
                    fr: 'Libellés de navigation',
                  ),
                ),
                initialValue: _navigationLabelMode,
                items: [
                  DropdownMenuItem<AppNavigationLabelMode>(
                    value: AppNavigationLabelMode.always,
                    child: Text(
                      context.localized(
                        en: 'Always visible',
                        fr: 'Toujours visibles',
                      ),
                    ),
                  ),
                  DropdownMenuItem<AppNavigationLabelMode>(
                    value: AppNavigationLabelMode.selectedOnly,
                    child: Text(
                      context.localized(
                        en: 'Selected tab only',
                        fr: 'Onglet sélectionné uniquement',
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    unawaited(_setNavigationLabelMode(value));
                  }
                },
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: SwitchListTile(
                title: Text(
                  context.localized(
                    en: 'Reduce animations',
                    fr: 'Réduire les animations',
                  ),
                ),
                subtitle: Text(
                  context.localized(
                    en: 'Limits transitions and image fades throughout the application.',
                    fr: 'Limite les transitions et fondus d’image dans toute l’application.',
                  ),
                ),
                value: _reducedMotion,
                onChanged: (value) => unawaited(_setReducedMotion(value)),
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonFormField<AppDisplayDensity>(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: context.localized(
                    en: 'Display density',
                    fr: 'Densité d’affichage',
                  ),
                ),
                initialValue: _displayDensity,
                items: [
                  DropdownMenuItem<AppDisplayDensity>(
                    value: AppDisplayDensity.comfortable,
                    child: Text(
                      context.localized(en: 'Comfortable', fr: 'Confortable'),
                    ),
                  ),
                  DropdownMenuItem<AppDisplayDensity>(
                    value: AppDisplayDensity.compact,
                    child: Text(
                      context.localized(en: 'Compact', fr: 'Compacte'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) unawaited(_setDisplayDensity(value));
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: SwitchListTile(
                title: Text(localizations.adultContent),
                subtitle: Text(localizations.adultContentPreferenceDescription),
                value: _adultContentEnabled,
                onChanged: _setAdultContentPreference,
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: SwitchListTile(
                title: Text(localizations.scanPreviousVolumesSuggestion),
                subtitle: Text(
                  localizations.scanPreviousVolumesSuggestionDescription,
                ),
                value: _scanPreviousVolumesSuggestionEnabled,
                onChanged: _setScanPreviousVolumesSuggestionPreference,
              ),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            ValueListenableBuilder<PushNotificationState>(
              valueListenable: connector.pushNotificationState,
              builder: (context, notificationState, _) {
                final unavailable =
                    notificationState.authorization ==
                    PushAuthorizationState.unavailable;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SwitchListTile(
                    secondary: notificationState.busy
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            notificationState.enabled
                                ? Icons.notifications_active_outlined
                                : Icons.notifications_none_outlined,
                          ),
                    title: Text(
                      context.localized(
                        en: 'Push notifications',
                        fr: 'Notifications push',
                      ),
                    ),
                    subtitle: Text(
                      unavailable
                          ? context.localized(
                              en: 'Push notifications are not available on this platform.',
                              fr: 'Les notifications push ne sont pas disponibles sur cette plateforme.',
                            )
                          : notificationState.authorization ==
                                PushAuthorizationState.denied
                          ? context.localized(
                              en: 'Permission denied in the browser or system settings.',
                              fr: 'Permission refusée dans les réglages du navigateur ou du système.',
                            )
                          : context.localized(
                              en: 'Receive followed-series releases, account alerts and selected recommendations.',
                              fr: 'Recevez les sorties des séries suivies, les alertes de compte et certaines recommandations.',
                            ),
                    ),
                    value: notificationState.enabled,
                    onChanged: unavailable || notificationState.busy
                        ? null
                        : (value) => unawaited(_setPushNotifications(value)),
                  ),
                );
              },
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            StreamBuilder<List<InAppNotification>>(
              stream: connector.listenToNotifications(),
              initialData: connector.notifications,
              builder: (context, snapshot) {
                final unread = (snapshot.data ?? const <InAppNotification>[])
                    .where((notification) => notification.openedAt == null)
                    .length;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Badge(
                    isLabelVisible: unread > 0,
                    label: Text(unread > 99 ? '99+' : '$unread'),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    context.localized(
                      en: 'Notification inbox',
                      fr: 'Boîte de notifications',
                    ),
                  ),
                  subtitle: Text(
                    unread == 0
                        ? context.localized(
                            en: 'No unread notification.',
                            fr: 'Aucune notification non lue.',
                          )
                        : context.localized(
                            en: '$unread unread notification(s).',
                            fr: '$unread notification(s) non lue(s).',
                          ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => pushOrGo(context, '/profile/notifications'),
                );
              },
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(
                Icons.recommend_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                context.localized(
                  en: 'Recommendation preferences',
                  fr: 'Préférences de recommandation',
                ),
              ),
              subtitle: Text(
                context.localized(
                  en: 'Genres, novelty, diversity and popular fallback.',
                  fr: 'Genres, nouveautés, diversité et repli populaire.',
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => pushOrGo(context, '/profile/recommendations'),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(
                Icons.move_to_inbox_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                context.localized(
                  en: 'Import an existing collection',
                  fr: 'Importer une collection existante',
                ),
              ),
              subtitle: Text(
                context.localized(
                  en: 'Mangacollec, CSV, JSON, EAN/ISBN or a text list.',
                  fr: 'Mangacollec, CSV, JSON, EAN/ISBN ou liste textuelle.',
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => pushOrGo(context, '/profile/import-collection'),
            ),
            MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
            SingleChildScrollView(
              child: GestureDetector(
                onTap: () async {
                  final storage = LocalStorage();
                  await Future.wait<void>([
                    storage.deleteToken(),
                    storage.deleteOwnedSubSerie(
                      userId: connector.getConnectedUser()?.id,
                    ),
                    storage.deleteOwnedSubSerie(),
                    storage.clearAllCache(),
                    DefaultCacheManager().emptyCache(),
                  ]);
                  PaintingBinding.instance.imageCache
                    ..clear()
                    ..clearLiveImages();
                  if (!context.mounted) return;
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
