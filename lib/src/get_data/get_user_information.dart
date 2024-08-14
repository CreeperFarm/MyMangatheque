import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mymangatheque/src/services/pocketbase.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:path/path.dart';

class GetUserInfo extends StatelessWidget {
  final String beforeText;
  final String dataWanted;
  final String afterText;

  const GetUserInfo(
      {required this.beforeText, required this.dataWanted, required this.afterText, super.key});

  @override
  Widget build(BuildContext context) {

    final pb = PocketBase('https://api.mymangatheque.com', lang: "fr-FR");

    return FutureBuilder(
      future: pb.collection('users').getOne(pb.authStore.model.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          print(snapshot.data);
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(beforeText),
              Text(snapshot.data.toString()/*[dataWanted]*/ + afterText),
            ],
          );
        }
        return const Text("En chargement...");
      },
    );
  }
}

class GetUserProfilePicture extends StatelessWidget {
  final PocketBaseFile file;

  const GetUserProfilePicture({required this.file, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    PocketBaseConnector connector = PocketBaseConnector();
    User? user = connector.getConnectedUser();

    if (user?.avatar == null || user?.avatar?.path == null) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(150.0),
          child: Image.asset(
            'assets/images/unknown.webp',
            height: 175,
            width: 175,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(150.0),
          child: Image.network(
            join(PocketBaseConnector().serverUrl, user!.avatar!.path),
            height: 175,
            width: 175,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }
}