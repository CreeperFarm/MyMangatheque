import 'package:mymangatheque/src/models/manga/sub_serie_for_collection.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';

enum MissingVolumeAvailability { available, announced, unreleased }

MissingVolumeAvailability missingVolumeAvailability(
  Volume volume, {
  DateTime? now,
}) {
  final release = volume.release;
  if (release == null) return MissingVolumeAvailability.unreleased;
  final today = now ?? DateTime.now();
  return release.isAfter(today)
      ? MissingVolumeAvailability.announced
      : MissingVolumeAvailability.available;
}

List<Volume> prioritizeMissingVolumes(
  Iterable<Volume> volumes, {
  Set<String> wantedVolumeIds = const <String>{},
  DateTime? now,
}) {
  final result = volumes.toList();
  final reference = now ?? DateTime.now();
  int availabilityRank(Volume volume) =>
      switch (missingVolumeAvailability(volume, now: reference)) {
        MissingVolumeAvailability.available => 0,
        MissingVolumeAvailability.announced => 1,
        MissingVolumeAvailability.unreleased => 2,
      };

  result.sort((a, b) {
    final wantedComparison = (wantedVolumeIds.contains(b.id) ? 1 : 0).compareTo(
      wantedVolumeIds.contains(a.id) ? 1 : 0,
    );
    if (wantedComparison != 0) return wantedComparison;
    final availabilityComparison = availabilityRank(
      a,
    ).compareTo(availabilityRank(b));
    if (availabilityComparison != 0) return availabilityComparison;
    final releaseComparison = (a.release ?? DateTime(9999)).compareTo(
      b.release ?? DateTime(9999),
    );
    if (releaseComparison != 0) return releaseComparison;
    return (a.tomeNumber ?? 0).compareTo(b.tomeNumber ?? 0);
  });
  return result;
}

DateTime latestLibraryRelease(Iterable<Volume> volumes) {
  var latest = DateTime.fromMillisecondsSinceEpoch(0);
  for (final volume in volumes) {
    final release = volume.release;
    if (release != null && release.isAfter(latest)) latest = release;
  }
  return latest;
}

int ownedLibraryVolumeCount(Iterable<SubSerieForCollection> subSeries) {
  return subSeries.fold<int>(0, (total, item) => total + item.volumes.length);
}

int readLibraryVolumeCount(Iterable<SubSerieForCollection> subSeries) {
  return subSeries.fold<int>(
    0,
    (total, item) =>
        total + item.volumes.where((volume) => volume.readed).length,
  );
}

List<SubSerieForCollection> buildReadPileSubSeries(
  Iterable<SubSerieForCollection> subSeries, {
  String searchQuery = '',
  String order = 'manga',
}) {
  final query = searchQuery.trim().toLowerCase();
  final pending = <SubSerieForCollection>[];

  for (final subSerie in subSeries) {
    final unreadVolumes =
        subSerie.volumes.where((volume) => !volume.readed).toList()
          ..sort((a, b) => (a.tomeNumber ?? 0).compareTo(b.tomeNumber ?? 0));
    if (unreadVolumes.isEmpty) continue;
    if (query.isNotEmpty &&
        !subSerie.title.toLowerCase().contains(query) &&
        !unreadVolumes.any(
          (volume) => volume.title.toLowerCase().contains(query),
        )) {
      continue;
    }

    pending.add(
      SubSerieForCollection(
        id: subSerie.id,
        title: subSerie.title,
        numberOfVolumes: subSerie.numberOfVolumes,
        numberOwnedVolumes: subSerie.volumes.length,
        volumes: unreadVolumes,
        cover: subSerie.cover,
      ),
    );
  }

  sortLibrarySubSeries(pending, order: order);
  return pending;
}

List<SubSerieForCollection> filterLibrarySubSeries(
  Iterable<SubSerieForCollection> subSeries, {
  String searchQuery = '',
  String order = 'manga',
  String Function(SubSerieForCollection item)? additionalSearchText,
}) {
  final query = searchQuery.trim().toLowerCase();
  final visible = subSeries.where((subSerie) {
    if (query.isEmpty) return true;
    return subSerie.title.toLowerCase().contains(query) ||
        subSerie.volumes.any(
          (volume) => volume.title.toLowerCase().contains(query),
        ) ||
        (additionalSearchText?.call(subSerie).toLowerCase().contains(query) ??
            false);
  }).toList();
  sortLibrarySubSeries(visible, order: order);
  return visible;
}

void sortLibrarySubSeries(
  List<SubSerieForCollection> subSeries, {
  required String order,
}) {
  subSeries.sort((a, b) {
    if (order == 'releaseDate') {
      final releaseComparison = latestLibraryRelease(
        b.volumes,
      ).compareTo(latestLibraryRelease(a.volumes));
      if (releaseComparison != 0) return releaseComparison;
    }
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  });
}

String libraryRelationId(dynamic value) {
  if (value == null) return '';
  if (value is String || value is num) {
    final id = value.toString().trim();
    return id == 'null' || id == 'undefined' ? '' : id;
  }
  if (value is List) {
    for (final item in value) {
      final id = libraryRelationId(item);
      if (id.isNotEmpty) return id;
    }
    return '';
  }
  if (value is Map) {
    return libraryRelationId(value['id'] ?? value[r'$id']);
  }
  return '';
}
