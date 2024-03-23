import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mymangatheque/src/screen/profile/profile_page.dart';
import 'package:mymangatheque/src/screen/auth/signin_page.dart';

class RedirectToProfile extends StatelessWidget {
  const RedirectToProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user is logged in
          if (snapshot.hasData) {
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
