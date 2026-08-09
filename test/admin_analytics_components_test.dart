import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_analytics_components.dart';

void main() {
  group('admin analytics parsing', () {
    test('unwraps the API data object and resolves nested values', () {
      final data = adminAnalyticsData(<String, dynamic>{
        'status': 'success',
        'data': <String, dynamic>{
          'activity': <String, dynamic>{'activeUsers': 42},
        },
      });

      expect(
        adminAnalyticsNumber(data, const ['activity.activeUsers']),
        42,
      );
    });

    test('parses numeric breakdowns and ignores invalid values', () {
      final values = adminAnalyticsNumericMap(
        <String, dynamic>{
          'platforms': <String, dynamic>{
            'web': 12,
            'ios': '8',
            'unknown': 'not-a-number',
          },
        },
        const ['platforms'],
      );

      expect(values, <String, num>{'web': 12, 'ios': 8});
    });

    test('parses campaign records from a nested response', () {
      final records = adminAnalyticsRecords(
        <String, dynamic>{
          'notifications': <String, dynamic>{
            'campaigns': <Map<String, dynamic>>[
              <String, dynamic>{'id': 'campaign-1', 'opened': 20},
            ],
          },
        },
        const ['notifications.campaigns'],
      );

      expect(records.single['id'], 'campaign-1');
      expect(records.single['opened'], 20);
    });

    test('reads supported previous-period envelopes', () {
      expect(
        adminAnalyticsPrevious(<String, dynamic>{
          'comparison': <String, dynamic>{
            'previous': <String, dynamic>{'events': 12},
          },
        })['events'],
        12,
      );
      expect(
        adminAnalyticsPrevious(<String, dynamic>{
          'previousPeriod': <String, dynamic>{'events': 8},
        })['events'],
        8,
      );
    });

    testWidgets('formats positive, stable and new trends', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (value) {
              context = value;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(adminAnalyticsTrend(context, 12, 10), contains('+20.0'));
      expect(adminAnalyticsTrend(context, 0, 0), isNotEmpty);
      expect(adminAnalyticsTrend(context, 4, 0), isNotEmpty);
      expect(adminAnalyticsTrend(context, 4, null), isNull);
    });
  });
}
