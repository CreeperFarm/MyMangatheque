import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_management_page.dart';

void main() {
  group('admin management', () {
    test('exposes one unique route for every management section', () {
      final slugs = AdminManagementSection.values
          .map((section) => section.slug)
          .toList();

      expect(slugs.toSet(), hasLength(slugs.length));
      expect(
        slugs,
        containsAll(const <String>[
          'sponsorship',
          'editorial',
          'revenue',
          'catalog-quality',
          'moderation',
          'operations',
          'audit',
        ]),
      );
    });

    test('parses suspended users returned by the moderation API', () {
      final user = AdminUser.fromJson(const <String, dynamic>{
        'id': 'user-1',
        'pseudo': 'Lectrice',
        'mail': 'reader@example.test',
        'role': 'moderator',
        'isSuspended': true,
      });

      expect(user.id, 'user-1');
      expect(user.role, 'moderator');
      expect(user.suspended, isTrue);
    });

    test('defaults missing suspension state to false', () {
      final user = AdminUser.fromJson(const <String, dynamic>{
        'id': 'user-2',
        'pseudo': 'Lecteur',
      });

      expect(user.suspended, isFalse);
    });
  });
}
