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
- [0.0.1+10](#0020---friday-january-30-2026)
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

- Added a weighted project roadmap ordered by descending importance, covering
  product, persistent caching, platform, recommendation, social, local AI, and
  public API priorities.

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
- [0.0.1+10](#0020---vendredi-30-janvier-2026)
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

- Ajout d'une roadmap pondérée et classée par importance décroissante couvrant
  les priorités produit, cache persistant, plateformes, recommandations,
  fonctions sociales, IA locale et API publique.

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
