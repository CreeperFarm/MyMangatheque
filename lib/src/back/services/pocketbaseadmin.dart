import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:mymangatheque/generated/l10n.dart';
import 'package:mymangatheque/src/back/services/utils.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:rxdart/rxdart.dart';

class PocketBaseAdminConnector {
  late PocketBase _pocketBase = PocketBase(
    'https://api.mymangatheque.com',
    lang: 'fr-FR',
  );

  static final PocketBaseAdminConnector _singleton =
      PocketBaseAdminConnector._internal();

  factory PocketBaseAdminConnector() {
    return _singleton;
  }

  bool _isConnected = false;

  PocketBaseAdminConnector._internal()
    : _pocketBase = PocketBase(
        'https://api.mymangatheque.com',
        lang: PlatformDispatcher.instance.locale.languageCode == 'fr'
            ? 'fr-FR'
            : 'en-US',
      ) {
    _pocketBase.authStore.onChange.listen((event) {
      _isConnected = _pocketBase.authStore.isValid;
      debugPrint('Auth store changed: $_isConnected');
    });
  }

  // Check if your logged-in
  bool isLoggedIn() {
    return _isConnected;
  }

  Future<bool> loginAsAdmin(String email, String password, context) async {
    try {
      await _pocketBase
          .collection('_superusers')
          .authWithPassword(email.toString().toLowerCase(), password);
      _isConnected = _pocketBase.authStore.isValid;
      return _isConnected = _pocketBase.authStore.isValid;
    } catch (err) {
      if (err.toString().contains('Failed to authenticate')) {
        showMessage(AppLocalizations.of(context).authFailed, context);
      } else {
        showMessage(err.toString(), context);
      }
      return _isConnected = false;
    }
  }

  void logout() async {
    _pocketBase.authStore.clear();
    _isConnected = false;
  }

  // Remove an entry from a collection
  Future<void> removeEntry(String collectionId, String entryId) {
    return _pocketBase.collection(collectionId).delete(entryId);
  }

  // Get the data from one field of a collection
  Future<List<RecordModel>> getOne(String collectionId, String recordId) {
    return _pocketBase
        .collection(collectionId)
        .getOne(recordId)
        .then((value) => [value]);
  }

  // Get the data from a collection
  Future<List<RecordModel>> getCollectionData(String collectionId) {
    return _pocketBase
        .collection(collectionId)
        .getList()
        .then((value) => value.items);
  }

  // Get all the data from a collection
  Future<List<RecordModel>> getCollectionFullList(String collectionId) {
    return _pocketBase.collection(collectionId).getFullList();
  }

  Future<List<RecordModel>> getCollectionFullListOrder(
    String collectionId,
    String order,
  ) {
    return _pocketBase.collection(collectionId).getFullList(sort: order);
  }

  // Get the data from a collection with a filter
  Future<List<RecordModel>> getCollectionDataWithFilter(
    String collectionId,
    String query,
  ) {
    return _pocketBase
        .collection(collectionId)
        .getList(page: 1, perPage: 500, filter: query)
        .then((value) => value.items);
  }

  // Get the data from a collection and listen to the changes
  Stream<List<RecordModel>> getCollectionDataListener(String collectionId) {
    PublishSubject<List<RecordModel>> subject =
        PublishSubject<List<RecordModel>>();

    StreamSubscription<RecordSubscriptionEvent> subscription =
        listenToCollectionEvents(collectionId).listen((event) async {
          subject.add(await getCollectionData(collectionId));
        });

    subject.onCancel = () {
      debugPrint('on cancel');
      subscription.cancel();
    };
    subject.onListen = () async =>
        subject.add(await getCollectionData(collectionId));
    return subject.stream;
  }

  Stream<RecordSubscriptionEvent> listenToCollectionEvents(
    String collectionId,
  ) {
    return _pocketBase.collection(collectionId).listen();
  }

  void createGenre(String genreName) {
    _pocketBase.collection('genres').create(body: {'name': genreName});
  }

  Future<void> createVolume(
    Map<String, dynamic> body,
    String fileName,
    List<int>? fileBytes,
  ) async {
    List<MultipartFile>? files;
    if (fileBytes != null && fileName.isNotEmpty) {
      files = [MultipartFile.fromBytes('image', fileBytes, filename: fileName)];
    }

    await _pocketBase
        .collection('volumes')
        .create(body: body, files: files ?? []);
  }

  Future<void> createAuthor(
    Map<String, dynamic> body,
    String fileName,
    List<int>? fileBytes,
  ) async {
    List<MultipartFile>? files;
    if (fileBytes != null && fileName.isNotEmpty) {
      files = [MultipartFile.fromBytes('image', fileBytes, filename: fileName)];
    }

    await _pocketBase
        .collection('authors')
        .create(body: body, files: files ?? []);
  }

  Future<bool> checkIfExist(
    String collectionId,
    String field,
    String value,
  ) async {
    final query = '{"$field":"$value"}';
    final data = await _pocketBase
        .collection(collectionId)
        .getFirstListItem(query);
    if (data.toString().contains('"code": 4')) {
      return false;
    } else {
      return true;
    }
  }

  String get serverUrl => _pocketBase.baseURL;

  /// Utility to build multipart files from bytes (used by tests and callers).
  static List<MultipartFile>? buildMultipartFiles(
    String fieldName,
    String fileName,
    List<int>? fileBytes,
  ) {
    if (fileBytes == null || fileName.isEmpty) return null;
    return [MultipartFile.fromBytes(fieldName, fileBytes, filename: fileName)];
  }
}
