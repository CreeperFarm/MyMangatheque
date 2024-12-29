import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:mymangatheque/src/back/app_router/app_navigation.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/theme/dark_mode.dart';
import 'package:mymangatheque/src/const/theme/light_mode.dart';
import 'package:mymangatheque/src/front/components/my_manga_show_tile.dart';
import 'package:mymangatheque/src/models/local_storage/service_locator.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  PocketBaseConnector().init();

  usePathUrlStrategy();

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
    return FutureBuilder(
      future: PocketBaseConnector().getCollectionFullListOrder('volumes', '-release'),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Chargement..."),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Aucune connexion"),
            ),
            body: Center(
              child: const Text("Aucune connexion"),
            ),
          );
        }
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return Scaffold(
            appBar: AppBar(
              title: Text("Une erreur est survenue"),
            ),
            body: Center(
              child: const Text("Une erreur est survenue"),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          debugPrint(snapshot.data.toString());
          return LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 1200) {
              return GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.7,
                ),
                itemCount: json.decode(snapshot.data!.toString()).length,
                itemBuilder: (BuildContext context, int index) {
                  return MyMangaShowTile(
                    mangaData: json.decode(snapshot.data!.toString())[index],
                    initRoute: "/",
                    width: constraints.maxWidth / 4 - 30,
                    height: (constraints.maxWidth / 4 - 30) * 1.5,
                  );
                },
              );
            } else if (constraints.maxWidth > 800) {
              return GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.7,
                ),
                scrollDirection: Axis.vertical,
                itemCount: json.decode(snapshot.data!.toString()).length,
                itemBuilder: (BuildContext context, int index) {
                  return MyMangaShowTile(
                    mangaData: json.decode(snapshot.data!.toString())[index],
                    initRoute: "/",
                    width: constraints.maxWidth / 3 - 30,
                    height: (constraints.maxWidth / 3 - 30) * 1.5,
                  );
                },
              );
            } else {
              return GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                ),
                itemCount: json.decode(snapshot.data!.toString()).length,
                itemBuilder: (BuildContext context, int index) {
                  return MyMangaShowTile(
                    mangaData: json.decode(snapshot.data!.toString())[index],
                    initRoute: "/",
                    width: constraints.maxWidth / 2 - 30,
                    height: (constraints.maxWidth / 2 - 30) * 1.5,
                  );
                },
              );
            }
          });
        } else {
          debugPrint(snapshot.error.toString());
          return Scaffold(
            appBar: AppBar(
              title: Text("Une erreur est survenue"),
            ),
            body: Center(
              child: const Text("Une erreur est survenue"),
            ),
          );
        }
      },
    );
  }
}
