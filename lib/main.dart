import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:mymangatheque/src/back/app_router/app_navigation.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/theme/dark_mode.dart';
import 'package:mymangatheque/src/const/theme/light_mode.dart';
import 'package:mymangatheque/src/models/local_storage/service_locator.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  await PocketBaseConnector().init();

  usePathUrlStrategy();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  //final container = ProviderContainer();
  //await container.read(MangaOwnedProvider.notifier).initialize();

  runApp(
    ProviderScope(
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
    return AdaptiveTheme(
      light: lightMode,
      dark: darkMode,
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp.router(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('fr'), // French
        ],
        routerConfig: AppNavigation.router,
        title: 'MyMangatheque',
        theme: theme,
        darkTheme: darkTheme,
      ),
    );
  }
}
