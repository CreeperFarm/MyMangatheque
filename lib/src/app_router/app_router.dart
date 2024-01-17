import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/main.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final rootNaveKey = GlobalKey<NavigatorState>(debugLabel: 'rootnav');
  final listenable = ref.watch(appRouterListenablePro)
  return GoRouter(
    initialLocation: '/',
      navigatorKey: rootNaveKey,
      refreshListenable: ,
      redirect: (context, state) => appRouteRedirect(context, ref, state),
      routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(title: 'title');
    )
  ]);
});
