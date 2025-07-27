// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'fr';

  static String m0(date) => "Compte créé le ${date}";

  static String m1(appVersion, buildVersion) =>
      "Version de l\'application : ${appVersion} & version du build : ${buildVersion}";

  static String m2(date) => "Votre anniversaire est le ${date}";

  static String m3(email) => "Votre email est ${email}";

  static String m4(count) =>
      "${Intl.plural(count, zero: 'Vous avez 0 série', one: 'Vous avez une série', other: 'Vous avez ${count} séries')} en favoris";

  static String m5(maxLength) =>
      "Le nombre maximum de caractères autorisés est ${maxLength}.";

  static String m6(minLength) =>
      "Le nombre minimum de caractères requis est ${minLength}.";

  static String m7(gender) =>
      "${Intl.gender(gender, female: 'elle', male: 'il', other: 'iel')}";

  static String m8(username) => "Votre pseudo est ${username}";

  static String m9(count) => "Tome ${count}";

  static String m10(count) =>
      "${Intl.plural(count, zero: 'Vous possédez 0 volume', one: 'Vous possédez un volume', other: 'Vous possédez ${count} volumes')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accountCreatedOn": m0,
    "accountEmail": MessageLookupByLibrary.simpleMessage("Email du compte"),
    "adminHomePage": MessageLookupByLibrary.simpleMessage(
      "Page d\'accueil de l\'administrateur",
    ),
    "adminHomePageDescription": MessageLookupByLibrary.simpleMessage(
      "Bienvenue sur la page d\'accueil de l\'administrateur. Ici, vous pouvez gérer les auteurs, les genres, les volumes et plus encore.",
    ),
    "adminLoginPage": MessageLookupByLibrary.simpleMessage(
      "Page de connexion administrateur",
    ),
    "adminLoginSuccess": MessageLookupByLibrary.simpleMessage(
      "Vous êtes connecté en tant qu\'administrateur avec succès.",
    ),
    "adultContent": MessageLookupByLibrary.simpleMessage("Contenu adulte"),
    "adultContentWarning": MessageLookupByLibrary.simpleMessage(
      "Avertissement de contenu adulte",
    ),
    "appVersionAndAppBuildVersion": m1,
    "april": MessageLookupByLibrary.simpleMessage("Avril"),
    "artbook": MessageLookupByLibrary.simpleMessage("Artbook"),
    "august": MessageLookupByLibrary.simpleMessage("Août"),
    "authFailed": MessageLookupByLibrary.simpleMessage(
      "Email ou mot de passe incorrect.",
    ),
    "author": MessageLookupByLibrary.simpleMessage("Auteur"),
    "authorAdd": MessageLookupByLibrary.simpleMessage("Ajouter l\'auteur"),
    "authorAddSuccess": MessageLookupByLibrary.simpleMessage(
      "Auteur ajouté avec succès.",
    ),
    "authorDuplicate": MessageLookupByLibrary.simpleMessage(
      "Un auteur avec ce nom existe déjà.",
    ),
    "authorJobs": MessageLookupByLibrary.simpleMessage(
      "Métiers de l\'auteur (séparé par des virgules)",
    ),
    "authorName": MessageLookupByLibrary.simpleMessage("Nom de l\'auteur"),
    "birthdayDateIs": m2,
    "boxSet": MessageLookupByLibrary.simpleMessage("Coffret"),
    "chooseVolumeLanguage": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner la langue du volume.",
    ),
    "chooseVolumeSupport": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner le support du volume.",
    ),
    "clearCache": MessageLookupByLibrary.simpleMessage("Vider le cache"),
    "clearCacheSuccess": MessageLookupByLibrary.simpleMessage(
      "Cache vidé avec succès.",
    ),
    "collection": MessageLookupByLibrary.simpleMessage("Collection"),
    "confirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "Confirmer le nouveau mot de passe",
    ),
    "confirmYourPassword": MessageLookupByLibrary.simpleMessage(
      "Confirmer votre mot de passe",
    ),
    "contentOfBoxSet": MessageLookupByLibrary.simpleMessage(
      "Contenu du coffret",
    ),
    "createAccount": MessageLookupByLibrary.simpleMessage("Créer un compte"),
    "createAuthor": MessageLookupByLibrary.simpleMessage("Créer un auteur"),
    "createGenre": MessageLookupByLibrary.simpleMessage("Créer un genre"),
    "createVolume": MessageLookupByLibrary.simpleMessage("Créer un volume"),
    "dangerZone": MessageLookupByLibrary.simpleMessage("Zone de danger"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Thème sombre"),
    "december": MessageLookupByLibrary.simpleMessage("Décembre"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage(
      "Supprimer le compte",
    ),
    "deleteAccountConfirmation": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.",
    ),
    "deleteAccountFailed": MessageLookupByLibrary.simpleMessage(
      "Une erreur est survenue, votre compte n\'a pas été supprimé, vous avez été déconnecté.",
    ),
    "deleteAccountSuccess": MessageLookupByLibrary.simpleMessage(
      "Compte supprimé avec succès.",
    ),
    "edition": MessageLookupByLibrary.simpleMessage("Édition"),
    "editor": MessageLookupByLibrary.simpleMessage("Éditeur"),
    "emailIs": m3,
    "emailResetSent": MessageLookupByLibrary.simpleMessage(
      "Un email de réinitialisation de mot de passe a été envoyé à votre adresse email.",
    ),
    "english": MessageLookupByLibrary.simpleMessage("Anglais"),
    "enterEmailForSendingEmailReset": MessageLookupByLibrary.simpleMessage(
      "Entrez votre email pour recevoir un lien pour réinitialiser votre mot de passe.",
    ),
    "errorOccurred": MessageLookupByLibrary.simpleMessage(
      "Une erreur est survenue, veuillez réessayer plus tard.",
    ),
    "favoriteSeriesNumber": m4,
    "february": MessageLookupByLibrary.simpleMessage("Février"),
    "female": MessageLookupByLibrary.simpleMessage("Femme"),
    "french": MessageLookupByLibrary.simpleMessage("Français"),
    "genre": MessageLookupByLibrary.simpleMessage("Genre"),
    "genreAdd": MessageLookupByLibrary.simpleMessage("Ajouter le genre"),
    "genreAddSuccess": MessageLookupByLibrary.simpleMessage(
      "Genre ajouté avec succès.",
    ),
    "genreDuplicate": MessageLookupByLibrary.simpleMessage(
      "Un genre avec ce nom existe déjà.",
    ),
    "genreName": MessageLookupByLibrary.simpleMessage("Nom du genre"),
    "german": MessageLookupByLibrary.simpleMessage("Allemand"),
    "helloWorld": MessageLookupByLibrary.simpleMessage("Bonjour le monde !"),
    "home": MessageLookupByLibrary.simpleMessage("Accueil"),
    "invalidEmail": MessageLookupByLibrary.simpleMessage(
      "L\'adresse email est invalide.",
    ),
    "isbn": MessageLookupByLibrary.simpleMessage("ISBN"),
    "italian": MessageLookupByLibrary.simpleMessage("Italien"),
    "january": MessageLookupByLibrary.simpleMessage("Janvier"),
    "japanese": MessageLookupByLibrary.simpleMessage("Japonais"),
    "july": MessageLookupByLibrary.simpleMessage("Juillet"),
    "june": MessageLookupByLibrary.simpleMessage("Juin"),
    "legalNotice": MessageLookupByLibrary.simpleMessage("Mentions légales"),
    "lightMode": MessageLookupByLibrary.simpleMessage("Thème clair"),
    "lightNovel": MessageLookupByLibrary.simpleMessage("Light Novel"),
    "logIn": MessageLookupByLibrary.simpleMessage("Se connecter"),
    "logInFailed": MessageLookupByLibrary.simpleMessage(
      "Une erreur est survenue, vous n\'avez pas été connecté à votre compte.",
    ),
    "logInSuccess": MessageLookupByLibrary.simpleMessage(
      "Vous êtes connecté avec succès.",
    ),
    "logInWithApple": MessageLookupByLibrary.simpleMessage(
      "Se connecter avec Apple",
    ),
    "logInWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Se connecter avec Google",
    ),
    "logOut": MessageLookupByLibrary.simpleMessage("Se déconnecter"),
    "logOutFailed": MessageLookupByLibrary.simpleMessage(
      "Une erreur est survenue, vous n\'avez pas été déconnecté.",
    ),
    "logOutSuccess": MessageLookupByLibrary.simpleMessage(
      "Vous êtes déconnecté avec succès.",
    ),
    "male": MessageLookupByLibrary.simpleMessage("Homme"),
    "manga": MessageLookupByLibrary.simpleMessage("Manga"),
    "march": MessageLookupByLibrary.simpleMessage("Mars"),
    "maxLengthExceeded": m5,
    "may": MessageLookupByLibrary.simpleMessage("Mai"),
    "minLengthNotReached": m6,
    "modifyPassword": MessageLookupByLibrary.simpleMessage(
      "Modifier le mot de passe",
    ),
    "modifyPasswordSuccess": MessageLookupByLibrary.simpleMessage(
      "Mot de passe modifié avec succès.",
    ),
    "newPassword": MessageLookupByLibrary.simpleMessage("Nouveau mot de passe"),
    "noAccountYet": MessageLookupByLibrary.simpleMessage(
      "Vous n\'avez pas encore de compte ?",
    ),
    "novel": MessageLookupByLibrary.simpleMessage("Roman"),
    "november": MessageLookupByLibrary.simpleMessage("Novembre"),
    "october": MessageLookupByLibrary.simpleMessage("Octobre"),
    "oldPassword": MessageLookupByLibrary.simpleMessage("Ancien mot de passe"),
    "orContinueWith": MessageLookupByLibrary.simpleMessage("Ou continuez avec"),
    "other": MessageLookupByLibrary.simpleMessage("Autre"),
    "owned": MessageLookupByLibrary.simpleMessage("Possédé"),
    "passwordForgot": MessageLookupByLibrary.simpleMessage(
      "Mot de passe oublié ?",
    ),
    "passwordMinLength": MessageLookupByLibrary.simpleMessage(
      "Le mot de passe doit comporter au moins 8 caractères.",
    ),
    "passwordReset": MessageLookupByLibrary.simpleMessage(
      "Réinitialisation du mot de passe",
    ),
    "passwordTooShort": MessageLookupByLibrary.simpleMessage(
      "Le mot de passe doit comporter au moins 6 caractères.",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "Les mots de passe ne correspondent pas.",
    ),
    "pleaseConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "Veuillez confirmer votre mot de passe.",
    ),
    "pleaseSelectDate": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner une date.",
    ),
    "pleaseWait": MessageLookupByLibrary.simpleMessage("Veuillez patienter..."),
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "profileSettings": MessageLookupByLibrary.simpleMessage(
      "Page de profil et réglages",
    ),
    "pronoun": m7,
    "provideAccountEmail": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir l\'email du compte.",
    ),
    "provideAuthorJobs": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir les métiers de l\'auteur (séparés par des virgules).",
    ),
    "provideAuthorName": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir le nom de l\'auteur.",
    ),
    "provideConfirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "Veuillez confirmer votre nouveau mot de passe.",
    ),
    "provideContentOfBoxSet": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir le contenu du coffret.",
    ),
    "provideGenreName": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir le nom du genre.",
    ),
    "provideNewPassword": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir votre nouveau mot de passe.",
    ),
    "provideOldPassword": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir votre ancien mot de passe.",
    ),
    "provideSeriesIdOfAuthor": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir le(s) ID(s) de la série de l\'auteur.",
    ),
    "provideUsername": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer un pseudo.",
    ),
    "provideValidAccountEmail": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir un email de compte valide.",
    ),
    "provideValidVolumeEditorId": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir un ID d\'éditeur de volume valide.",
    ),
    "provideValidVolumeSeriesId": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir un ID de série de volume valide.",
    ),
    "provideValidVolumeSubSeriesId": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir un ID de sous-série de volume valide.",
    ),
    "provideVolumeAuthorsIds": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir les IDs des auteurs du volume.",
    ),
    "provideVolumeEAN": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir l\'EAN du volume.",
    ),
    "provideVolumeEditorId": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir l\'ID de l\'éditeur du volume",
    ),
    "provideVolumeInfo": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir les informations sur le volume.",
    ),
    "provideVolumeLink": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir le lien du volume.",
    ),
    "provideVolumeNumber": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir le numéro du volume.",
    ),
    "provideVolumePrice": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir le prix du volume.",
    ),
    "provideVolumeSeriesId": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir l\'ID de la série du volume.",
    ),
    "provideVolumeSubSeriesId": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir l\'ID de la sous-série du volume.",
    ),
    "provideVolumeSummary": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir le résumé du volume.",
    ),
    "provideVolumeTitle": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir le titre du volume.",
    ),
    "provideYourBirthday": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir votre date d\'anniversaire.",
    ),
    "provideYourEmail": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer votre email.",
    ),
    "provideYourGender": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir votre genre.",
    ),
    "provideYourPassword": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer votre mot de passe.",
    ),
    "publicationDate": MessageLookupByLibrary.simpleMessage(
      "Date de publication",
    ),
    "publisher": MessageLookupByLibrary.simpleMessage("Éditeur"),
    "scanner": MessageLookupByLibrary.simpleMessage("Scanner"),
    "scannerDescription": MessageLookupByLibrary.simpleMessage(
      "Scanner les codes-barres des volumes pour les ajouter à votre collection.",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Recherche"),
    "selectDate": MessageLookupByLibrary.simpleMessage("Sélectionner la date"),
    "september": MessageLookupByLibrary.simpleMessage("Septembre"),
    "series": MessageLookupByLibrary.simpleMessage("Série"),
    "seriesIdOfAuthor": MessageLookupByLibrary.simpleMessage(
      "ID de la série de l\'auteur",
    ),
    "signIn": MessageLookupByLibrary.simpleMessage("Se connecter"),
    "signInPage": MessageLookupByLibrary.simpleMessage("Page de connexion"),
    "signUp": MessageLookupByLibrary.simpleMessage("Créer un compte"),
    "signUpPage": MessageLookupByLibrary.simpleMessage("Page d\'inscription"),
    "spanish": MessageLookupByLibrary.simpleMessage("Espagnol"),
    "subSeries": MessageLookupByLibrary.simpleMessage("Sous-séries"),
    "systemMode": MessageLookupByLibrary.simpleMessage("Thème du système"),
    "userLoginFailed": MessageLookupByLibrary.simpleMessage(
      "Une erreur est survenue, vous n\\\'avez pas été connecter à votre compte.",
    ),
    "userLoginSuccess": MessageLookupByLibrary.simpleMessage(
      "Vous êtes connecté avec succès.",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Pseudo"),
    "usernameIs": m8,
    "usernameMinLength": MessageLookupByLibrary.simpleMessage(
      "Le pseudo doit comporter au moins 3 caractères.",
    ),
    "volume": MessageLookupByLibrary.simpleMessage("Tome"),
    "volumeAdd": MessageLookupByLibrary.simpleMessage("Ajouter un volume"),
    "volumeAddError": MessageLookupByLibrary.simpleMessage(
      "Une erreur est survenue, le volume n\'a pas été ajouté.",
    ),
    "volumeAddSuccess": MessageLookupByLibrary.simpleMessage(
      "Volume ajouté avec succès.",
    ),
    "volumeAuthorsIds": MessageLookupByLibrary.simpleMessage(
      "IDs des auteurs du volume",
    ),
    "volumeEAN": MessageLookupByLibrary.simpleMessage("EAN du volume"),
    "volumeEditorId": MessageLookupByLibrary.simpleMessage(
      "ID de l\'éditeur du volume",
    ),
    "volumeInfo": MessageLookupByLibrary.simpleMessage(
      "Informations sur le volume",
    ),
    "volumeLanguage": MessageLookupByLibrary.simpleMessage("Langue du volume"),
    "volumeLink": MessageLookupByLibrary.simpleMessage("Lien du volume"),
    "volumeNum": m9,
    "volumeNumber": MessageLookupByLibrary.simpleMessage("Numéro du volume"),
    "volumeOwnedNumber": m10,
    "volumePrice": MessageLookupByLibrary.simpleMessage("Prix du volume"),
    "volumeSeriesId": MessageLookupByLibrary.simpleMessage(
      "ID de la série du volume",
    ),
    "volumeSubSeriesId": MessageLookupByLibrary.simpleMessage(
      "ID de la sous-série du volume",
    ),
    "volumeSummary": MessageLookupByLibrary.simpleMessage("Résumé du volume"),
    "volumeSupport": MessageLookupByLibrary.simpleMessage("Support du volume"),
    "volumeTitle": MessageLookupByLibrary.simpleMessage("Titre du volume"),
    "whyLogInDescription": MessageLookupByLibrary.simpleMessage(
      "Connectez-vous pour pouvoir sauvegarder vos mangas favoris et dans votre collection et vous éviter les doublons.",
    ),
    "whySignUpDescription": MessageLookupByLibrary.simpleMessage(
      "Inscrivez-vous pour pouvoir sauvegarder vos mangas favoris et dans votre collection et vous éviter les doublons.",
    ),
    "yourBirthday": MessageLookupByLibrary.simpleMessage("Votre anniversaire"),
    "yourEmail": MessageLookupByLibrary.simpleMessage("Votre email"),
    "yourGender": MessageLookupByLibrary.simpleMessage("Votre genre"),
    "yourPassword": MessageLookupByLibrary.simpleMessage("Votre mot de passe"),
  };
}
