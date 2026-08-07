import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';

void main() {
  group('followed sub-series relation parsing', () {
    final connector = AppwriteConnector();

    test('reads a direct relation id', () {
      expect(
        connector.followedEntrySubSeriesIdForTesting(
          <String, dynamic>{'subSeriesId': 'sub-series-1'},
        ),
        'sub-series-1',
      );
    });

    test('reads an expanded relation object', () {
      expect(
        connector.followedEntrySubSeriesIdForTesting(<String, dynamic>{
          'subSeries': <String, dynamic>{r'$id': 'sub-series-2'},
        }),
        'sub-series-2',
      );
    });

    test('reads alternate relation names nested in expand', () {
      expect(
        connector.followedEntrySubSeriesIdForTesting(<String, dynamic>{
          'expand': <String, dynamic>{
            'sub_serie': <String, dynamic>{'id': 'sub-series-3'},
          },
        }),
        'sub-series-3',
      );
    });
  });
}
