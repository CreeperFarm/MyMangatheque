# Language in this CHANGELOG.md file

- [English 🇺🇸/🇬🇧](#changelog)
  - [Summary](#summary)
  - [Changes](#changes)
- [Français 🇫🇷](#journal-des-modifications)
  - [Sommaire](#sommaire)
  - [Changements](#changements)

# Changelog

All notable changes to this project are documented in reverse chronological order (most recent first).

## Summary

- [Unreleased](#unreleased)
- [0.0.2+1](#0021---saturday-august-8-2026)
- [0.0.1+10](#00110---friday-january-30-2026)
- [0.0.1+9](#0019---wednesday-january-28-2026)
- [0.0.1+8](#0018---sunday-november-9-2025)
- [0.0.1+7](#0017---tuesday-august-19-2025)
- [0.0.1+6](#0016---friday-august-15-2025)
- [0.0.1+5](#0015---friday-july-25-2025)
- [0.0.1+4](#0014---saturday-february-24-2024)
- [0.0.1+3](#0013---sunday-january-14-2024)
- [0.0.1+2](#0012---monday-november-27-2023)
- [0.0.1+1](#0011---sunday-november-19-2023)

---

## Changes

## [Unreleased]

### Added

- Added complete Firebase Cloud Messaging reception for Android and Web, with
  iOS support prepared for future Apple signing, explicit profile permission,
  foreground notifications, background/terminated handling, and safe deep
  links.
- Added per-installation Appwrite push targets using the
  `mmt_notification_provider` provider, automatic FCM token renewal, target
  removal on sign-out/opt-out, Web VAPID build injection, and notification CSP
  endpoints.
- Added notification route-security and Firebase deployment regression tests,
  bringing the validated suite to **168 passing tests**, with a successful
  Web/WASM Firebase build and unsigned iOS release build.
- Added a persistent, bounded notification inbox with unread state, safe
  navigation, mark-all-as-read and local history clearing.
- Added durable and deduplicated received/opened notification analytics with
  offline retry, stable event identifiers, platform/version metadata and
  opening latency.
- Added shared Appwrite Realtime collection subscriptions with automatic cache
  invalidation, reconnect, adaptive polling fallback and transport metrics,
  replacing the former unconditional 15-second polling.
- Added notification inbox and Realtime synchronization regression tests.
- Added a weighted project roadmap ordered by descending importance, covering
  product, persistent caching, platform, recommendation, social, local AI, and
  public API priorities.
- Added one-time collection imports from Mangacollec profiles, Mangacollec or
  generic CSV/JSON exports, EAN/ISBN lists and free text, with mandatory preview,
  catalogue matching, duplicate detection, manual correction, bounded progress,
  cancellation, per-user history and safe undo. No subsequent Mangacollec
  synchronization is performed.
- Added recommendation preferences, local ranking from the collection, reading
  state, followed series, genres, authors and publishers, cold-start choices,
  diversity, explanations and reversible hide/not-relevant feedback. Sponsored
  and editorial placements remain independent and fixed.
- Added an admin user list with configurable `orderBy` and sort direction.
- Added searchable relation selectors to catalog creation forms.
- Added volume issue corrections for tome numbers and sub-series assignments.
- Improved the administrator statistics dashboard with analytics health and
  permission diagnostics, application version information, wish-list rankings,
  and support for the current popular-volume API response.
- Added dedicated administrator dashboards for product usage and notification
  delivery/opening analytics, including retention, platform, version, campaign,
  and cumulative opening-delay views.
- Added previous-period comparisons to administrator analytics, sponsorship and
  revenue, reusable exports for summary, product, notification and editorial
  data, user search by username/e-mail/ID, and operational version, health and
  latency information.
- Added notification received/opened lifecycle events with stable identifiers
  and deduplicated opening measurements.
- Added privacy-conscious session-start and page-view events for product usage
  analytics, excluding administration routes.
- Consolidated Web and Android delivery into one tested CI/CD workflow, with
  parallel multi-architecture Web container publishing and obfuscated Android
  App Bundle publishing to the Google Play internal track. Android version names
  and codes are now read directly from the `version` field in `pubspec.yaml`.
- Added French and English Google Play release notes for the current version.
- Added seven administrator management modules for sponsored campaigns,
  editorial recommendations, sponsor revenue, full catalogue quality,
  moderation and privacy requests, operations, and immutable audit history.
- Added campaign creation with manga search, budget, schedule, placement,
  targeting and frequency caps, plus performance, cost and report views.
- Added role changes and account suspension/reactivation actions to the user
  administration page, with explicit confirmations for sensitive operations.
- Documented the API routes, permissions and audit requirements required by the
  new administration interface.
- Added visible sponsored and editorial labels on recommendation cards, plus
  privacy-safe, idempotent impression, click, and seven-day conversion tracking.
- Added complete French/English runtime localization for administrator pages,
  catalogue creation, authentication callbacks, planning, EAN scanning,
  services, validators, exceptions and diagnostic logs, with English fallback.
- Added localization-parity, secret-redaction, secure-URL, localized service,
  raw-log and network-image regression tests.
- Added automated OAuth callback, notification lifecycle, secure-storage
  migration, catalogue cache, model round-trip, administrator component,
  deployment hardening and release-configuration tests, with coverage reports
  uploaded by CI for production pushes and pull requests.
- Added regression tests for stale search responses, concurrent pagination,
  home retry recovery, lazy collection rendering, per-user private caches and
  duplicate authentication submissions.
- Added a versioned persistent application cache with per-type expiration,
  stale fallback, bounded pruning, corrupted-entry recovery and private user
  scopes for catalogue data, recommendations, collections and release planning.
- Added persistent bounded image caching and complete cache eviction from the
  profile settings.
- Restored the monthly Planning page with previous/next navigation, responsive
  release cards, refresh, empty/error states and offline recovery.
- Added complete missing-volume tracking with availability states, per-user
  wanted markers, purchase prioritization and sub-series release tracking.
- Added privacy-safe reliability monitoring for API latency, HTTP failures,
  timeouts, network failures and uncaught Flutter errors.
- Extended persistent offline recovery to paginated catalogue browsing, recent
  searches, detailed series/author/editor/volume pages and EAN scans, with
  platform-specific storage quotas and oldest-entry eviction.
- Added persistent interface preferences for recommendation order, compact or
  comfortable density, navigation-label visibility and reduced motion.
- Added scheduled and post-deployment production smoke checks for the Web shell,
  Wasm artifact, security headers, API health and CORS, plus an unsigned iOS
  release build on pushes and pull requests.
- Added regression tests for cache byte quotas, stale retention, interface
  preference restoration, immediate recommendation reordering, reduced-motion
  image rendering, production monitoring and iOS release configuration.
- Added persistent-cache, Planning, missing-volume prioritization, image-cache,
  reliability-monitoring and post-deployment health-check tests, including
  collection-import and recommendation-ranking coverage.

### Changed

- Aligned campaign budgets, targeting, placements, editorial fields, catalogue
  scans, volume issue resolution, exports, and monetary rendering with the
  deployed production OpenAPI contract.
- Preserved promotion metadata while normalizing hydrated volumes so public
  placements can activate as soon as recommendation responses provide it.
- Centralized debug logging behind a localized, release-disabled logger that
  redacts bearer tokens, JWTs, API keys, OAuth tokens and attacker-controlled
  error output.
- Restricted remote images, purchase links, OAuth callbacks and administrator
  exports to validated HTTPS URLs; hardened Appwrite endpoint validation,
  Android/iOS transport policy, Web response headers and CI permissions.
- Migrated the legacy authentication token from preferences to secure storage
  and automatically removes any former unencrypted copy.
- Preserved nullable volume release dates and collection cover images across
  local cache serialization, and made notification timing/reporting injectable
  for deterministic tests.
- Hardened CI with least-privilege permissions, credential persistence disabled,
  timeouts, signing-material cleanup and weekly Dependabot checks for Dart,
  GitHub Actions and Docker dependencies.
- Made collection rendering lazy, increased responsive home-grid density and
  bounded network-image decode sizes to reduce rebuild, memory and scrolling
  costs on large libraries and wide screens.
- Scoped owned-library persistence to the authenticated user and invalidated
  in-memory private data immediately when the account changes.
- Kept generated localization output outside strict static analysis while
  retaining source translation tests, and resolved all remaining analyzer
  issues in application-owned code.
- Reworked the README to document the current Appwrite/API architecture,
  verified feature set, local setup, quality commands, GHCR image, Portainer
  `7765:80` mapping, Google Play delivery and required CI/CD configuration.
- Restored the README to two complete and equivalent English/French sections,
  with both tables of contents directly below the badges, and made the roadmap
  title explicitly bilingual while preserving its complete dual-language plan.
- Restored Planning as the third of five synchronized navigation branches and
  added a compact/comfortable home display-density preference.
- Added a bounded production health check after Portainer redeployment, with an
  optional `PRODUCTION_HEALTHCHECK_URL` override.
- Applied display density across home, collection, search and Planning; home
  recommendations can now retain personalized ranking or be ordered by release
  date or title, while phone navigation can show all labels or only the active
  one.
- Made static analysis warnings fatal in every delivery workflow and moved
  completed work out of the roadmap so it contains only future development.
- Added explicit delivery statuses, the validated client baseline and the next
  recommended milestones to the roadmap.

### Fixed

- Fixed stale and blank states across the reading pile, collection, missing
  volumes and wishlist tabs, including empty-collection wishlist loading,
  resilient relation-ID parsing, retryable API failures, narrow-screen
  collection overflow and consistent empty/search states.
- Fixed collection mutations to compare sub-series and volumes by stable IDs,
  notify Riverpod after changes, remove empty sub-series and refresh the reading
  pile only after a successful read-state update.
- Fixed stale realtime/full-search responses, cross-resource search
  cancellation, duplicate page loads and unrecoverable suggestion errors.
- Fixed authentication failures navigating to the profile, duplicate sign-in,
  sign-up, recovery and password-reset submissions, and raw sign-in errors being
  displayed to users.
- Fixed failed account deletion incorrectly signing the user out and removed
  duplicate logout handling after successful deletion.
- Fixed home cards crashing when recommendation data omits a tome number and
  made initial recommendation failures retryable without restarting the app.
- Fixed catalogue HTTP and mobile-key failures being interpreted as valid empty
  collections, allowing cached content and explicit retry states to remain
  available offline.

## [0.0.2+1] - Saturday, August 8, 2026

### Added

- Added Appwrite authentication, account, storage, guest session, and OAuth
  integration.
- Added a unified REST API client with temporary mobile API keys, automatic
  rotation, and retry after key expiration.
- Added REST-based administration tools for catalog creation, statistics, and
  volume quality control.
- Added push and in-app notification services with a polling fallback.
- Added automated Flutter Web/WASM container builds, private GHCR publishing,
  and Portainer redeployment on pushes to `main`.

### Changed

- Replaced direct PocketBase runtime usage with Appwrite + API service architecture.
- Changed Google authentication on the Web to a same-tab OAuth redirect so it
  works reliably when browsers block popups.
- Updated secure storage and JavaScript interoperability dependencies for Dart
  WebAssembly compatibility.
- Improved catalog parsing, collection synchronization, search, EAN scanning,
  and administration workflows.

### Fixed

- Fixed the WebAssembly build failure caused by the former Web secure-storage
  implementation.
- Fixed mobile API-key registration by generating the secret locally and
  sending its SHA-256 hash to the API.
- Fixed Docker builds when resolving `pubspec.lock` and made application
  dependency resolution reproducible.

### Removed

- Removed `pocketbase` dependency from runtime stack.

## [0.0.1+10] - Friday, January 30, 2026

### Minor Updates

- Modification of the account deletion form
- Automatics compilation when pushing to main

## [0.0.1+9] - Wednesday, January 28, 2026

### Maintenance

- Improved documentation and finalized internal formatting changes for version consistency.

---

## [0.0.1+8] - Sunday, November 9, 2025

### Major Updates

- Upgraded several dependencies including `flutter_riverpod` and `go_router`.
- Refactored `ProfilePage` to improve formatting and null safety.

### Notable Changes

- Simplified and cleaned up unused dependencies.

---

## [0.0.1+7] - Tuesday, August 19, 2025

### Added

- Added an Easter egg feature.
- Resolved a login bug redirecting users incorrectly to the profile.

---

## [0.0.1+6] - Friday, August 15, 2025

### Added

- Integrated user statistics tracking.
- Added a refresh feature after user-initiated updates.

---

## [0.0.1+5] - Friday, July 25, 2025

### Added

- Added text internationalization for multilingual support.

---

## [0.0.1+4] - Saturday, February 24, 2024

### Major Updates

- Improved app theming architecture.
- Refined the profile page layout and routing.

---

## [0.0.1+3] - Sunday, January 14, 2024

### Changed

- Updated app logo and splash screen.

---

## [0.0.1+2] - Monday, November 27, 2023

### Changed

- Renamed the app from `myangatheque` to `mymangatheque`.
- Integrated basic provider implementation.
- Added AutoRoute for navigation.
- Implemented sign-in, sign-up, and Google OAuth integration.

---

## [0.0.1+1] - Sunday, November 19, 2023

### Added

- Initial project setup and dependency installation.

---

# Journal des modifications

Toutes les modifications notables de ce projet sont documentées par ordre chronologique inverse (le plus récent en premier).

## Sommaire

- [Non publié](#non-publié)
- [0.0.2+1](#0021---samedi-8-août-2026)
- [0.0.1+10](#00110---vendredi-30-janvier-2026)
- [0.0.1+9](#0019---mercredi-28-janvier-2026)
- [0.0.1+8](#0018---dimanche-9-novembre-2025)
- [0.0.1+7](#0017---mardi-19-août-2025)
- [0.0.1+6](#0016---vendredi-15-août-2025)
- [0.0.1+5](#0015---vendredi-25-juillet-2025)
- [0.0.1+4](#0014---samedi-24-février-2024)
- [0.0.1+3](#0013---dimanche-14-janvier-2024)
- [0.0.1+2](#0012---lundi-27-novembre-2023)
- [0.0.1+1](#0011---dimanche-19-novembre-2023)

---

## Changements

## [Non publié]

### Ajouts

- Ajout de la réception Firebase Cloud Messaging complète sur Android et Web,
  avec prise en charge iOS préparée pour la future signature Apple, permission
  explicite dans le profil, notifications au premier plan, gestion arrière-plan
  ou application fermée et deep links sécurisés.
- Ajout de cibles push Appwrite par installation via le provider
  `mmt_notification_provider`, renouvellement automatique du jeton FCM,
  suppression à la déconnexion/désactivation, injection VAPID dans le build Web
  et endpoints CSP nécessaires aux notifications.
- Ajout de tests de sécurité des routes de notification et de configuration
  Firebase, portant la suite validée à **168 tests réussis**, avec build
  Web/WASM Firebase et build iOS release non signé validés.
- Ajout d’une boîte de notifications persistante et bornée avec état lu/non lu,
  navigation sécurisée, marquage global comme lu et suppression de l’historique
  local.
- Ajout d’événements de notification reçu/ouvert durables et dédupliqués, avec
  reprise hors ligne, identifiants stables, plateforme/version et délai
  d’ouverture.
- Ajout d’abonnements Appwrite Realtime partagés avec invalidation automatique
  du cache, reconnexion, repli par polling adaptatif et métriques de transport,
  en remplacement du polling systématique toutes les 15 secondes.
- Ajout de tests de régression pour la boîte de notifications et la
  synchronisation temps réel.
- Ajout d'une roadmap pondérée et classée par importance décroissante couvrant
  les priorités produit, cache persistant, plateformes, recommandations,
  fonctions sociales, IA locale et API publique.
- Ajout d'imports ponctuels depuis un profil Mangacollec, des exports
  Mangacollec ou génériques CSV/JSON, des listes EAN/ISBN et du texte libre, avec
  prévisualisation obligatoire, rapprochement catalogue, détection des doublons,
  correction manuelle, progression bornée, annulation, historique par utilisateur
  et retour arrière sûr. Aucune synchronisation Mangacollec ultérieure n'est
  effectuée.
- Ajout des préférences de recommandation et d'un classement local fondé sur la
  collection, l'état de lecture, les séries suivies, genres, auteurs et éditeurs,
  avec démarrage à froid, diversité, explications et retours réversibles
  masquer/non pertinent. Les emplacements sponsorisés et éditoriaux restent
  indépendants et fixes.
- Ajout d'une liste administrateur des utilisateurs avec champ `orderBy` et sens
  de tri configurables.
- Ajout de sélecteurs de relations recherchables dans les formulaires de création.
- Ajout de la correction du numéro de tome et de la sous-série depuis les
  anomalies de volumes.
- Amélioration du tableau de statistiques administrateur avec le diagnostic de
  santé et de permissions analytics, la version de l'application, le classement
  des envies et la prise en charge du contrat actuel des volumes populaires.
- Ajout de tableaux administrateur dédiés à l'usage produit et aux statistiques
  de livraison et d'ouverture des notifications, avec rétention, plateformes,
  versions, campagnes et délais d'ouverture cumulés.
- Ajout des comparaisons avec la période précédente pour les statistiques,
  sponsorisations et revenus, d'exports réutilisables pour les données générales,
  produit, notifications et éditoriales, de la recherche utilisateur par pseudo,
  e-mail ou ID, et des versions, états de santé et latences d'exploitation.
- Ajout des événements de cycle de vie reçu/ouvert des notifications avec
  identifiants stables et mesure d'ouverture dédupliquée.
- Ajout d'événements de démarrage de session et de consultation de page pour les
  statistiques produit, sans suivi des routes d'administration.
- Regroupement des livraisons Web et Android dans un même workflow CI/CD testé,
  avec publication parallèle du conteneur Web multi-architecture et de l'Android
  App Bundle obfusqué sur la piste interne Google Play. Le nom et le code de
  version Android proviennent désormais directement du champ `version` de
  `pubspec.yaml`.
- Ajout des notes de version Google Play en français et en anglais.
- Ajout de sept modules de gestion administrateur pour les campagnes
  sponsorisées, recommandations éditoriales, revenus sponsors, qualité globale
  du catalogue, modération et demandes RGPD, exploitation et journal d’audit.
- Ajout de la création de campagnes avec recherche du manga, budget, période,
  emplacement, ciblage et plafonnement, ainsi que les performances, coûts et
  rapports associés.
- Ajout de la modification des rôles et de la suspension/réactivation des
  comptes depuis la liste utilisateurs, avec confirmation des actions sensibles.
- Documentation des routes API, permissions et exigences d’audit nécessaires à
  la nouvelle interface administrateur.
- Ajout de libellés visibles pour les contenus sponsorisés et éditoriaux, ainsi
  que du suivi respectueux de la vie privée et idempotent des impressions, clics
  et conversions attribuées sur sept jours.
- Internationalisation complète en français et en anglais des pages
  administrateur, de la création du catalogue, des callbacks
  d’authentification, du planning, du scan EAN, des services, validateurs,
  exceptions et logs, avec repli en anglais.
- Ajout de tests de parité des traductions, de masquage des secrets, d’URLs
  sécurisées, de services localisés et de non-régression sur les logs et images
  réseau.
- Ajout de tests de non-régression pour les réponses de recherche obsolètes, la
  pagination concurrente, la reprise de l’accueil, le rendu paresseux des
  collections, les caches privés par utilisateur et les doubles soumissions
  d’authentification.
- Ajout d’un cache applicatif persistant versionné avec expiration par type,
  repli obsolète, nettoyage borné, récupération des entrées corrompues et
  isolation par utilisateur pour catalogue, recommandations, collection et
  planning.
- Ajout d’un cache d’images persistant et borné, avec purge complète depuis les
  réglages du profil.
- Restauration du Planning mensuel avec navigation entre les mois, cartes de
  sorties adaptatives, actualisation, états vide/erreur et reprise hors ligne.
- Ajout du suivi complet des tomes manquants : disponibilité, souhaits par
  utilisateur, priorité d’achat et suivi des sorties par sous-série.
- Ajout d’une observabilité respectueuse de la vie privée pour la latence API,
  les erreurs HTTP, timeouts, échecs réseau et erreurs Flutter non interceptées.
- Extension de la reprise hors ligne aux pages paginées du catalogue, recherches
  récentes, fiches détaillées de séries, auteurs, éditeurs et tomes, ainsi qu’au
  scan EAN, avec quotas propres à chaque plateforme et éviction des entrées les
  plus anciennes.
- Ajout de préférences persistantes pour l’ordre des recommandations, la densité
  compacte ou confortable, la visibilité des libellés de navigation et la
  réduction des animations.
- Ajout de contrôles de production planifiés et post-déploiement pour le shell
  Web, l’artefact Wasm, les en-têtes de sécurité, la santé API et CORS, ainsi que
  d’un build iOS release non signé sur les pushes et pull requests.
- Ajout de tests pour les quotas en octets, la rétention obsolète, la restauration
  des préférences, le réordonnancement immédiat de l’accueil, la réduction des
  animations, la surveillance de production et la configuration iOS release.
- Ajout de tests pour le cache persistant, le Planning, la priorité des tomes
  manquants, le cache d’images, l’observabilité et la santé post-déploiement,
  dont l'import de collection et le classement des recommandations.

### Modifications

- Alignement des budgets, ciblages, emplacements, champs éditoriaux, analyses du
  catalogue, résolutions d’anomalies, exports et montants sur le contrat OpenAPI
  de production déployé.
- Conservation des métadonnées promotionnelles pendant la normalisation des
  volumes afin d’activer les emplacements publics dès que les recommandations
  les fourniront.
- Centralisation des logs de débogage derrière un journal bilingue, désactivé en
  production et masquant les jetons Bearer/JWT, clés API, jetons OAuth et erreurs
  contrôlées par un serveur.
- Restriction des images distantes, liens d’achat, callbacks OAuth et exports
  administrateur aux URLs HTTPS validées, avec durcissement du point d’accès
  Appwrite, des transports Android/iOS, des en-têtes Web et des permissions CI.
- Migration automatique du jeton d’authentification historique vers le stockage
  sécurisé et suppression de son ancienne copie non chiffrée.
- Durcissement de la CI avec permissions minimales, absence de persistance des
  identifiants, délais limites, nettoyage des éléments de signature et contrôles
  Dependabot hebdomadaires pour Dart, GitHub Actions et Docker.
- Rendu paresseux de la collection, densité adaptative accrue de la grille
  d’accueil et limitation de la taille de décodage des images réseau afin de
  réduire les reconstructions, la mémoire et le coût du défilement.
- Séparation du cache de collection possédée par utilisateur et invalidation
  immédiate des données privées en mémoire lors d’un changement de compte.
- Exclusion du code de localisation généré de l’analyse statique stricte, tout
  en conservant les tests des traductions sources, et résolution de toutes les
  alertes restantes dans le code applicatif maintenu par le projet.
- Refonte du README pour documenter l’architecture Appwrite/API actuelle, les
  fonctionnalités validées, l’installation locale, la qualité, l’image GHCR,
  le mapping Portainer `7765:80`, Google Play et la configuration CI/CD requise.
- Restauration du README en deux sections française et anglaise complètes et
  équivalentes, avec les deux sommaires directement sous les badges, et titre de
  la roadmap rendu explicitement bilingue sans modifier son plan complet FR/EN.
- Restauration du Planning comme troisième des cinq branches synchronisées et
  ajout d’une préférence de densité d’accueil compacte ou confortable.
- Ajout d’un contrôle borné de la santé de production après redéploiement
  Portainer, avec surcharge facultative `PRODUCTION_HEALTHCHECK_URL`.
- Application de la densité à l’accueil, la collection, la recherche et au
  Planning ; les recommandations peuvent conserver l’ordre personnalisé ou être
  triées par date ou titre, et la navigation mobile peut afficher tous les
  libellés ou uniquement celui de l’onglet actif.
- Passage de toutes les alertes d’analyse statique en erreurs de CI et retrait
  des travaux terminés de la roadmap afin qu’elle ne contienne que le futur.
- Ajout des états de livraison, du socle client validé et des prochains jalons
  recommandés dans la roadmap.

### Corrections

- Correction des réponses temps réel ou complètes obsolètes dans la recherche,
  de l’annulation entre ressources, des doubles chargements de page et des
  erreurs de suggestions qui bloquaient l’écran.
- Correction de la navigation vers le profil après un échec de connexion, des
  doubles soumissions de connexion, inscription et récupération, ainsi que de
  l’affichage d’erreurs techniques brutes.
- Correction de la déconnexion incorrecte après un échec de suppression de
  compte et suppression de la double déconnexion après une suppression réussie.
- Correction du plantage des cartes d’accueil lorsqu’une recommandation ne
  fournit pas de numéro de tome, avec reprise explicite après un premier échec.
- Correction des erreurs HTTP du catalogue et de clé mobile auparavant
  interprétées comme des collections vides valides, afin de préserver le contenu
  en cache et les états de nouvelle tentative hors ligne.

## [0.0.2+1] - Samedi, 8 août 2026

### Ajouts

- Ajout de l'authentification, des comptes, du stockage, des sessions invitées et
  de l'OAuth avec Appwrite.
- Ajout d'un client API REST unifié avec clés mobiles temporaires, rotation
  automatique et nouvelle tentative après expiration.
- Ajout des outils d'administration REST pour la création du catalogue, les
  statistiques et le contrôle qualité des volumes.
- Ajout des notifications push et internes avec un fallback par polling.
- Ajout du build automatisé du conteneur Flutter Web/WASM, de sa publication
  privée sur GHCR et du redéploiement Portainer après un push sur `main`.

### Modifications

- Remplacement de l'usage runtime direct de PocketBase par une architecture Appwrite + API.
- Passage de l'authentification Google Web à une redirection OAuth dans l'onglet
  courant afin de fonctionner lorsque les navigateurs bloquent les popups.
- Mise à jour du stockage sécurisé et des dépendances d'interopérabilité
  JavaScript pour assurer la compatibilité avec Dart WebAssembly.
- Amélioration du parsing du catalogue, de la synchronisation des collections,
  de la recherche, du scan EAN et des parcours d'administration.

### Corrections

- Correction de l'échec de compilation WebAssembly provoqué par l'ancienne
  implémentation du stockage sécurisé Web.
- Correction de l'enregistrement des clés API mobiles grâce à la génération
  locale du secret et à l'envoi de son hash SHA-256 à l'API.
- Correction du build Docker lors de la résolution de `pubspec.lock` et
  verrouillage reproductible des dépendances de l'application.

### Suppressions

- Suppression de la dépendance `pocketbase` de la stack runtime.

## [0.0.1+10] - Vendredi, 30 janvier 2026

### Mises à jour mineures

- Modifications du formulaire de suppression du compte
- Ajout de la compilation automatique quand il y a un push sur le main

## [0.0.1+9] - Mercredi, 28 janvier 2026

### Maintenance

- Amélioration de la documentation et finalisation des modifications internes pour assurer la cohérence des versions.

---

## [0.0.1+8] - Dimanche, 9 novembre 2025

### Mises à jour majeures

- Mise à niveau de plusieurs dépendances, y compris `flutter_riverpod` et `go_router`.
- Refactorisation de la `ProfilePage` pour améliorer la mise en page et la sécurité null.

### Changements notables

- Nettoyage et simplification des dépendances inutilisées.

---

## [0.0.1+7] - Mardi, 19 août 2025

### Ajouts

- Ajout d'un Easter egg dans l'application.
- Résolution d'un problème de connexion redirigeant incorrectement les utilisateurs vers le profil.

---

## [0.0.1+6] - Vendredi, 15 août 2025

### Ajouts

- Intégration du suivi des statistiques des utilisateurs.
- Ajout d'une fonctionnalité de rafraîchissement après une mise à jour initiée par l'utilisateur.

---

## [0.0.1+5] - Vendredi, 25 juillet 2025

### Ajouts

- Intégration de la fonctionnalité de texte internationalisé pour le support multi-langue.

---

## [0.0.1+4] - Samedi, 24 février 2024

### Mises à jour majeures

- Amélioration de l'architecture des thèmes dans tout l'application.
- Révision de la mise en page de la page de profil et amélioration du routage de l'application.

---

## [0.0.1+3] - Dimanche, 14 janvier 2024

### Modifications

- Mise à jour du logo de l'application et de l'écran de chargement.

---

## [0.0.1+2] - Lundi, 27 novembre 2023

### Modifications

- Renommage de l'application de `myangatheque` à `mymangatheque`.
- Ajout de l'intégration de base de Provider.
- Intégration du package AutoRoute pour la navigation.
- Implémentation des options de connexion, inscription et OAuth Google.

---

## [0.0.1+1] - Dimanche, 19 novembre 2023

### Ajouts

- Initialisation du projet et installation des dépendances.
