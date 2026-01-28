# MyMangathèque

Une application pour mettre les mangas que l'on a, a lu, nos envies manga, les mangas qui sortent, etc.

[![wakatime](https://wakatime.com/badge/github/CreeperFarm/MyMangatheque.svg)](https://wakatime.com/badge/github/CreeperFarm/MyMangatheque)

#### Modification of the icons :
Modify the files name in `pubspec.yaml` and modify this :
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
`flutter pub get && dart run flutter_launcher_icons`

#### Build App Android Obfuscated :
`flutter build appbundle --obfuscate --split-debug-info out/android`

#### Changelog Management :
The project uses an automated changelog generation system that updates `CHANGELOG.md` when the version in `pubspec.yaml` changes.

**Automatic Update (via GitHub Actions):**
- When you push a commit that changes the version in `pubspec.yaml`, the GitHub Actions workflow will automatically:
  - Detect the version change
  - Update `CHANGELOG.md` with a new version entry
  - Commit the changes back to the repository

**Manual Update:**
To manually update the changelog, run:
```bash
./scripts/update_changelog.sh
```
This script will:
- Read the current version from `pubspec.yaml`
- Add a new entry to `CHANGELOG.md` if the version doesn't already exist
- Provide a template for you to fill in the changes

After running the script, review and update the changelog entries with your specific changes before committing.

## Getting Started

#### To launch the app for the first time

1. First download this repository and open it into your IDE.
2. Run those commands :
```bash
flutter pub get
dart run flutter_launcher_icons
```
3. To launch the app in chrome run this command : `flutter run web`. To launch app on mobile run `flutter run` and then select where you want to launch the app
4. The app compile and then launch if no error occured
