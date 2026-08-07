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

  static String m1(count) =>
      "${Intl.plural(count, one: 'Voulez-vous ajouter ce tome à votre collection ?', other: 'Voulez-vous ajouter ces ${count} tomes à votre collection ?')}";

  static String m2(appVersion, buildVersion) =>
      "Version de l\'application : ${appVersion} & version du build : ${buildVersion}";

  static String m3(availability) =>
      "${Intl.select(availability, {'inStock': 'En Stock', 'available': 'Disponible', 'unavailable': 'Indisponible', 'onPreorder': 'En Précommande', 'other': '${availability}'})}";

  static String m4(date) => "Votre anniversaire est le ${date}";

  static String m5(store) => "Acheter sur ${store}";

  static String m6(number) =>
      "Vous avez scanné le tome ${number} d\'une nouvelle sous-série. Sélectionnez les tomes jusqu\'à celui-ci que vous souhaitez ajouter.";

  static String m7(email) => "Votre email est ${email}";

  static String m8(object) =>
      "Une erreur s\'est produite lors de l\'initialisation ${object}.";

  static String m9(message) => "Une erreur s\'est produite : ${message}";

  static String m10(characters) => "Personnage(s) favori(s) : ${characters}";

  static String m11(count) =>
      "${Intl.plural(count, zero: 'Vous avez 0 série', one: 'Vous avez une série', other: 'Vous avez ${count} séries')} en favoris";

  static String m12(job) =>
      "${Intl.select(job, {'writerMen': 'Écrivain', 'writerWomen': 'Écrivaine', 'artistMen': 'Dessinateur', 'artistWomen': 'Dessinatrice', 'editorMen': 'Éditeur', 'editorWomen': 'Éditrice', 'illustratorMen': 'Illustrateur', 'illustratorWomen': 'Illustratrice', 'scriptwriterMen': 'Scénariste', 'scriptwriterWomen': 'Scénariste', 'authorMen': 'Auteur', 'authorWomen': 'Auteure', 'mangakaMen': 'Mangaka', 'mangakaWomen': 'Mangaka', 'charaDesignMen': 'Chara Design', 'charaDesignWomen': 'Chara Design', 'other': 'Other'})}";

  static String m13(ean) => "Dernier EAN scanné : ${ean}";

  static String m14(maxLength) =>
      "Le nombre maximum de caractères autorisés est ${maxLength}.";

  static String m15(minLength) =>
      "Le nombre minimum de caractères requis est ${minLength}.";

  static String m16(gender) =>
      "${Intl.gender(gender, female: 'elle', male: 'il', other: 'iel')}";

  static String m17(count) => "Étoiles : ${count}/5";

  static String m18(error) => "Impossible d\'envoyer l\'avis : ${error}";

  static String m19(ean) => "Aucun tome trouvé pour l\'EAN ${ean}.";

  static String m20(count) =>
      "${Intl.plural(count, zero: '0 tome', one: '1 tome', other: '${count} tomes')}";

  static String m21(count) =>
      "${Intl.plural(count, zero: 'Série', one: 'Série', other: 'Séries')}";

  static String m22(days) => "Expédition sous ${days} jours";

  static String m23(count) =>
      "Expédition sous {count, select, 0{0 semaine} 1{1 semaine} other{${count} semaines}}";

  static String m24(seller) => "Vendu et expédié par ${seller}";

  static String m25(author) =>
      "${Intl.select(author, {'error': '', 'other': 'De ${author}'})}";

  static String m26(count) =>
      "Total de ${Intl.plural(count, zero: '0 tome', one: '1 tome', other: '${count} tomes')}";

  static String m27(count) =>
      "${Intl.plural(count, zero: 'Sous-série', one: 'Sous-série', other: 'Sous-séries')}";

  static String m28(support) =>
      "${Intl.select(support, {'manga': 'Manga', 'novel': 'Roman', 'artbook': 'Artbook', 'lightNovel': 'Light Novel', 'boxSet': 'Coffret', 'other': 'Other'})}";

  static String m29(username) => "Votre pseudo est ${username}";

  static String m30(count) => "Tome ${count}";

  static String m31(count) =>
      "${Intl.plural(count, zero: 'Vous possédez 0 volume', one: 'Vous possédez un volume', other: 'Vous possédez ${count} volumes')}";

  static String m32(owned, total) =>
      "${Intl.plural(owned, zero: '0 tome possédé', one: '1 tome possédé', other: '${owned} tomes possédés')} sur ${Intl.plural(total, zero: '0 tome', one: '1 tome', other: '${total} tomes')}";

  static String m33(readed, total) =>
      "${Intl.plural(readed, zero: '0 tome lu', one: '1 tome lu', other: '${readed} tomes lus')} sur ${Intl.plural(total, zero: '0 tome', one: '1 tome', other: '${total} tomes')}.";

  static String m34(readed, total) =>
      "${Intl.plural(readed, zero: '0 tome lu', one: '1 tome lu', other: '${readed} tomes lus')} sur ${Intl.plural(total, zero: '0 tome possédé', one: '1 tome possédé', other: '${total} tomes possédés')}.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accountCreatedOn": m0,
    "accountEmail": MessageLookupByLibrary.simpleMessage("Email du compte"),
    "accountHaveBeenDeleted": MessageLookupByLibrary.simpleMessage(
      "Votre compte a été supprimé avec succès.",
    ),
    "add": MessageLookupByLibrary.simpleMessage("Ajouter"),
    "addScannedVolumesConfirmation": m1,
    "addScannedVolumesTitle": MessageLookupByLibrary.simpleMessage(
      "Ajouter les tomes scannés ?",
    ),
    "addSelectedVolumes": MessageLookupByLibrary.simpleMessage(
      "Ajouter les tomes sélectionnés",
    ),
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
    "adultContentBlockedDescription": MessageLookupByLibrary.simpleMessage(
      "Ce tome est marqué 18+. Activez le contenu adulte dans les réglages du profil pour afficher la couverture.",
    ),
    "adultContentDisabled": MessageLookupByLibrary.simpleMessage(
      "Affichage du contenu adulte désactivé.",
    ),
    "adultContentEnabled": MessageLookupByLibrary.simpleMessage(
      "Affichage du contenu adulte activé.",
    ),
    "adultContentPreferenceDescription": MessageLookupByLibrary.simpleMessage(
      "Autoriser l\'affichage des couvertures et contenus marqués 18+.",
    ),
    "adultContentWarning": MessageLookupByLibrary.simpleMessage(
      "Avertissement de contenu adulte",
    ),
    "allVolumesOwned": MessageLookupByLibrary.simpleMessage(
      "Vous possedez tous les tomes de volumes. Vous les possédez tous 👏.",
    ),
    "allVolumesReaded": MessageLookupByLibrary.simpleMessage(
      "Vous avez lu tous les tomes possédés.",
    ),
    "allVolumesReadedSubSeries": MessageLookupByLibrary.simpleMessage(
      "Vous avez lu tous les tomes de cette sous-série 👏.",
    ),
    "alphabeticalOrder": MessageLookupByLibrary.simpleMessage(
      "Ordre alphabétique",
    ),
    "alreadyHaveAnAccount": MessageLookupByLibrary.simpleMessage(
      "Vous avez déjà un compte ?",
    ),
    "appVersionAndAppBuildVersion": m2,
    "applicableLawAndCompetentJurisdiction":
        MessageLookupByLibrary.simpleMessage(
          "Droit applicable et Juridiction compétente",
        ),
    "applicableLawAndCompetentJurisdictionLane1":
        MessageLookupByLibrary.simpleMessage(
          "Les présentes mentions légales sont soumises au droit français. En cas de litige, les tribunaux français seront seuls compétents.",
        ),
    "april": MessageLookupByLibrary.simpleMessage("Avril"),
    "areYouSureDeleteAccount": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible et entraînera la suppression de toutes vos données, y compris votre collection, vos séries suivies et vos informations de profil.",
    ),
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
    "authorDoesNotExist": MessageLookupByLibrary.simpleMessage(
      "L\'auteur n\'existe pas.",
    ),
    "authorDuplicate": MessageLookupByLibrary.simpleMessage(
      "Un auteur avec ce nom existe déjà.",
    ),
    "authorJobs": MessageLookupByLibrary.simpleMessage(
      "Métiers de l\'auteur (séparé par des virgules)",
    ),
    "authorName": MessageLookupByLibrary.simpleMessage("Nom de l\'auteur"),
    "authorRights": MessageLookupByLibrary.simpleMessage("Droits d\'auteur"),
    "authorRightsLane1": MessageLookupByLibrary.simpleMessage(
      "MyMangatheque et son contenu (textes, images, vidéos, etc.) sont protégés par les lois sur la propriété intellectuelle en vigueur en France. Toute reproduction, représentation, modification, publication, adaptation de tout ou partie des éléments du site, quel que soit le moyen ou le procédé utilisé, est interdite, sauf autorisation écrite préalable ou à titre personnel comme challenge de code mais sans publication.",
    ),
    "authors": MessageLookupByLibrary.simpleMessage("Auteurs"),
    "availability": m3,
    "availabilityUnknown": MessageLookupByLibrary.simpleMessage(
      "Disponibilité inconnue",
    ),
    "birthdayDateIs": m4,
    "boxSet": MessageLookupByLibrary.simpleMessage("Coffret"),
    "buildAppVersionImpossibleToRetreive": MessageLookupByLibrary.simpleMessage(
      "Impossible de récupérer la version de l\'application et la version du build.",
    ),
    "buyOn": m5,
    "cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
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
    "clearSelection": MessageLookupByLibrary.simpleMessage(
      "Effacer la sélection",
    ),
    "collection": MessageLookupByLibrary.simpleMessage("Collection"),
    "comment": MessageLookupByLibrary.simpleMessage("Commentaire"),
    "completeLibrary": MessageLookupByLibrary.simpleMessage("Compléter"),
    "completeScannedSubSeriesDescription": m6,
    "completeScannedSubSeriesTitle": MessageLookupByLibrary.simpleMessage(
      "Ajouter les tomes précédents ?",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirmer"),
    "confirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "Confirmer le nouveau mot de passe",
    ),
    "confirmYourPassword": MessageLookupByLibrary.simpleMessage(
      "Confirmer votre mot de passe",
    ),
    "contact": MessageLookupByLibrary.simpleMessage("Contact"),
    "contactLane1": MessageLookupByLibrary.simpleMessage(
      "Pour toute question ou réclamation, veuillez nous contacter à l\'une des adresses mail suivante : mymangatheque@gmail.com ou contact@mymangatheque.com .",
    ),
    "contactRightsAndUpdateDate": MessageLookupByLibrary.simpleMessage(
      "Contact, Droit et Date de Mise à Jour",
    ),
    "contentOfBoxSet": MessageLookupByLibrary.simpleMessage(
      "Contenu du coffret",
    ),
    "cookieUsage": MessageLookupByLibrary.simpleMessage(
      "Utilisation des cookies",
    ),
    "cookieUsageLane1": MessageLookupByLibrary.simpleMessage(
      "L\'utilisateur est informé, qu’à l’occasion d’une visite sur le Site, un cookie peut s\'installer automatiquement sur son logiciel de navigation. Un cookie consiste en un bloc de données qui ne permet pas d\'identifier l\'utilisateur mais permet d’enregistrer des informations relatives à la navigation de celui-ci sur le Site afin de procéder à des analyses de fréquentation du Site, le tout pour améliorer la qualité du Site.",
    ),
    "cookieUsageLane2": MessageLookupByLibrary.simpleMessage(
      "L\'utilisateur dispose d\'un droit d\'accès, de rectification ou de suppression des données personnelles communiquées par le biais d’un cookie dans les conditions indiquées ci-dessus.",
    ),
    "createAccount": MessageLookupByLibrary.simpleMessage("Créer un compte"),
    "createAuthor": MessageLookupByLibrary.simpleMessage("Créer un auteur"),
    "createGenre": MessageLookupByLibrary.simpleMessage("Créer un genre"),
    "createVolume": MessageLookupByLibrary.simpleMessage("Créer un volume"),
    "dangerZone": MessageLookupByLibrary.simpleMessage("Zone de danger"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Thème sombre"),
    "dataUndercase": MessageLookupByLibrary.simpleMessage("des données"),
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
    "desiredLibrary": MessageLookupByLibrary.simpleMessage("Envies"),
    "discover": MessageLookupByLibrary.simpleMessage("Découvrir"),
    "ean": MessageLookupByLibrary.simpleMessage("EAN"),
    "edition": MessageLookupByLibrary.simpleMessage("Édition"),
    "editor": MessageLookupByLibrary.simpleMessage("Éditeur"),
    "editorDoesNotExist": MessageLookupByLibrary.simpleMessage(
      "L\'éditeur n\'existe pas.",
    ),
    "editors": MessageLookupByLibrary.simpleMessage("Éditeurs"),
    "emailIs": m7,
    "emailResetSent": MessageLookupByLibrary.simpleMessage(
      "Un email de réinitialisation de mot de passe a été envoyé à votre adresse email.",
    ),
    "english": MessageLookupByLibrary.simpleMessage("Anglais"),
    "englishAndJapaneseTitle": MessageLookupByLibrary.simpleMessage(
      "Titre anglais et japonais",
    ),
    "englishTitle": MessageLookupByLibrary.simpleMessage("Titre anglais"),
    "enterEmailForSendingEmailReset": MessageLookupByLibrary.simpleMessage(
      "Entrez votre email pour recevoir un lien pour réinitialiser votre mot de passe.",
    ),
    "error404": MessageLookupByLibrary.simpleMessage("Erreur 404"),
    "errorDeleteAccount": MessageLookupByLibrary.simpleMessage(
      "Une erreur est survenue lors de la suppression de votre compte. Veuillez réessayer plus tard.",
    ),
    "errorInitializing": m8,
    "errorOccurred": MessageLookupByLibrary.simpleMessage(
      "Une erreur est survenue, veuillez réessayer plus tard.",
    ),
    "errorOccurredMessage": m9,
    "externalLinks": MessageLookupByLibrary.simpleMessage("Liens externes"),
    "externalLinksLane1": MessageLookupByLibrary.simpleMessage(
      "Le site web MyMangatheque peut contenir des liens vers des sites externes. Nous déclinons toute responsabilité quant au contenu et aux pratiques de confidentialité de ces sites. Ces liens sont proposés aux utilisateurs du Site ou des sites web de ses filiales et entités affiliées en tant que service. La décision d\'activer les liens appartient exclusivement aux utilisateurs.",
    ),
    "favorite": MessageLookupByLibrary.simpleMessage("Favori"),
    "favoriteCharacters": MessageLookupByLibrary.simpleMessage(
      "Personnage(s) favori(s)",
    ),
    "favoriteCharactersHint": MessageLookupByLibrary.simpleMessage(
      "Tanjiro, Nezuko, ...",
    ),
    "favoriteCharactersLabel": m10,
    "favoriteSeriesNumber": m11,
    "february": MessageLookupByLibrary.simpleMessage("Février"),
    "female": MessageLookupByLibrary.simpleMessage("Femme"),
    "follow": MessageLookupByLibrary.simpleMessage("Suivre"),
    "followed": MessageLookupByLibrary.simpleMessage("Suivi"),
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
    "genres": MessageLookupByLibrary.simpleMessage("Genres"),
    "german": MessageLookupByLibrary.simpleMessage("Allemand"),
    "goHome": MessageLookupByLibrary.simpleMessage("Aller à l\'accueil"),
    "helloWorld": MessageLookupByLibrary.simpleMessage("Bonjour le monde !"),
    "home": MessageLookupByLibrary.simpleMessage("Accueil"),
    "informations": MessageLookupByLibrary.simpleMessage("Informations"),
    "intellectualProperty": MessageLookupByLibrary.simpleMessage(
      "Propriété intellectuelle",
    ),
    "invalidEmail": MessageLookupByLibrary.simpleMessage(
      "L\'adresse email est invalide.",
    ),
    "isbn": MessageLookupByLibrary.simpleMessage("ISBN"),
    "italian": MessageLookupByLibrary.simpleMessage("Italien"),
    "january": MessageLookupByLibrary.simpleMessage("Janvier"),
    "japanese": MessageLookupByLibrary.simpleMessage("Japonais"),
    "japaneseTitle": MessageLookupByLibrary.simpleMessage("Titre japonais"),
    "jobsName": m12,
    "july": MessageLookupByLibrary.simpleMessage("Juillet"),
    "june": MessageLookupByLibrary.simpleMessage("Juin"),
    "lastRelease": MessageLookupByLibrary.simpleMessage("Dernière sortie"),
    "lastScannedEan": m13,
    "lastUpdateDate": MessageLookupByLibrary.simpleMessage(
      "Date de dernière mise à jour",
    ),
    "legalNotice": MessageLookupByLibrary.simpleMessage("Mentions légales"),
    "lightMode": MessageLookupByLibrary.simpleMessage("Thème clair"),
    "lightNovel": MessageLookupByLibrary.simpleMessage("Light Novel"),
    "loading": MessageLookupByLibrary.simpleMessage("Chargement..."),
    "loadingData": MessageLookupByLibrary.simpleMessage(
      "Chargement des données...",
    ),
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
    "maxLengthExceeded": m14,
    "may": MessageLookupByLibrary.simpleMessage("Mai"),
    "minLengthNotReached": m15,
    "modifyPassword": MessageLookupByLibrary.simpleMessage(
      "Modifier le mot de passe",
    ),
    "modifyPasswordSuccess": MessageLookupByLibrary.simpleMessage(
      "Mot de passe modifié avec succès.",
    ),
    "neverShowAgain": MessageLookupByLibrary.simpleMessage(
      "Ne plus jamais afficher cette option",
    ),
    "newPassword": MessageLookupByLibrary.simpleMessage("Nouveau mot de passe"),
    "noAccountYet": MessageLookupByLibrary.simpleMessage(
      "Vous n\'avez pas encore de compte ?",
    ),
    "noConnection": MessageLookupByLibrary.simpleMessage(
      "Aucune connexion Internet",
    ),
    "noFollowedSubSerie": MessageLookupByLibrary.simpleMessage(
      "Vous ne suivez aucune sous-série, vous pouvez en suivre via la page de recherche.",
    ),
    "noResults": MessageLookupByLibrary.simpleMessage("Aucun résultat"),
    "noReviewsForThisVolumeYet": MessageLookupByLibrary.simpleMessage(
      "Aucun avis pour ce tome pour le moment.",
    ),
    "noScannedVolumesYet": MessageLookupByLibrary.simpleMessage(
      "Aucun tome scanné pour le moment.",
    ),
    "noVolumeOwned": MessageLookupByLibrary.simpleMessage(
      "Vous ne possédez aucun tome dans votre collection, vous pouvez en ajouter via la page de recherche ou en scannant les codes barres des tomes que vous possédez.",
    ),
    "notAvailable": MessageLookupByLibrary.simpleMessage("Non disponible"),
    "novel": MessageLookupByLibrary.simpleMessage("Roman"),
    "november": MessageLookupByLibrary.simpleMessage("Novembre"),
    "numberOfPages": MessageLookupByLibrary.simpleMessage("Nombre de pages"),
    "october": MessageLookupByLibrary.simpleMessage("Octobre"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "oldPassword": MessageLookupByLibrary.simpleMessage("Ancien mot de passe"),
    "openContentSettings": MessageLookupByLibrary.simpleMessage(
      "Ouvrir les réglages du contenu",
    ),
    "openQuestionnaire": MessageLookupByLibrary.simpleMessage(
      "Ouvrir le questionnaire",
    ),
    "openScan": MessageLookupByLibrary.simpleMessage("Ouvrir le scan"),
    "orContinueWith": MessageLookupByLibrary.simpleMessage("Ou continuez avec"),
    "other": MessageLookupByLibrary.simpleMessage("Autre"),
    "owned": MessageLookupByLibrary.simpleMessage("Possédé"),
    "pageNotFound": MessageLookupByLibrary.simpleMessage("Page non trouvée"),
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
    "pendingModeration": MessageLookupByLibrary.simpleMessage(
      "En attente de modération",
    ),
    "personalData": MessageLookupByLibrary.simpleMessage(
      "Données personnelles",
    ),
    "pleaseConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "Veuillez confirmer votre mot de passe.",
    ),
    "pleaseSelectDate": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner une date.",
    ),
    "pleaseWait": MessageLookupByLibrary.simpleMessage("Veuillez patienter..."),
    "preamble": MessageLookupByLibrary.simpleMessage("Préambule"),
    "preambleLane1": MessageLookupByLibrary.simpleMessage(
      "Les informations et recommandations ( « Informations » ) disponibles sur ce site web ( ou aussi « le Site » ) vous sont proposées en toute bonne foi. Ces informations sont censées être correctes au moment où vous en prenez connaissance. Toutefois, MyMangatheque ou ses filiales et entités affiliées ne sont pas garantes du caractère exhaustif et de l\'exactitude des Informations. Vous assumez pleinement les risques liés au crédit que vous leur accordez.",
    ),
    "preambleLane2": MessageLookupByLibrary.simpleMessage(
      "Les Informations vous sont fournies à la condition que vous, ou toute autre personne les récent, puissiez déterminer leur intérêt pour un objectif précis avant de les utiliser. En aucun cas, MyMangatheque ou ses filiales et entités affiliées ne seront responsables des dommages susceptibles de résultée du crédit accordé à ces informations, de leur utilisation ou de l\'utilisation d\'un produit auquel elles font référence.",
    ),
    "preambleLane3": MessageLookupByLibrary.simpleMessage(
      "Les Informations ne doivent pas être considérées comme des recommandations pour l\'utilisation d\'informations, de produits, de procédures, d\'équipements ou de formulations qui seraient en contradiction avec un brevet, un copyright ou une marque déposée.",
    ),
    "preambleLane4": MessageLookupByLibrary.simpleMessage(
      "MyMangatheque ou ses filiales et entités affiliées déclineraient toute responsabilité si l\'utilisation des Informations venait de contrevenir à un brevet, une marque déposée ou plus généralement un droit de propriété intellectuelle quelconque.",
    ),
    "preambleLane5": MessageLookupByLibrary.simpleMessage(
      "Aucune garantit, expresse ou implicite, n\'est donnée quant à la nature marchande des informations fournies, ni quant à leur adéquation à une finalité déterminée, ainsi qu\'en ce qui concerne les produits auxquels il est fait référence dans ces informations.",
    ),
    "preambleLane6": MessageLookupByLibrary.simpleMessage(
      "En aucun cas, MyMangatheque ou ses filiales et entités affiliées ne s\'engagent à mettre à jour ou à corriger les Informations qui seront diffusées par elles sur Internet ou sur leurs serveurs web. De même, MyMangatheque ou ses filiales et entités affiliées se réservent le droit de modifier ou de corriger le contenu de leurs sites à tout moment et sans préavis.",
    ),
    "price": MessageLookupByLibrary.simpleMessage("Prix"),
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "profileSettings": MessageLookupByLibrary.simpleMessage(
      "Page de profil et réglages",
    ),
    "pronoun": m16,
    "protectionOfPersonalData": MessageLookupByLibrary.simpleMessage(
      "Protection des données personnelles",
    ),
    "protectionOfPersonalDataLane1": MessageLookupByLibrary.simpleMessage(
      "Vos données personnelles sont uniquement destinées à MyMangatheque. Elles ne seront en aucun cas communiquées à des tiers. Au regard des règles de protection des données personnelles (article 34 de Loi « Informatiques et Libertés » du 6 Janvier 1978, directives 95/46 et 97/66), vous disposez d\'un droit d\'accès, de rectification et de suppression des données qui vous concernent. Pour l\'exercer, pour vous opposer à la réception de tout message commercial ou pour toute rectification, adressez-vous par mail, présent dans la rubrique contact.",
    ),
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
    "read": MessageLookupByLibrary.simpleMessage("Lire"),
    "readPile": MessageLookupByLibrary.simpleMessage("Pile à lire"),
    "readed": MessageLookupByLibrary.simpleMessage("Lu"),
    "remove": MessageLookupByLibrary.simpleMessage("Retirer"),
    "reviewCommentHint": MessageLookupByLibrary.simpleMessage(
      "Qu\'avez-vous pensé de ce tome ?",
    ),
    "reviewQuestionnaireDescription": MessageLookupByLibrary.simpleMessage(
      "Maintenant que ce tome est marqué comme lu, vous pouvez le noter et laisser un commentaire.",
    ),
    "reviewQuestionnaireTitle": MessageLookupByLibrary.simpleMessage(
      "Questionnaire d\'avis",
    ),
    "reviewStars": m17,
    "reviewSubmitFailed": m18,
    "reviewSubmittedSuccess": MessageLookupByLibrary.simpleMessage(
      "Avis envoyé avec succès.",
    ),
    "reviews": MessageLookupByLibrary.simpleMessage("Avis"),
    "scanEAN": MessageLookupByLibrary.simpleMessage("Scan EAN"),
    "scanPreviousVolumesSuggestion": MessageLookupByLibrary.simpleMessage(
      "Proposer les tomes précédents après un scan",
    ),
    "scanPreviousVolumesSuggestionDescription":
        MessageLookupByLibrary.simpleMessage(
          "Lors du scan d\'un tome avancé d\'une nouvelle sous-série, proposer aussi l\'ajout des tomes précédents.",
        ),
    "scannedVolumeAlreadyInList": MessageLookupByLibrary.simpleMessage(
      "Ce tome est déjà dans la liste scannée.",
    ),
    "scannedVolumeNotFound": m19,
    "scannedVolumesAdded": MessageLookupByLibrary.simpleMessage(
      "Les tomes scannés ont été ajoutés à votre collection.",
    ),
    "scannedVolumesCount": m20,
    "scannedVolumesPreview": MessageLookupByLibrary.simpleMessage(
      "Prévisualisation des tomes scannés",
    ),
    "scanner": MessageLookupByLibrary.simpleMessage("Scanner"),
    "scannerDescription": MessageLookupByLibrary.simpleMessage(
      "Scanner les codes-barres des volumes pour les ajouter à votre collection.",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Recherche"),
    "seeLess": MessageLookupByLibrary.simpleMessage("Voir moins"),
    "seeMore": MessageLookupByLibrary.simpleMessage("Voir plus"),
    "selectAllVolumes": MessageLookupByLibrary.simpleMessage(
      "Tout sélectionner",
    ),
    "selectDate": MessageLookupByLibrary.simpleMessage("Sélectionner la date"),
    "september": MessageLookupByLibrary.simpleMessage("Septembre"),
    "series": MessageLookupByLibrary.simpleMessage("Série"),
    "seriesCount": m21,
    "seriesDoesNotExist": MessageLookupByLibrary.simpleMessage(
      "La série n\'existe pas.",
    ),
    "seriesIdOfAuthor": MessageLookupByLibrary.simpleMessage(
      "ID de la série de l\'auteur",
    ),
    "shippingUnderDays": m22,
    "shippingUnderWeeks": m23,
    "signIn": MessageLookupByLibrary.simpleMessage("Se connecter"),
    "signInPage": MessageLookupByLibrary.simpleMessage("Page de connexion"),
    "signUp": MessageLookupByLibrary.simpleMessage("Créer un compte"),
    "signUpPage": MessageLookupByLibrary.simpleMessage("Page d\'inscription"),
    "soldAndShippedBy": m24,
    "spanish": MessageLookupByLibrary.simpleMessage("Espagnol"),
    "subSerie": MessageLookupByLibrary.simpleMessage("Sous-série"),
    "subSerieFromAuthor": m25,
    "subSerieVolumeNumber": m26,
    "subSeries": MessageLookupByLibrary.simpleMessage("Sous-séries"),
    "subSeriesCount": m27,
    "subSeriesDoesNotExist": MessageLookupByLibrary.simpleMessage(
      "La sous-série n\'existe pas.",
    ),
    "summary": MessageLookupByLibrary.simpleMessage("Résumé"),
    "supportIs": m28,
    "systemMode": MessageLookupByLibrary.simpleMessage("Thème du système"),
    "thirdPartyContent": MessageLookupByLibrary.simpleMessage("Contenu tiers"),
    "thirdPartyContentLane1": MessageLookupByLibrary.simpleMessage(
      "Les contenus tiers utilisés sur le site MyMangatheque appartiennent à leurs auteurs respectifs.",
    ),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "unknownError": MessageLookupByLibrary.simpleMessage(
      "Une erreur inconnue s\'est produite.",
    ),
    "userContent": MessageLookupByLibrary.simpleMessage("Contenu utilisateur"),
    "userContentLane1": MessageLookupByLibrary.simpleMessage(
      "L’Utilisateur est seul responsable du Contenu Utilisateur qu’il met en ligne via le Service, ainsi que des textes et/ou opinions qu’il formule. L\'Utilisateur cède expressément et gracieusement à MyMangatheque tout droits de propriété intellectuelle y afférant et notamment le droit de reproduction, de représentation et d\'adaptation, pour la durée légale de protection des droits d\'auteur. Il s’engage notamment à ce que ces données ne soient pas de nature à porter atteinte aux intérêts légitimes de tiers quels qu’ils soient. À ce titre, il garantit MyMangatheque contre tout recours, fondés directement ou indirectement sur ces propos et/ou données, susceptibles d’être intentés par quiconque à l’encontre de MyMangatheque. Il s’engage en particulier à prendre en charge le paiement des sommes, quelles qu’elles soient, résultant du recours d\'un tiers à l\'encontre de MyMangatheque, y compris les honoraires d’avocat et frais de justice.",
    ),
    "userContentLane2": MessageLookupByLibrary.simpleMessage(
      "MyMangatheque se réserve le droit de supprimer tout ou partie du Contenu Utilisateur, à tout moment et pour quelque raison que ce soit, sans avertissement ou justification préalable. L\'Utilisateur ne pourra faire valoir aucune réclamation à ce titre.",
    ),
    "userContentLane3": MessageLookupByLibrary.simpleMessage(
      "MyMangatheque collecte et traite des données personnelles dans le respect de la réglementation en vigueur, notamment du Règlement Général sur la Protection des Données (RGPD).",
    ),
    "userLoginFailed": MessageLookupByLibrary.simpleMessage(
      "Une erreur est survenue, vous n\\\'avez pas été connecter à votre compte.",
    ),
    "userLoginSuccess": MessageLookupByLibrary.simpleMessage(
      "Vous êtes connecté avec succès.",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Pseudo"),
    "usernameIs": m29,
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
    "volumeDoesNotExist": MessageLookupByLibrary.simpleMessage(
      "Le tome n\'existe pas.",
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
    "volumeNotAvailableAnymore": MessageLookupByLibrary.simpleMessage(
      "Malheureusement, ce volume n\'est plus disponible.",
    ),
    "volumeNotAvailableForSale": MessageLookupByLibrary.simpleMessage(
      "Malheureusement, ce volume n\'est pas disponible à la vente.",
    ),
    "volumeNum": m30,
    "volumeNumber": MessageLookupByLibrary.simpleMessage("Numéro du volume"),
    "volumeOwnedNumber": m31,
    "volumeOwnedOverX": m32,
    "volumePrice": MessageLookupByLibrary.simpleMessage("Prix du volume"),
    "volumeReadedOverSeriesX": m33,
    "volumeReadedOverX": m34,
    "volumeSeriesId": MessageLookupByLibrary.simpleMessage(
      "ID de la série du volume",
    ),
    "volumeSubSeriesId": MessageLookupByLibrary.simpleMessage(
      "ID de la sous-série du volume",
    ),
    "volumeSummary": MessageLookupByLibrary.simpleMessage("Résumé du volume"),
    "volumeSupport": MessageLookupByLibrary.simpleMessage("Support du volume"),
    "volumeTitle": MessageLookupByLibrary.simpleMessage("Titre du volume"),
    "volumes": MessageLookupByLibrary.simpleMessage("Tomes"),
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
    "zeroVolumesOwned": MessageLookupByLibrary.simpleMessage(
      "Vous ne possédez aucun tome.",
    ),
  };
}
