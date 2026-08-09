import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';

void main() {
  group('AdminInputValidator', () {
    test('normalise les textes requis et optionnels', () {
      expect(
        AdminInputValidator.requiredText('  Titre  ', label: 'Titre'),
        'Titre',
      );
      expect(
        AdminInputValidator.optionalText('   ', label: 'Résumé'),
        isNull,
      );
      expect(
        () => AdminInputValidator.requiredText('\u0000', label: 'Titre'),
        throwsA(isA<AdminInputException>()),
      );
    });

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
      expect(
        () => AdminInputValidator.httpsUrl(
          'https:///cover.webp',
          label: 'Image',
        ),
        throwsA(isA<AdminInputException>()),
      );
    });

    test('déduplique les URLs et applique la limite de liste', () {
      expect(
        AdminInputValidator.httpsUrlList(
          const <String>[
            'https://example.com/a',
            'https://example.com/a',
            '',
          ],
          label: 'Liens',
        ),
        const <String>['https://example.com/a'],
      );
      expect(
        () => AdminInputValidator.httpsUrlList(
          const <String>['https://example.com/a', 'https://example.com/b'],
          label: 'Liens',
          maxItems: 1,
        ),
        throwsA(isA<AdminInputException>()),
      );
    });

    test('accepte les identifiants de relation documentés', () {
      for (final id in <String>['volume-1', 'series_2', 'a.b:c']) {
        expect(AdminInputValidator.relationId(id, label: 'ID'), id);
      }
      for (final id in <String>['/absolute', '%2e%2e', 'with space']) {
        expect(
          () => AdminInputValidator.relationId(id, label: 'ID'),
          throwsA(isA<AdminInputException>()),
        );
      }
    });

    test('vérifie la clé de contrôle EAN-13', () {
      expect(AdminInputValidator.ean13(9780306406157), 9780306406157);
      expect(
        () => AdminInputValidator.ean13(9780306406158),
        throwsA(isA<AdminInputException>()),
      );
      expect(AdminInputValidator.ean13(0), 0);
      expect(
        () => AdminInputValidator.ean13(10000000000000),
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
      expect(
        () => AdminInputValidator.metadata(<String, String>{
          for (var index = 0; index < 51; index++) 'key$index': 'value',
        }),
        throwsA(isA<AdminInputException>()),
      );
    });

    test('refuse les budgets négatifs ou non finis', () {
      expect(
        AdminInputValidator.nonNegativeNumber(25.50, label: 'Budget'),
        25.50,
      );
      expect(
        () => AdminInputValidator.nonNegativeNumber(-1, label: 'Budget'),
        throwsA(isA<AdminInputException>()),
      );
      expect(
        () => AdminInputValidator.nonNegativeNumber(
          double.infinity,
          label: 'Budget',
        ),
        throwsA(isA<AdminInputException>()),
      );
    });

    test('convertit les montants en centimes sans perte', () {
      expect(
        AdminInputValidator.moneyInMinorUnits(12.34, label: 'Budget'),
        1234,
      );
      expect(
        () => AdminInputValidator.moneyInMinorUnits(
          12.345,
          label: 'Budget',
        ),
        throwsA(isA<AdminInputException>()),
      );
    });

    test('localise chaque ressource de relation', () {
      final expected = <AdminRelationResource, List<String>>{
        AdminRelationResource.volumes: <String>['Volume', 'Volume'],
        AdminRelationResource.subSeries: <String>['Sub-series', 'Sous-série'],
        AdminRelationResource.series: <String>['Series', 'Série'],
        AdminRelationResource.authors: <String>['Author', 'Auteur'],
        AdminRelationResource.editors: <String>['Publisher', 'Éditeur'],
        AdminRelationResource.genres: <String>['Genre', 'Genre'],
      };

      for (final entry in expected.entries) {
        expect(entry.key.localizedLabel('en'), entry.value[0]);
        expect(entry.key.localizedLabel('fr-FR'), entry.value[1]);
      }
    });

    test('produit un libellé de recherche de volume riche et borné', () {
      final option = AdminRelationOption.fromJson(
        AdminRelationResource.volumes,
        <String, dynamic>{
          r'$id': 'volume-1',
          'titleFr': 'Titre',
          'tome_number': 2.5,
          'sub_series': <String, dynamic>{'title': 'Sous-série'},
          'summary': List<String>.filled(100, 'x').join(),
        },
      );

      expect(option.id, 'volume-1');
      expect(option.label, 'Titre');
      expect(option.detail, startsWith('Tome 2.5 · Sous-série · '));
      expect(option.detail, endsWith('…'));
    });
  });
}
