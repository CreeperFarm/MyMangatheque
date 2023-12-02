import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetUserCreationDate extends StatelessWidget {
  final String documentId;
  final String beforeText;

  const GetUserCreationDate({required this.documentId, required this.beforeText, super.key});

  @override
  Widget build(BuildContext context) {

    // Get the collection
    CollectionReference users = FirebaseFirestore.instance.collection("users");

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Text("$beforeText${data['createdOn']}");
        }
        return const Text("En chargement...");
      },
    );
  }
}

class GetUserEmail extends StatelessWidget {
  final String documentId;
  final String beforeText;

  const GetUserEmail({required this.documentId, required this.beforeText, super.key});

  @override
  Widget build(BuildContext context) {

    // Get the collection
    CollectionReference users = FirebaseFirestore.instance.collection("users");

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Text("$beforeText${data['email']}");
        }
        return const Text("En chargement...");
      },
    );
  }
}

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
