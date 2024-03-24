import 'package:mymangatheque/src/screen/profile/profile_settings_page.dart';
import 'package:mymangatheque/src/app_router/redirect_profile_page.dart';
import 'package:mymangatheque/src/screen/auth/forgot_password_page.dart';
import 'package:mymangatheque/src/screen/auth/modify_password_page.dart';
import 'package:mymangatheque/src/screen/planning/planning_page.dart';
import 'package:mymangatheque/src/screen/library/library_page.dart';
import 'package:mymangatheque/src/screen/info_manga/authors.dart';
import 'package:mymangatheque/src/screen/info_manga/editors.dart';
import 'package:mymangatheque/src/screen/search/search_page.dart';
import 'package:mymangatheque/src/screen/info_manga/series.dart';
import 'package:mymangatheque/src/app_router/main_wrapper.dart';
import 'package:mymangatheque/src/screen/auth/signin_page.dart';
import 'package:mymangatheque/src/screen/auth/signup_page.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/main.dart';
import 'package:flutter/cupertino.dart';

class AppNavigation {
  AppNavigation._();

  static String initR = '/';

  // Private Navigator Key
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _rootNavigatorHome = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _rootNavigatorLibrary = GlobalKey<NavigatorState>(debugLabel: 'shellLibrary');
  static final _rootNavigatorProfile = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  //GoRouter Config
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initR,
    routes: <RouteBase>[
      // MainWrapper Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _rootNavigatorHome,
            routes: [
              GoRoute(
                path: '/',
                name: 'Home',
                builder: (context, state) {
                  return MyHomePage(title: 'HomePage', key: state.pageKey);
                },
                routes: [
                  GoRoute(
                      path: 'editor/:name',
                      name: 'Editor Home',
                      builder: (context, state) {
                        return EditorPage(editorName: state.pathParameters['name']!, key: state.pageKey);
                      }
                  ),
                  GoRoute(
                      path: 'author/:name',
                      name: 'Author Home',
                      builder: (context, state) {
                        return AuthorPage(authorName: state.pathParameters['name']!, key: state.pageKey);
                      }
                  ),
                  GoRoute(
                      path: 'series/:name',
                      name: 'Series Home',
                      builder: (context, state) {
                        return SeriesPages(seriesName: state.pathParameters['name']!, key: state.pageKey);
                      }
                  ),
                  GoRoute(
                      path: 'manga/:tomeId',
                      name: 'Manga Home',
                      builder: (context, state) {
                        return SeriesPages(seriesName: state.pathParameters['tomeId']!, key: state.pageKey);
                      }
                  ),
                ]
              ),
            ]
          ),
          StatefulShellBranch(
            navigatorKey: _rootNavigatorLibrary,
            routes: [
              GoRoute(
                path: '/library',
                name: 'Mangathèque',
                builder: (context, state) {
                  return LibraryPage(key: state.pageKey,);
                },
                  routes: [
                    GoRoute(
                        path: 'editor/:name',
                        name: 'Editor Library',
                        builder: (context, state) {
                          return EditorPage(editorName: state.pathParameters['name']!, key: state.pageKey);
                        }
                    ),
                    GoRoute(
                        path: 'author/:name',
                        name: 'Author Library',
                        builder: (context, state) {
                          return AuthorPage(authorName: state.pathParameters['name']!, key: state.pageKey);
                        }
                    ),
                    GoRoute(
                        path: 'series/:name',
                        name: 'Series Library',
                        builder: (context, state) {
                          return SeriesPages(seriesName: state.pathParameters['name']!, key: state.pageKey);
                        }
                    ),
                    GoRoute(
                        path: 'manga/:tomeId',
                        name: 'Manga Library',
                        builder: (context, state) {
                          return SeriesPages(seriesName: state.pathParameters['tomeId']!, key: state.pageKey);
                        }
                    )
                  ]
              )
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: 'Search',
                builder: (context, state) {
                  return SearchPage(
                    key: state.pageKey,
                  );
                },
                  routes: [
                    GoRoute(
                        path: 'editor/:name',
                        name: 'Editor Search',
                        builder: (context, state) {
                          return EditorPage(editorName: state.pathParameters['name']!, key: state.pageKey);
                        }
                    ),
                    GoRoute(
                        path: 'author/:name',
                        name: 'Author Search',
                        builder: (context, state) {
                          return AuthorPage(authorName: state.pathParameters['name']!, key: state.pageKey);
                        }
                    ),
                    GoRoute(
                        path: 'series/:name',
                        name: 'Series Search',
                        builder: (context, state) {
                          return SeriesPages(seriesName: state.pathParameters['name']!, key: state.pageKey);
                        }
                    ),
                    GoRoute(
                        path: 'manga/:tomeId',
                        name: 'Manga Search',
                        builder: (context, state) {
                          return SeriesPages(seriesName: state.pathParameters['tomeId']!, key: state.pageKey);
                        }
                    )
                  ]
              )
            ]
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/planning',
                name: 'Planning',
                builder: (context, state) {
                  return PlanningPage(key: state.pageKey,);
                },
                  routes: [
                    GoRoute(
                        path: 'editor/:name',
                        name: 'Editor Planning',
                        builder: (context, state) {
                          return EditorPage(editorName: state.pathParameters['name']!, key: state.pageKey);
                        }
                    ),
                    GoRoute(
                        path: 'author/:name',
                        name: 'Author Planning',
                        builder: (context, state) {
                          return AuthorPage(authorName: state.pathParameters['name']!, key: state.pageKey);
                        }
                    ),
                    GoRoute(
                        path: 'series/:name',
                        name: 'Series Planning',
                        builder: (context, state) {
                          return SeriesPages(seriesName: state.pathParameters['name']!, key: state.pageKey);
                        }
                    ),
                    GoRoute(
                        path: 'manga/:tomeId',
                        name: 'Manga Planning',
                        builder: (context, state) {
                          return SeriesPages(seriesName: state.pathParameters['tomeId']!, key: state.pageKey);
                        }
                    )
                  ]
              )
            ]
          ),
          StatefulShellBranch(
            navigatorKey: _rootNavigatorProfile,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'Profile',
                builder: (context, state) {
                  return RedirectToProfile(key: state.pageKey);
                },
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: 'Settings',
                    builder: (context, state) {
                      return SettingsProfilePage(key: state.pageKey);
                    }
                  ),
                  GoRoute(
                    path: 'modify_password',
                    name: 'ModifyPassword',
                    builder: (context, state) {
                      return ModifyPasswordPage(key: state.pageKey);
                    }
                  ),
                  GoRoute(
                    path: 'signin',
                    name: 'SignIn',
                    builder: (context, state) {
                      return SignInPage(key: state.pageKey);
                    }
                  ),
                  GoRoute(
                    path: 'signup',
                    name: 'SignUp',
                    builder: (context, state) {
                      return SignUpPage(key: state.pageKey);
                    }
                  ),
                  GoRoute(
                    path: 'forgot_password',
                    name: 'ForgotPassword',
                    builder: (context, state) {
                      return ForgotPasswordPage(key: state.pageKey);
                    }
                  ),
                ]
              )
            ]
          ),
        ]
      ),
    ]
  );
}