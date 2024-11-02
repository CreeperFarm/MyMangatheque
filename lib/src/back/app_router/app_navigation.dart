import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/main.dart';
import 'package:mymangatheque/src/back/app_router/main_wrapper.dart';
import 'package:mymangatheque/src/back/app_router/redirect_to_page.dart';
import 'package:mymangatheque/src/front/dev_page/component_show_page.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_create_page.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_home.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_login_page.dart';
import 'package:mymangatheque/src/front/page/auth/forgot_password_page.dart';
import 'package:mymangatheque/src/front/page/auth/modify_password_page.dart';
import 'package:mymangatheque/src/front/page/auth/signin_page.dart';
import 'package:mymangatheque/src/front/page/auth/signup_page.dart';
import 'package:mymangatheque/src/front/page/discover_page.dart';
import 'package:mymangatheque/src/front/page/info_manga/authors.dart';
import 'package:mymangatheque/src/front/page/info_manga/editors.dart';
import 'package:mymangatheque/src/front/page/info_manga/series.dart';
import 'package:mymangatheque/src/front/page/mentions_legales_page.dart';
import 'package:mymangatheque/src/front/page/planning/planning_page.dart';
import 'package:mymangatheque/src/front/page/scan_ean_page.dart';
import 'package:mymangatheque/src/front/page/search/search_page.dart';

class AppNavigation {
  AppNavigation._();

  static String initR = '/';

  // Private Navigator Key
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _rootNavigatorHome = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _rootNavigatorLibrary = GlobalKey<NavigatorState>(debugLabel: 'shellLibrary');
  static final _rootNavigatorProfile = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  //GoRouter Config
  static final GoRouter router = GoRouter(navigatorKey: _rootNavigatorKey, initialLocation: initR, routes: <RouteBase>[
    // MainWrapper Route
    StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(navigatorKey: _rootNavigatorHome, routes: [
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
                      }),
                  GoRoute(
                      path: 'author/:name',
                      name: 'Author Home',
                      builder: (context, state) {
                        return AuthorPage(authorName: state.pathParameters['name']!, key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'series/:name',
                      name: 'Series Home',
                      builder: (context, state) {
                        return SeriesPages(seriesName: state.pathParameters['name']!, key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'manga/:tomeId',
                      name: 'Manga Home',
                      builder: (context, state) {
                        return SeriesPages(seriesName: state.pathParameters['tomeId']!, key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'discover',
                      name: 'Discover',
                      builder: (context, state) {
                        return DiscoverPage(key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'devpage',
                      name: 'DevPage',
                      builder: (context, state) {
                        return ComponentShowPage(key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'mentions_legales',
                      name: 'Mentions Légales',
                      builder: (context, state) {
                        return MentionsLegalesPage(key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'delete_account',
                      name: 'Suppression du compte',
                      builder: (context, state) {
                        return RedirectToDelete(key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'admin',
                      name: 'Admin',
                      builder: (context, state) {
                        return AdminHomePage(key: state.pageKey);
                      },
                      routes: [
                        GoRoute(
                          path: 'admin_login',
                          name: 'Admin Login',
                          builder: (context, state) {
                            return AdminLoginPage(key: state.pageKey);
                          },
                        ),
                        GoRoute(
                          path: 'create',
                          name: 'Admin Create',
                          builder: (context, state) {
                            return AdminCreatePage(key: state.pageKey);
                          },
                        ),
                      ]),
                ]),
          ]),
          StatefulShellBranch(
            navigatorKey: _rootNavigatorLibrary,
            routes: [
              GoRoute(
                  path: '/library',
                  name: 'Mangathèque',
                  builder: (context, state) {
                    return RedirectToLibrary(key: state.pageKey);
                  },
                  routes: [
                    GoRoute(
                        path: 'editor/:name',
                        name: 'Editor Library',
                        builder: (context, state) {
                          return EditorPage(editorName: state.pathParameters['name']!, key: state.pageKey);
                        }),
                    GoRoute(
                        path: 'author/:name',
                        name: 'Author Library',
                        builder: (context, state) {
                          return AuthorPage(authorName: state.pathParameters['name']!, key: state.pageKey);
                        }),
                    GoRoute(
                        path: 'series/:name',
                        name: 'Series Library',
                        builder: (context, state) {
                          return SeriesPages(seriesName: state.pathParameters['name']!, key: state.pageKey);
                        }),
                    GoRoute(
                        path: 'manga/:tomeId',
                        name: 'Manga Library',
                        builder: (context, state) {
                          return SeriesPages(seriesName: state.pathParameters['tomeId']!, key: state.pageKey);
                        }),
                    GoRoute(
                        path: 'scan',
                        name: 'Scan',
                        builder: (context, state) {
                          return ScanEanPage(key: state.pageKey);
                        })
                  ])
            ],
          ),
          StatefulShellBranch(routes: [
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
                      }),
                  GoRoute(
                      path: 'author/:name',
                      name: 'Author Search',
                      builder: (context, state) {
                        return AuthorPage(authorName: state.pathParameters['name']!, key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'series/:name',
                      name: 'Series Search',
                      builder: (context, state) {
                        return SeriesPages(seriesName: state.pathParameters['name']!, key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'manga/:tomeId',
                      name: 'Manga Search',
                      builder: (context, state) {
                        return SeriesPages(seriesName: state.pathParameters['tomeId']!, key: state.pageKey);
                      })
                ])
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/planning',
                name: 'Planning',
                builder: (context, state) {
                  return PlanningPage(
                    key: state.pageKey,
                  );
                },
                routes: [
                  GoRoute(
                      path: 'editor/:name',
                      name: 'Editor Planning',
                      builder: (context, state) {
                        return EditorPage(editorName: state.pathParameters['name']!, key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'author/:name',
                      name: 'Author Planning',
                      builder: (context, state) {
                        return AuthorPage(authorName: state.pathParameters['name']!, key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'series/:name',
                      name: 'Series Planning',
                      builder: (context, state) {
                        return SeriesPages(seriesName: state.pathParameters['name']!, key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'manga/:tomeId',
                      name: 'Manga Planning',
                      builder: (context, state) {
                        return SeriesPages(seriesName: state.pathParameters['tomeId']!, key: state.pageKey);
                      })
                ])
          ]),
          StatefulShellBranch(navigatorKey: _rootNavigatorProfile, routes: [
            GoRoute(
                path: '/profile',
                name: 'Profile',
                builder: (context, state) {
                  return RedirectToProfile(key: state.pageKey);
                },
                routes: [
                  GoRoute(
                      path: 'modify_password',
                      name: 'ModifyPassword',
                      builder: (context, state) {
                        return ModifyPasswordPage(key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'signin',
                      name: 'SignIn',
                      builder: (context, state) {
                        return SignInPage(key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'signup',
                      name: 'SignUp',
                      builder: (context, state) {
                        return SignUpPage(key: state.pageKey);
                      }),
                  GoRoute(
                      path: 'forgot_password',
                      name: 'ForgotPassword',
                      builder: (context, state) {
                        return ForgotPasswordPage(key: state.pageKey);
                      }),
                ])
          ]),
        ]),
  ]);
}
