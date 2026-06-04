import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:mymangatheque/src/models/local_storage/service_locator.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';

class MangaOwnedNotifier extends Notifier<Set<SubSerieForCollection>> {
  @override
  Set<SubSerieForCollection> build() => <SubSerieForCollection>{};

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) {
    return value is List<dynamic> ? value : const <dynamic>[];
  }

  List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) {
            if (item is Map) {
              return (item['name'] ?? item['id'] ?? '').toString();
            }
            return item.toString();
          })
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    if (value == null) return <String>[];
    final stringValue = value.toString().trim();
    return stringValue.isEmpty ? <String>[] : <String>[stringValue];
  }

  Map<String, dynamic> _firstMap(dynamic value) {
    final direct = _asMap(value);
    if (direct.isNotEmpty) return direct;

    if (value is List) {
      for (final item in value) {
        final map = _asMap(item);
        if (map.isNotEmpty) return map;
      }
    }

    return <String, dynamic>{};
  }

  int _volumeCount(Map<String, dynamic> subSeries) {
    final volumes = _asList(subSeries['volumes']);
    if (volumes.isNotEmpty) return volumes.length;

    final candidates = <dynamic>[
      subSeries['numberOfVolumes'],
      subSeries['volumeCount'],
      subSeries['volumesCount'],
      subSeries['totalVolumes'],
    ];
    for (final candidate in candidates) {
      if (candidate is int) return candidate;
      if (candidate is num) return candidate.toInt();
      final parsed = int.tryParse(candidate?.toString() ?? '');
      if (parsed != null) return parsed;
    }

    return 0;
  }

  Volume? _buildVolumeFromExpandedData(Map<String, dynamic> data, bool readed) {
    final volumeId = data['id']?.toString() ?? '';
    if (volumeId.isEmpty) return null;

    final expand = _asMap(data['expand']);
    final authors = _asStringList(expand['authors'] ?? data['authors']);

    return Volume(
      id: volumeId,
      title: data['title']?.toString() ?? data['titleFr']?.toString() ?? '',
      tomeNumber: data['tome_number'] ?? data['tomeNumber'],
      price: data['price'] ?? -1,
      image: data['coverUrl']?.toString() ?? data['image']?.toString() ?? '',
      over18: data['over18'] == true,
      resume: data['resume']?.toString() ?? '',
      bookLink: _asList(data['book_link'] ?? data['bookLink']),
      release:
          DateTime.tryParse(
            (data['release'] ?? data['publicationDate'])?.toString() ?? '',
          ) ??
          DateTime.now(),
      ean: num.tryParse(data['ean']?.toString() ?? '') ?? 0,
      language: data['language']?.toString(),
      subSeries: (data['sub_series'] ?? data['subSeries'])?.toString() ?? '',
      readed: readed,
      authors: authors,
      series: data['series']?.toString() ?? data['serie']?.toString() ?? '',
      contains: data['contains'] != null ? _asStringList(data['contains']) : null,
      info: _asMap(data['info']).isEmpty ? null : _asMap(data['info']),
      support: data['support']?.toString() ?? 'manga',
      japGenre: data['genre_jap']?.toString() ?? data['genderJp']?.toString(),
      lastTimeChecked: DateTime.now(),
    );
  }

  SubSerieForCollection? _buildSubSeriesFromExpandedData(
    Map<String, dynamic> volumeData,
    bool readed,
  ) {
    final volumeExpand = _asMap(volumeData['expand']);
    // try multiple locations for sub-series (support new/old API shapes)
    final subSeries = _firstMap(
      volumeExpand['sub_series'] ??
          volumeExpand['subSeries'] ??
          volumeData['subSeries'] ??
          volumeData['sub_series'] ??
          volumeData['sub_serie'] ??
          volumeData['subSerie'],
    );
    final subSeriesId =
        subSeries['id']?.toString() ??
        volumeData['sub_serie']?.toString() ??
        volumeData['sub_series']?.toString() ??
        volumeData['subSeries']?.toString() ??
        volumeData['subSerie']?.toString() ??
        '';
    if (subSeriesId.isEmpty) return null;

    final title = subSeries['title']?.toString() ?? subSeries['titleFr']?.toString() ?? '';
    final volumeModel = _buildVolumeFromExpandedData(volumeData, readed);
    if (volumeModel == null) return null;
    final totalVolumes = _volumeCount(subSeries);

    return SubSerieForCollection(
      id: subSeriesId,
      title: title,
      numberOfVolumes: totalVolumes < 1 ? 1 : totalVolumes,
      numberOwnedVolumes: 1,
      volumes: <Volume>[volumeModel],
      cover: subSeries['coverUrl']?.toString() ?? subSeries['image']?.toString(),
    );
  }

  void _mergeOwnedEntry(
    Set<SubSerieForCollection> currentState,
    Map<String, dynamic> entryData,
  ) {
    final expand = _asMap(entryData['expand']);
    // Primary source: expand.volume
    var volume = _asMap(expand['volume']);
    // Fallbacks in case the new API returns different shapes
    if (volume.isEmpty) {
      // try top-level keys or the entry itself
      volume = _firstMap(entryData['volume'] ?? entryData['volumes'] ?? entryData);
    }
    final readed = entryData['readed'] == true;

    final built = _buildSubSeriesFromExpandedData(volume, readed);
    if (built == null) return;

    final existingIndex = currentState.toList().indexWhere(
      (item) => item.id == built.id && item.title == built.title,
    );

    if (existingIndex == -1) {
      currentState.add(built);
      return;
    }

    final existing = currentState.elementAt(existingIndex);
    existing.numberOwnedVolumes += 1;
    existing.volumes.addAll(built.volumes);
  }

  // Init the data
  Future<bool> initData(User user) async {
    final storage = getIt<LocalStorage>();

    final nextState = <SubSerieForCollection>{};
    try {
      final result = await AppwriteConnector().getOwned(
        user.id,
        'volumes.subSeries.editors',
      );

      debugPrint('Owned API returned ${result.length} entries.');

      for (final entry in result) {
        _mergeOwnedEntry(nextState, Map<String, dynamic>.from(entry.data));
      }
    } catch (e) {
      debugPrint('Unable to load owned sub series from API: $e');
    }

    if (nextState.isNotEmpty) {
      for (final subSeries in nextState) {
        subSeries.volumes.sort(
          (a, b) => (a.tomeNumber ?? 0).compareTo(b.tomeNumber ?? 0),
        );
      }

      state = nextState;
      await storage.saveOwnedSubSerie(state);
      return true;
    }

    state = <SubSerieForCollection>{};
    await storage.saveOwnedSubSerie(state);
    return true;
  }

  // Add a sub series to the owned list
  Future<void> addSubSeriesToOwned(SubSerieForCollection subSeries) async {
    final storage = getIt<LocalStorage>();
    if (!state.contains(subSeries)) {
      state = {...state, subSeries};
    }
    await storage.saveOwnedSubSerie(state);
  }

  // Remove a sub series from the owned list
  Future<void> removeSubSeriesFromOwned(SubSerieForCollection subSeries) async {
    final storage = getIt<LocalStorage>();
    if (state.contains(subSeries)) {
      state = state.where((item) => item != subSeries).toSet();
    }
    await storage.saveOwnedSubSerie(state);
  }

  // Add a volume to a sub series
  Future<void> addVolumeToSubSeries(
    SubSerieForCollection subSerie,
    Volume volume,
  ) async {
    final storage = getIt<LocalStorage>();
    if (state.contains(subSerie)) {
      final current = state.firstWhere((item) => item == subSerie);
      if (!current.volumes.contains(volume)) {
        current.volumes.add(volume);
        current.numberOwnedVolumes += 1;
      }
    }
    await storage.saveOwnedSubSerie(state);
  }

  // Remove a volume from a sub series
  Future<void> removeVolumeFromSubSeries(
    SubSerieForCollection subSerie,
    Volume volume,
  ) async {
    final storage = getIt<LocalStorage>();
    if (state.contains(subSerie)) {
      final current = state.firstWhere((item) => item == subSerie);
      if (current.volumes.contains(volume)) {
        current.volumes.remove(volume);
        current.numberOwnedVolumes -= 1;
      }
    }
    await storage.saveOwnedSubSerie(state);
  }

  // Check if a sub series is owned
  bool isSubSeriesOwned(SubSerieForCollection subSeries) {
    return state.contains(subSeries);
  }

  // Check if a volume is owned
  bool isVolumeOwned(SubSerieForCollection subSeries, Volume volume) {
    return subSeries.volumes.contains(volume);
  }

  // Find a sub series index from it's title and it's id
  SubSerieForCollection findSubSeriesFromTitle(String title, String id) {
    return state.firstWhere(
      (subSeries) => subSeries.title == title && subSeries.id == id,
    );
  }

  // Find a volume from it's id
  Volume findVolumeFromId(
    SubSerieForCollection subSeries,
    String title,
    String id,
  ) {
    final index = subSeries.volumes.indexWhere(
      (volume) => volume.title == title && volume.id == id,
    );
    return subSeries.volumes[index];
  }

  // Clear the data
  Future<void> clear() async {
    final storage = getIt<LocalStorage>();
    state = <SubSerieForCollection>{};
    await storage.saveOwnedSubSerie(state);
  }
}

final mangaOwnedProvider = NotifierProvider<MangaOwnedNotifier, Set<SubSerieForCollection>>(() {
  return MangaOwnedNotifier();
});
