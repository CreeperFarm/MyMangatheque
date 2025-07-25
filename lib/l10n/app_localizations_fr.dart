// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get helloWorld => 'Bonjour le monde !';

  @override
  String get home => 'Accueil';

  @override
  String get collection => 'Collection';

  @override
  String get search => 'Recherche';

  @override
  String get profile => 'Profil';

  @override
  String pronoun(String gender) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'male': 'il',
        'female': 'elle',
        'other': 'iel',
      },
    );
    return '$_temp0';
  }

  @override
  String get authFailed => 'Email ou mot de passe incorrect.';

  @override
  String get userLoginFailed =>
      'Une erreur est survenue, vous n\\\'avez pas été connecter à votre compte.';

  @override
  String get userLoginSuccess => 'Vous êtes connecté avec succès.';

  @override
  String get errorOccurred =>
      'Une erreur est survenue, veuillez réessayer plus tard.';

  @override
  String get pleaseWait => 'Veuillez patienter...';

  @override
  String get emailResetSent =>
      'Un email de réinitialisation de mot de passe a été envoyé à votre adresse email.';

  @override
  String get invalidEmail => 'L\'adresse email est invalide.';

  @override
  String get modifyPasswordSuccess => 'Mot de passe modifié avec succès.';

  @override
  String get logIn => 'Se connecter';

  @override
  String get legalNotice => 'Mentions légales';

  @override
  String get january => 'Janvier';

  @override
  String get february => 'Février';

  @override
  String get march => 'Mars';

  @override
  String get april => 'Avril';

  @override
  String get may => 'Mai';

  @override
  String get june => 'Juin';

  @override
  String get july => 'Juillet';

  @override
  String get august => 'Août';

  @override
  String get september => 'Septembre';

  @override
  String get october => 'Octobre';

  @override
  String get november => 'Novembre';

  @override
  String get december => 'Décembre';

  @override
  String get profileSettings => 'Page de profil et réglages';

  @override
  String emailIs(String email) {
    return 'Votre email est $email';
  }

  @override
  String usernameIs(String username) {
    return 'Votre pseudo est $username';
  }

  @override
  String accountCreatedOn(String date) {
    return 'Compte créé le $date';
  }

  @override
  String birthdayDateIs(String date) {
    return 'Votre anniversaire est le $date';
  }

  @override
  String volumeOwnedNumber(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vous possédez $countString volumes',
      one: 'Vous possédez un volume',
      zero: 'Vous possédez 0 volume',
    );
    return '$_temp0';
  }

  @override
  String favoriteSeriesNumber(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vous avez $countString séries',
      one: 'Vous avez une série',
      zero: 'Vous avez 0 série',
    );
    return '$_temp0 en favoris';
  }

  @override
  String get lightMode => 'Thème clair';

  @override
  String get darkMode => 'Thème sombre';

  @override
  String get systemMode => 'Thème du système';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';
}
