import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('scan previous volumes suggestion preference', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('is enabled by default', () async {
      expect(
        await LocalStorage().getScanPreviousVolumesSuggestionEnabled(),
        isTrue,
      );
    });

    test('persists disable and re-enable choices', () async {
      final storage = LocalStorage();

      await storage.setScanPreviousVolumesSuggestionEnabled(false);
      expect(await storage.getScanPreviousVolumesSuggestionEnabled(), isFalse);

      await storage.setScanPreviousVolumesSuggestionEnabled(true);
      expect(await storage.getScanPreviousVolumesSuggestionEnabled(), isTrue);
    });
  });
}
