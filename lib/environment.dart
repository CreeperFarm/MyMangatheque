class Environment {
  static const String appwriteProjectId = '69a59d8c003140f373d3';
  static const String appwriteProjectName = 'MyMangatheque';
  static const String appwritePublicEndpoint =
      'https://appwrite.mymangatheque.com/v1';
  static const String appwriteFcmProviderId = 'mmt_notification_provider';

  /// Public Web Push key generated in Firebase Console > Cloud Messaging.
  /// Inject it into Web builds with FIREBASE_WEB_VAPID_KEY.
  static const String firebaseWebVapidKey = String.fromEnvironment(
    'FIREBASE_WEB_VAPID_KEY',
  );
}
