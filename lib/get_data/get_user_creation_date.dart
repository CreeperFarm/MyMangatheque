import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class GetUserInformation {

  final user = FirebaseAuth.instance.currentUser!;

  getUserCreationDate() async {
    final snapshot = await FirebaseDatabase.instance.ref('users/${user.uid}/email').get();
    if (snapshot.exists) {
      print(snapshot.value);
      return snapshot.value;
    } else {
      print('No data available.');
      return("An error as occurred");
    }
  }

}