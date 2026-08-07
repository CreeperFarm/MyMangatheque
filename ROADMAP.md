# Roadmap MyMangathèque

Cette roadmap présente les prochains axes de développement identifiés pour
MyMangathèque. Elle ne fixe pas encore de dates de livraison et pourra évoluer
selon les retours des utilisateurs et les priorités du projet.

## Pondération et ordre recommandé

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

| Ordre | Axe | Importance | Priorité | Score |
| ---: | --- | :---: | :---: | ---: |
| 1 | Validation de production | 5/5 | P0 | 96/100 |
| 2 | Cache persistant et mode hors ligne | 5/5 | P0 | 92/100 |
| 3 | Interface fluide et personnalisable | 5/5 | P1 | 87/100 |
| 4 | Suivi des tomes manquants | 5/5 | P1 | 86/100 |
| 5 | Import automatique de collection | 5/5 | P1 | 84/100 |
| 6 | Meilleur système de recommandation | 5/5 | P1 | 82/100 |
| 7 | Restauration de la page Planning | 4/5 | P1 | 79/100 |
| 8 | Finalisation du back-office | 4/5 | P1 | 77/100 |
| 9 | Fiabilisation des notifications | 4/5 | P2 | 75/100 |
| 10 | Synchronisation en temps réel | 4/5 | P2 | 73/100 |
| 11 | Expérience tablette | 4/5 | P2 | 72/100 |
| 12 | Prix et valeur de la collection | 4/5 | P2 | 70/100 |
| 13 | Statistiques avancées | 4/5 | P2 | 69/100 |
| 14 | Connexion avec Apple | 3/5 | P2 | 62/100 |
| 15 | Dimension sociale | 3/5 | P3 | 58/100 |
| 16 | Widgets Android et iOS | 3/5 | P3 | 54/100 |
| 17 | IA personnalisée et locale | 3/5 | P3 | 48/100 |
| 18 | API publique payante | 2/5 | P3 | 44/100 |

Le score mesure l'intérêt du chantier, mais l'ordre recommandé tient également
compte de ses dépendances. Par exemple, les recommandations, les statistiques,
les widgets et l'IA bénéficieront directement du cache et d'une donnée fiable.

Les sections détaillées sont classées par importance décroissante. Lorsque deux
axes ont la même importance, leur score puis leurs dépendances déterminent leur
position.

## Importance 5/5 — essentielle

### 1. Terminer la validation de production — P0 · Score 96/100

- Valider l'authentification complète sur mobile et Web, dont Google OAuth.
- Tester la rotation automatique et l'expiration des clés API mobiles.
- Vérifier la récupération du mot de passe, le profil et les avatars.
- Valider les collections, les suivis, les états de lecture et la recherche.
- Tester les notifications et les redéploiements sans interruption de service.
- Mettre en place un suivi des erreurs, des latences et des échecs de connexion.

### 2. Mettre en place un véritable cache persistant — P0 · Score 92/100

- Faire évoluer les caches ponctuels déjà présents vers une couche unifiée et
  persistante, adaptée à chaque plateforme. Le stockage JSON actuel et les
  caches mémoire à durée courte ne constituent pas encore un mode hors ligne
  complet et cohérent.
- Mettre en cache les données du catalogue, les images et photos de profil, les
  tomes possédés, les recommandations, les sorties à venir et les principales
  pages consultées par l'utilisateur.
- Adopter une stratégie « stale-while-revalidate » : afficher immédiatement les
  dernières données connues, puis les actualiser silencieusement en arrière-plan.
- Définir une durée de validité, une invalidation et une limite de stockage selon
  la nature de chaque donnée afin d'éviter les informations obsolètes.
- Séparer les données privées par utilisateur et les purger à la déconnexion ou
  au changement de compte. Les secrets d'authentification ne feront pas partie
  de ce cache métier.
- Prévoir les migrations de schéma, le nettoyage LRU et des tests couvrant le
  démarrage à chaud, le mode hors ligne et le retour de la connexion.

### 3. Rendre l'interface plus fluide et personnalisable — P1 · Score 87/100

- Réduire les chargements visibles grâce au cache, au préchargement ciblé et à
  des transitions plus naturelles.
- Permettre de personnaliser l'accueil, l'ordre de certaines sections, la
  densité d'affichage et les préférences de navigation.
- Améliorer les états de chargement, les écrans vides, les erreurs récupérables
  et le retour visuel après chaque action.
- Préserver l'accessibilité, les thèmes clair et sombre et les performances sur
  les appareils moins puissants.

### 4. Améliorer le suivi des tomes manquants — P1 · Score 86/100

- Détecter automatiquement les trous dans les séries commencées.
- Distinguer les tomes manquants, souhaités, annoncés et pas encore publiés.
- Prioriser les achats permettant de compléter une série ou un arc.
- Ajouter des alertes optionnelles lors d'une sortie ou d'un changement de
  disponibilité.

### 5. Importer automatiquement une collection existante — P1 · Score 84/100

- Permettre l'import depuis des formats documentés tels que CSV ou JSON et,
  lorsque cela est légalement et techniquement possible, depuis d'autres outils.
- Ajouter une prévisualisation avant import avec correspondance des séries et des
  tomes, détection des doublons et signalement des éléments introuvables.
- Autoriser la correction manuelle des correspondances et l'annulation d'un
  import récent.
- Concevoir le traitement pour les grandes collections sans bloquer l'interface.

### 6. Construire un meilleur système de recommandation — P1 · Score 82/100

- Combiner le contenu de la collection, les lectures, les envies, les séries
  suivies et les similarités de genres, auteurs et éditeurs.
- Prendre en charge les nouveaux utilisateurs avec des préférences initiales et
  des recommandations populaires adaptées.
- Expliquer simplement pourquoi un titre est recommandé et permettre de masquer
  un titre ou d'indiquer qu'une suggestion n'est pas pertinente.
- Mesurer la qualité des recommandations sans collecter plus de données que
  nécessaire et sans enfermer l'utilisateur dans une bulle de filtres.

## Importance 4/5 — élevée

### 7. Restaurer la page Planning — P1 · Score 79/100

- Réintégrer la page Planning dans la navigation principale.
- Remplacer l'écran temporaire actuel par une véritable liste des sorties.
- Présenter clairement les sorties récentes et à venir.
- Vérifier le comportement sur mobile, tablette et Web.

### 8. Finaliser le back-office administrateur — P1 · Score 77/100

- Fiabiliser les parcours de connexion administrateur et modérateur.
- Compléter et valider les opérations de création et de modification du
  catalogue.
- Consolider les statistiques et les outils de contrôle qualité des volumes.
- Ajouter des tests d'autorisation, de validation et de non-régression.

### 9. Fiabiliser les notifications — P2 · Score 75/100

- Valider l'enregistrement et le renouvellement des cibles push.
- Améliorer les notifications internes à l'application.
- Ajuster la fréquence du fallback polling selon la charge réelle.
- Tester la réception sur Android, iOS et Web lorsque la plateforme le permet.

### 10. Améliorer la synchronisation en temps réel — P2 · Score 73/100

- Réduire la dépendance au polling périodique des données métier.
- Utiliser le temps réel lorsque l'API et Appwrite le permettent.
- Conserver un mécanisme de repli fiable en cas de perte de connexion.
- Mesurer l'impact sur la charge serveur, le réseau et la batterie.

### 11. Améliorer l'expérience sur tablette — P2 · Score 72/100

- Concevoir des dispositions réellement adaptatives plutôt que simplement
  agrandir l'interface mobile.
- Exploiter les vues en plusieurs colonnes et les parcours maître/détail pour le
  catalogue, la collection, la recherche et les fiches de tomes.
- Optimiser les orientations portrait et paysage, les grandes zones tactiles,
  le clavier, la souris et le trackpad.
- Tester les principales tailles d'iPad et de tablettes Android.

### 12. Suivre les prix et estimer la valeur de la collection — P2 · Score 70/100

- Enregistrer le prix, la devise, la date et éventuellement le lieu d'achat de
  chaque tome.
- Calculer le coût réel de la collection et son évolution dans le temps.
- Proposer une estimation indicative de la valeur actuelle à partir de sources
  fiables et autorisées, en distinguant clairement prix payé et valeur estimée.
- Laisser ces informations privées par défaut et offrir un export à l'utilisateur.

### 13. Proposer des statistiques avancées — P2 · Score 69/100

- Présenter l'évolution de la collection, des lectures et de la valeur estimée.
- Analyser les genres, auteurs, éditeurs, séries complétées, rythmes de lecture et
  dépenses sur des périodes choisies.
- Ajouter des objectifs personnels et des comparaisons avec les périodes
  précédentes, sans mécanismes culpabilisants.
- Permettre l'export des statistiques et des données sources de l'utilisateur.

## Importance 3/5 — modérée

### 14. Ajouter la connexion avec Apple — P2 · Score 62/100

- Ajouter Apple aux fournisseurs d'authentification Appwrite.
- Implémenter le parcours de connexion sur les plateformes compatibles.
- Gérer correctement les callbacks, les annulations et les erreurs OAuth.
- Ajouter les tests du parcours d'inscription et de connexion.

### 15. Ajouter une dimension sociale maîtrisée — P3 · Score 58/100

- Créer des profils publics optionnels et permettre le partage de collections,
  listes, avis et recommandations.
- Ajouter des abonnements entre utilisateurs et un fil d'activité configurable.
- Permettre des réglages de confidentialité précis pour chaque type de donnée.
- Prévoir dès le départ le signalement, le blocage, la modération et la lutte
  contre le spam et le harcèlement.

### 16. Ajouter des widgets Android et iOS — P3 · Score 54/100

- Proposer un widget affichant les dernières sorties et les prochaines parutions.
- Permettre des variantes centrées sur les séries suivies ou les tomes manquants.
- Ouvrir directement la fiche concernée dans l'application grâce aux deep links.
- Actualiser les widgets en arrière-plan sans consommation excessive de batterie
  ou de données mobiles.

### 17. Ajouter une couche d'IA personnalisée et locale — P3 · Score 48/100

- Étudier une IA exécutée autant que possible sur l'appareil afin de préserver
  la confidentialité et de limiter les coûts serveur.
- Utiliser les préférences locales pour améliorer la recherche, les résumés de
  collection, le classement et les recommandations personnalisées.
- Rendre cette fonctionnalité entièrement optionnelle, expliquer les données
  utilisées et permettre leur suppression immédiate.
- Prévoir des modèles légers, une consommation maîtrisée et un fonctionnement
  dégradé sur les appareils non compatibles.

## Importance 2/5 — secondaire à court terme

### 18. Proposer une API publique payante à bas coût — P3 · Score 44/100

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
