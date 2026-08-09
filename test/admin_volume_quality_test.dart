import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';

void main() {
  group('AdminVolumeIssuePage', () {
    test('parses duplicate and zero tome issues with pagination', () {
      final page = AdminVolumeIssuePage.fromJson(<String, dynamic>{
        'status': 'success',
        'data': <String, dynamic>{
          'issues': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'issue-duplicate',
              'issueType': 'duplicate_tome_number',
              'status': 'open',
              'fingerprint': 'duplicate-hash',
              'subSeries': <String, dynamic>{
                'id': 'sub-series-1',
                'titleFr': 'Sous-série test',
              },
              'tomeNumber': 4,
              'volumes': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'volume-1',
                  'titleFr': 'Tome quatre A',
                  'tomeNumber': 4,
                  'ean': '1234567890123',
                },
                <String, dynamic>{
                  'id': 'volume-2',
                  'titleFr': 'Tome quatre B',
                  'tomeNumber': 4,
                  'ean': '3210987654321',
                },
              ],
              'isCurrentlyPresent': true,
            },
            <String, dynamic>{
              'id': 'issue-zero',
              'issueType': 'zero_tome_number',
              'status': 'resolved',
              'subSeriesId': 'sub-series-2',
              'tomeNumber': 0,
              'volumeIds': <String>['volume-3'],
              'resolutionNote': 'Numéro corrigé.',
            },
          ],
          'pagination': <String, dynamic>{
            'page': 2,
            'totalPages': 3,
            'totalItems': 102,
          },
        },
      });

      expect(page.page, 2);
      expect(page.totalPages, 3);
      expect(page.totalItems, 102);
      expect(page.issues, hasLength(2));

      final duplicate = page.issues.first;
      expect(duplicate.type, AdminVolumeIssueType.duplicateTomeNumber);
      expect(duplicate.status, AdminVolumeIssueStatus.open);
      expect(duplicate.subSeriesTitle, 'Sous-série test');
      expect(duplicate.volumes.map((volume) => volume.id), <String>[
        'volume-1',
        'volume-2',
      ]);

      final zero = page.issues.last;
      expect(zero.type, AdminVolumeIssueType.zeroTomeNumber);
      expect(zero.status, AdminVolumeIssueStatus.resolved);
      expect(zero.volumes.single.id, 'volume-3');
      expect(zero.resolutionNote, 'Numéro corrigé.');
    });
  });

  group('AdminUserPage', () {
    test('parses users and pagination', () {
      final page = AdminUserPage.fromJson(<String, dynamic>{
        'data': <String, dynamic>{
          'users': <Map<String, dynamic>>[
            <String, dynamic>{
              r'$id': 'user-1',
              'pseudo': 'MangaFan',
              'mail': 'fan@example.com',
              'role': 'admin',
              'coverURL': 'https://example.com/avatar.webp',
              r'$createdAt': '2026-08-08T08:00:00.000Z',
            },
          ],
          'pagination': <String, dynamic>{
            'page': 1,
            'totalPages': 4,
            'totalItems': 151,
          },
        },
      });

      expect(page.totalItems, 151);
      expect(page.totalPages, 4);
      expect(page.users.single.id, 'user-1');
      expect(page.users.single.pseudo, 'MangaFan');
      expect(page.users.single.email, 'fan@example.com');
      expect(page.users.single.role, 'admin');
      expect(page.users.single.createdAt, isNotNull);
    });
  });

  group('AdminRelationOption', () {
    test('describes a volume with tome, sub-series and resume', () {
      final option = AdminRelationOption.fromJson(
        AdminRelationResource.volumes,
        <String, dynamic>{
          'id': 'volume-42',
          'titleFr': 'Exemple',
          'tomeNumber': 4.5,
          'resume': 'Résumé du volume',
          'subSeries': <String, dynamic>{'titleFr': 'Édition principale'},
        },
      );

      expect(option.id, 'volume-42');
      expect(option.label, 'Exemple');
      expect(option.detail, contains('Tome 4.5'));
      expect(option.detail, contains('Édition principale'));
      expect(option.detail, contains('Résumé du volume'));
    });
  });
}
