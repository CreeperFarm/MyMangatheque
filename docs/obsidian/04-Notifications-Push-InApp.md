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

## Fallback polling
- Intervalle par défaut: 5 min.
- Endpoint heartbeat actuel: `/api/analytics/health`.
- Si succès: insertion d’un événement in-app.

## Intégration UI (phase suivante recommandée)
- Brancher un `StreamBuilder` sur `listenToNotifications()`.
- Afficher un badge + liste in-app.
- Marquer lu/non-lu côté client (ou via endpoint backend dédié si ajouté).
