import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';

void main() {
  group('AdminInputValidator', () {
    test('normalise et déduplique les listes', () {
      expect(
        AdminInputValidator.textList(
          const <String>[' auteur-1 ', 'auteur-1', '', 'auteur-2'],
          label: 'Auteurs',
          relationIds: true,
        ),
        const <String>['auteur-1', 'auteur-2'],
      );
    });

    test('refuse les identifiants injectés dans un chemin', () {
      expect(
        () => AdminInputValidator.relationId(
          '../autre-ressource',
          label: 'Relation',
        ),
        throwsA(isA<AdminInputException>()),
      );
    });

    test('accepte uniquement les URLs HTTPS sans identifiants', () {
      expect(
        AdminInputValidator.httpsUrl(
          'https://cdn.example.com/cover.webp',
          label: 'Image',
        ),
        'https://cdn.example.com/cover.webp',
      );
      expect(
        () => AdminInputValidator.httpsUrl(
          'http://example.com/cover.webp',
          label: 'Image',
        ),
        throwsA(isA<AdminInputException>()),
      );
      expect(
        () => AdminInputValidator.httpsUrl(
          'https://user:secret@example.com/cover.webp',
          label: 'Image',
        ),
        throwsA(isA<AdminInputException>()),
      );
    });

    test('vérifie la clé de contrôle EAN-13', () {
      expect(AdminInputValidator.ean13(9780306406157), 9780306406157);
      expect(
        () => AdminInputValidator.ean13(9780306406158),
        throwsA(isA<AdminInputException>()),
      );
    });

    test('refuse les charges textuelles trop longues', () {
      expect(
        () => AdminInputValidator.requiredText(
          List<String>.filled(201, 'x').join(),
          label: 'Titre',
          maxLength: 200,
        ),
        throwsA(isA<AdminInputException>()),
      );
    });

    test('valide les métadonnées structurées', () {
      expect(
        AdminInputValidator.metadata(const <String, String>{
          'nombre de pages': '192',
          'format': 'Tankōbon',
        }),
        const <String, String>{
          'nombre de pages': '192',
          'format': 'Tankōbon',
        },
      );
      expect(
        () => AdminInputValidator.metadata(
          const <String, String>{'<script>': 'interdit'},
        ),
        throwsA(isA<AdminInputException>()),
      );
    });
  });
}
