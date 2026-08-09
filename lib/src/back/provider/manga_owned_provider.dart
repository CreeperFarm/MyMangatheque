import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:mymangatheque/src/models/local_storage/service_locator.dart';
import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';

class MangaOwnedNotifier extends Notifier<Set<SubSerieForCollection>> {
  static const Duration _freshDataDuration = Duration(seconds: 20);

  Future<bool>? _initDataInFlight;
  String? _initDataInFlightUserId;
  String? _activeUserId;
  String? _lastLoadedUserId;
  DateTime? _lastLoadedAt;
  int _loadGeneration = 0;

  @override
  Set<SubSerieForCollection> build() => <SubSerieForCollection>{};

  /// Immediately isolates in-memory private data when the authenticated user
  /// changes. Network requests already in flight are allowed to finish, but
  /// their results can no longer update the provider.
  void handleUserChanged(String? userId) {
    final normalizedUserId = userId?.trim();
    final nextUserId = normalizedUserId == null || normalizedUserId.isEmpty
        ? null
        : normalizedUserId;
    if (_activeUserId == nextUserId) return;

    _activeUserId = nextUserId;
    _lastLoadedUserId = null;
    _lastLoadedAt = null;
    _loadGeneration += 1;
    state = <SubSerieForCollection>{};
  }

  SubSerieForCollection? _findSubSeriesById(String id) {
    for (final item in state) {
      if (item.id == id) return item;
    }
    return null;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) {
    return value is List ? List<dynamic>.from(value) : const <dynamic>[];
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
      release: DateTime.tryParse(
        (data['release'] ?? data['publicationDate'])?.toString() ?? '',
      ),
      ean: num.tryParse(data['ean']?.toString() ?? '') ?? 0,
      language: data['language']?.toString(),
      subSeries: (data['sub_series'] ?? data['subSeries'])?.toString() ?? '',
      readed: readed,
      authors: authors,
      series: data['series']?.toString() ?? data['serie']?.toString() ?? '',
      contains: data['contains'] != null
          ? _asStringList(data['contains'])
          : null,
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

    final title =
        subSeries['title']?.toString() ??
        subSeries['titleFr']?.toString() ??
        '';
    final volumeModel = _buildVolumeFromExpandedData(volumeData, readed);
    if (volumeModel == null) return null;
    final totalVolumes = _volumeCount(subSeries);

    return SubSerieForCollection(
      id: subSeriesId,
      title: title,
      numberOfVolumes: totalVolumes < 1 ? 1 : totalVolumes,
      numberOwnedVolumes: 1,
      volumes: <Volume>[volumeModel],
      cover:
          subSeries['coverUrl']?.toString() ?? subSeries['image']?.toString(),
    );
  }

  void _mergeOwnedEntry(
    Set<SubSerieForCollection> currentState,
    Map<String, dynamic> entryData,
  ) {
    final expand = _asMap(entryData['expand']);

    // After _normalizeOwnedEntry, the volume map is at expand['volume'].
    // Fallback: top-level 'volume' key if expand is absent.
    var volume = _asMap(expand['volume'] ?? expand['volumes']);
    if (volume.isEmpty) {
      volume = _firstMap(
        entryData['volume'] ?? entryData['volumes'] ?? entryData['volumeData'],
      );
    }

    // Last resort: the entry data itself might be the volume (flat API shape)
    if (volume.isEmpty && entryData.containsKey('sub_series')) {
      volume = entryData;
    }

    if (volume.isEmpty) {
      RuntimeLocalization.debug(
        en: 'Unable to resolve a volume from an owned collection entry.',
        fr: 'Impossible de déterminer le volume d’une entrée de la collection possédée.',
      );
      return;
    }

    final readed = entryData['readed'] == true;
    final built = _buildSubSeriesFromExpandedData(volume, readed);
    if (built == null) {
      RuntimeLocalization.debug(
        en: 'Unable to build the sub-series for an owned volume.',
        fr: 'Impossible de construire la sous-série d’un volume possédé.',
      );
      return;
    }

    SubSerieForCollection? existing;
    for (final item in currentState) {
      if (item.id == built.id) {
        existing = item;
        break;
      }
    }

    if (existing == null) {
      currentState.add(built);
      return;
    }

    for (final volume in built.volumes) {
      if (!existing.volumes.any((item) => item.id == volume.id)) {
        existing.volumes.add(volume);
        existing.numberOwnedVolumes += 1;
      }
    }
  }

  @visibleForTesting
  Set<SubSerieForCollection> mergeOwnedEntriesForTesting(
    Iterable<Map<String, dynamic>> entries,
  ) {
    final nextState = <SubSerieForCollection>{};
    for (final entry in entries) {
      _mergeOwnedEntry(nextState, entry);
    }
    return nextState;
  }

  Future<bool> initData(User user, {bool forceRefresh = false}) {
    handleUserChanged(user.id);

    final lastLoadedAt = _lastLoadedAt;
    final isFresh =
        _lastLoadedUserId == user.id &&
        lastLoadedAt != null &&
        DateTime.now().difference(lastLoadedAt) < _freshDataDuration;

    if (!forceRefresh && state.isNotEmpty && isFresh) {
      return Future<bool>.value(true);
    }

    final inFlight = _initDataInFlight;
    if (!forceRefresh &&
        inFlight != null &&
        _initDataInFlightUserId == user.id) {
      return inFlight;
    }

    final generation = ++_loadGeneration;
    final future = _loadOwnedData(
      user,
      forceRefresh: forceRefresh,
      generation: generation,
    );
    _initDataInFlight = future;
    _initDataInFlightUserId = user.id;
    return future.whenComplete(() {
      if (identical(_initDataInFlight, future)) {
        _initDataInFlight = null;
        _initDataInFlightUserId = null;
      }
    });
  }

  // Init the data
  Future<bool> _loadOwnedData(
    User user, {
    required bool forceRefresh,
    required int generation,
  }) async {
    final storage = getIt<LocalStorage>();
    final nextState = <SubSerieForCollection>{};
    var apiRequestSucceeded = false;
    final cachedBeforeRequest = await storage.getOwnedSubSerie(userId: user.id);
    if (_isCurrentLoad(user.id, generation) &&
        state.isEmpty &&
        cachedBeforeRequest != null &&
        cachedBeforeRequest.isNotEmpty) {
      state = cachedBeforeRequest;
      RuntimeLocalization.debug(
        en: 'Displayed the cached collection while refreshing it in the background.',
        fr: 'Affichage de la collection en cache pendant son actualisation en arrière-plan.',
      );
    }

    try {
      final result = await AppwriteConnector().getOwned(
        user.id,
        'volumes.subSeries.editors',
        forceRefresh: forceRefresh,
      );
      apiRequestSucceeded = true;

      RuntimeLocalization.debug(
        en: 'Owned collection loaded (${result.length} entries).',
        fr: 'Collection possédée chargée (${result.length} entrées).',
      );

      for (final entry in result) {
        _mergeOwnedEntry(nextState, entry.data);
      }
      if (result.isNotEmpty && nextState.isEmpty) {
        apiRequestSucceeded = false;
        RuntimeLocalization.debug(
          en: 'Owned collection entries could not be parsed; preserving the user cache.',
          fr: 'Les entrées de la collection possédée sont illisibles ; conservation du cache utilisateur.',
        );
      }
    } catch (e) {
      RuntimeLocalization.debug(
        en: 'Unable to load owned sub-series from the API: $e',
        fr: 'Impossible de charger les sous-séries possédées depuis l’API : $e',
      );
    }

    if (!_isCurrentLoad(user.id, generation)) return true;

    if (apiRequestSucceeded) {
      for (final subSeries in nextState) {
        subSeries.volumes.sort(
          (a, b) => (a.tomeNumber ?? 0).compareTo(b.tomeNumber ?? 0),
        );
      }
      state = nextState;
      _lastLoadedUserId = user.id;
      _lastLoadedAt = DateTime.now();
      await storage.saveOwnedSubSerie(nextState, userId: user.id);
      return true;
    }

    final cached = cachedBeforeRequest;
    if (!_isCurrentLoad(user.id, generation)) return true;
    if (cached != null && cached.isNotEmpty) {
      state = cached;
      _lastLoadedUserId = user.id;
      _lastLoadedAt = DateTime.now();
      RuntimeLocalization.debug(
        en: 'The API is unavailable; restored the owned collection from the user cache.',
        fr: 'L’API est indisponible ; restauration de la collection possédée depuis le cache utilisateur.',
      );
      return true;
    }

    state = <SubSerieForCollection>{};
    _lastLoadedUserId = user.id;
    _lastLoadedAt = DateTime.now();
    return false;
  }

  bool _isCurrentLoad(String userId, int generation) {
    return _activeUserId == userId && _loadGeneration == generation;
  }

  String? _prepareMutationUser() {
    final connectedUserId = AppwriteConnector().getConnectedUser()?.id;
    if (connectedUserId != null && connectedUserId != _activeUserId) {
      handleUserChanged(connectedUserId);
    }
    return _activeUserId;
  }

  // Add a sub series to the owned list
  Future<void> addSubSeriesToOwned(SubSerieForCollection subSeries) async {
    final storage = getIt<LocalStorage>();
    final userId = _prepareMutationUser();
    if (!state.any((item) => item.id == subSeries.id)) {
      state = {...state, subSeries};
    }
    await storage.saveOwnedSubSerie(state, userId: userId);
  }

  // Remove a sub series from the owned list
  Future<void> removeSubSeriesFromOwned(SubSerieForCollection subSeries) async {
    final storage = getIt<LocalStorage>();
    final userId = _prepareMutationUser();
    state = state.where((item) => item.id != subSeries.id).toSet();
    await storage.saveOwnedSubSerie(state, userId: userId);
  }

  // Add a volume to a sub series
  Future<void> addVolumeToSubSeries(
    SubSerieForCollection subSerie,
    Volume volume,
  ) async {
    final storage = getIt<LocalStorage>();
    final userId = _prepareMutationUser();
    final current = _findSubSeriesById(subSerie.id);
    if (current != null) {
      if (!current.volumes.any((item) => item.id == volume.id)) {
        current.volumes.add(volume);
        current.volumes.sort(
          (a, b) => (a.tomeNumber ?? 0).compareTo(b.tomeNumber ?? 0),
        );
        current.numberOwnedVolumes = current.volumes.length;
        state = {...state};
      }
    }
    await storage.saveOwnedSubSerie(state, userId: userId);
  }

  // Remove a volume from a sub series
  Future<void> removeVolumeFromSubSeries(
    SubSerieForCollection subSerie,
    Volume volume,
  ) async {
    final storage = getIt<LocalStorage>();
    final userId = _prepareMutationUser();
    final current = _findSubSeriesById(subSerie.id);
    if (current != null) {
      current.volumes.removeWhere((item) => item.id == volume.id);
      current.numberOwnedVolumes = current.volumes.length;
      state = current.volumes.isEmpty
          ? state.where((item) => item.id != current.id).toSet()
          : {...state};
    }
    await storage.saveOwnedSubSerie(state, userId: userId);
  }

  // Check if a sub series is owned
  bool isSubSeriesOwned(SubSerieForCollection subSeries) {
    return state.any((item) => item.id == subSeries.id);
  }

  // Check if a volume is owned
  bool isVolumeOwned(SubSerieForCollection subSeries, Volume volume) {
    return state
        .where((item) => item.id == subSeries.id)
        .any((item) => item.volumes.any((owned) => owned.id == volume.id));
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
    final userId = _activeUserId;
    if (userId != null) {
      await storage.saveOwnedSubSerie(state, userId: userId);
    }
  }
}

final mangaOwnedProvider =
    NotifierProvider<MangaOwnedNotifier, Set<SubSerieForCollection>>(() {
      return MangaOwnedNotifier();
    });
