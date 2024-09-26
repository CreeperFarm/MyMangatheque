import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';
import 'package:mymangatheque/src/local_storage/local_storage.dart';
import 'package:mymangatheque/src/local_storage/service_locator.dart';
import 'package:mymangatheque/src/services/models/user.dart';
import 'package:mymangatheque/src/services/utils.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

export 'models/file.dart';
export 'models/user.dart';

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
      lang: 'fr-FR',
      authStore: customAuthStore,
    );

    if (_pocketBase.authStore.isValid) {
      final authRecord = await _pocketBase.collection('users').authRefresh();
      final authInfo = json.decode(authRecord.toString());
      _connectedUser.add(await findUser(authInfo['record']['email']));
    } else {}
  }

  // Singleton
  static final PocketBaseConnector _singleton = PocketBaseConnector._internal();

  factory PocketBaseConnector() {
    return _singleton;
  }

  final BehaviorSubject<User?> _connectedUser = BehaviorSubject<User?>();

  PocketBaseConnector._internal()
      : _pocketBase =
            PocketBase('https://api.mymangatheque.com', lang: 'fr-FR');

  Future<void> refresh() async {
    if (!_pocketBase.authStore.isValid) {
      // TODO: The token has expired. Ask the user to sign in again.
      return;
    }
    final authData = await _pocketBase.collection('users').authRefresh();
  }

  // Check if your logged-in
  bool isLoggedIn() {
    return _connectedUser.valueOrNull != null;
  }

  signInWithGoogle(context) async {
    final authData = await _pocketBase
        .collection('users')
        .authWithOAuth2('google', (url) async {
      await launchUrl(url);
    }, scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/user.gender.read',
      'https://www.googleapis.com/auth/user.birthday.read'
    ], createData: {
      "role": "user",
      "emailVisibility": true,
      "gender": "other",
    });

    print(authData);
    dynamic authData2 = json.decode(authData.toString());
    print(authData2['meta']);
    print(authData2['meta']['isNew']);

    var meta = authData.meta;
    print(meta);

    if (authData2['meta']['isNew']) {
      var data = authData2['meta']['rawUser'];
      print('The email is ' + data['email']);
      print('The link is ' + data['picture']);
      try {
        /*var imageId = await ImageDownloader.downloadImage(data['picture']);
        if (imageId == null) {
          return;
        }
        var fileName = await ImageDownloader.findName(imageId);
        var path = await ImageDownloader.findPath(imageId);*/
        var body = <String, dynamic>{
          "email": data['email'],
          "birthday": DateTime.now().toString(),
        };

        // Upload the image of the user
        var sendImg = await _pocketBase
            .collection('users')
            .update(_pocketBase.authStore.model.id, body: body, files: [
          /*http.MultipartFile.fromBytes(
            'avatar',
            File(path!).readAsBytesSync(),
            filename: fileName,
          )*/
        ]);
        print(sendImg);
      } on PlatformException catch (e) {
        print(e);
        showMessage("Un erreur s'est déroullé", context);
      }
    } else {
      print('User already exists');
    }
    print(authData2['meta']['rawUser']['email']);
    _connectedUser.add(await findUser(
        authData2['meta']['rawUser']['email'].toString().toLowerCase()));
    closeInAppWebView();
  }

  // Login the user with email and password
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      await _pocketBase
          .collection('users')
          .authWithPassword(email.toLowerCase(), password)
          .then((value) => value.token.isNotEmpty);

      _connectedUser.add(await findUser(email.toLowerCase()));

      return _connectedUser.value;
    } catch (err) {
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

  Future resetPassword(String email, context) async {
    await _pocketBase.collection('users').requestPasswordReset(email);
    return showMessage(
        'Un lien vous as été envoyé pour la réinitialisation de votre mots de passe, vérifiez vos spams.',
        context);
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
  Future<String> createUser(String username, String email, String password,
      String passwordVerifier, String gender, String birthday, context) async {
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

    return _pocketBase.collection('users').create(body: body).catchError((e) {
      print(e);
      showMessage('Une erreur est arrivé $e', context);
    }).then((value) => value.id);
  }

  sendVerification(String email) {
    return _pocketBase.collection('users').requestVerification(email);
  }

  deleteUser(String recordId) {
    return _pocketBase.collection('users').delete(recordId);
  }

  // Find the user in the collection of users
  Future<User?> findUser(String email) {
    assert(email.isNotEmpty);
    return _pocketBase
        .collection('users')
        .getFirstListItem('email="$email"')
        .then(
          (value) => User.fromJSON(value.id, value.collectionId, value.data),
        );
  }

  // Update the avatar of the user
  updateAvatar(String collectionId, String userId, String fileName,
      String filePath, context) {
    return _pocketBase.collection(collectionId).update(userId, files: [
      MultipartFile.fromBytes(
        'avatar',
        File(filePath).readAsBytesSync(),
        filename: fileName,
      )
    ]).catchError((e) {
      print(e.toString());
      showMessage('Une erreur est arrivé', context);
    });
  }

  // Remove an entry from a collection
  Future<void> removeEntry(
    String collectionId,
    String entryId,
  ) {
    return _pocketBase.collection(collectionId).delete(entryId);
  }

  // Get the data from a collection
  Future<List<RecordModel>> getCollectionData(String collectionId) {
    return _pocketBase
        .collection(collectionId)
        .getList()
        .then((value) => value.items);
  }

  // Get the data from a collection with a filter
  Future<List<RecordModel>> getCollectionDataWithFilter(
      String collectionId, String query) {
    return _pocketBase
        .collection(collectionId)
        .getList(
          page: 1,
          perPage: 250,
          filter: query,
        )
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
      print('on cancel');
      subscription.cancel();
    };
    subject.onListen = () async => subject.add(
          await getCollectionData(collectionId),
        );
    return subject.stream;
  }

  // Listen to the changes of a collection
  Stream<RecordSubscriptionEvent> listenToCollectionEvents(
      String collectionId) {
    return _pocketBase.collection(collectionId).listen();
  }

  String get serverUrl => _pocketBase.baseUrl;
}
