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
