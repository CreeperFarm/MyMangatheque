import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';

class AuthServices {

  final pb = PocketBase('https://api.mymangatheque.com', lang: "fr-FR");

  // Google Sign In
  /*signInWithGoogle() async {
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

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }*/

  signInWithGoogle(context) async {
    final authData = await pb.collection('users').authWithOAuth2(
        'google',
            (url) async {
          await launchUrl(url);
        },
        scopes: [
          'email',
          'profile',
          'https://www.googleapis.com/auth/user.gender.read',
          'https://www.googleapis.com/auth/user.birthday.read'
        ],
        createData: {
          "role": "user",
          "emailVisibility": true,
          "gender": "other",

        }
    );

    print(authData);
    dynamic authData2 = json.decode(authData.toString());
    print(authData2['meta']);
    print(authData2['meta']['isNew']);

    if (authData2['meta']['isNew']) {
      var data = authData2['meta']['rawUser'];
      print('The email is ' + data['email']);
      print('The link is ' + data['picture']);
      try {
        var imageId = await ImageDownloader.downloadImage(data['picture']);
        if (imageId == null) {
          return;
        }
        var fileName = await ImageDownloader.findName(imageId);
        var path = await ImageDownloader.findPath(imageId);

        var body = <String, dynamic>{
          "email": data['email'],
        };

        // Upload the image of the user
        var sendImg = await pb.collection('users').update(
            pb.authStore.model.id,
            body: body,
            files: [
              http.MultipartFile.fromBytes(
                'avatar',
                File(path!).readAsBytesSync(),
                filename: fileName,
              )
            ]
        );
        print(sendImg);
      } on PlatformException catch (e) {
        print(e);
        showMessage("Un erreur s'est déroullé", context);
      }
    } else {
      print('User already exists');
    }
    closeInAppWebView();
  }

}