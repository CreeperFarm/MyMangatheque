import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/front/page/auth/delete_account_page.dart';
import 'package:mymangatheque/src/front/page/auth/signin_page.dart';
import 'package:mymangatheque/src/front/page/profile/profile_page.dart';

class RedirectToProfile extends StatelessWidget {
  const RedirectToProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: PocketBaseConnector().listenToUserChanges(),
        builder: (context, snapshot) {
          print('snapshot: $snapshot');
          //user is logged in
          if (PocketBaseConnector().isLoggedIn()) {
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
        stream: PocketBaseConnector().listenToUserChanges(),
        builder: (context, snapshot) {
          print('snapshot: $snapshot');
          //user is logged in
          if (PocketBaseConnector().isLoggedIn()) {
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
