import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/app_router/app_navigation.dart';
import 'package:mymangatheque/src/back/language/language.dart';
import 'package:mymangatheque/src/back/language/language_repository.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/theme/dark_mode.dart';
import 'package:mymangatheque/src/const/theme/light_mode.dart';
import 'package:mymangatheque/src/models/local_storage/service_locator.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  await PocketBaseConnector().init();

  setPathUrlStrategy();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final container = ProviderContainer();
  final language = await container.read(languageRepositoryProvider).getLanguage();

  runApp(
    ProviderScope(
      overrides: [languageProvider.overrideWith((ref) => language)],
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({required this.savedThemeMode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FlutterNativeSplash.remove();
    final language = ref.watch(languageProvider);

    return AdaptiveTheme(
      light: lightMode,
      dark: darkMode,
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(language.code, ''),
        routerConfig: AppNavigation.router,
        title: 'MyMangatheque',
        theme: theme,
        darkTheme: darkTheme,
      ),
    );
  }
}
