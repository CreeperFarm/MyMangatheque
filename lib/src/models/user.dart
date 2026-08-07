import 'package:mymangatheque/src/models/file.dart';

class User {
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.gender,
    required this.avatar,
    required this.birthday,
    required this.created,
    required this.updated,
  });

  final String id;
  final String username;
  final String email;
  final String gender;
  final AppwriteFile? avatar;
  final DateTime birthday;
  final DateTime created;
  final DateTime updated;

  factory User.fromApiJson(Map<String, dynamic> json) {
    final now = DateTime.now().toUtc();

    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value == null) return fallback;
      return DateTime.tryParse(value.toString())?.toUtc() ?? fallback;
    }

    final avatarUrl = json['coverURL']?.toString();

    return User(
      id: (json['id'] ?? '').toString(),
      username: (json['pseudo'] ?? json['username'] ?? '').toString(),
      email: (json['mail'] ?? json['email'] ?? '').toString(),
      gender: (json['gender'] ?? 'other').toString(),
      avatar: (avatarUrl != null && avatarUrl.isNotEmpty)
          ? AppwriteFile.fromUrl(avatarUrl)
          : null,
      birthday: parseDate(json['birthday'], now),
      created: parseDate(json['created'] ?? json[r'$createdAt'], now),
      updated: parseDate(json['updated'] ?? json[r'$updatedAt'], now),
    );
  }
}
