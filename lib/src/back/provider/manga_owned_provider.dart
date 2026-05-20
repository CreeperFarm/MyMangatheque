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
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) {
    return value is List<dynamic> ? value : const <dynamic>[];
  }

  Volume? _buildVolumeFromExpandedData(Map<String, dynamic> data, bool readed) {
    final volumeId = data['id']?.toString() ?? '';
    if (volumeId.isEmpty) return null;

    final authors = <String>[];
    for (final author in _asList(data['authors'])) {
      if (author is Map<String, dynamic>) {
        final name = author['name']?.toString() ?? '';
        if (name.isNotEmpty) authors.add(name);
      } else {
        final name = author.toString().trim();
        if (name.isNotEmpty) authors.add(name);
      }
    }

    return Volume(
      id: volumeId,
      title: data['title']?.toString() ?? data['titleFr']?.toString() ?? '',
      tomeNumber: data['tome_number'],
      price: data['price'],
      image: data['coverUrl']?.toString() ?? data['image']?.toString() ?? '',
      over18: data['over18'],
      resume: data['resume'],
      bookLink: data['book_link'],
      release: DateTime.tryParse(data['release']?.toString() ?? '') ?? DateTime.now(),
      ean: data['ean'],
      language: data['language'],
      subSeries: data['sub_series']?.toString() ?? '',
      readed: readed,
      authors: authors,
      series: data['series'],
      contains: data['contains'],
      info: data['info'],
      support: data['support'],
      japGenre: data['genre_jap'],
      lastTimeChecked: DateTime.now(),
    );
  }

  SubSerieForCollection? _buildSubSeriesFromExpandedData(Map<String, dynamic> volumeData, bool readed) {
    final volumeExpand = _asMap(volumeData['expand']);
    final subSeries = _asMap(volumeExpand['sub_series']);
    final subSeriesId = subSeries['id']?.toString() ?? volumeData['sub_series']?.toString() ?? '';
    if (subSeriesId.isEmpty) return null;

    final title = subSeries['title']?.toString() ?? subSeries['titleFr']?.toString() ?? '';
    final volumeModel = _buildVolumeFromExpandedData(volumeData, readed);
    if (volumeModel == null) return null;

    return SubSerieForCollection(
      id: subSeriesId,
      title: title,
      numberOfVolumes: _asList(subSeries['volumes']).length,
      numberOwnedVolumes: 1,
      volumes: <Volume>[volumeModel],
    );
  }

  void _mergeOwnedEntry(Set<SubSerieForCollection> currentState, Map<String, dynamic> entryData) {
    final expand = _asMap(entryData['expand']);
    final volume = _asMap(expand['volume']);
    final readed = entryData['readed'] == true;

    final built = _buildSubSeriesFromExpandedData(volume, readed);
    if (built == null) return;

    final existingIndex = currentState.toList().indexWhere((item) => item.id == built.id && item.title == built.title);

    if (existingIndex == -1) {
      currentState.add(built);
      return;
    }

    final existing = currentState.elementAt(existingIndex);
    existing.numberOwnedVolumes += 1;
    existing.volumes.addAll(built.volumes);
  }

  // Init the data
  Future<bool> initData() async {
    final storage = getIt<LocalStorage>();
    await storage.getOwnedSubSerie(); // Get the data from the local storage

    try {
      final result = await AppwriteConnector().getCollectionFullDataWithFilterExpand(
        'owned',
        '',
        'volume.sub_series.editor',
      );

      debugPrint(result.toString());
      state = <SubSerieForCollection>{};

      for (final entry in result) {
        _mergeOwnedEntry(state, Map<String, dynamic>.from(entry.data));
      }
    } catch (e) {
      // Print the error to the debug console
      debugPrint(e.toString());
    }

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
  Future<void> addVolumeToSubSeries(SubSerieForCollection subSerie, Volume volume) async {
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
  Future<void> removeVolumeFromSubSeries(SubSerieForCollection subSerie, Volume volume) async {
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
    return state.firstWhere((subSeries) => subSeries.title == title && subSeries.id == id);
  }

  // Find a volume from it's id
  Volume findVolumeFromId(SubSerieForCollection subSeries, String title, String id) {
    final index = subSeries.volumes.indexWhere((volume) => volume.title == title && volume.id == id);
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
