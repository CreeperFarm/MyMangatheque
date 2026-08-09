enum CollectionImportSource { mangacollec, csv, json, ean, text }

enum CollectionImportItemStatus {
  pending,
  ready,
  duplicate,
  unmatched,
  invalid,
  imported,
  failed,
  skipped,
}

class CollectionImportEntry {
  const CollectionImportEntry({
    required this.sourceIndex,
    this.title = '',
    this.volumeNumber,
    this.ean = '',
    this.subSeries = '',
    this.read = false,
  });

  final int sourceIndex;
  final String title;
  final num? volumeNumber;
  final String ean;
  final String subSeries;
  final bool read;

  bool get hasLookupData => title.trim().isNotEmpty || ean.trim().isNotEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'sourceIndex': sourceIndex,
    if (title.isNotEmpty) 'title': title,
    if (volumeNumber != null) 'volumeNumber': volumeNumber,
    if (ean.isNotEmpty) 'ean': ean,
    if (subSeries.isNotEmpty) 'subSeries': subSeries,
    'read': read,
  };
}

class CollectionImportCandidate {
  const CollectionImportCandidate({
    required this.id,
    required this.title,
    this.volumeNumber,
    this.ean = '',
    this.subSeries = '',
    this.subSeriesId = '',
    this.coverUrl = '',
  });

  final String id;
  final String title;
  final num? volumeNumber;
  final String ean;
  final String subSeries;
  final String subSeriesId;
  final String coverUrl;

  factory CollectionImportCandidate.fromJson(Map<String, dynamic> json) {
    num? number(dynamic value) {
      if (value is num) return value;
      return num.tryParse(value?.toString() ?? '');
    }

    String relationId(dynamic value) {
      if (value is String) return value.trim();
      if (value is Map) {
        return (value['id'] ?? value[r'$id'] ?? '').toString().trim();
      }
      return '';
    }

    final subSeries =
        json['subSeries'] ?? json['sub_series'] ?? json['sub_serie'];
    return CollectionImportCandidate(
      id: (json['id'] ?? json[r'$id'] ?? '').toString(),
      title: (json['title'] ?? json['titleFr'] ?? json['name'] ?? '')
          .toString(),
      volumeNumber: number(json['tomeNumber'] ?? json['tome_number']),
      ean: (json['ean'] ?? json['isbn'] ?? '').toString(),
      subSeries: subSeries is Map
          ? (subSeries['title'] ?? subSeries['name'] ?? '').toString()
          : '',
      subSeriesId: relationId(
        json['subSeriesId'] ?? json['sub_series_id'] ?? subSeries,
      ),
      coverUrl: (json['coverUrl'] ?? json['image'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    if (volumeNumber != null) 'volumeNumber': volumeNumber,
    if (ean.isNotEmpty) 'ean': ean,
    if (subSeries.isNotEmpty) 'subSeries': subSeries,
    if (subSeriesId.isNotEmpty) 'subSeriesId': subSeriesId,
    if (coverUrl.isNotEmpty) 'coverUrl': coverUrl,
  };
}

class CollectionImportItem {
  const CollectionImportItem({
    required this.entry,
    required this.status,
    this.candidate,
    this.alternatives = const <CollectionImportCandidate>[],
    this.message = '',
  });

  final CollectionImportEntry entry;
  final CollectionImportItemStatus status;
  final CollectionImportCandidate? candidate;
  final List<CollectionImportCandidate> alternatives;
  final String message;

  bool get canImport =>
      candidate != null &&
      (status == CollectionImportItemStatus.ready ||
          status == CollectionImportItemStatus.failed);

  CollectionImportItem copyWith({
    CollectionImportItemStatus? status,
    CollectionImportCandidate? candidate,
    bool clearCandidate = false,
    List<CollectionImportCandidate>? alternatives,
    String? message,
  }) {
    return CollectionImportItem(
      entry: entry,
      status: status ?? this.status,
      candidate: clearCandidate ? null : candidate ?? this.candidate,
      alternatives: alternatives ?? this.alternatives,
      message: message ?? this.message,
    );
  }
}

class CollectionImportPreview {
  const CollectionImportPreview({
    required this.id,
    required this.source,
    required this.createdAt,
    required this.items,
  });

  final String id;
  final CollectionImportSource source;
  final DateTime createdAt;
  final List<CollectionImportItem> items;

  int count(CollectionImportItemStatus status) =>
      items.where((item) => item.status == status).length;

  CollectionImportPreview copyWith({List<CollectionImportItem>? items}) {
    return CollectionImportPreview(
      id: id,
      source: source,
      createdAt: createdAt,
      items: items ?? this.items,
    );
  }
}

class CollectionImportResult {
  const CollectionImportResult({
    required this.preview,
    required this.importedVolumeIds,
    required this.cancelled,
  });

  final CollectionImportPreview preview;
  final List<String> importedVolumeIds;
  final bool cancelled;
}

class CollectionImportHistoryEntry {
  const CollectionImportHistoryEntry({
    required this.id,
    required this.source,
    required this.createdAt,
    required this.importedVolumeIds,
    required this.failedCount,
    this.undoneAt,
  });

  final String id;
  final CollectionImportSource source;
  final DateTime createdAt;
  final List<String> importedVolumeIds;
  final int failedCount;
  final DateTime? undoneAt;

  bool get canUndo => undoneAt == null && importedVolumeIds.isNotEmpty;

  factory CollectionImportHistoryEntry.fromJson(Map<String, dynamic> json) {
    final sourceName = json['source']?.toString() ?? '';
    return CollectionImportHistoryEntry(
      id: json['id']?.toString() ?? '',
      source: CollectionImportSource.values.firstWhere(
        (source) => source.name == sourceName,
        orElse: () => CollectionImportSource.text,
      ),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      importedVolumeIds: (json['importedVolumeIds'] is List)
          ? (json['importedVolumeIds'] as List)
                .map((value) => value.toString())
                .where((value) => value.isNotEmpty)
                .toList()
          : <String>[],
      failedCount: json['failedCount'] is num
          ? (json['failedCount'] as num).toInt()
          : int.tryParse(json['failedCount']?.toString() ?? '') ?? 0,
      undoneAt: DateTime.tryParse(json['undoneAt']?.toString() ?? '')?.toUtc(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'source': source.name,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'importedVolumeIds': importedVolumeIds,
    'failedCount': failedCount,
    if (undoneAt != null) 'undoneAt': undoneAt!.toUtc().toIso8601String(),
  };

  CollectionImportHistoryEntry markUndone(DateTime date) {
    return CollectionImportHistoryEntry(
      id: id,
      source: source,
      createdAt: createdAt,
      importedVolumeIds: importedVolumeIds,
      failedCount: failedCount,
      undoneAt: date.toUtc(),
    );
  }
}

class CollectionImportCancellationToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;
}
