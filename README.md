# MyMangathèque

[![wakatime](https://wakatime.com/badge/github/CreeperFarm/MyMangatheque.svg)](https://wakatime.com/badge/github/CreeperFarm/MyMangatheque)

![Activity](https://repobeats.axiom.co/api/embed/3b844bd0e1b84b95bcc25e23fa7f52a85254e1fe.svg "Repobeats analytics image")

## Summary
- [English](#english)
    - [Modification of the icons](#modification-of-the-icons-)
    - [Build App Android Obfuscated](#build-app-android-obfuscated-)
    - [Getting Started](#getting-started)
    - [Features](#features)
    - [License](#license)
- [Français](#français)
    - [Modification des icônes](#modification-des-icônes-)
    - [Build de l'application Android Obfusqué](#build-de-lapplication-android-obfusqué-)
    - [Démarrage](#démarrage)
    - [Fonctionnalités](#fonctionnalités)
    - [License](#license)

---

## English

An application to list the manga you have, have read, your manga wishes, upcoming releases, etc.

### Modification of the icons :
Modify the files name in pubspec.yaml and modify this :
```yaml
flutter_launcher_icons:
    android: true
    min_sdk_android: 19
    ios: true
    remove_alpha_ios: true
    image_path: "assets/images/logo_app.png"
    # adaptive_icon_background: "assets/images/logo_background.png"
    # adaptive_icon_foreground: "assets/images/logo_foreground.png"
    web:
        generate: true
        image_path: "assets/images/logo_app.png"
        background_color: "#000b4b6c"
        theme_color: "#0b4b6c"
```

And then run this command :

```bash
flutter pub get && dart run flutter_launcher_icons
```

### Build App Android Obfuscated :

```bash
flutter build appbundle --obfuscate --split-debug-info out/android
```

### Getting Started

To launch the app for the first time

First download this repository and open it into your IDE.

Then run those commands :

```bash
flutter pub get
dart run flutter_launcher_icons
```

To launch the app in chrome run this command : `flutter run web`. To launch app on mobile run `flutter run` and then select where you want to launch the app.

The app compile and then launch if no error occured.

### Features

- Authentication: Sign in or sign up using Email/Password or Google or Apple (Coming Soon...).
- Collection Management:
    - Keep track of volumes you Own, volumes you Desire (wishlist), and your Read Pile (owned but unread).
    - View a list to help Complete the series you've started.
    - Add or remove volumes from your collection.
    - Mark volumes as read or unread.
- Discovery:
    - Browse volumes, series, authors, and editors.
    - Search for series.
    - Follow or unfollow sub-series.
- Barcode Scanning: Quickly add volumes to your collection by scanning their EAN barcode.
- Personalization:
    - Manage your user profile.
    - Switch between Light, Dark, or System theme.
    - Change the application language (English/French supported).

### License

This project is under the license specified in the [LICENSE](LICENSE) file.

The third-party licenses are available in the [THIRD_PARTY_LICENSE.md](THIRD_PARTY_LICENSE.md) file.

---

## Français

Une application pour mettre les mangas que l'on a, a lu, nos envies manga, les mangas qui sortent, etc.

### Modification des icônes :

Modifiez le nom des fichiers dans pubspec.yaml et modifiez ceci :
```yaml
flutter_launcher_icons:
    android: true
    min_sdk_android: 19
    ios: true
    remove_alpha_ios: true
    image_path: "assets/images/logo_app.png"
    # adaptive_icon_background: "assets/images/logo_background.png"
    # adaptive_icon_foreground: "assets/images/logo_foreground.png"
    web:
        generate: true
        image_path: "assets/images/logo_app.png"
        background_color: "#000b4b6c"
        theme_color: "#0b4b6c"
```

Puis exécutez cette commande :

```bash
flutter pub get && dart run flutter_launcher_icons
```

### Build de l'application Android Obfusqué :

```bash
flutter build appbundle --obfuscate --split-debug-info out/android
```

### Démarrage

Pour lancer l'application pour la première fois

D'abord, téléchargez ce dépôt et ouvrez-le dans votre IDE.

Exécutez ces commandes :
```dart
flutter pub get
dart run flutter_launcher_icons
```

Pour lancer l'application dans Chrome, exécutez cette commande : `flutter run web`. Pour lancer l'application sur mobile, exécutez `flutter run` et sélectionnez où vous voulez la lancer.

L'application compile puis se lance si aucune erreur ne s'est produite.

### Fonctionnalités

- Authentification: Connectez-vous ou inscrivez-vous avec Email/Mot de passe ou Google.
- Gestion de Collection:
    - Suivez les volumes que vous Possédez, vos Envies (wishlist), et votre Pile à Lire (possédés mais non lus).
    - Consultez une liste pour vous aider à Compléter les séries que vous avez commencées.
    - Ajoutez ou retirez des volumes de votre collection.
    - Marquez les volumes comme lus ou non lus.
- Découverte:
    - Parcourez les volumes, séries, auteurs et éditeurs.
    - Recherchez des séries.
    - Suivez ou ne suivez plus des sous-séries.
- Scan de Code-barres: Ajoutez rapidement des volumes à votre collection en scannant leur code-barres EAN.
- Personnalisation:
    - Gérez votre profil utilisateur.
    - Basculez entre les thèmes Clair, Sombre ou Système.
    - Changez la langue de l'application (Anglais/Français supportés).

### License

Ce projet est sous la licence spécifiée dans le fichier [LICENSE](LICENSE).

Les licences tierces sont disponibles dans le fichier [THIRD_PARTY_LICENSE.md](THIRD_PARTY_LICENSE.md).
