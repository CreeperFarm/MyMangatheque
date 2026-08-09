import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/api/mobile_api_client.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/back/services/import/collection_import_models.dart';
import 'package:mymangatheque/src/back/services/import/collection_import_parser.dart';
import 'package:mymangatheque/src/back/services/models/api_record_model.dart';
import 'package:mymangatheque/src/back/services/search_service.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef CollectionImportProgress =
    void Function(int completed, int total, CollectionImportItem item);

class CollectionImportService {
  CollectionImportService({
    AppwriteConnector? connector,
    SearchService? search,
    MobileApiClient? api,
    CollectionImportParser parser = const CollectionImportParser(),
  }) : _connector = connector ?? AppwriteConnector(),
       _search = search ?? SearchService(),
       _api = api ?? MobileApiClient(),
       _parser = parser;

  static const String mangacollecPreviewPath =
      '/api/users/me/collection-imports/mangacollec/preview';
  static const int _historyLimit = 20;

  final AppwriteConnector _connector;
  final SearchService _search;
  final MobileApiClient _api;
  final CollectionImportParser _parser;
  final Random _random = Random.secure();

  List<CollectionImportEntry> parse(
    CollectionImportSource source,
    String content,
  ) => _parser.parse(source, content);

  Future<List<CollectionImportEntry>> loadMangacollecProfile(
    String profile,
  ) async {
    final normalized = profile.trim();
    if (normalized.isEmpty || normalized.length > 300) {
      throw const CollectionImportFormatException(
        'Enter a valid Mangacollec profile name or URL.',
      );
    }
    final uri = Uri.tryParse(normalized);
    if (uri != null && uri.hasScheme) {
      final host = uri.host.toLowerCase();
      if (uri.scheme != 'https' ||
          !(host == 'mangacollec.com' || host.endsWith('.mangacollec.com'))) {
        throw const CollectionImportFormatException(
          'Only HTTPS Mangacollec profile URLs are accepted.',
        );
      }
    }

    final response = await _api.post(
      mangacollecPreviewPath,
      requiresApiKey: true,
      requiresBearer: true,
      body: <String, dynamic>{'profile': normalized},
    );
    if (response.statusCode == 404 || response.statusCode == 501) {
      throw StateError(
        RuntimeLocalization.text(
          en: 'The protected Mangacollec importer is currently unavailable. Use a Mangacollec CSV or JSON export for now.',
          fr: 'L’importeur Mangacollec protégé est actuellement indisponible. Utilisez pour le moment un export CSV ou JSON Mangacollec.',
        ),
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        RuntimeLocalization.text(
          en: 'Mangacollec import failed (${response.statusCode}): ${redactSensitiveText(response.body)}',
          fr: 'L’import Mangacollec a échoué (${response.statusCode}) : ${redactSensitiveText(response.body)}',
        ),
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const CollectionImportFormatException(
        'The Mangacollec importer returned invalid JSON.',
      );
    }
    final data = decoded is Map ? decoded['data'] ?? decoded : decoded;
    return _parser.parseJson(jsonEncode(data));
  }

  Future<CollectionImportPreview> buildPreview(
    CollectionImportSource source,
    List<CollectionImportEntry> entries, {
    CollectionImportCancellationToken? cancellation,
    CollectionImportProgress? onProgress,
  }) async {
    final user = _connector.getConnectedUser();
    if (user == null) {
      throw StateError(
        RuntimeLocalization.text(
          en: 'Sign in before importing a collection.',
          fr: 'Connectez-vous avant d’importer une collection.',
        ),
      );
    }

    final items = <CollectionImportItem>[];
    for (var index = 0; index < entries.length; index += 1) {
      final entry = entries[index];
      if (cancellation?.isCancelled == true) break;
      CollectionImportItem item;
      try {
        final candidates = await findCandidates(entry);
        if (candidates.isEmpty) {
          item = CollectionImportItem(
            entry: entry,
            status: CollectionImportItemStatus.unmatched,
            message: RuntimeLocalization.text(
              en: 'No catalogue match.',
              fr: 'Aucune correspondance dans le catalogue.',
            ),
          );
        } else {
          final selected = candidates.first;
          final duplicate = await _connector.isVolumeOwned(
            user.id,
            selected.id,
          );
          item = CollectionImportItem(
            entry: entry,
            status: duplicate
                ? CollectionImportItemStatus.duplicate
                : CollectionImportItemStatus.ready,
            candidate: selected,
            alternatives: candidates.skip(1).toList(),
            message: duplicate
                ? RuntimeLocalization.text(
                    en: 'Already in the collection.',
                    fr: 'Déjà présent dans la collection.',
                  )
                : '',
          );
        }
      } on Object catch (error) {
        item = CollectionImportItem(
          entry: entry,
          status: CollectionImportItemStatus.failed,
          message: redactSensitiveText(error),
        );
      }
      items.add(item);
      onProgress?.call(index + 1, entries.length, item);
      if (index % 10 == 9) await Future<void>.delayed(Duration.zero);
    }

    return CollectionImportPreview(
      id: _newId(),
      source: source,
      createdAt: DateTime.now().toUtc(),
      items: items,
    );
  }

  Future<List<CollectionImportCandidate>> findCandidates(
    CollectionImportEntry entry, {
    int limit = 8,
  }) async {
    if (entry.ean.isNotEmpty) {
      final exact = await _connector.getVolumeByEan(entry.ean);
      if (exact != null) {
        return <CollectionImportCandidate>[_candidate(exact)];
      }
    }

    final query = <String>[
      entry.title,
      if (entry.volumeNumber != null) 'tome ${entry.volumeNumber}',
      if (entry.subSeries.isNotEmpty) entry.subSeries,
    ].where((value) => value.trim().isNotEmpty).join(' ');
    if (query.length < 2) return const <CollectionImportCandidate>[];
    final records = await _search.realtime('volumes', q: query, limit: limit);
    final candidates = records.map(_candidate).toList();
    candidates.sort(
      (a, b) => _matchScore(entry, b).compareTo(_matchScore(entry, a)),
    );
    return candidates;
  }

  Future<CollectionImportResult> execute(
    CollectionImportPreview preview, {
    CollectionImportCancellationToken? cancellation,
    CollectionImportProgress? onProgress,
  }) async {
    final user = _connector.getConnectedUser();
    if (user == null) {
      throw StateError(
        RuntimeLocalization.text(
          en: 'The user session expired before the import.',
          fr: 'La session utilisateur a expiré avant l’import.',
        ),
      );
    }
    final nextItems = List<CollectionImportItem>.from(preview.items);
    final importableIndexes = <int>[
      for (var index = 0; index < nextItems.length; index += 1)
        if (nextItems[index].canImport) index,
    ];
    final importedIds = <String>[];
    for (var position = 0; position < importableIndexes.length; position += 1) {
      if (cancellation?.isCancelled == true) break;
      final index = importableIndexes[position];
      final item = nextItems[index];
      final candidate = item.candidate!;
      try {
        final result = await _connector.addVolumeToOwned(
          user.id,
          candidate.id,
          item.entry.read,
          subSeriesId: candidate.subSeriesId,
        );
        nextItems[index] = item.copyWith(
          status: result.wasAlreadyOwned
              ? CollectionImportItemStatus.duplicate
              : CollectionImportItemStatus.imported,
          message: result.wasAlreadyOwned
              ? RuntimeLocalization.text(
                  en: 'Already in the collection.',
                  fr: 'Déjà présent dans la collection.',
                )
              : '',
        );
        if (!result.wasAlreadyOwned) importedIds.add(candidate.id);
      } on Object catch (error) {
        nextItems[index] = item.copyWith(
          status: CollectionImportItemStatus.failed,
          message: redactSensitiveText(error),
        );
      }
      onProgress?.call(
        position + 1,
        importableIndexes.length,
        nextItems[index],
      );
      if (position % 10 == 9) await Future<void>.delayed(Duration.zero);
    }

    final resultPreview = preview.copyWith(items: nextItems);
    if (importedIds.isNotEmpty) {
      await _recordHistory(
        user.id,
        CollectionImportHistoryEntry(
          id: preview.id,
          source: preview.source,
          createdAt: DateTime.now().toUtc(),
          importedVolumeIds: importedIds,
          failedCount: nextItems
              .where((item) => item.status == CollectionImportItemStatus.failed)
              .length,
        ),
      );
    }
    return CollectionImportResult(
      preview: resultPreview,
      importedVolumeIds: importedIds,
      cancelled: cancellation?.isCancelled == true,
    );
  }

  CollectionImportPreview replaceCandidate(
    CollectionImportPreview preview,
    int itemIndex,
    CollectionImportCandidate candidate,
  ) {
    if (itemIndex < 0 || itemIndex >= preview.items.length) return preview;
    final items = List<CollectionImportItem>.from(preview.items);
    items[itemIndex] = items[itemIndex].copyWith(
      candidate: candidate,
      status: CollectionImportItemStatus.ready,
      message: '',
    );
    return preview.copyWith(items: items);
  }

  CollectionImportPreview skipItem(
    CollectionImportPreview preview,
    int itemIndex,
  ) {
    if (itemIndex < 0 || itemIndex >= preview.items.length) return preview;
    final items = List<CollectionImportItem>.from(preview.items);
    items[itemIndex] = items[itemIndex].copyWith(
      status: CollectionImportItemStatus.skipped,
    );
    return preview.copyWith(items: items);
  }

  Future<List<CollectionImportHistoryEntry>> history() async {
    final user = _connector.getConnectedUser();
    if (user == null) return const <CollectionImportHistoryEntry>[];
    return _readHistory(user.id);
  }

  Future<List<CollectionImportHistoryEntry>> _readHistory(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_historyKey(userId));
    if (raw == null || raw.isEmpty) {
      return const <CollectionImportHistoryEntry>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <CollectionImportHistoryEntry>[];
      return decoded
          .whereType<Map>()
          .map(
            (item) => CollectionImportHistoryEntry.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((item) => item.id.isNotEmpty)
          .toList();
    } on FormatException {
      await preferences.remove(_historyKey(userId));
      return const <CollectionImportHistoryEntry>[];
    }
  }

  Future<CollectionImportHistoryEntry> undo(
    CollectionImportHistoryEntry entry, {
    CollectionImportCancellationToken? cancellation,
    void Function(int completed, int total)? onProgress,
  }) async {
    final user = _connector.getConnectedUser();
    if (user == null || !entry.canUndo) return entry;
    final remaining = <String>[];
    for (var index = 0; index < entry.importedVolumeIds.length; index += 1) {
      final volumeId = entry.importedVolumeIds[index];
      if (cancellation?.isCancelled == true) {
        remaining.addAll(entry.importedVolumeIds.skip(index));
        break;
      }
      try {
        await _connector.removeVolumeFromOwned(user.id, volumeId);
      } on Object {
        remaining.add(volumeId);
      }
      onProgress?.call(index + 1, entry.importedVolumeIds.length);
    }

    final updated = CollectionImportHistoryEntry(
      id: entry.id,
      source: entry.source,
      createdAt: entry.createdAt,
      importedVolumeIds: remaining,
      failedCount: entry.failedCount,
      undoneAt: remaining.isEmpty ? DateTime.now().toUtc() : null,
    );
    final historyItems = await _readHistory(user.id);
    final next = <CollectionImportHistoryEntry>[
      for (final item in historyItems) item.id == entry.id ? updated : item,
    ];
    await _writeHistory(user.id, next);
    return updated;
  }

  Future<void> _recordHistory(
    String userId,
    CollectionImportHistoryEntry entry,
  ) async {
    final current = await _readHistory(userId);
    final next = <CollectionImportHistoryEntry>[
      entry,
      ...current.where((item) => item.id != entry.id),
    ].take(_historyLimit).toList();
    await _writeHistory(userId, next);
  }

  Future<void> _writeHistory(
    String userId,
    List<CollectionImportHistoryEntry> entries,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _historyKey(userId),
      jsonEncode(entries.map((entry) => entry.toJson()).toList()),
    );
  }

  String _historyKey(String userId) => 'mmt_collection_import_history_$userId';

  CollectionImportCandidate _candidate(ApiRecordModel record) {
    return CollectionImportCandidate.fromJson(<String, dynamic>{
      ...record.data,
      'id': record.id,
    });
  }

  int _matchScore(
    CollectionImportEntry entry,
    CollectionImportCandidate value,
  ) {
    var score = 0;
    final expectedTitle = _normalizeText(entry.title);
    final actualTitle = _normalizeText(value.title);
    if (expectedTitle.isNotEmpty) {
      if (expectedTitle == actualTitle) {
        score += 100;
      } else if (actualTitle.contains(expectedTitle) ||
          expectedTitle.contains(actualTitle)) {
        score += 55;
      }
    }
    if (entry.volumeNumber != null && value.volumeNumber != null) {
      score += entry.volumeNumber == value.volumeNumber ? 80 : -40;
    }
    if (entry.ean.isNotEmpty && entry.ean == value.ean) score += 200;
    if (entry.subSeries.isNotEmpty &&
        _normalizeText(entry.subSeries) == _normalizeText(value.subSeries)) {
      score += 30;
    }
    return score;
  }

  String _normalizeText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9à-ÿ]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _newId() {
    final random = List<int>.generate(12, (_) => _random.nextInt(256));
    return '${DateTime.now().microsecondsSinceEpoch}-${base64UrlEncode(random).replaceAll('=', '')}';
  }
}
