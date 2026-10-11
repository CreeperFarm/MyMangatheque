import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  group('mobile transport security', () {
    test('Android forbids cleartext traffic and device backups', () {
      final manifest = _read('android/app/src/main/AndroidManifest.xml');
      final network = _read(
        'android/app/src/main/res/xml/network_security_config.xml',
      );

      expect(manifest, contains('android:usesCleartextTraffic="false"'));
      expect(manifest, contains('android:allowBackup="false"'));
      expect(manifest, contains('@xml/network_security_config'));
      expect(network, contains('cleartextTrafficPermitted="false"'));
      expect(network, isNot(contains('cleartextTrafficPermitted="true"')));
      expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
      expect(
        manifest,
        contains(
          'com.google.firebase.messaging.default_notification_channel_id',
        ),
      );
    });

    test('Android routes Appwrite OAuth callbacks to the auth plugin', () {
      final manifest = _read('android/app/src/main/AndroidManifest.xml');
      final callbackActivity = RegExp(
        r'<activity\b(?=[^>]*android:name="com\.linusu\.flutter_web_auth_2\.CallbackActivity")[\s\S]*?</activity>',
      ).firstMatch(manifest)?.group(0);
      final mainActivity = RegExp(
        r'<activity\b(?=[^>]*android:name="\.MainActivity")[\s\S]*?</activity>',
      ).firstMatch(manifest)?.group(0);

      expect(callbackActivity, isNotNull);
      expect(callbackActivity, contains('android:exported="true"'));
      expect(callbackActivity, contains('android:taskAffinity=""'));
      expect(
        callbackActivity,
        contains(
          'android:scheme="appwrite-callback-69a59d8c003140f373d3"',
        ),
      );
      expect(mainActivity, isNotNull);
      expect(mainActivity, contains('android:taskAffinity=""'));
      expect(mainActivity, isNot(contains('appwrite-callback-')));
    });

    test('Android keeps collection imports active while the screen sleeps', () {
      final manifest = _read('android/app/src/main/AndroidManifest.xml');
      final importService = RegExp(
        r'<service\b(?=[^>]*android:name="\.CollectionImportForegroundService")[\s\S]*?/>',
      ).firstMatch(manifest)?.group(0);

      expect(manifest, contains('android.permission.FOREGROUND_SERVICE'));
      expect(
        manifest,
        contains('android.permission.FOREGROUND_SERVICE_DATA_SYNC'),
      );
      expect(manifest, contains('android.permission.WAKE_LOCK'));
      expect(importService, isNotNull);
      expect(
        importService,
        contains('android:name=".CollectionImportForegroundService"'),
      );
      expect(
        importService,
        contains('android:foregroundServiceType="dataSync"'),
      );
      expect(importService, contains('android:exported="false"'));
    });

    test('iOS does not permit arbitrary HTTP and localizes permissions', () {
      final plist = _read('ios/Runner/Info.plist');
      final french = _read('ios/Runner/fr.lproj/InfoPlist.strings');
      final english = _read('ios/Runner/en.lproj/InfoPlist.strings');

      expect(plist, contains('<key>NSAppTransportSecurity</key>'));
      expect(plist, isNot(contains('NSAllowsArbitraryLoads')));
      for (final key in <String>[
        'NSCameraUsageDescription',
        'NSPhotoLibraryUsageDescription',
        'NSPhotoLibraryAddUsageDescription',
      ]) {
        expect(french, contains(key));
        expect(english, contains(key));
      }
    });
  });

  group('push notification configuration', () {
    test(
      'Firebase clients and Appwrite provider are wired for each platform',
      () {
        final environment = _read('lib/environment.dart');
        final settings = _read('android/settings.gradle');
        final appGradle = _read('android/app/build.gradle');
        final iosPlist = _read('ios/Runner/Info.plist');
        final serviceWorker = _read('web/firebase-messaging-sw.js');

        expect(
          environment,
          contains("appwriteFcmProviderId = 'mmt_notification_provider'"),
        );
        expect(environment, contains('FIREBASE_WEB_VAPID_KEY'));
        expect(settings, contains('com.google.gms.google-services'));
        expect(appGradle, contains('id "com.google.gms.google-services"'));
        expect(File('android/app/google-services.json').existsSync(), isTrue);
        expect(
          File('ios/Runner/GoogleService-Info.plist').existsSync(),
          isTrue,
        );
        expect(iosPlist, contains('<string>remote-notification</string>'));
        expect(serviceWorker, contains('firebase.messaging()'));
        expect(serviceWorker, contains('firebase.initializeApp'));
      },
    );
  });

  group('Web container hardening', () {
    test('Nginx sends isolation and browser security headers', () {
      final nginx = _read('nginx/default.conf');

      expect(nginx, contains('Cross-Origin-Opener-Policy "same-origin"'));
      expect(nginx, contains('Cross-Origin-Embedder-Policy "credentialless"'));
      expect(nginx, contains('X-Frame-Options "DENY"'));
      expect(nginx, contains('Content-Security-Policy'));
      expect(nginx, contains("default-src 'self'"));
      expect(nginx, contains('https://api.mymangatheque.com'));
      expect(nginx, contains('https://appwrite.mymangatheque.com'));
      expect(nginx, contains('wss://appwrite.mymangatheque.com'));
      expect(nginx, contains('location = /healthz'));
    });

    test('Docker build is reproducible, WASM-enabled and health checked', () {
      final dockerfile = _read('Dockerfile');

      expect(dockerfile, contains('COPY pubspec.* ./'));
      expect(dockerfile, contains('flutter pub get'));
      expect(dockerfile, contains('flutter build web --release --wasm'));
      expect(dockerfile, contains('FIREBASE_WEB_VAPID_KEY'));
      expect(dockerfile, contains('HEALTHCHECK'));
      expect(File('pubspec.lock').existsSync(), isTrue);
    });
  });

  group('release automation', () {
    test('deployment tests before parallel Web and Android builds', () {
      final workflow = _read('.github/workflows/deploy-web-&-android.yml');

      expect(workflow, contains('permissions:\n  contents: read'));
      expect(workflow, contains('persist-credentials: false'));
      expect(workflow, contains('flutter analyze'));
      expect(workflow, contains('flutter test --coverage'));
      expect(workflow, contains('needs: test'));
      expect(workflow, contains('flutter build appbundle'));
      expect(workflow, contains('--obfuscate'));
      expect(workflow, contains('--split-debug-info'));
      expect(workflow, contains("awk '/^version:/"));
      expect(workflow, contains('upload-google-play'));
      expect(workflow, contains('whatsNewDirectory: distribution/whatsnew'));
      expect(workflow, contains('Redeploy Portainer service'));
      expect(workflow, contains('Verify production health after redeployment'));
      expect(workflow, contains('PRODUCTION_HEALTHCHECK_URL'));
      expect(workflow, contains('https://mymangatheque.com/healthz'));
      expect(workflow, contains('tool/production_smoke_check.sh'));
      expect(workflow, contains('PRODUCTION_WEB_BASE_URL'));
      expect(workflow, contains('PRODUCTION_API_BASE_URL'));
      expect(workflow, contains('FIREBASE_WEB_VAPID_KEY'));
    });

    test('pull requests run analysis, tests, coverage and SonarQube', () {
      final workflow = _read('.github/workflows/code-quality.yml');

      expect(workflow, contains('pull_request:'));
      expect(workflow, contains('persist-credentials: false'));
      expect(workflow, contains('flutter analyze'));
      expect(workflow, contains('flutter test --coverage'));
      expect(workflow, contains('coverage/lcov.info'));
      expect(workflow, contains('sonarqube-scan-action'));
    });

    test('iOS release compilation is validated without signing', () {
      final workflow = _read('.github/workflows/validate-ios.yml');

      expect(workflow, contains('pull_request:'));
      expect(workflow, contains('push:'));
      expect(workflow, contains('runs-on: macos-latest'));
      expect(workflow, contains('persist-credentials: false'));
      expect(workflow, contains('flutter analyze'));
      expect(workflow, contains('flutter test'));
      expect(workflow, contains('flutter build ios --release --no-codesign'));
    });

    test('iOS plugins use Swift Package Manager without CocoaPods', () {
      final project = _read('ios/Runner.xcodeproj/project.pbxproj');
      final workspace = _read(
        'ios/Runner.xcworkspace/contents.xcworkspacedata',
      );
      final debugConfiguration = _read('ios/Flutter/Debug.xcconfig');
      final releaseConfiguration = _read('ios/Flutter/Release.xcconfig');

      expect(File('ios/Podfile').existsSync(), isFalse);
      expect(project, contains('FlutterGeneratedPluginSwiftPackage'));
      expect(project, isNot(contains('[CP]')));
      expect(project, isNot(contains('Pods')));
      expect(workspace, isNot(contains('Pods')));
      expect(debugConfiguration, isNot(contains('Pods')));
      expect(releaseConfiguration, isNot(contains('Pods')));
    });

    test('Appwrite SDK matches the deployed 1.8 server', () {
      final pubspec = _read('pubspec.yaml');

      expect(pubspec, contains('appwrite: 22.0.0'));
      expect(pubspec, contains('deployed Appwrite 1.8.x'));
    });

    test('French and English Play notes are present and within the limit', () {
      for (final path in <String>[
        'distribution/whatsnew/whatsnew-fr-FR',
        'distribution/whatsnew/whatsnew-en-US',
      ]) {
        final note = _read(path).trim();
        expect(note, isNotEmpty, reason: path);
        expect(note.runes.length, lessThanOrEqualTo(500), reason: path);
      }
    });

    test('obsolete Web dependencies stay removed', () {
      final pubspec = _read('pubspec.yaml');
      final lock = _read('pubspec.lock');

      expect(
        pubspec,
        isNot(contains(RegExp(r'^\s*url_strategy:', multiLine: true))),
      );
      expect(
        lock,
        isNot(contains(RegExp(r'^\s*url_strategy:', multiLine: true))),
      );
    });
  });
}
