import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/app_router/app_navigation.dart';
import 'package:mymangatheque/src/provider/compteur_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      child: MyApp(savedThemeMode: savedThemeMode),
    )
  );
}

class MyApp extends ConsumerWidget {
  dynamic savedThemeMode;
  MyApp({required this.savedThemeMode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FlutterNativeSplash.remove();
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: Colors.deepPurpleAccent.shade100,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.deepPurpleAccent.shade100,
          unselectedItemColor: Colors.grey,
        ),
        textTheme: const TextTheme(
          labelLarge: TextStyle(color: Colors.black),
          labelMedium: TextStyle(color: Colors.black),
          labelSmall: TextStyle(color: Colors.black),
        ),
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
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
  var result;
  @override
  Widget build(BuildContext context) {
    final compteur = ref.watch(compteurProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                "$compteur",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ElevatedButton(
                onPressed: () {
                  if (user != null) {
                    context.go('/profile');
                  } else {
                    context.go('/profile/signin');
                  }
                },
                child: const Text("Go to Profile Page")
              ),
              ElevatedButton(
                  onPressed: () {
                    if (user != null) {
                      context.go('/profile/settings');
                    } else {
                      context.go('/profile/signin');
                    }
                  },
                  child: const Text("Go to Setting Profile Page")
              ),
              ElevatedButton(
                  onPressed: () {
                    context.go('/scan');
                  },
                  child: const Text("Go to Scan Page")
              ),
              Row(
                children: [
                  const Text('The barcode is: '),
                  Text(result.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(compteurProvider.notifier).incrementer();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
