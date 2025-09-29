# MyMangaTheque

Une application pour mettre les mangas que l'on a, a lu, nos envies manga, les mangas qui sortent,
etc.

[![wakatime](https://wakatime.com/badge/github/CreeperFarm/MyMangatheque.svg)](https://wakatime.com/badge/github/CreeperFarm/MyMangatheque)

####Modification of the icons :
Modify the files name in `pubspec.yaml` and modify this :
```yaml```
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

####Build App Android Obfuscated :
`flutter build appbundle --obfuscate --split-debug-info out/android`

## Getting Started
