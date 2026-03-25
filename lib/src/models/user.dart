import 'package:mymangatheque/src/models/file.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String gender;
  final PocketBaseFile? avatar;
  final DateTime birthday;
  final DateTime created;
  final DateTime updated;

  User.fromJSON(
    this.id,
    String collectionId,
    Map<String, dynamic> json,
    String created,
    String updated,
    String birthday,
  ) : username = json['username'],
      email = json['email'],
      gender = json['gender'],
      avatar = json['avatar'] != null
          ? PocketBaseFile(
              id: id,
              collectionId: collectionId,
              fileName: json['avatar'],
            )
          : null,
      created = DateTime.parse(created),
      updated = DateTime.parse(updated),
      birthday = DateTime.parse(birthday);
}
