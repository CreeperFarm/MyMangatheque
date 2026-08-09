import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Public Firebase client configuration.
///
/// These identifiers select the Firebase project; they are not server secrets.
/// Server credentials (service-account JSON and APNs private keys) must stay in
/// Appwrite/Firebase and must never be added to this file.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static bool get isSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Firebase Messaging is only configured for Android, iOS and Web.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBf9yqBoDJccYXmBW4vQhDQtnFJXwkRf7M',
    appId: '1:390944577899:web:3c08cc5975878305f7142e',
    messagingSenderId: '390944577899',
    projectId: 'mymangatheque',
    authDomain: 'mymangatheque.firebaseapp.com',
    databaseURL:
        'https://mymangatheque-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'mymangatheque.appspot.com',
    measurementId: 'G-Y50ZXZX206',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAq4h5rJN8kUk7vKu5YvkCaISHBQjMiz98',
    appId: '1:390944577899:android:876fc7a86c7d83ebf7142e',
    messagingSenderId: '390944577899',
    projectId: 'mymangatheque',
    databaseURL:
        'https://mymangatheque-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'mymangatheque.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAAdrTx38SuEocRDswxSryy-_ucgfdRZpU',
    appId: '1:390944577899:ios:e6ee014b15e00a86f7142e',
    messagingSenderId: '390944577899',
    projectId: 'mymangatheque',
    databaseURL:
        'https://mymangatheque-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'mymangatheque.appspot.com',
    iosBundleId: 'com.mymangatheque',
  );
}
