import 'package:firebase_database/firebase_database.dart';

class GetUserInformation {

  static Future<String> getUserCreationDate(useruid, beforeText) async {

    final snapshot = await FirebaseDatabase.instance.ref('users/$useruid/createdOn').get();
      if (snapshot.exists) {
        print(snapshot.value);
        final value = beforeText + snapshot.value;
        value.toString();
        return value;
      } else {
        print('No data available.');
        return("An error as occurred");
      }
  }

  static Future<String> getUserEmail(useruid, beforeText) async {

    final snapshot = await FirebaseDatabase.instance.ref('users/$useruid/email').get();
    if (snapshot.exists) {
      print(snapshot.value);
      final value = beforeText + snapshot.value;
      value.toString();
      return value;
    } else {
      print('No data available.');
      return("An error as occurred");
    }
  }

  static Future<String> getUserProfilePicture(useruid) async {

    final snapshot = await FirebaseDatabase.instance.ref('users/$useruid/imageUrl').get();
    if (snapshot.exists) {
      print(snapshot.value);
      final values = snapshot.value.toString();
      return values;
    } else {
      print('No data available.');
      return("An error as occurred");
    }
  }

  static Future<String> getUserPseudo(useruid, beforeText) async {

    final snapshot = await FirebaseDatabase.instance.ref('users/$useruid/pseudo').get();
    if (snapshot.exists) {
      print(snapshot.value);
      final value = beforeText + snapshot.value;
      value.toString();
      return value;
    } else {
      print('No data available.');
      return("An error as occurred");
    }
  }

}