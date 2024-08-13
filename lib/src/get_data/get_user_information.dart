import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

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
  const GetUserProfilePicture({super.key});

  @override
  Widget build(BuildContext context) {

    final pb = PocketBase('https://api.mymangatheque.com', lang: "fr-FR");

    return FutureBuilder(
      future: pb.collection('users').getOne(pb.authStore.model.id), // Get the user collection
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {

          // Retrieve the file name and the image url
          final fileName = snapshot.data!.getListValue<String>('avatar')[0];
          final url = pb.files.getUrl(snapshot.data!, fileName);

          return Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(150.0),
              child: Image.network(
                url.toString(),
                height: 175,
                width: 175,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}