import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/front/page/auth/delete_account_page.dart';
import 'package:mymangatheque/src/front/page/auth/signin_page.dart';
import 'package:mymangatheque/src/front/page/profile/profile_page.dart';

class RedirectToProfile extends StatelessWidget {
  const RedirectToProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: AppwriteConnector().listenToUserChanges(),
        builder: (context, snapshot) {
          RuntimeLocalization.debug(
            en: 'Profile authentication state changed.',
            fr: 'L’état d’authentification du profil a changé.',
          );
          //user is logged in
          if (AppwriteConnector().isLoggedIn()) {
            return const ProfilePage();
          }
          //user is NOT logged in
          else {
            return const SignInPage();
          }
        },
      ),
    );
  }
}

class RedirectToDelete extends StatelessWidget {
  const RedirectToDelete({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: AppwriteConnector().listenToUserChanges(),
        builder: (context, snapshot) {
          RuntimeLocalization.debug(
            en: 'Admin authentication state changed.',
            fr: 'L’état d’authentification administrateur a changé.',
          );
          //user is logged in
          if (AppwriteConnector().isLoggedIn()) {
            return const DeleteAccountPage();
          }
          //user is NOT logged in
          else {
            return const SignInPage();
          }
        },
      ),
    );
  }
}
