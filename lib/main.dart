import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/provider/compteur_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mymangatheque/src/screen/auth/forgot_password_page.dart';
import 'package:mymangatheque/src/screen/auth/modify_password_page.dart';
import 'package:mymangatheque/src/screen/auth/profile_page.dart';
import 'package:mymangatheque/src/screen/auth/signin_page.dart';
import 'package:mymangatheque/src/screen/auth/signup_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(ProviderScope(child: MyApp(savedThemeMode: savedThemeMode)));
}

class MyApp extends StatelessWidget {
  dynamic savedThemeMode;
  MyApp({required this.savedThemeMode, super.key});

  GoRouter router = GoRouter(
      routes: [
        ShellRoute(
            routes: [
              GoRoute(
                  path: '/',
                  builder: (context, state) => const MyHomePage(title: 'HomePage'),
                  routes: [
                    GoRoute(
                      path: 'profile',
                      builder: (context, state) => const ProfilePage(),
                      routes: [
                        GoRoute(
                            path: '/signin',
                            builder: (context, state) => const SignInPage()
                        ),
                        GoRoute(
                            path: '/signup',
                            builder: (context, state) => const SignUpPage()
                        ),
                        GoRoute(
                            path: '/modify_password',
                            builder: (context, state) => const ModifyPasswordPage()
                        ),
                        GoRoute(
                            path: '/forgot_password',
                            builder: (context, state) => const ForgotPasswordPage()
                        ),
                      ]
                    )
                  ]
              ),
            ],
          builder: (context, state, child) {
              return BottomNavigationBar(
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.menu_book_outlined),
                      label: 'Collection',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_month),
                      label: 'Planning',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: 'Recherche',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle_outlined),
                      label: 'Compte',
                    ),
                  ]
              );
          }
        )
      ]
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final goRouter = ref.watch(GoRouterProvider);
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
        routerConfig: goRouter,
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
    final compteur = ref.watch(compteurProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
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
                  GoRouter.of(context).go('/profile');
                } else {
                  GoRouter.of(context).go('/profile/signin');
                }
              },
              child: const Text("Go to Profile Page"))
          ],
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
