import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// TODO: Make it work formally on Firestore
class GetUserProfilePicture extends StatelessWidget {
  final String documentId;

  const GetUserProfilePicture({required this.documentId, super.key});

  @override
  Widget build(BuildContext context) {

    // Get the collection
    CollectionReference users = FirebaseFirestore.instance.collection("users");

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(150.0),
              child: Image.network(
                "${data['imageUrl']}",
                height: 175,
                width: 175,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        return const Text("En chargement...");
      },
    );
  }
}
