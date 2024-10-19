import 'package:mymangatheque/src/services/models/file.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String gender;
  final PocketBaseFile? avatar;
  final DateTime? birthday;
  final DateTime? created;
  final DateTime? updated;

  User.fromJSON(this.id, String collectionId, Map<dynamic, dynamic> json)
      : username = json['username'],
        email = json['email'],
        gender = json['gender'],
        avatar = json['avatar'] != null ? PocketBaseFile(id: id, collectionId: collectionId, fileName: json['avatar']) : null,
        created = json['created'] != null ? DateTime.parse(json['created']) : null,
        updated = json['updated'] != null ? DateTime.parse(json['updated']) : null,
        birthday = json['birthday'] != null ? DateTime.parse(json['birthday']) : null;
}
