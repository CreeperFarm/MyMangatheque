// Importing dart libraries
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Importing other libraries
import 'package:dart_date/dart_date.dart';
import 'package:fetch_client/fetch_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:http/http.dart';
import 'package:mymangatheque/src/back/services/utils.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:mymangatheque/src/models/local_storage/service_locator.dart';
import 'package:mymangatheque/src/models/user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:rxdart/rxdart.dart';

// Exporting the classes
export 'package:mymangatheque/src/models/file.dart';
export 'package:mymangatheque/src/models/user.dart';

class PocketBaseConnector {
  late PocketBase _pocketBase;

  Future<void> init() async {
    final storage = getIt<LocalStorage>();
    final token = await storage.getToken();

    final customAuthStore = AsyncAuthStore(
      initial: token,
      save: storage.setToken,
      clear: storage.deleteToken,
    );

    _pocketBase = PocketBase(
      'https://api.mymangatheque.com',
      httpClientFactory: kIsWeb ? () => FetchClient(mode: RequestMode.cors) : null,
      lang: 'fr-FR',
      authStore: customAuthStore,
    );

    if (_pocketBase.authStore.isValid) {
      final authRecord = await _pocketBase.collection('users').authRefresh();
      final authInfo = json.decode(authRecord.toString());
      _connectedUser.add(await findUser(authInfo['record']['email']));
    } else {}

    /*if (!PocketBaseConnector().isLoggedIn()) {
      MangaOwnedNotifier().newDataSet([]);
    } else {
      try {
        final result = await PocketBaseConnector().getCollectionDataWithFilterExpand(
          'owned',
          "user='${PocketBaseConnector().getConnectedUser()!.id}'",
          'volume.sub_series',
        );
        final data = json.decode(result.toString());
        Map<String, dynamic> subSeriesMap = {};
        for (var i = 0; i < data.length; i++) {
          String title = data[i]['expand']['volume']['expand']['sub_series']['title'];
          if (subSeriesMap.containsKey(title)) {
            subSeriesMap[title]['volumes'].add({
              'title': data[i]['expand']['volume']['title'],
              'image': data[i]['expand']['volume']['image'],
              'id': data[i]['expand']['volume']['id']
            });
          } else {
            subSeriesMap[title] = {
              'title': title,
              'id': data[i]['expand']['volume']['expand']['sub_series']['id'],
              'first_index_data': i,
              'volumes': [
                {
                  'title': data[i]['expand']['volume']['title'],
                  'image': data[i]['expand']['volume']['image'],
                  'id': data[i]['expand']['volume']['id']
                }
              ]
            };
          }
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }*/
  }

  // Singleton
  static final PocketBaseConnector _singleton = PocketBaseConnector._internal();

  factory PocketBaseConnector() {
    return _singleton;
  }

  final BehaviorSubject<User?> _connectedUser = BehaviorSubject<User?>();

  PocketBaseConnector._internal()
      : _pocketBase =
            PocketBase('https://api.mymangatheque.com', httpClientFactory: kIsWeb ? () => FetchClient(mode: RequestMode.cors) : null, lang: 'fr-FR');

  Future<void> refresh() async {
    if (!_pocketBase.authStore.isValid) {
      // TODO: The token has expired. Ask the user to sign in again.
      return;
    }
    await _pocketBase.collection('users').authRefresh();
  }

  // Check if your logged-in
  bool isLoggedIn() {
    return _connectedUser.valueOrNull != null;
  }

  Future<void> _launchUrl(Uri url, context) async {
    try {
      await launchUrl(
        url,
        customTabsOptions: CustomTabsOptions(
          showTitle: true,
          shareState: CustomTabsShareState.on,
          urlBarHidingEnabled: true,
          closeButton: CustomTabsCloseButton(
            icon: CustomTabsCloseButtonIcons.back,
          ),
        ),
        safariVCOptions: SafariViewControllerOptions(
          preferredBarTintColor: Theme.of(context).colorScheme.surface,
          preferredControlTintColor: Theme.of(context).colorScheme.onSurface,
          barCollapsingEnabled: true,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Sign in with Google (all-in-one)
  signInWithGoogle(context) async {
    try {
      PocketBaseConnector().logOut();
      _pocketBase.authStore.clear();
      final authData = await _pocketBase.collection('users').authWithOAuth2(
        'google',
        (url) async {
          await _launchUrl(url, context);
        },
      );
      debugPrint(authData.toString());
      dynamic authData2 = await json.decode(authData.toString());

      if (_pocketBase.authStore.isValid) {
        if (DateTime.parse(authData2['record']['created']) >= DateTime.now().subtract(const Duration(minutes: 1))) {
          var data = authData2['meta']['rawUser'];
          try {
            /*var imageId = await ImageDownloader.downloadImage(data['picture']);
        if (imageId == null) {
          return;
        }
        var fileName = await ImageDownloader.findName(imageId);
        var path = await ImageDownloader.findPath(imageId);*/
            var body = <String, dynamic>{
              "email": data['email'],
              "username": data['name'],
              "birthday": DateTime.now().toString(),
              "gender": "other",
              "role": "user",
              "emailVisibility": true,
            };

            // Upload the image of the user
            await _pocketBase.collection('users').update(
                  authData2['record']['id'],
                  body: body,
                );
            _pocketBase.realtime.unsubscribe('users');
            await sendVerification(data['email']);
          } catch (e) {
            debugPrint(e.toString());
            showMessage("Un erreur est survenue.", context);
          }
        } else {
          debugPrint('User already exists');
        }
        _connectedUser.add(await findUser(authData2['meta']['rawUser']['email'].toString().toLowerCase()));
        _pocketBase.realtime.unsubscribe('users');
      } else {
        debugPrint('User isn\'t connected');
        showMessage('Une erreur est survenue', context);
      }
    } catch (e) {
      showMessage("Une erreur est survenue.", context);
      debugPrint(e.toString());
    }
    await closeCustomTabs();
  }

  // Login the user with email and password
  Future<User?> loginWithEmail(String email, String password, context) async {
    try {
      await _pocketBase.collection('users').authWithPassword(email.toLowerCase(), password).then((value) => value.token.isNotEmpty);

      _connectedUser.add(await findUser(email.toLowerCase()));

      showMessage("Vous êtes connecté(e).", context);

      return _connectedUser.value;
    } catch (err, context) {
      showMessage("Une erreur est survenue.", context);
      debugPrint(err.toString());
      return null;
    }
  }

  // Update User Data
  Future<User?> updateUserData(String email) async {
    try {
      _connectedUser.add(await findUser(email));
      return _connectedUser.value;
    } catch (err) {
      return null;
    }
  }

  // Log Out
  void logOut() {
    _pocketBase.authStore.clear();
    _connectedUser.add(null);
  }

  // Reset Password
  Future resetPassword(String email, context) async {
    try {
      await _pocketBase.collection('users').requestPasswordReset(email);
      Navigator.pop(context);
      return showMessage(
          'Un lien vous as été envoyé par mail pour la réinitialisation de votre mots de passe, veuillez verifier vos spams.', context);
    } catch (e) {
      if (e.toString().contains('Must be a valid email address')) {
        return showMessage('Veuillez entrer une adresse email valide.', context);
      } else {
        return showMessage('Une erreur est arrivé.', context);
      }
    }
  }

  // Modify Password
  Future modifyPassword(String email, String oldPassword, String newPassword, context) async {
    try {
      _pocketBase.authStore.clear();
      loginWithEmail(email, oldPassword, context);
      await _pocketBase.collection('users').confirmPasswordReset(_pocketBase.authStore.token, newPassword, newPassword);
      return showMessage('Votre mots de passe a bien été modifié.', context);
    } catch (e) {
      print(e);
      if (e.toString().contains('Must be a valid email address')) {
        return showMessage('Veuillez entrer une adresse email valide.', context);
      } else {
        return showMessage('Une erreur est arrivé.', context);
      }
    }
  }

  // Watch if someone connect or disconnect from his account
  Stream<User?> listenToUserChanges() {
    return _connectedUser.stream;
  }

  // Check if the user is logged in
  User? getConnectedUser() {
    return _connectedUser.valueOrNull;
  }

  // Create the user in the collection of users
  Future<String> createUser(String username, String email, String password, String passwordVerifier, String gender, String birthday, context) async {
    assert(username.isNotEmpty);
    assert(email.isNotEmpty);
    assert(password.isNotEmpty);
    assert(passwordVerifier.isNotEmpty);
    assert(birthday.isNotEmpty);
    assert(gender.isNotEmpty);

    final body = <String, dynamic>{
      "username": username,
      "email": email.toLowerCase(),
      "emailVisibility": true,
      "password": password,
      "passwordConfirm": passwordVerifier,
      "birthday": birthday,
      "gender": gender,
      "role": "user"
    };

    return _pocketBase
        .collection('users')
        .create(body: body)
        .catchError((e) {
          print(e);
          showMessage('Une erreur est arrivé $e', context);
          return e;
        })
        .then((value) => value.id)
        .then((id) async {
          await sendVerification(email);
          return id;
        });
  }

  sendVerification(String email) {
    return _pocketBase.collection('users').requestVerification(email);
  }

  deleteUser(String recordId) {
    return _pocketBase.collection('users').delete(recordId);
  }

  // Find the user in the collection of users
  Future<User?> findUser(String email) async {
    assert(email.isNotEmpty);
    debugPrint('Finding user with email $email');
    var value2 = await _pocketBase.collection('users').getFirstListItem('email="$email"');
    debugPrint('User found with email $email');
    return _pocketBase.collection('users').getFirstListItem('email="$email"').then(
          (value) => User.fromJSON(value.id, value.collectionId, value.data, value.created, value.updated, value.data['birthday']),
        );
  }

  // Update the avatar of the user
  updateAvatar(String collectionId, String userId, String fileName, String filePath, context) {
    return _pocketBase.collection(collectionId).update(userId, files: [
      MultipartFile.fromBytes(
        'avatar',
        File(filePath).readAsBytesSync(),
        filename: fileName,
      )
    ]).catchError((e) {
      debugPrint(e.toString());
      showMessage('Une erreur est arrivé', context);
      return e;
    });
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

  // Get the data from one field of a collection with order
  Future<List<RecordModel>> getOneOrder(String collectionId, String recordId, order) {
    return _pocketBase.collection(collectionId).getOne(recordId).then((value) => [value]);
  }

  // Get the data from one field of a collection with expand
  Future<List<RecordModel>> getOneExpand(String collectionId, String recordId, String? expand) {
    return _pocketBase.collection(collectionId).getOne(recordId, expand: expand).then((value) => [value]);
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

  Future<List<RecordModel>> getCollectionDataWithFilterExpand(String collectionId, String query, String expand) {
    return _pocketBase
        .collection(collectionId)
        .getList(
          page: 1,
          perPage: 500,
          filter: query,
          expand: expand,
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

  Future<int> getNumberOwnedManga(String id) async {
    int count = 0;

    try {
      // Get the data from the collection owned (The API send only the one that are created by the user)
      final result = await _pocketBase.collection('owned').getFullList(
            filter: "user='$id'",
          );

      // Get the number of manga owned by the user
      count = result.length;
    } catch (e) {
      print(e);
    }

    return count; // Return the number of manga owned by the user
  }

  Future<int> getNumberFavSerie(String id) async {
    int count = 0;

    try {
      // Get the data from the collection fav (The API send only the one that are created by the user)
      final result = await _pocketBase.collection('followed').getFullList(
            filter: "user='$id'",
          );
      // Get the number of manga fav by the user
      count = result.length;
    } catch (e) {
      print(e);
    }

    return count; // Return the number of manga fav by the user
  }

  // Listen to the changes of a collection
  Stream<RecordSubscriptionEvent> listenToCollectionEvents(String collectionId) {
    return _pocketBase.collection(collectionId).listen();
  }

  // Get the author name
  Future<String> getAuthorName(String authorId) async {
    var author = await PocketBaseConnector().getOne('authors', authorId);
    return json.decode(author[0].toString())['name'].toString();
  }

  // Get the editor name
  Future<String> getEditorName(String editorId) async {
    var editor = await PocketBaseConnector().getOne('editors', editorId);
    return json.decode(editor[0].toString())['name'].toString();
  }

  Future<String> getVolumeImage(String volumeId) async {
    var volumeImage = await PocketBaseConnector().getOne('volumes', volumeId);
    return json.decode(volumeImage[0].toString())['image'].toString();
  }

  // Get the information about a sub serie
  Future<Map<String, dynamic>> getSubSerie(String id) async {
    var subSeries = await PocketBaseConnector().getOne('sub_series', id);
    return json.decode(subSeries[0].toString());
  }

  // Get the images of some volumes of a sub serie
  Future<List<String>> getSubSerieVolumesImages(String id) async {
    var subSeries = await PocketBaseConnector().getOne('sub_series', id);
    var volumes = json.decode(subSeries[0].toString())['volumes'];
    List<String> images = [];
    List<String> tomeNumbers = [];

    // Get the images of the volumes
    for (var volume in volumes) {
      var volumeImage = await PocketBaseConnector().getOne('volumes', volume);
      images.add(
          '"https://api.mymangatheque.com/api/files/tnof8u6oqfepdq6/${json.decode(volumeImage[0].toString())['id']}/${json.decode(volumeImage[0].toString())['image']}"');
      tomeNumbers.add(json.decode(volumeImage[0].toString())['tome_number'].toString());
    }

    // Sort the images by the tome number
    for (var i = 0; i < tomeNumbers.length; i++) {
      for (var j = i + 1; j < tomeNumbers.length; j++) {
        if (int.parse(tomeNumbers[i]) > int.parse(tomeNumbers[j])) {
          var temp = tomeNumbers[i];
          tomeNumbers[i] = tomeNumbers[j];
          tomeNumbers[j] = temp;
          temp = images[i];
          images[i] = images[j];
          images[j] = temp;
        }
      }
    }
    return images;
  }

  // Add a volume to the collection owned
  Future<void> addVolumeToOwned(String userId, String volumeId, bool readState) async {
    final body = <String, dynamic>{
      "user": userId,
      "volume": volumeId,
      "readed": readState,
    };

    await _pocketBase.collection('owned').create(body: body);
  }

  // Remove a volume from the collection owned
  Future<void> removeVolumeFromOwned(String userId, String volumeId) async {
    final result = await _pocketBase.collection('owned').getFullList(
          filter: "user='$userId'&&volume='$volumeId'",
        );
    final id = json.decode(result.toString())[0]['id'];
    await _pocketBase.collection('owned').delete(id);
  }

  // Verify if the user already own the volume
  Future<bool> isVolumeOwned(String userId, String volumeId) async {
    final result = await _pocketBase.collection('owned').getFullList(
          filter: "user='$userId'&&volume='$volumeId'",
        );
    return !result.toString().contains('[]');
  }

  // Change the read state of a volume
  Future<void> changeReadState(String userId, String volumeId, bool readState) async {
    final result = await _pocketBase.collection('owned').getFullList(
          filter: "user='$userId'&&volume='$volumeId'",
        );
    final id = json.decode(result.toString())[0]['id'];
    final body = <String, dynamic>{
      "readed": readState,
    };
    await _pocketBase.collection('owned').update(id, body: body);
  }

  // Verify if the user as read the volume
  Future<bool> isVolumeReaded(String userId, String volumeId) async {
    final result = await _pocketBase.collection('owned').getFullList(
          filter: "user='$userId'&&volume='$volumeId'",
        );
    return json.decode(result.toString())[0]['readed'];
  }

  // Add a sub_series to the collection followed
  Future<void> addSubSeriesToFollowed(String userId, String subSeriesId) async {
    final body = <String, dynamic>{
      "user": userId,
      "sub_serie": subSeriesId,
    };

    await _pocketBase.collection('followed').create(body: body);
  }

  Future<void> removeSubSeriesToFollowed(String userId, String subSeriesId) async {
    final result = await _pocketBase.collection('followed').getFullList(
          filter: "user='$userId'&&sub_serie='$subSeriesId'",
        );
    final id = json.decode(result.toString())[0]['id'];
    await _pocketBase.collection('followed').delete(id);
  }

  // Verify if the user already own the volume
  Future<bool> isSubSeriesFollowed(String userId, String subSeriesId) async {
    final result = await _pocketBase.collection('followed').getFullList(
          filter: "user='$userId'&&sub_serie='$subSeriesId'",
        );
    return !result.toString().contains('[]');
  }

  Future<String> getAppVersion() async {
    return PackageInfo.fromPlatform().then((value) => value.version).toString();
  }

  Future<String> get appVersion async => await PackageInfo.fromPlatform().then((value) => value.version);

  Future<String> get buildVersion async => await PackageInfo.fromPlatform().then((value) => value.buildNumber);

  String get serverUrl => _pocketBase.baseUrl;
}
