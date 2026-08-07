class SafeExpandReader {
  const SafeExpandReader._();

  static Map<String, dynamic> asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  static List<Map<String, dynamic>> asMapList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value.whereType<Map<String, dynamic>>().toList();
  }

  static Map<String, dynamic> firstMap(List<dynamic> candidates) {
    for (final candidate in candidates) {
      final map = asMap(candidate);
      if (map.isNotEmpty) return map;
    }
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> firstMapList(List<dynamic> candidates) {
    for (final candidate in candidates) {
      final list = asMapList(candidate);
      if (list.isNotEmpty) return list;
    }
    return <Map<String, dynamic>>[];
  }
}
