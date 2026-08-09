import 'dart:convert';

import 'package:mymangatheque/src/back/services/import/collection_import_models.dart';

class CollectionImportFormatException implements Exception {
  const CollectionImportFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CollectionImportParser {
  const CollectionImportParser();

  List<CollectionImportEntry> parse(
    CollectionImportSource source,
    String content,
  ) {
    final normalized = content.replaceFirst('\ufeff', '').trim();
    if (normalized.isEmpty) {
      throw const CollectionImportFormatException('The import is empty.');
    }
    return switch (source) {
      CollectionImportSource.csv => parseCsv(normalized),
      CollectionImportSource.json => parseJson(normalized),
      CollectionImportSource.ean => parseEanList(normalized),
      CollectionImportSource.text => parseText(normalized),
      CollectionImportSource.mangacollec =>
        throw const CollectionImportFormatException(
          'Mangacollec profiles must be loaded through the protected API.',
        ),
    };
  }

  List<CollectionImportEntry> parseJson(String content) {
    dynamic decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException {
      throw const CollectionImportFormatException('Invalid JSON document.');
    }

    dynamic rows = decoded;
    if (decoded is Map) {
      for (final key in const <String>[
        'volumes',
        'items',
        'collection',
        'mangas',
        'books',
        'data',
      ]) {
        if (decoded[key] is List) {
          rows = decoded[key];
          break;
        }
      }
      if (rows is Map && rows['data'] is Map) {
        final nested = rows['data'] as Map;
        for (final key in const <String>[
          'volumes',
          'items',
          'collection',
          'mangas',
          'books',
        ]) {
          if (nested[key] is List) {
            rows = nested[key];
            break;
          }
        }
      }
    }
    if (rows is! List) {
      throw const CollectionImportFormatException(
        'JSON must contain an array of volumes.',
      );
    }

    final entries = <CollectionImportEntry>[];
    for (var index = 0; index < rows.length; index += 1) {
      final row = rows[index];
      if (row is String) {
        entries.addAll(
          parseText(row).map(
            (entry) => CollectionImportEntry(
              sourceIndex: index + 1,
              title: entry.title,
              volumeNumber: entry.volumeNumber,
              ean: entry.ean,
              subSeries: entry.subSeries,
              read: entry.read,
            ),
          ),
        );
        continue;
      }
      if (row is! Map) continue;
      entries.add(_entryFromMap(row, index + 1));
    }
    return _requireUsable(entries);
  }

  List<CollectionImportEntry> parseCsv(String content) {
    final firstLine = content.split(RegExp(r'\r?\n')).first;
    final delimiter = _detectDelimiter(firstLine);
    final rows = _parseDelimited(
      content,
      delimiter,
    ).where((row) => row.any((cell) => cell.trim().isNotEmpty)).toList();
    if (rows.isEmpty) {
      throw const CollectionImportFormatException('The CSV file is empty.');
    }

    final headers = rows.first.map(_normalizeHeader).toList();
    final hasHeader = headers.any(_knownHeaders.contains);
    if (!hasHeader && rows.every((row) => row.length == 1)) {
      return parseEanList(rows.map((row) => row.first).join('\n'));
    }

    final entries = <CollectionImportEntry>[];
    final start = hasHeader ? 1 : 0;
    for (var index = start; index < rows.length; index += 1) {
      final row = rows[index];
      final map = <String, dynamic>{};
      for (var column = 0; column < row.length; column += 1) {
        final header = hasHeader && column < headers.length
            ? headers[column]
            : switch (column) {
                0 => 'title',
                1 => 'volume',
                2 => 'ean',
                _ => 'column$column',
              };
        map[header] = row[column];
      }
      entries.add(_entryFromMap(map, index + 1));
    }
    return _requireUsable(entries);
  }

  List<CollectionImportEntry> parseEanList(String content) {
    final tokens = content
        .split(RegExp(r'[\s,;]+'))
        .map(normalizeEan)
        .where((value) => value.isNotEmpty)
        .toList();
    final entries = <CollectionImportEntry>[];
    for (var index = 0; index < tokens.length; index += 1) {
      entries.add(
        CollectionImportEntry(sourceIndex: index + 1, ean: tokens[index]),
      );
    }
    return _requireUsable(entries);
  }

  List<CollectionImportEntry> parseText(String content) {
    final entries = <CollectionImportEntry>[];
    final lines = content
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);
    for (final line in lines) {
      final ean = normalizeEan(line);
      if (_looksLikeEan(line, ean)) {
        entries.add(
          CollectionImportEntry(sourceIndex: entries.length + 1, ean: ean),
        );
        continue;
      }

      final range = RegExp(
        r'^(.*?)\s*(?:[-–—,:]\s*)?(?:tome|volume|vol\.?|t\.?)\s*(\d+(?:[.,]\d+)?)\s*(?:à|a|au|to|[-–—])\s*(\d+(?:[.,]\d+)?)$',
        caseSensitive: false,
      ).firstMatch(line);
      if (range != null) {
        final title = range.group(1)!.trim();
        final start = int.tryParse(
          range.group(2)!.split(RegExp(r'[.,]')).first,
        );
        final end = int.tryParse(range.group(3)!.split(RegExp(r'[.,]')).first);
        if (title.isNotEmpty &&
            start != null &&
            end != null &&
            end >= start &&
            end - start <= 500) {
          for (var number = start; number <= end; number += 1) {
            entries.add(
              CollectionImportEntry(
                sourceIndex: entries.length + 1,
                title: title,
                volumeNumber: number,
              ),
            );
          }
          continue;
        }
      }

      final single = RegExp(
        r'^(.*?)\s*(?:[-–—,:]\s*)?(?:tome|volume|vol\.?|t\.?)\s*(\d+(?:[.,]\d+)?)$',
        caseSensitive: false,
      ).firstMatch(line);
      entries.add(
        CollectionImportEntry(
          sourceIndex: entries.length + 1,
          title: (single?.group(1) ?? line).trim(),
          volumeNumber: _parseNumber(single?.group(2)),
        ),
      );
    }
    return _requireUsable(entries);
  }

  CollectionImportEntry _entryFromMap(Map<dynamic, dynamic> row, int index) {
    final normalized = <String, dynamic>{
      for (final entry in row.entries)
        _normalizeHeader(entry.key.toString()): entry.value,
    };
    dynamic first(Iterable<String> keys) {
      for (final key in keys) {
        final value = normalized[key];
        if (value != null && value.toString().trim().isNotEmpty) return value;
      }
      return null;
    }

    return CollectionImportEntry(
      sourceIndex: index,
      title:
          first(const [
            'title',
            'titre',
            'name',
            'nom',
            'serie',
          ])?.toString().trim() ??
          '',
      volumeNumber: _parseNumber(
        first(const [
          'volume',
          'tome',
          'tomenumber',
          'volumenumber',
          'number',
          'numero',
        ]),
      ),
      ean: normalizeEan(
        first(const [
              'ean',
              'isbn',
              'isbn10',
              'isbn13',
              'barcode',
              'code',
            ])?.toString() ??
            '',
      ),
      subSeries:
          first(const [
            'subseries',
            'sousserie',
            'edition',
          ])?.toString().trim() ??
          '',
      read: _parseBool(first(const ['read', 'readed', 'lu', 'lue'])) ?? false,
    );
  }

  List<CollectionImportEntry> _requireUsable(
    List<CollectionImportEntry> entries,
  ) {
    final usable = entries.where((entry) => entry.hasLookupData).toList();
    if (usable.isEmpty) {
      throw const CollectionImportFormatException(
        'No title, EAN or ISBN could be read from the import.',
      );
    }
    if (usable.length > 10000) {
      throw const CollectionImportFormatException(
        'A single import cannot contain more than 10,000 volumes.',
      );
    }
    return usable;
  }

  String normalizeEan(String value) {
    final normalized = value.toUpperCase().replaceAll(
      RegExp(r'[^0-9X]'),
      '',
    );
    if (normalized.length == 10 && normalized.endsWith('X')) return normalized;
    return normalized.replaceAll('X', '');
  }

  bool _looksLikeEan(String original, String normalized) {
    if (!RegExp(r'^[\d\s-]+[\dXx]$').hasMatch(original.trim())) return false;
    return const <int>{8, 10, 12, 13}.contains(normalized.length);
  }

  String _detectDelimiter(String line) {
    final counts = <String, int>{
      ',': ','.allMatches(line).length,
      ';': ';'.allMatches(line).length,
      '\t': '\t'.allMatches(line).length,
    };
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  List<List<String>> _parseDelimited(String content, String delimiter) {
    final rows = <List<String>>[];
    var row = <String>[];
    var cell = StringBuffer();
    var quoted = false;
    for (var index = 0; index < content.length; index += 1) {
      final character = content[index];
      if (character == '"') {
        if (quoted && index + 1 < content.length && content[index + 1] == '"') {
          cell.write('"');
          index += 1;
        } else {
          quoted = !quoted;
        }
      } else if (!quoted && character == delimiter) {
        row.add(cell.toString().trim());
        cell = StringBuffer();
      } else if (!quoted && (character == '\n' || character == '\r')) {
        if (character == '\r' &&
            index + 1 < content.length &&
            content[index + 1] == '\n') {
          index += 1;
        }
        row.add(cell.toString().trim());
        rows.add(row);
        row = <String>[];
        cell = StringBuffer();
      } else {
        cell.write(character);
      }
    }
    row.add(cell.toString().trim());
    rows.add(row);
    return rows;
  }

  String _normalizeHeader(String value) {
    var result = value.toLowerCase().trim();
    const replacements = <String, String>{
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'ç': 'c',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'ô': 'o',
      'ö': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
    };
    replacements.forEach((key, replacement) {
      result = result.replaceAll(key, replacement);
    });
    return result.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  num? _parseNumber(dynamic value) {
    if (value is num) return value;
    final parsed = num.tryParse(
      (value?.toString() ?? '').trim().replaceAll(',', '.'),
    );
    return parsed;
  }

  bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return switch ((value?.toString() ?? '').trim().toLowerCase()) {
      'true' || 'yes' || 'oui' || '1' || 'lu' || 'lue' => true,
      'false' || 'no' || 'non' || '0' || 'non lu' || 'non lue' => false,
      _ => null,
    };
  }

  static const Set<String> _knownHeaders = <String>{
    'title',
    'titre',
    'name',
    'nom',
    'serie',
    'volume',
    'tome',
    'tomenumber',
    'volumenumber',
    'ean',
    'isbn',
    'isbn10',
    'isbn13',
    'barcode',
    'code',
  };
}
