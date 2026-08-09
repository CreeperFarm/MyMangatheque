import 'dart:async';
import 'dart:ui';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/firebase_options.dart';
import 'package:mymangatheque/src/back/app_router/app_navigation.dart';
import 'package:mymangatheque/src/back/language/language.dart';
import 'package:mymangatheque/src/back/language/language_repository.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/back/services/analytics/product_analytics_service.dart';
import 'package:mymangatheque/src/back/services/notifications/notification_service.dart';
import 'package:mymangatheque/src/const/theme/dark_mode.dart';
import 'package:mymangatheque/src/const/theme/light_mode.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:mymangatheque/src/models/local_storage/service_locator.dart';

Future<void> _initializeFirebase() async {
  if (!DefaultFirebaseOptions.isSupported || Firebase.apps.isNotEmpty) return;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await _initializeFirebase();
  await NotificationService().handleBackgroundMessage(message);
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(
      ProductAnalyticsService().trackReliabilityFailure('flutter.framework'),
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(
      ProductAnalyticsService().trackReliabilityFailure('flutter.unhandled'),
    );
    return false;
  };
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  setupServiceLocator();

  await _initializeFirebase();
  if (DefaultFirebaseOptions.isSupported) {
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );
  }

  final localStorage = LocalStorage();
  await Future.wait<Object?>([
    localStorage.getDisplayDensity(),
    localStorage.getHomeRecommendationOrder(),
    localStorage.getNavigationLabelMode(),
    localStorage.getReducedMotion(),
  ]);

  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  final container = ProviderContainer();
  final language = await container
      .read(languageRepositoryProvider)
      .getLanguage();
  container.dispose();

  await AppwriteConnector().init();

  usePathUrlStrategy();

  runApp(
    ProviderScope(
      overrides: [languageProvider.overrideWith((ref) => language)],
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({required this.savedThemeMode, super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<String>? _notificationRouteSubscription;

  @override
  void initState() {
    super.initState();
    final connector = AppwriteConnector();
    _notificationRouteSubscription = connector
        .listenToNotificationOpenRoutes()
        .listen(_openNotificationRoute);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingRoute = connector.takePendingNotificationOpenRoute();
      if (pendingRoute != null) _openNotificationRoute(pendingRoute);
    });
  }

  void _openNotificationRoute(String route) {
    if (!mounted) return;
    AppNavigation.router.go(route);
  }

  @override
  void dispose() {
    unawaited(_notificationRouteSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    final language = ref.watch(languageProvider);

    return AdaptiveTheme(
      light: lightMode,
      dark: darkMode,
      initial: widget.savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => ValueListenableBuilder<bool>(
        valueListenable: LocalStorage.reducedMotionNotifier,
        builder: (context, reducedMotion, _) => MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale(language.code, ''),
          routerConfig: AppNavigation.router,
          title: 'MyMangatheque',
          theme: theme,
          darkTheme: darkTheme,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                disableAnimations:
                    mediaQuery.disableAnimations || reducedMotion,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}
