import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/models/file.dart';
import 'package:mymangatheque/src/models/user.dart';

void main() {
  test('User parses current and legacy API field names', () {
    final user = User.fromApiJson(<String, dynamic>{
      'id': 'user-1',
      'pseudo': 'Reader',
      'mail': 'reader@example.com',
      'gender': 'other',
      'coverURL': 'https://cdn.example/avatar.webp',
      'birthday': '2000-01-02T00:00:00+02:00',
      r'$createdAt': '2026-01-01T10:00:00Z',
      r'$updatedAt': '2026-02-01T10:00:00Z',
    });

    expect(user.id, 'user-1');
    expect(user.username, 'Reader');
    expect(user.email, 'reader@example.com');
    expect(user.avatar?.url, 'https://cdn.example/avatar.webp');
    expect(user.birthday.isUtc, isTrue);
    expect(user.created, DateTime.utc(2026, 1, 1, 10));
    expect(user.updated, DateTime.utc(2026, 2, 1, 10));
  });

  test('User applies safe defaults to incomplete API responses', () {
    final before = DateTime.now().toUtc();
    final user = User.fromApiJson(<String, dynamic>{
      'username': 'Fallback',
      'email': 'fallback@example.com',
      'birthday': 'invalid',
    });
    final after = DateTime.now().toUtc();

    expect(user.id, isEmpty);
    expect(user.username, 'Fallback');
    expect(user.email, 'fallback@example.com');
    expect(user.gender, 'other');
    expect(user.avatar, isNull);
    expect(
      !user.birthday.isBefore(before) && !user.birthday.isAfter(after),
      isTrue,
    );
  });

  test('AppwriteFile handles null URLs and compares files by URL', () {
    final empty = AppwriteFile.fromUrl(null);
    final first = AppwriteFile.fromUrl('https://cdn.example/avatar.webp');
    final same = AppwriteFile(
      url: 'https://cdn.example/avatar.webp',
      id: 'different-metadata',
    );

    expect(empty.url, isEmpty);
    expect(first.path, first.url);
    expect(first, same);
    expect(first.hashCode, same.hashCode);
  });
}
