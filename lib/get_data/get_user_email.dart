import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

// TODO: Make it work formally on Firestore
class GetUserEmail extends StatelessWidget {
  final String documentId;
  final String beforeText;

  const GetUserEmail({required this.documentId, required this.beforeText, super.key});


  // Get the collection
  await email = FirebaseDatabase.instance.ref("users/${documentId}/email").get();

  return Text("$beforeText$email");
  }
}
