import 'package:mymangatheque/src/page/auth/delete_account_page.dart';
import 'package:mymangatheque/src/page/profile/profile_page.dart';
import 'package:mymangatheque/src/page/library/library_page.dart';
import 'package:mymangatheque/src/page/auth/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:mymangatheque/src/services/pocketbase.dart';

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

class RedirectToLibrary extends StatelessWidget {
  const RedirectToLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: PocketBaseConnector().listenToUserChanges(),
        builder: (context, snapshot) {
          print('snapshot: $snapshot');
          //user is logged in
          if (PocketBaseConnector().isLoggedIn()) {
            return const LibraryPage();
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
