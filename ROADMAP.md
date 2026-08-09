# MyMangathèque Roadmap / Feuille de route MyMangathèque

## Summary / Sommaire

### English

- [Current state](#current-state)
- [Weighting and recommended order](#weighting-and-recommended-order)
- [High priorities](#importance-45--high)
- [Moderate priorities](#importance-35--moderate)
- [Long-term priority](#importance-25--long-term)
- [Recommended next sequence](#recommended-next-sequence)

### Français

- [État actuel](#état-actuel)
- [Pondération et ordre recommandé](#pondération-et-ordre-recommandé)
- [Priorités élevées](#importance-45--élevée)
- [Priorités modérées](#importance-35--modérée)
- [Priorité à long terme](#importance-25--secondaire-à-court-terme)
- [Prochaine séquence recommandée](#prochaine-séquence-recommandée)

---

## English

This roadmap presents the next identified development areas for MyMangathèque.
It does not set release dates and may evolve based on user feedback and project
priorities.

**Last updated: August 9, 2026 — application version `0.0.2+16`.**

### Current state

The following client-side foundations are now available and validated:

- unified Appwrite and REST API architecture with short-lived mobile keys;
- email and Google authentication, password recovery, and automatically tested
  OAuth callbacks;
- paginated home feed with personalized recommendations and public fallback;
- paginated search, real-time suggestions, and protection against stale network
  responses;
- collection, reading pile, missing volumes, and wishlist with loading states,
  recoverable errors, and a private cache separated by user;
- one-time collection import from Mangacollec, CSV, JSON, EAN/ISBN or free text,
  with preview, matching, corrections, progress, cancellation and undo;
- persistent offline data for paginated browsing, recent searches, detail pages,
  EAN scans, recommendations, collections, releases and bounded images;
- configurable density, recommendation order, navigation labels and reduced
  motion;
- locally refined, explainable recommendations with explicit preferences,
  diversity and feedback, independently of sponsored/editorial placements;
- completed administration covering users, catalogue, sponsored campaigns,
  editorial recommendations, revenue, analytics comparisons and exports,
  operations, and audit history;
- product analytics, notification analytics, and notification lifecycle;
- Firebase/Appwrite push reception on Android and Web, with explicit consent,
  per-installation targets, token renewal, foreground display, safe deep links,
  a persistent notification inbox, durable received/opened reporting, and an
  iOS client ready for future Apple signing;
- shared Appwrite Realtime subscriptions for user collections with automatic
  cache invalidation, reconnection, adaptive polling fallback and observable
  transport counters;
- Web/WASM delivery through GHCR and Portainer, plus automated publication of
  the obfuscated AAB to Google Play;
- strict Web/Android/iOS build validation and scheduled production smoke checks;
- clean Flutter analysis, **168 passing tests**, and a validated production
  Web/WASM build.

The statuses below are **in progress**, **to do**, and **research**. Completed
work is removed from this roadmap and documented in the changelog.

### Weighting and recommended order

Each area's score uses the following criteria:

- user impact: **40%**;
- reliability, security, and risk reduction: **30%**;
- foundational value for subsequent features: **20%**;
- speed of delivering visible value: **10%**.

Priority levels mean:

- **P0 — immediate**: required for production stability and trust;
- **P1 — priority**: high product value or essential foundation;
- **P2 — planned**: important, after the corresponding foundations;
- **P3 — long term**: differentiation or a new model requiring more maturity.

| Order | Area | Status | Importance | Priority | Score |
| ---: | --- | :---: | :---: | :---: | ---: |
| 1 | Production notification activation | In progress | 4/5 | P2 | 75/100 |
| 2 | Tablet experience | To do | 4/5 | P2 | 72/100 |
| 3 | Purchase prices and collection value | To do | 4/5 | P2 | 70/100 |
| 4 | Advanced statistics | To do | 4/5 | P2 | 69/100 |
| 5 | Sign in with Apple | To do | 3/5 | P2 | 62/100 |
| 6 | Social features | To do | 3/5 | P3 | 58/100 |
| 7 | Android and iOS widgets | To do | 3/5 | P3 | 54/100 |
| 8 | Personalized local AI | Research | 3/5 | P3 | 48/100 |
| 9 | Low-cost paid public API | Research | 2/5 | P3 | 44/100 |

The score measures the value of the work, while the recommended order also
considers dependencies. Recommendations, statistics, widgets, and AI will all
benefit directly from caching and reliable data.

Detailed sections are ordered by decreasing importance. When two areas have
the same importance, their score and dependencies determine their order.

### Importance 4/5 — high

#### 1. Activate notifications in production — P2 · Score 75/100

- Configure the production Web VAPID public key and run real-device delivery
  tests on Android and Web.
- Activate APNs and validate iOS reception when Apple signing becomes
  available.

#### 2. Improve the tablet experience — P2 · Score 72/100

- Design genuinely adaptive layouts instead of enlarging the mobile interface.
- Use multi-column and master-detail layouts for catalogue, collection, search,
  and volume pages.
- Optimize portrait and landscape orientations, touch targets, keyboard, mouse,
  and trackpad use.
- Test major iPad and Android tablet sizes.

#### 3. Track prices and estimate collection value — P2 · Score 70/100

- Store each volume's purchase price, currency, date, and optional seller.
- Calculate the collection's actual cost and changes over time.
- Offer an indicative current-value estimate from reliable, authorized sources,
  clearly separating paid price from estimated value.
- Keep this information private by default and allow user export.

#### 4. Provide advanced statistics — P2 · Score 69/100

- Show changes in collection size, reading progress, and estimated value.
- Analyze genres, authors, publishers, completed series, reading pace, and
  spending over selected periods.
- Add personal goals and previous-period comparisons without guilt-inducing
  mechanics.
- Allow export of statistics and the user's source data.

### Importance 3/5 — moderate

#### 5. Add Sign in with Apple — P2 · Score 62/100

- Add Apple to the Appwrite authentication providers.
- Implement sign-in on compatible platforms.
- Correctly handle OAuth callbacks, cancellations, and errors.
- Add registration and sign-in flow tests.

#### 6. Add controlled social features — P3 · Score 58/100

- Create optional public profiles and sharing for collections, lists, reviews,
  and recommendations.
- Add user follows and a configurable activity feed.
- Provide precise privacy settings for every data type.
- Design reporting, blocking, moderation, and anti-spam/harassment safeguards
  from the start.

#### 7. Add Android and iOS widgets — P3 · Score 54/100

- Provide a widget for the latest and upcoming releases.
- Offer variants focused on followed series or missing volumes.
- Open the relevant application page directly through deep links.
- Refresh in the background without excessive battery or mobile-data use.

#### 8. Add a personalized local AI layer — P3 · Score 48/100

- Research AI that runs on-device whenever possible to preserve privacy and
  limit server costs.
- Use local preferences to improve search, collection summaries, ranking, and
  personalized recommendations.
- Keep it fully optional, explain the data used, and allow immediate deletion.
- Plan lightweight models, controlled resource use, and degraded operation on
  unsupported devices.

### Importance 2/5 — long term

#### 9. Offer a low-cost paid public API — P3 · Score 44/100

- Design a versioned, documented API through which third-party developers can
  legally access authorized catalogue data.
- Provide API keys, quotas, rate limits, and a usage dashboard.
- Offer accessible pricing, potentially with a small free tier for trials and
  community projects.
- Define usage rights, personal-data protection, expected availability, and an
  abuse-revocation process.
- Strictly separate the public API from MyMangathèque's internal and
  administrative routes.

### Recommended next sequence

1. **Activate production notifications:** provide the Web VAPID key and perform
   delivery tests on real Android and Web devices.
2. **Advance tablet layouts:** add adaptive master-detail experiences for
   larger screens.
3. **Increase collection value:** add purchase prices, valuation, advanced
   statistics, and exports before starting social, AI, or public API work.

---

## Français

Cette roadmap présente les prochains axes de développement identifiés pour
MyMangathèque. Elle ne fixe pas encore de dates de livraison et pourra évoluer
selon les retours des utilisateurs et les priorités du projet.

**Dernière mise à jour : 9 août 2026 — version applicative `0.0.2+16`.**

### État actuel

Les fondations suivantes sont désormais disponibles et validées côté client :

- architecture Appwrite + API REST unifiée et clés mobiles temporaires ;
- authentification e-mail et Google, récupération du mot de passe et callbacks
  OAuth testés automatiquement ;
- accueil paginé avec recommandations personnalisées et repli public ;
- recherche paginée, suggestions temps réel et protection contre les réponses
  réseau obsolètes ;
- collection, pile à lire, tomes manquants et envies avec états de chargement,
  erreurs récupérables et cache privé séparé par utilisateur ;
- import ponctuel depuis Mangacollec, CSV, JSON, EAN/ISBN ou texte libre, avec
  prévisualisation, rapprochement, corrections, progression, annulation et retour
  arrière ;
- données hors ligne persistantes pour navigation paginée, recherches récentes,
  fiches, scans EAN, recommandations, collection, sorties et images bornées ;
- densité, ordre des recommandations, libellés de navigation et réduction des
  animations configurables ;
- recommandations explicables affinées localement avec préférences, diversité et
  retours, indépendamment des emplacements sponsorisés et éditoriaux ;
- back-office finalisé couvrant utilisateurs, catalogue, campagnes sponsorisées,
  recommandations éditoriales, revenus, comparaisons et exports statistiques,
  exploitation et audit ;
- analytics produit, statistiques de notifications et cycle de vie des
  notifications ;
- réception push Firebase/Appwrite sur Android et Web avec consentement
  explicite, cibles par installation, renouvellement du jeton, affichage au
  premier plan, deep links sécurisés, boîte persistante, rapports reçu/ouvert
  durables et client iOS prêt pour une future signature Apple ;
- abonnements Appwrite Realtime partagés pour les collections utilisateur avec
  invalidation automatique du cache, reconnexion, polling adaptatif de secours
  et compteurs de transport observables ;
- livraison Web/WASM sur GHCR et Portainer, plus publication automatisée de
  l'AAB obfusqué sur Google Play ;
- validation stricte des builds Web/Android/iOS et contrôles de production
  planifiés ;
- analyse Flutter sans anomalie, **168 tests** réussis et build Web/WASM de
  production validé.

Les statuts utilisés ci-dessous sont : **en cours**, **à faire** et **étude**.
Les travaux terminés sont retirés de cette roadmap et documentés dans le
changelog.

### Pondération et ordre recommandé

Le score de chaque axe est calculé selon les critères suivants :

- impact utilisateur : **40 %** ;
- fiabilité, sécurité et réduction des risques : **30 %** ;
- valeur de fondation pour les fonctionnalités suivantes : **20 %** ;
- rapidité d'obtention d'une valeur visible : **10 %**.

Les niveaux de priorité ont la signification suivante :

- **P0 — immédiat** : nécessaire à la stabilité et à la confiance en production ;
- **P1 — prioritaire** : forte valeur produit ou fondation indispensable ;
- **P2 — planifié** : important, à lancer après les fondations correspondantes ;
- **P3 — long terme** : différenciation ou nouveau modèle nécessitant plus de maturité.

| Ordre | Axe | État | Importance | Priorité | Score |
| ---: | --- | :---: | :---: | :---: | ---: |
| 1 | Activation des notifications en production | En cours | 4/5 | P2 | 75/100 |
| 2 | Expérience tablette | À faire | 4/5 | P2 | 72/100 |
| 3 | Prix et valeur de la collection | À faire | 4/5 | P2 | 70/100 |
| 4 | Statistiques avancées | À faire | 4/5 | P2 | 69/100 |
| 5 | Connexion avec Apple | À faire | 3/5 | P2 | 62/100 |
| 6 | Dimension sociale | À faire | 3/5 | P3 | 58/100 |
| 7 | Widgets Android et iOS | À faire | 3/5 | P3 | 54/100 |
| 8 | IA personnalisée et locale | Étude | 3/5 | P3 | 48/100 |
| 9 | API publique payante | Étude | 2/5 | P3 | 44/100 |

Le score mesure l'intérêt du chantier, mais l'ordre recommandé tient également
compte de ses dépendances. Par exemple, les recommandations, les statistiques,
les widgets et l'IA bénéficieront directement du cache et d'une donnée fiable.

Les sections détaillées sont classées par importance décroissante. Lorsque deux
axes ont la même importance, leur score puis leurs dépendances déterminent leur
position.

### Importance 4/5 — élevée

#### 1. Activer les notifications en production — P2 · Score 75/100

- Configurer la clé publique VAPID Web de production et tester la livraison sur
  de vrais appareils Android et Web.
- Activer APNs et valider la réception iOS lorsque la signature Apple sera
  disponible.

#### 2. Améliorer l'expérience sur tablette — P2 · Score 72/100

- Concevoir des dispositions réellement adaptatives plutôt que simplement
  agrandir l'interface mobile.
- Exploiter les vues en plusieurs colonnes et les parcours maître/détail pour le
  catalogue, la collection, la recherche et les fiches de tomes.
- Optimiser les orientations portrait et paysage, les grandes zones tactiles,
  le clavier, la souris et le trackpad.
- Tester les principales tailles d'iPad et de tablettes Android.

#### 3. Suivre les prix et estimer la valeur de la collection — P2 · Score 70/100

- Enregistrer le prix, la devise, la date et éventuellement le lieu d'achat de
  chaque tome.
- Calculer le coût réel de la collection et son évolution dans le temps.
- Proposer une estimation indicative de la valeur actuelle à partir de sources
  fiables et autorisées, en distinguant clairement prix payé et valeur estimée.
- Laisser ces informations privées par défaut et offrir un export à l'utilisateur.

#### 4. Proposer des statistiques avancées — P2 · Score 69/100

- Présenter l'évolution de la collection, des lectures et de la valeur estimée.
- Analyser les genres, auteurs, éditeurs, séries complétées, rythmes de lecture et
  dépenses sur des périodes choisies.
- Ajouter des objectifs personnels et des comparaisons avec les périodes
  précédentes, sans mécanismes culpabilisants.
- Permettre l'export des statistiques et des données sources de l'utilisateur.

### Importance 3/5 — modérée

#### 5. Ajouter la connexion avec Apple — P2 · Score 62/100

- Ajouter Apple aux fournisseurs d'authentification Appwrite.
- Implémenter le parcours de connexion sur les plateformes compatibles.
- Gérer correctement les callbacks, les annulations et les erreurs OAuth.
- Ajouter les tests du parcours d'inscription et de connexion.

#### 6. Ajouter une dimension sociale maîtrisée — P3 · Score 58/100

- Créer des profils publics optionnels et permettre le partage de collections,
  listes, avis et recommandations.
- Ajouter des abonnements entre utilisateurs et un fil d'activité configurable.
- Permettre des réglages de confidentialité précis pour chaque type de donnée.
- Prévoir dès le départ le signalement, le blocage, la modération et la lutte
  contre le spam et le harcèlement.

#### 7. Ajouter des widgets Android et iOS — P3 · Score 54/100

- Proposer un widget affichant les dernières sorties et les prochaines parutions.
- Permettre des variantes centrées sur les séries suivies ou les tomes manquants.
- Ouvrir directement la fiche concernée dans l'application grâce aux deep links.
- Actualiser les widgets en arrière-plan sans consommation excessive de batterie
  ou de données mobiles.

#### 8. Ajouter une couche d'IA personnalisée et locale — P3 · Score 48/100

- Étudier une IA exécutée autant que possible sur l'appareil afin de préserver
  la confidentialité et de limiter les coûts serveur.
- Utiliser les préférences locales pour améliorer la recherche, les résumés de
  collection, le classement et les recommandations personnalisées.
- Rendre cette fonctionnalité entièrement optionnelle, expliquer les données
  utilisées et permettre leur suppression immédiate.
- Prévoir des modèles légers, une consommation maîtrisée et un fonctionnement
  dégradé sur les appareils non compatibles.

### Importance 2/5 — secondaire à court terme

#### 9. Proposer une API publique payante à bas coût — P3 · Score 44/100

- Concevoir une API versionnée et documentée pour permettre à des développeurs
  tiers d'accéder légalement aux données autorisées du catalogue.
- Fournir des clés API, des quotas, des limites de débit et un tableau de bord de
  consommation.
- Proposer un tarif accessible avec éventuellement un petit palier gratuit pour
  les essais et les projets communautaires.
- Définir les droits d'utilisation, la protection des données personnelles, la
  disponibilité attendue et une procédure de révocation en cas d'abus.
- Séparer strictement l'API publique des routes internes et administratives de
  MyMangathèque.

### Prochaine séquence recommandée

1. **Activer les notifications en production** : fournir la clé VAPID Web et
   tester la livraison sur de vrais appareils Android et Web.
2. **Faire progresser l’interface tablette** : ajouter des interfaces
   maître/détail adaptatives sur grands écrans.
3. **Renforcer la valeur de la collection** : ajouter prix d'achat, estimation,
   statistiques avancées et exports avant les fonctions sociales, l'IA et
   l'API publique.
