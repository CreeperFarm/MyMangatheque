// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get spanish => 'Espagnol';

  @override
  String get italian => 'Italien';

  @override
  String get german => 'Allemand';

  @override
  String get japanese => 'Japonais';

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
  String get passwordTooShort =>
      'Le mot de passe doit comporter au moins 6 caractères.';

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
  String get logInWithGoogle => 'Se connecter avec Google';

  @override
  String get logInWithApple => 'Se connecter avec Apple';

  @override
  String get logInSuccess => 'Vous êtes connecté avec succès.';

  @override
  String get logInFailed =>
      'Une erreur est survenue, vous n\'avez pas été connecté à votre compte.';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get logOutSuccess => 'Vous êtes déconnecté avec succès.';

  @override
  String get logOutFailed =>
      'Une erreur est survenue, vous n\'avez pas été déconnecté.';

  @override
  String minLengthNotReached(num minLength) {
    final intl.NumberFormat minLengthNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String minLengthString = minLengthNumberFormat.format(minLength);

    return 'Le nombre minimum de caractères requis est $minLengthString.';
  }

  @override
  String maxLengthExceeded(num maxLength) {
    final intl.NumberFormat maxLengthNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String maxLengthString = maxLengthNumberFormat.format(maxLength);

    return 'Le nombre maximum de caractères autorisés est $maxLengthString.';
  }

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
  String get clearCache => 'Vider le cache';

  @override
  String get clearCacheSuccess => 'Cache vidé avec succès.';

  @override
  String get modifyPassword => 'Modifier le mot de passe';

  @override
  String get dangerZone => 'Zone de danger';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountConfirmation =>
      'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.';

  @override
  String get deleteAccountSuccess => 'Compte supprimé avec succès.';

  @override
  String get deleteAccountFailed =>
      'Une erreur est survenue, votre compte n\'a pas été supprimé, vous avez été déconnecté.';

  @override
  String appVersionAndAppBuildVersion(String appVersion, String buildVersion) {
    return 'Version de l\'application : $appVersion & version du build : $buildVersion';
  }

  @override
  String volumeNum(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Tome $countString';
  }

  @override
  String get owned => 'Possédé';

  @override
  String get volume => 'Tome';

  @override
  String get series => 'Série';

  @override
  String get edition => 'Édition';

  @override
  String get author => 'Auteur';

  @override
  String get publisher => 'Éditeur';

  @override
  String get publicationDate => 'Date de publication';

  @override
  String get isbn => 'ISBN';

  @override
  String get scanner => 'Scanner';

  @override
  String get scannerDescription =>
      'Scanner les codes-barres des volumes pour les ajouter à votre collection.';

  @override
  String get createAuthor => 'Créer un auteur';

  @override
  String get authorName => 'Nom de l\'auteur';

  @override
  String get provideAuthorName => 'Veuillez fournir le nom de l\'auteur.';

  @override
  String get authorJobs => 'Métiers de l\'auteur (séparé par des virgules)';

  @override
  String get provideAuthorJobs =>
      'Veuillez fournir les métiers de l\'auteur (séparés par des virgules).';

  @override
  String get seriesIdOfAuthor => 'ID de la série de l\'auteur';

  @override
  String get provideSeriesIdOfAuthor =>
      'Veuillez fournir le(s) ID(s) de la série de l\'auteur.';

  @override
  String get authorAdd => 'Ajouter l\'auteur';

  @override
  String get authorAddSuccess => 'Auteur ajouté avec succès.';

  @override
  String get authorDuplicate => 'Un auteur avec ce nom existe déjà.';

  @override
  String get createGenre => 'Créer un genre';

  @override
  String get genreName => 'Nom du genre';

  @override
  String get provideGenreName => 'Veuillez fournir le nom du genre.';

  @override
  String get genreAdd => 'Ajouter le genre';

  @override
  String get genreAddSuccess => 'Genre ajouté avec succès.';

  @override
  String get genreDuplicate => 'Un genre avec ce nom existe déjà.';

  @override
  String get createVolume => 'Créer un volume';

  @override
  String get volumeTitle => 'Titre du volume';

  @override
  String get provideVolumeTitle => 'Veuillez fournir le titre du volume.';

  @override
  String get volumeNumber => 'Numéro du volume';

  @override
  String get provideVolumeNumber => 'Veuillez fournir le numéro du volume.';

  @override
  String get volumeEAN => 'EAN du volume';

  @override
  String get provideVolumeEAN => 'Veuillez fournir l\'EAN du volume.';

  @override
  String get volumePrice => 'Prix du volume';

  @override
  String get provideVolumePrice => 'Veuillez fournir le prix du volume.';

  @override
  String get volumeSummary => 'Résumé du volume';

  @override
  String get provideVolumeSummary => 'Veuillez fournir le résumé du volume.';

  @override
  String get volumeLink => 'Lien du volume';

  @override
  String get provideVolumeLink => 'Veuillez fournir le lien du volume.';

  @override
  String get volumeInfo => 'Informations sur le volume';

  @override
  String get provideVolumeInfo =>
      'Veuillez fournir les informations sur le volume.';

  @override
  String get adultContent => 'Contenu adulte';

  @override
  String get adultContentWarning => 'Avertissement de contenu adulte';

  @override
  String get volumeLanguage => 'Langue du volume';

  @override
  String get chooseVolumeLanguage =>
      'Veuillez sélectionner la langue du volume.';

  @override
  String get manga => 'Manga';

  @override
  String get novel => 'Roman';

  @override
  String get artbook => 'Artbook';

  @override
  String get lightNovel => 'Light Novel';

  @override
  String get boxSet => 'Coffret';

  @override
  String get other => 'Autre';

  @override
  String get volumeSupport => 'Support du volume';

  @override
  String get chooseVolumeSupport =>
      'Veuillez sélectionner le support du volume.';

  @override
  String get selectDate => 'Sélectionner la date';

  @override
  String get pleaseSelectDate => 'Veuillez sélectionner une date.';

  @override
  String get volumeSeriesId => 'ID de la série du volume';

  @override
  String get provideVolumeSeriesId =>
      'Veuillez fournir l\'ID de la série du volume.';

  @override
  String get provideValidVolumeSeriesId =>
      'Veuillez fournir un ID de série de volume valide.';

  @override
  String get volumeSubSeriesId => 'ID de la sous-série du volume';

  @override
  String get provideVolumeSubSeriesId =>
      'Veuillez fournir l\'ID de la sous-série du volume.';

  @override
  String get provideValidVolumeSubSeriesId =>
      'Veuillez fournir un ID de sous-série de volume valide.';

  @override
  String get volumeEditorId => 'ID de l\'éditeur du volume';

  @override
  String get provideVolumeEditorId =>
      'Veuillez fournir l\'ID de l\'éditeur du volume';

  @override
  String get provideValidVolumeEditorId =>
      'Veuillez fournir un ID d\'éditeur de volume valide.';

  @override
  String get volumeAuthorsIds => 'IDs des auteurs du volume';

  @override
  String get provideVolumeAuthorsIds =>
      'Veuillez fournir les IDs des auteurs du volume.';

  @override
  String get contentOfBoxSet => 'Contenu du coffret';

  @override
  String get provideContentOfBoxSet =>
      'Veuillez fournir le contenu du coffret.';

  @override
  String get volumeAdd => 'Ajouter un volume';

  @override
  String get volumeAddSuccess => 'Volume ajouté avec succès.';

  @override
  String get volumeAddError =>
      'Une erreur est survenue, le volume n\'a pas été ajouté.';

  @override
  String get subSeries => 'Sous-séries';

  @override
  String get editor => 'Éditeur';

  @override
  String get genre => 'Genre';

  @override
  String get adminHomePage => 'Page d\'accueil de l\'administrateur';

  @override
  String get adminHomePageDescription =>
      'Bienvenue sur la page d\'accueil de l\'administrateur. Ici, vous pouvez gérer les auteurs, les genres, les volumes et plus encore.';

  @override
  String get adminLoginPage => 'Page de connexion administrateur';

  @override
  String get yourEmail => 'Votre email';

  @override
  String get provideYourEmail => 'Veuillez entrer votre email.';

  @override
  String get yourPassword => 'Votre mot de passe';

  @override
  String get provideYourPassword => 'Veuillez entrer votre mot de passe.';

  @override
  String get adminLoginSuccess =>
      'Vous êtes connecté en tant qu\'administrateur avec succès.';

  @override
  String get passwordForgot => 'Mot de passe oublié ?';

  @override
  String get passwordReset => 'Réinitialisation du mot de passe';

  @override
  String get enterEmailForSendingEmailReset =>
      'Entrez votre email pour recevoir un lien pour réinitialiser votre mot de passe.';

  @override
  String get accountEmail => 'Email du compte';

  @override
  String get provideAccountEmail => 'Veuillez fournir l\'email du compte.';

  @override
  String get provideValidAccountEmail =>
      'Veuillez fournir un email de compte valide.';

  @override
  String get oldPassword => 'Ancien mot de passe';

  @override
  String get provideOldPassword =>
      'Veuillez fournir votre ancien mot de passe.';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get provideNewPassword =>
      'Veuillez fournir votre nouveau mot de passe.';

  @override
  String get confirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get provideConfirmNewPassword =>
      'Veuillez confirmer votre nouveau mot de passe.';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get signInPage => 'Page de connexion';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUpPage => 'Page d\'inscription';

  @override
  String get signUp => 'Créer un compte';

  @override
  String get whyLogInDescription =>
      'Connectez-vous pour pouvoir sauvegarder vos mangas favoris et dans votre collection et vous éviter les doublons.';

  @override
  String get whySignUpDescription =>
      'Inscrivez-vous pour pouvoir sauvegarder vos mangas favoris et dans votre collection et vous éviter les doublons.';

  @override
  String get orContinueWith => 'Ou continuez avec';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get noAccountYet => 'Vous n\'avez pas encore de compte ?';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit comporter au moins 8 caractères.';

  @override
  String get usernameMinLength =>
      'Le pseudo doit comporter au moins 3 caractères.';

  @override
  String get username => 'Pseudo';

  @override
  String get provideUsername => 'Veuillez entrer un pseudo.';

  @override
  String get pleaseConfirmPassword => 'Veuillez confirmer votre mot de passe.';

  @override
  String get confirmYourPassword => 'Confirmer votre mot de passe';

  @override
  String get yourBirthday => 'Votre anniversaire';

  @override
  String get provideYourBirthday =>
      'Veuillez fournir votre date d\'anniversaire.';

  @override
  String get yourGender => 'Votre genre';

  @override
  String get provideYourGender => 'Veuillez fournir votre genre.';

  @override
  String get male => 'Homme';

  @override
  String get female => 'Femme';
}
