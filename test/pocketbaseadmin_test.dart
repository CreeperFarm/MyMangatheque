import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/pocketbaseadmin.dart';

void main() {
  test('buildMultipartFiles returns null when bytes or filename missing', () {
    final noBytes = PocketBaseAdminConnector.buildMultipartFiles(
      'image',
      'img.png',
      null,
    );
    expect(noBytes, isNull);

    final noName = PocketBaseAdminConnector.buildMultipartFiles('image', '', [
      1,
      2,
      3,
    ]);
    expect(noName, isNull);
  });

  test('buildMultipartFiles returns a MultipartFile with correct filename', () {
    final bytes = <int>[1, 2, 3, 4];
    final files = PocketBaseAdminConnector.buildMultipartFiles(
      'image',
      'avatar.png',
      bytes,
    );
    expect(files, isNotNull);
    expect(files!.length, 1);
    expect(files[0].filename, 'avatar.png');
  });
}
