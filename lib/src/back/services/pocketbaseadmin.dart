import 'dart:async';

import 'package:mymangatheque/src/back/services/utils.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:rxdart/rxdart.dart';

class PocketBaseAdminConnector {
  late PocketBase _pocketBase = PocketBase('https://api.mymangatheque.com', lang: 'fr-FR');

  static final PocketBaseAdminConnector _singleton = PocketBaseAdminConnector._internal();

  factory PocketBaseAdminConnector() {
    return _singleton;
  }

  bool _isConnected = false;

  PocketBaseAdminConnector._internal() : _pocketBase = PocketBase('https://api.mymangatheque.com', lang: 'fr-FR');

  // Check if your logged-in
  bool isLoggedIn() {
    return _isConnected;
  }

  Future<bool> loginAsAdmin(String email, String password, context) async {
    try {
      await _pocketBase.collection('_superusers').authWithPassword(email.toString(), password);
      _isConnected = _pocketBase.authStore.isValid;
      return _isConnected = _pocketBase.authStore.isValid;
    } catch (err) {
      if (err.toString().contains('Failed to authenticate')) {
        showMessage('Email ou mot de passe incorrect', context);
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
  Future<void> removeEntry(
    String collectionId,
    String entryId,
  ) {
    return _pocketBase.collection(collectionId).delete(entryId);
  }

  // Get the data from one field of a collection
  Future<List<RecordModel>> getOne(String collectionId, String recordId) {
    return _pocketBase.collection(collectionId).getOne(recordId).then((value) => [value]);
  }

  // Get the data from a collection
  Future<List<RecordModel>> getCollectionData(String collectionId) {
    return _pocketBase.collection(collectionId).getList().then((value) => value.items);
  }

  // Get all the data from a collection
  Future<List<RecordModel>> getCollectionFullList(String collectionId) {
    return _pocketBase.collection(collectionId).getFullList();
  }

  Future<List<RecordModel>> getCollectionFullListOrder(String collectionId, String order) {
    return _pocketBase.collection(collectionId).getFullList(
          sort: order,
        );
  }

  // Get the data from a collection with a filter
  Future<List<RecordModel>> getCollectionDataWithFilter(String collectionId, String query) {
    return _pocketBase
        .collection(collectionId)
        .getList(
          page: 1,
          perPage: 500,
          filter: query,
        )
        .then((value) => value.items);
  }

  // Get the data from a collection and listen to the changes
  Stream<List<RecordModel>> getCollectionDataListener(String collectionId) {
    PublishSubject<List<RecordModel>> subject = PublishSubject<List<RecordModel>>();

    StreamSubscription<RecordSubscriptionEvent> subscription = listenToCollectionEvents(collectionId).listen((event) async {
      subject.add(await getCollectionData(collectionId));
    });

    subject.onCancel = () {
      print('on cancel');
      subscription.cancel();
    };
    subject.onListen = () async => subject.add(
          await getCollectionData(collectionId),
        );
    return subject.stream;
  }

  Stream<RecordSubscriptionEvent> listenToCollectionEvents(String collectionId) {
    return _pocketBase.collection(collectionId).listen();
  }

  String get serverUrl => _pocketBase.baseUrl;
}
