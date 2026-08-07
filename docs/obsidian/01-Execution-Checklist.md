# Checklist d’Exécution (ordre strict)

## 1. Initialisation services
- [x] Créer `AppwriteConnector`, `AppwriteClientService`, `MobileApiClient`, `MobileApiKeyManager`.
- [x] Ajouter couche compatibilité RecordModel/subscribe pour limiter la casse UI.
- [x] Brancher `main.dart` sur `AppwriteConnector().init()`.

## 2. Authentification Appwrite
- [x] Signup email/password.
- [x] Login email/password.
- [x] OAuth Google.
- [x] Logout + purge locale.
- [x] Reset password (email recovery).
- [x] Update mot de passe connecté.
- [x] Suppression compte via `updateStatus`.
- [x] Callback auth/recovery (`/auth/callback`).

## 3. Clé API mobile 2h
- [x] Session guest Appwrite assurée au démarrage invité.
- [x] Générer JWT Appwrite.
- [x] `POST /api/auth/keys/mobile`.
- [x] Stocker `key + expiresAt` (secure storage + fallback).
- [x] Refresh auto à `T-5 min`.
- [x] Retry transparent sur `401/403`.
- [x] Rotation après login/logout.

## 4. Migration données métier
- [x] Séries / sous-séries / volumes / auteurs / éditeurs / genres via API.
- [x] Owned/followed utilisateur via `/api/users/me/*`.
- [x] Pagination auto `page/limit`.
- [x] Reconstruction `expand` côté client pour compat écrans existants.

## 5. Avatar utilisateur
- [x] Upload fichier sur Appwrite Storage (`user-bucket`).
- [x] Patch profil via `/api/users/me` avec `coverURL`.
- [x] Suppression des URLs hardcodées `api/files/...` côté UI.

## 6. Realtime / synchro
- [x] Realtime Appwrite pour session/profil (via refresh + stream user).
- [x] Compat subscriptions via polling contrôlé pour données métier.

## 7. Notifications
- [x] Service notifications push + in-app.
- [x] Enregistrement push target Appwrite (`createPushTarget`).
- [x] Fallback polling API.

## 8. Admin phase 2
- [x] Routes/pages admin maintenues mais désactivées (message migration).
- [x] Dépendance runtime PocketBase admin supprimée.

## 9. Nettoyage codebase
- [x] Supprimer anciens services PocketBase.
- [x] Mettre à jour imports.
- [x] Vérifier `rg pocketbase` == 0 dans `lib/` et `test/`.

## 10. Validation finale
- [x] `flutter analyze` sans erreurs bloquantes.
- [ ] `flutter test` complet (à lancer en CI/dev machine).

## Commandes de vérification
```bash
rg -n "pocketbase|PocketBase|pocket base" lib test
rg -n "api/files" lib
flutter analyze
flutter test
```
