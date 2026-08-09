# MyMangathèque

[![WakaTime](https://wakatime.com/badge/github/CreeperFarm/MyMangatheque.svg)](https://wakatime.com/badge/github/CreeperFarm/MyMangatheque)

## Summary / Sommaire

### English

- [Overview](#english)
- [Features](#features)
- [Architecture](#architecture)
- [Local setup](#local-setup)
- [Quality and tests](#quality-and-tests)
- [Production builds](#production-builds)
- [Push notifications](#push-notifications)
- [Docker, GHCR, and Portainer](#docker-ghcr-and-portainer)
- [CI/CD](#cicd)
- [Configuration and security](#configuration-and-security)
- [License](#license)

### Français

- [Présentation](#français)
- [Fonctionnalités](#fonctionnalités)
- [Architecture](#architecture-1)
- [Démarrage local](#démarrage-local)
- [Qualité et tests](#qualité-et-tests)
- [Builds de production](#builds-de-production)
- [Notifications push](#notifications-push)
- [Docker, GHCR et Portainer](#docker-ghcr-et-portainer)
- [CI/CD](#cicd-1)
- [Configuration et sécurité](#configuration-et-sécurité)
- [Licence](#licence)

---

## English

MyMangathèque is a Flutter application for managing a manga collection,
tracking reading progress and wishlists, searching the catalogue, and
discovering new releases.

- Website: [mymangatheque.com](https://mymangatheque.com)
- API: [api.mymangatheque.com](https://api.mymangatheque.com)
- Current version: `0.0.2+16`
- Languages: English and French
- Platforms: Web, Android, and iOS
- Documentation: [changelog](CHANGELOG.md) · [roadmap](ROADMAP.md)

### Features

#### Personal library

- Owned-volume collection with read and unread states.
- Reading pile calculated from owned volumes.
- Wishlist and sub-series tracking.
- Detection of missing volumes needed to complete a series.
- Fast additions through EAN barcode scanning.
- User-isolated collection cache with local recovery when the API is
  temporarily unavailable.
- Missing-volume statuses, wanted-volume markers, purchase prioritization, and
  release tracking by sub-series.
- Collection import from a Mangacollec profile, Mangacollec CSV/JSON exports,
  generic CSV/JSON files, EAN/ISBN lists, or free text, with mandatory preview,
  duplicate detection, manual matching, progress, cancellation, and undo. The
  import is one-time: no later Mangacollec synchronization is performed.

#### Catalogue and discovery

- Browsing of volumes, series, sub-series, authors, and publishers.
- Paginated search and real-time suggestions.
- Public or personalized home recommendations, with an automatic public
  fallback when personalized recommendations are unavailable.
- Privacy-conscious local re-ranking based on owned/read volumes, followed
  series, genres, authors, publishers, and explicit preferences, with diversity,
  explanations, hide/not-relevant feedback, and fixed sponsored/editorial slots.
- Monthly release calendar with previous/next navigation, responsive cards,
  pull-to-refresh, and offline recovery.
- Persistent offline recovery for catalogue pages, recent searches, detailed
  records and EAN scans, with separate Web/native quotas.
- Clearly identified editorial and sponsored content, with deduplicated
  impression, click, and conversion measurement.

#### Account and personalization

- Email and password sign-up and sign-in.
- Google sign-in through Appwrite, using a Web redirect compatible with browsers
  that block popups.
- Password recovery and editing of the password, profile, and avatar.
- Account deletion and privacy-related requests.
- Light, dark, or system themes and an interface available in English or French.
- Comfortable or compact density across home, collection, search and releases.
- Configurable recommendation order, navigation-label visibility and reduced
  motion, all persisted and applied immediately.
- Opt-in push notifications through Firebase Cloud Messaging and Appwrite
  Messaging, with per-installation targets, token renewal, foreground display,
  safe deep links, and cleanup on sign-out.

#### Administration

The administration area covers:

- users, roles, suspensions, reports, and GDPR requests;
- catalogue creation and quality control, anomalies, duplicates, EANs, covers,
  and relationships;
- sponsored campaigns, editorial recommendations, budgets, targeting,
  frequency caps, impressions, clicks, conversions, and reports;
- revenue, sponsor invoices, and payment tracking;
- product and notification analytics;
- period comparisons and exports for summary, product, notification, commercial,
  and editorial analytics;
- deployments, versions, API/Appwrite health, jobs, caches, errors, latency,
  quotas, feature flags, and audit history.

### Architecture

| Layer | Technologies and responsibilities |
| --- | --- |
| Interface | Flutter, Material/Cupertino, and adaptive layouts |
| State | Riverpod, in-memory caches, and versioned persistent JSON caches |
| Navigation | `go_router` with independent stacks for the main user journeys |
| Authentication | Appwrite accounts, sessions, and OAuth |
| Application data | REST API at `api.mymangatheque.com` through a unified mobile client |
| Mobile keys | Short-lived client-generated keys with automatic rotation and renewal |
| Real time | Appwrite Realtime with fallback and deduplicated refreshes |
| Local storage | `flutter_secure_storage` for secrets, `shared_preferences` for preferences/data caches, and a bounded disk cache for images |
| Observability | Product events, notification lifecycle, and administrator analytics |
| Web | Flutter Web/WASM served by Nginx with CSP and isolation headers |

Main directories:

```text
lib/
├── l10n/                         # English/French localization sources and code
├── src/back/                     # Routing, providers, and services
│   ├── provider/                 # Riverpod state
│   └── services/                 # API, Appwrite, OAuth, analytics, security
├── src/front/                    # Flutter pages and components
│   ├── page/admin_pages/         # Administration area
│   ├── page/auth/                # Authentication and recovery
│   ├── page/library/             # Collection, reading pile, missing, wishlist
│   └── page/search/              # Catalogue search
└── src/models/                   # Models and local persistence
test/                             # Unit, widget, and regression tests
distribution/whatsnew/            # English/French Google Play release notes
nginx/                            # Web container configuration
```

### Local setup

#### Requirements

- Flutter `3.38.9` stable or compatible;
- Dart `>= 3.10.0 < 4.0.0`;
- Java 17 for Android;
- Chrome for Web development, or a mobile device/emulator.

#### Installation

```bash
git clone https://github.com/CreeperFarm/MyMangatheque.git
cd MyMangatheque
flutter pub get
flutter gen-l10n
```

Run the Web application:

```bash
flutter run -d chrome
```

Run on an available device:

```bash
flutter devices
flutter run -d <device-id>
```

The public Appwrite configuration is stored in
[`lib/environment.dart`](lib/environment.dart). The project identifier and
public endpoint are not secrets. Tokens, passwords, administrator keys, and
service accounts must never be committed.

#### Icons and splash screen

After changing `pubspec.yaml` or the related assets:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### Quality and tests

Recommended checks before opening a pull request:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter test --coverage
flutter build web --release --wasm
```

Latest documented local validation:

- clean Flutter analysis;
- **168 passing unit and widget tests**;
- successful production Flutter Web/WASM build;
- dedicated tests for OAuth, security, storage, notifications, administration,
  deployment, persistent caching, release planning, reliability monitoring,
  collection import, recommendation ranking, search, home, library, and account
  switching.

### Production builds

#### Web/WASM

```bash
flutter build web --release --wasm
```

The result is generated in `build/web`.

#### Obfuscated Android App Bundle

The version name and version code come from the `version` field in
`pubspec.yaml`.

```bash
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=out/android/symbols
```

Keep the symbols for each release so that error reports can be deobfuscated.

### Push notifications

Firebase Cloud Messaging transports notifications on Android, Web, and the
prepared iOS client. Appwrite Messaging remains the only sender and uses the
provider ID `mmt_notification_provider`. The application requests permission
only when a signed-in user enables **Push notifications** in their profile,
then creates a separate Appwrite target for that installation.

Received notifications are kept in a bounded, persistent on-device inbox
available from the profile. It supports unread counts, mark-all-as-read,
clearing, and validated internal deep links. Received/opened analytics are
deduplicated and queued locally for retry when the network is unavailable.

Android uses `android/app/google-services.json`. Web uses
`web/firebase-messaging-sw.js` and requires the public Web Push certificate
from Firebase Console > Project settings > Cloud Messaging. For a local Web
run or build, inject it with:

```bash
flutter run -d chrome \
  --dart-define=FIREBASE_WEB_VAPID_KEY=<public-vapid-key>

flutter build web --release --wasm \
  --dart-define=FIREBASE_WEB_VAPID_KEY=<public-vapid-key>
```

Set the same public value as the GitHub repository variable
`FIREBASE_WEB_VAPID_KEY`; the Docker workflow passes it to the Web build. Do
not put the Firebase service-account JSON, an Appwrite server key, or an APNs
private key in Flutter or in repository variables.

The iOS client code and `GoogleService-Info.plist` are ready. Once an Apple
Developer account is available, enable **Push Notifications** and
**Background Modes > Remote notifications** for Runner, upload an APNs `.p8`
key to Firebase, and build with an Apple provisioning profile. No client logic
change should then be required.

### Docker, GHCR, and Portainer

The `Dockerfile` compiles the application to WebAssembly and serves it through
Nginx. The image exposes port `80` and provides the `/healthz` health check.

#### Local build

```bash
docker build -t mymangatheque-web:local .
docker run --rm -p 7765:80 mymangatheque-web:local
curl --fail http://localhost:7765/healthz
```

The application is then available at `http://localhost:7765`.

#### GHCR image

The production image is published as:

```text
ghcr.io/creeperfarm/mymangatheque-web
```

For a private image, use a GitHub Personal Access Token limited to
`read:packages`:

```bash
docker login ghcr.io -u <github-username>
docker pull ghcr.io/creeperfarm/mymangatheque-web:latest
```

Configure Portainer with:

- registry: `ghcr.io`, using an account allowed to read the private package;
- image: `ghcr.io/creeperfarm/mymangatheque-web:latest`;
- published host port: **`7765`**;
- container port: **`80`**;
- redeployment webhook stored in the `PORTAINER_WEBHOOK_URL` GitHub secret.

### CI/CD

A push to `main` starts
[`deploy-web-&-android.yml`](.github/workflows/deploy-web-&-android.yml):

1. dependency installation, analysis, tests, and coverage;
2. in parallel after the tests:
   - multi-architecture Web/WASM build (`linux/amd64`, `linux/arm64`);
   - GHCR publication with `latest`, version, and Git SHA tags;
   - obfuscated Android App Bundle build and publication to the Google Play
     internal track;
3. Portainer webhook trigger after the Web image is published.
4. production `/healthz` verification with bounded retries after redeployment;
5. smoke validation of the Web shell, Wasm artifact, security headers, API
   health and CORS.

GitHub secrets required for a complete release:

| Secret | Purpose |
| --- | --- |
| `KEYSTORE_DECRYPTION_PASSWORD` | Decrypt the Android signing key |
| `STORE_PASSWORD` | Keystore password |
| `KEY_PASSWORD` | Android key password |
| `KEY_ALIAS` | Signing-key alias |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Google Play publication |
| `PORTAINER_WEBHOOK_URL` | Web container redeployment |
| `SONAR_TOKEN` | SonarQube analysis in the quality workflow |

Optional variables:

- `CONTAINER_IMAGE` overrides the GHCR image name;
- `GOOGLE_PLAY_TRACK` overrides the default `internal` track;
- `PRODUCTION_HEALTHCHECK_URL` overrides the default production health URL;
- `PRODUCTION_WEB_BASE_URL` and `PRODUCTION_API_BASE_URL` override the public
  endpoints used by smoke tests.
- `FIREBASE_WEB_VAPID_KEY` is the Firebase public Web Push certificate required
  for Web notification registration.

Google Play release notes are maintained in
`distribution/whatsnew/whatsnew-en-US` and
`distribution/whatsnew/whatsnew-fr-FR`, with a maximum of 500 characters per
file.

The [`code-quality.yml`](.github/workflows/code-quality.yml) workflow also runs
analysis, tests with coverage, and SonarQube analysis for pull requests and
changes to `main`.

[`validate-ios.yml`](.github/workflows/validate-ios.yml) compiles an unsigned
iOS release on pushes and pull requests. [`production-smoke.yml`](.github/workflows/production-smoke.yml)
repeats the external production checks every six hours and on demand.

### Configuration and security

- Application traffic uses HTTPS; cleartext Android traffic is disabled.
- Local secrets are stored through `flutter_secure_storage`.
- External images and links are validated before use.
- Production logs do not expose tokens, API keys, or raw errors.
- The Web container applies a CSP, isolation headers, a permissions policy, and
  conservative caching to prevent an obsolete build from being retained.
- Private caches are separated by user and cleared when switching accounts or
  signing out; public application data is capped at 4 MiB on Web and 16 MiB on
  native platforms, in addition to the bounded image cache.
- API latency, HTTP failures, timeouts, and uncaught application failures are
  measured without retaining sensitive payloads or record identifiers.

See [CHANGELOG.md](CHANGELOG.md) for the detailed history and
[ROADMAP.md](ROADMAP.md) for planned work.

### License

This project is distributed under the terms of [LICENSE](LICENSE).
Third-party dependency licenses are listed in
[THIRD_PARTY_LICENSE.md](THIRD_PARTY_LICENSE.md).

---

## Français

MyMangathèque est une application Flutter permettant de gérer une collection
de mangas, suivre ses lectures et ses envies, rechercher le catalogue et
découvrir de nouvelles parutions.

- Site : [mymangatheque.com](https://mymangatheque.com)
- API : [api.mymangatheque.com](https://api.mymangatheque.com)
- Version actuelle : `0.0.2+16`
- Langues : français et anglais
- Plateformes : Web, Android et iOS
- Documentation : [changelog](CHANGELOG.md) · [roadmap](ROADMAP.md)

### Fonctionnalités

#### Bibliothèque personnelle

- Collection de tomes possédés avec état lu ou non lu.
- Pile à lire calculée à partir des tomes possédés.
- Liste d'envies et suivi des sous-séries.
- Détection des tomes manquants pour compléter une série.
- Ajout rapide par scan du code-barres EAN.
- Cache de collection isolé par utilisateur et reprise locale en cas
  d'indisponibilité temporaire de l'API.
- États des tomes manquants, marquage des tomes souhaités, priorisation des
  achats et suivi des sorties par sous-série.
- Import de collection depuis un profil Mangacollec, ses exports CSV/JSON, des
  fichiers CSV/JSON génériques, des listes EAN/ISBN ou du texte libre, avec
  prévisualisation obligatoire, détection des doublons, correction manuelle,
  progression, annulation et retour arrière. L'import reste ponctuel : aucune
  synchronisation Mangacollec ultérieure n'est effectuée.

#### Catalogue et découverte

- Consultation des tomes, séries, sous-séries, auteurs et éditeurs.
- Recherche paginée et suggestions en temps réel.
- Accueil public ou personnalisé avec repli automatique si les recommandations
  personnalisées sont indisponibles.
- Reclassement local respectueux de la vie privée selon les tomes possédés/lus,
  séries suivies, genres, auteurs, éditeurs et préférences explicites, avec
  diversité, explications, retours masquer/non pertinent et emplacements
  sponsorisés/éditoriaux immuables.
- Calendrier mensuel des sorties avec navigation, cartes adaptatives,
  actualisation manuelle et reprise hors ligne.
- Reprise hors ligne persistante pour le catalogue, les recherches récentes,
  les fiches détaillées et le scan EAN, avec quotas Web/natif distincts.
- Contenus éditoriaux et sponsorisés clairement identifiés, avec mesure
  dédupliquée des impressions, clics et conversions.

#### Compte et personnalisation

- Connexion et inscription par e-mail et mot de passe.
- Connexion Google via Appwrite, avec redirection Web compatible avec les
  navigateurs bloquant les popups.
- Récupération et modification du mot de passe, profil et avatar.
- Suppression de compte et demandes liées à la vie privée.
- Thèmes clair, sombre ou système et interface en français ou en anglais.
- Densité confortable ou compacte sur l’accueil, la collection, la recherche
  et les sorties.
- Ordre des recommandations, visibilité des libellés de navigation et réduction
  des animations configurables, persistants et appliqués immédiatement.
- Notifications push optionnelles via Firebase Cloud Messaging et Appwrite
  Messaging, avec cible par installation, renouvellement du jeton, affichage au
  premier plan, deep links filtrés et nettoyage à la déconnexion.

#### Administration

Le back-office couvre notamment :

- utilisateurs, rôles, suspensions, signalements et demandes RGPD ;
- création et contrôle qualité du catalogue, anomalies, doublons, EAN,
  couvertures et relations ;
- campagnes sponsorisées, recommandations éditoriales, budgets, ciblage,
  plafonnement de fréquence, impressions, clics, conversions et rapports ;
- revenus, factures sponsors et suivi des paiements ;
- statistiques produit et notifications ;
- comparaisons de périodes et exports des statistiques générales, produit,
  notifications, commerciales et éditoriales ;
- déploiements, versions, santé API/Appwrite, tâches, caches, erreurs, latence,
  quotas, feature flags et journal d'audit.

### Architecture

| Couche | Technologies et responsabilités |
| --- | --- |
| Interface | Flutter, Material/Cupertino et mise en page adaptative |
| État | Riverpod, caches mémoire et caches JSON persistants versionnés |
| Navigation | `go_router` avec piles indépendantes pour les parcours principaux |
| Authentification | Appwrite pour les comptes, sessions et OAuth |
| Données métier | API REST `api.mymangatheque.com` via un client mobile unifié |
| Clés mobiles | Clés temporaires générées côté client, avec rotation et renouvellement automatiques |
| Temps réel | Appwrite Realtime avec repli et rafraîchissement dédupliqué |
| Stockage local | `flutter_secure_storage` pour les secrets, `shared_preferences` pour les préférences/caches métier et cache disque borné pour les images |
| Observabilité | Événements produit, cycle de vie des notifications et statistiques administrateur |
| Web | Flutter Web/WASM servi par Nginx avec CSP et en-têtes d'isolation |

Principaux dossiers :

```text
lib/
├── l10n/                         # Sources et code de traduction FR/EN
├── src/back/                     # Routage, providers et services
│   ├── provider/                 # État Riverpod
│   └── services/                 # API, Appwrite, OAuth, analytics, sécurité
├── src/front/                    # Pages et composants Flutter
│   ├── page/admin_pages/         # Back-office
│   ├── page/auth/                # Authentification et récupération
│   ├── page/library/             # Collection, pile à lire, manquants, envies
│   └── page/search/              # Recherche catalogue
└── src/models/                   # Modèles et persistance locale
test/                             # Tests unitaires, widgets et régressions
distribution/whatsnew/            # Notes de version Google Play FR/EN
nginx/                            # Configuration du conteneur Web
```

### Démarrage local

#### Prérequis

- Flutter `3.38.9` stable ou compatible ;
- Dart `>= 3.10.0 < 4.0.0` ;
- Java 17 pour Android ;
- Chrome pour le développement Web, ou un appareil/émulateur mobile.

#### Installation

```bash
git clone https://github.com/CreeperFarm/MyMangatheque.git
cd MyMangatheque
flutter pub get
flutter gen-l10n
```

Lancer la version Web :

```bash
flutter run -d chrome
```

Lancer sur un appareil disponible :

```bash
flutter devices
flutter run -d <device-id>
```

La configuration publique Appwrite se trouve dans
[`lib/environment.dart`](lib/environment.dart). L'identifiant de projet et le
point d'accès public ne sont pas des secrets. Les jetons, mots de passe, clés
d'administration et comptes de service ne doivent jamais être ajoutés au dépôt.

#### Icônes et écran de démarrage

Après une modification de `pubspec.yaml` ou des ressources associées :

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### Qualité et tests

Commandes de validation recommandées avant une pull request :

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter test --coverage
flutter build web --release --wasm
```

Dernière validation locale documentée :

- analyse Flutter sans anomalie ;
- **168 tests unitaires et widgets réussis** ;
- build Flutter Web/WASM de production réussi ;
- tests spécifiques pour OAuth, sécurité, stockage, notifications,
  administration, déploiement, cache persistant, planning des sorties,
  observabilité, import de collection, classement des recommandations,
  recherche, accueil, bibliothèque et changement de compte.

### Builds de production

#### Web/WASM

```bash
flutter build web --release --wasm
```

Le résultat est généré dans `build/web`.

#### Android App Bundle obfusqué

Le nom et le code de version proviennent du champ `version` de `pubspec.yaml`.

```bash
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=out/android/symbols
```

Conservez les symboles de chaque version afin de pouvoir désobfusquer les
rapports d'erreur.

### Notifications push

Firebase Cloud Messaging transporte les notifications sur Android, Web et le
client iOS déjà préparé. Appwrite Messaging reste l'unique expéditeur avec le
provider `mmt_notification_provider`. L'application demande la permission
uniquement lorsqu'un utilisateur connecté active **Notifications push** dans
son profil, puis crée une cible Appwrite distincte pour cette installation.

Les notifications reçues sont conservées dans une boîte locale persistante et
bornée, accessible depuis le profil. Elle affiche le nombre de messages non
lus, permet de tout marquer comme lu ou d'effacer l'historique, et n'ouvre que
des liens internes validés. Les événements reçu/ouvert sont dédupliqués et mis
en file locale pour être renvoyés après une coupure réseau.

Android utilise `android/app/google-services.json`. Le Web utilise
`web/firebase-messaging-sw.js` et nécessite le certificat Web Push public de
Firebase Console > Paramètres du projet > Cloud Messaging. Pour un lancement
ou un build Web local :

```bash
flutter run -d chrome \
  --dart-define=FIREBASE_WEB_VAPID_KEY=<cle-vapid-publique>

flutter build web --release --wasm \
  --dart-define=FIREBASE_WEB_VAPID_KEY=<cle-vapid-publique>
```

Ajoutez la même valeur publique comme variable GitHub
`FIREBASE_WEB_VAPID_KEY` ; le workflow Docker la transmet au build Web. Ne
placez jamais le JSON du compte de service Firebase, une clé serveur Appwrite
ou une clé privée APNs dans Flutter ou dans les variables du dépôt.

Le client iOS et son `GoogleService-Info.plist` sont prêts. Lorsque le compte
Apple Developer sera disponible, activez **Push Notifications** et
**Background Modes > Remote notifications** pour Runner, importez une clé APNs
`.p8` dans Firebase et signez avec un profil Apple. Aucun changement de logique
cliente ne devrait ensuite être nécessaire.

### Docker, GHCR et Portainer

Le `Dockerfile` compile l'application en WebAssembly puis la sert avec Nginx.
L'image expose le port `80` et fournit le contrôle de santé `/healthz`.

#### Build local

```bash
docker build -t mymangatheque-web:local .
docker run --rm -p 7765:80 mymangatheque-web:local
curl --fail http://localhost:7765/healthz
```

L'application est alors accessible sur `http://localhost:7765`.

#### Image GHCR

L'image de production est publiée sous :

```text
ghcr.io/creeperfarm/mymangatheque-web
```

Pour une image privée, utilisez un Personal Access Token GitHub limité à
`read:packages` :

```bash
docker login ghcr.io -u <github-username>
docker pull ghcr.io/creeperfarm/mymangatheque-web:latest
```

Dans Portainer, configurez :

- registre : `ghcr.io` avec un compte autorisé à lire le package privé ;
- image : `ghcr.io/creeperfarm/mymangatheque-web:latest` ;
- port publié sur l'hôte : **`7765`** ;
- port du conteneur : **`80`** ;
- webhook de redéploiement dans le secret GitHub
  `PORTAINER_WEBHOOK_URL`.

### CI/CD

Un push sur `main` lance le workflow
[`deploy-web-&-android.yml`](.github/workflows/deploy-web-&-android.yml) :

1. installation des dépendances, analyse et tests avec couverture ;
2. en parallèle après les tests :
   - build Web/WASM multi-architecture (`linux/amd64`, `linux/arm64`) ;
   - publication GHCR avec les tags `latest`, version et SHA Git ;
   - build de l'Android App Bundle obfusqué et publication sur la piste interne
     Google Play ;
3. déclenchement du webhook Portainer après la publication de l'image Web.
4. vérification de `/healthz` en production avec tentatives bornées après le
   redéploiement ;
5. validation du shell Web, de l’artefact Wasm, des en-têtes de sécurité, de la
   santé API et de CORS.

Secrets GitHub requis pour une livraison complète :

| Secret | Utilisation |
| --- | --- |
| `KEYSTORE_DECRYPTION_PASSWORD` | Déchiffrement de la clé de signature Android |
| `STORE_PASSWORD` | Mot de passe du keystore |
| `KEY_PASSWORD` | Mot de passe de la clé Android |
| `KEY_ALIAS` | Alias de signature |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Publication Google Play |
| `PORTAINER_WEBHOOK_URL` | Redéploiement du conteneur Web |
| `SONAR_TOKEN` | Analyse SonarQube du workflow qualité |

Variables facultatives :

- `CONTAINER_IMAGE` pour remplacer le nom de l'image GHCR ;
- `GOOGLE_PLAY_TRACK` pour remplacer la piste `internal` ;
- `PRODUCTION_HEALTHCHECK_URL` pour remplacer l'URL de santé de production ;
- `PRODUCTION_WEB_BASE_URL` et `PRODUCTION_API_BASE_URL` pour remplacer les
  points d’accès publics contrôlés par les tests de fumée.
- `FIREBASE_WEB_VAPID_KEY`, certificat Web Push public Firebase requis pour
  enregistrer les notifications Web.

Les notes de mise à jour Google Play sont maintenues dans
`distribution/whatsnew/whatsnew-fr-FR` et
`distribution/whatsnew/whatsnew-en-US`, avec une limite de 500 caractères par
fichier.

Le workflow [`code-quality.yml`](.github/workflows/code-quality.yml) relance
également l'analyse, les tests avec couverture et l'analyse SonarQube sur les
pull requests et les changements de `main`.

[`validate-ios.yml`](.github/workflows/validate-ios.yml) compile une release iOS
non signée sur les pushes et pull requests. [`production-smoke.yml`](.github/workflows/production-smoke.yml)
répète les contrôles externes de production toutes les six heures et à la demande.

### Configuration et sécurité

- Les communications applicatives utilisent HTTPS ; le trafic Android en clair
  est désactivé.
- Les secrets locaux sont stockés avec `flutter_secure_storage`.
- Les images et liens externes sont validés avant utilisation.
- Les logs de production n'exposent pas les jetons, clés API ou erreurs brutes.
- Le conteneur Web applique une CSP, des en-têtes d'isolation, une politique de
  permissions et un cache prudent pour éviter de conserver un ancien build.
- Les caches privés sont séparés par utilisateur et purgés au changement de
  compte ou à la déconnexion ; les données métier publiques sont limitées à
  4 Mio sur le Web et 16 Mio sur les plateformes natives, en plus du cache
  d’images borné.
- La latence API, les erreurs HTTP, les timeouts et les erreurs applicatives non
  interceptées sont mesurés sans conserver de payload sensible ni
  d'identifiant d'enregistrement.

Consultez [CHANGELOG.md](CHANGELOG.md) pour l'historique détaillé et
[ROADMAP.md](ROADMAP.md) pour les travaux prévus.

### Licence

Le projet est distribué selon les termes du fichier [LICENSE](LICENSE).
Les licences des dépendances tierces sont disponibles dans
[THIRD_PARTY_LICENSE.md](THIRD_PARTY_LICENSE.md).
