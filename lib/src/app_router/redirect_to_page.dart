import 'package:mymangatheque/src/page/profile/profile_page.dart';
import 'package:mymangatheque/src/page/library/library_page.dart';
import 'package:mymangatheque/src/page/auth/signin_page.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/material.dart';

class RedirectToProfile extends StatelessWidget {
  const RedirectToProfile({super.key});

  @override
  Widget build(BuildContext context) {

    final pb = PocketBase('https://api.mymangatheque.com', lang: 'fr-FR');

    return Scaffold(
      body: StreamBuilder(
        stream: pb.authStore.onChange,
        builder: (context, snapshot) {
          print('snapshot: ' + snapshot.toString());
          print(pb.authStore.isValid.toString() + ' redirect to profile');
          print(pb.authStore.token);
          //user is logged in
          if (pb.authStore.isValid) {
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

    final pb = PocketBase('https://api.mymangatheque.com', lang: 'fr-FR');

    return Scaffold(
      body: StreamBuilder(
        stream: pb.authStore.onChange,
        builder: (context, snapshot) {
          //user is logged in
          if (pb.authStore.isValid) {
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
