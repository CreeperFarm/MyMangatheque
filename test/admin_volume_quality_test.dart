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
}
