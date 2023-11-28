import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// TODO: Make it work formally on Firestore
class GetUserPseudo extends StatelessWidget {
  final String documentId;
  final String beforeText;

  const GetUserPseudo({required this.documentId, required this.beforeText, super.key});

  @override
  Widget build(BuildContext context) {

    // Get the collection
    CollectionReference users = FirebaseFirestore.instance.collection("users");

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Text("$beforeText${data['pseudo']}");
        }
        return const Text("En chargement...");
      },
    );
  }
}
