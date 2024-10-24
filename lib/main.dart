import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/back/app_router/app_navigation.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/theme/dark_mode.dart';
import 'package:mymangatheque/src/const/theme/light_mode.dart';
import 'package:mymangatheque/src/models/local_storage/service_locator.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  PocketBaseConnector().init();

  setPathUrlStrategy();

  runApp(ProviderScope(
    child: MyApp(savedThemeMode: savedThemeMode),
  ));
}

class MyApp extends ConsumerWidget {
  dynamic savedThemeMode;

  MyApp({required this.savedThemeMode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FlutterNativeSplash.remove();
    return AdaptiveTheme(
      light: lightMode,
      dark: darkMode,
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp.router(
        routerConfig: AppNavigation.router,
        title: 'MyMangatheque',
        theme: theme,
        darkTheme: darkTheme,
      ),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  if (PocketBaseConnector().isLoggedIn()) {
                    context.go('/profile');
                  } else {
                    context.go('/profile/signin');
                  }
                },
                child: const Text("Go to Profile Page")),
            ElevatedButton(
                onPressed: () {
                  if (PocketBaseConnector().isLoggedIn()) {
                    context.go('/profile/settings');
                  } else {
                    context.go('/profile/signin');
                  }
                },
                child: const Text("Go to Setting Profile Page")),
            ElevatedButton(
                onPressed: () {
                  context.go('/library/scan');
                },
                child: const Text("Go to Scan Page")),
            ElevatedButton(
                onPressed: () {
                  context.go('/discover');
                },
                child: const Text("Go to Discover Page")),
            ElevatedButton(
                onPressed: () {
                  context.go('/devpage');
                },
                child: const Text("Go to Dev Compo Show Page")),
            ElevatedButton(
                onPressed: () {
                  context.go('/mentions_legales');
                },
                child: const Text("Go to Mentions Légales Page")),
          ],
        ),
      ),
    );
  }
}
