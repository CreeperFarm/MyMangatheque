# Notifications Push + In-App

## But
Fournir une base notifications compatible mobile:
- push ciblé via Appwrite,
- affichage in-app,
- fallback polling API.

## Implémentation
- Service: `lib/src/back/services/notifications/notification_service.dart`
- Initialisation depuis `AppwriteConnector.init()`.
- Enregistrement device:
  - `registerPushTarget(deviceToken, targetId)`
  - Appwrite `Account.createPushTarget(...)`.

## In-App notifications
- Modèle: `InAppNotification`.
- Source:
  - push reçu (`ingestIncomingPush(payload)`),
  - fallback polling périodique.
- Stream broadcast pour UI:
  - `NotificationService.stream`
  - exposé via `AppwriteConnector.listenToNotifications()`.
- Boîte persistante bornée à 100 entrées, accessible depuis le profil.
- États lu/non lu, marquage global, effacement local et deep links validés.
- Événements reçu/ouvert dédupliqués et conservés pour reprise hors ligne.

## Fallback polling
- Intervalle adaptatif de 5 à 30 min afin de limiter réseau et batterie.
- Endpoint heartbeat actuel: `/api/analytics/health`.
- Les notifications applicatives restent transportées par FCM/Appwrite ; le
  heartbeat surveille uniquement la disponibilité du mécanisme de secours.
