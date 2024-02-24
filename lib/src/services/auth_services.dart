import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_date/dart_date.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {

  // Google Sign In
  signInWithGoogle() async {
    // Begin interactive sign in process
    final GoogleSignInAccount? gUser = await GoogleSignIn(
      forceCodeForRefreshToken: true,
    ).signIn();

    // Obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    // Create a new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // Finally, let's sign in
    await FirebaseAuth.instance.signInWithCredential(credential);

    // Add detail about user
    final user = FirebaseAuth.instance.currentUser!;

    final createdOnDay = user.metadata.creationTime!.format("dd");
    final createdOnMonthInt = user.metadata.creationTime!.format("MM");
    final createdOnYear = user.metadata.creationTime!.format("yyyy");
    Map month = {
      '01': 'Janvier',
      '02': 'Février',
      '03': 'Mars',
      '04': 'Avril',
      '05': 'Mai',
      '06': 'Juin',
      '07': 'Billet',
      '08': 'Août',
      '09': 'Septembre',
      '10': 'Octobre',
      '11': 'Novembre',
      '12': 'Décembre',
    };

    final userCollection = FirebaseFirestore.instance.collection("users");
    if (userCollection.doc(user.uid).get() == null) {
      userCollection.doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdOn': '$createdOnDay ${month[createdOnMonthInt]} $createdOnYear',
      });
    }

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

}