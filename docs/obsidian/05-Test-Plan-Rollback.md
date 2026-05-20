# Test Plan & Rollback

## Plan d’acceptation
- [ ] Démarrage invité: session anonyme + clé API 2h + home/search/library OK.
- [ ] Expiration clé: refresh auto avant expiration, retry transparent `401/403`.
- [ ] Auth complète: signup/login/logout/OAuth OK mobile + web.
- [ ] Recovery password: email envoyé, callback `userId/secret`, updateRecovery OK.
- [ ] Profil: `GET/PATCH /api/users/me` + avatar Appwrite Storage + `coverURL`.
- [ ] Owned/followed: add/remove/toggle readed cohérents côté UI.
- [ ] Détails contenus: pages série/sous-série/volume/auteur/éditeur cohérentes via mapping.
- [ ] Notifications: enregistrement push target + in-app + fallback polling.
- [ ] Routing: routes utilisateur OK, admin affiche “en migration”.
- [ ] Nettoyage: `rg pocketbase` == 0 dans `lib/` + `test/`.

## Commandes de validation
```bash
flutter analyze
flutter test
rg -n "pocketbase|PocketBase|pocket base" lib test
rg -n "api/files" lib
```

## Rollback (si incident prod)
1. Revenir au tag/commit stable pré-migration.
2. Réactiver build avec ancien backend (PocketBase) côté app.
3. Désactiver feature flag migration si disponible.
4. Purger cache local app (token/clé API) au redémarrage.
5. Communiquer incident + ETA correctif.

## Points de contrôle post-déploiement
- Taux login succès/échec.
- Taux erreurs `/api/auth/keys/mobile`.
- Erreurs `401/403` API key expirée.
- Latence endpoints catalogue.
- Taux crash sur pages profil/library/search.

## Risques connus
- Différences de schéma entre environnements (staging/prod).
- Données legacy partielles sur certains documents.
- Polling notifications à ajuster selon charge.
