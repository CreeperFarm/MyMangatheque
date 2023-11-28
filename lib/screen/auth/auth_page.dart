import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mymangatheque/main.dart';
import 'package:mymangatheque/screen/auth/profile_page.dart';
import 'package:mymangatheque/screen/auth/signin_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user is logged in
          if (snapshot.hasData) {
            return const MyHomePage(title: "Acceuil");
          }

          //user is NOT logged in
          else {
            return const SignInPage(pageBefore: false);
          }
        },
      ),
    );
  }
}

class AuthPageToProfile extends StatelessWidget {
  const AuthPageToProfile({super.key});

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
            return const SignInPage(pageBefore: false);
          }
        },
      ),
    );
  }
}
