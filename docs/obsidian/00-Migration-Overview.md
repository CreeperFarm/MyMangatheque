# Migration Flutter `PocketBase -> Appwrite + API`

## Objectif
- Basculer tous les parcours **utilisateur** vers Appwrite + API REST.
- Supprimer la dépendance runtime PocketBase côté app.
- Garder les routes admin accessibles, mais en mode maintenance (phase 2).

## Scope (Big Bang Utilisateur)
- Authentification: Appwrite (`email/password`, OAuth Google, session guest).
- Données métier: API `/api/*` + `/api/users/me*`.
- API key mobile temporaire (TTL 2h): `/api/auth/keys/mobile`.
- Upload avatar: Appwrite Storage (`user-bucket`) + sync `/api/users/me`.
- Notifications: service push + in-app + fallback polling.
- Admin: désactivé proprement (UI “en migration”).

## Architecture cible
- `AppwriteConnector` (façade unique)  
  Chemin: `lib/src/back/services/appwrite.dart`
- `AppwriteClientService` (SDK Appwrite: account/storage/realtime)  
  Chemin: `lib/src/back/services/appwrite_client.dart`
- `MobileApiClient` (HTTP unifié + headers + retry clé expirée)  
  Chemin: `lib/src/back/services/api/mobile_api_client.dart`
- `MobileApiKeyManager` (stockage clé + expiration + parsing tolérant)  
  Chemin: `lib/src/back/services/api/mobile_api_key_manager.dart`
- `NotificationService` (push target + in-app + polling fallback)  
  Chemin: `lib/src/back/services/notifications/notification_service.dart`
- Compat UI legacy (RecordModel/expand reconstruit)  
  Chemin: `lib/src/back/services/models/api_record_model.dart`

## Décisions techniques verrouillées
- Boot app: session Appwrite guest assurée pour invité.
- API key mobile: rotation automatique à `T-5 min`, refresh transparent sur `401/403`.
- Auth user: JWT Appwrite (`Authorization: Bearer <jwt>`) sur `/api/users/me*`.
- Parsing clé API robuste: support `data.key` ou `key`, `expiresAt` ou fallback `now + 2h`.
- Suppression compte: `Account.updateStatus()` + purge locale + logout.

## Livrables migration
- Nouveau stack services Appwrite/API.
- Remplacement du connecteur PocketBase.
- Routes admin v1 en mode maintenance.
- Documentation runbook + checklist + plan tests/rollback.

## Exclusions (phase 2)
- Refonte complète du back-office admin (CRUD admin avancé, stats admin dédiées).
- Optimisation fine realtime métier (actuellement polling contrôlé pour compat).
