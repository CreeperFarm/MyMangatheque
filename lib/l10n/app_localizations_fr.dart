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
  String get alphabeticalOrder => 'Ordre alphabétique';

  @override
  String get lastRelease => 'Last Release';

  @override
  String get completeLibrary => 'Compléter';

  @override
  String get desiredLibrary => 'Envies';

  @override
  String get readPile => 'Pile à lire';

  @override
  String get favorite => 'Favori';

  @override
  String get discover => 'Découvrir';

  @override
  String get dataUndercase => 'des données';

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
  String errorInitializing(String object) {
    return 'Une erreur s\'est produite lors de l\'initialisation $object.';
  }

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
  String supportIs(String support) {
    String _temp0 = intl.Intl.selectLogic(
      support,
      {
        'manga': 'Manga',
        'novel': 'Roman',
        'artbook': 'Artbook',
        'lightNovel': 'Light Novel',
        'boxSet': 'Coffret',
        'other': 'Other',
      },
    );
    return '$_temp0';
  }

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

  @override
  String get loading => 'Chargement...';

  @override
  String get loadingData => 'Chargement des données...';

  @override
  String get noConnection => 'Aucune connexion Internet';

  @override
  String jobsName(String job) {
    String _temp0 = intl.Intl.selectLogic(
      job,
      {
        'writerMen': 'Écrivain',
        'writerWomen': 'Écrivaine',
        'artistMen': 'Dessinateur',
        'artistWomen': 'Dessinatrice',
        'editorMen': 'Éditeur',
        'editorWomen': 'Éditrice',
        'illustratorMen': 'Illustrateur',
        'illustratorWomen': 'Illustratrice',
        'scriptwriterMen': 'Scénariste',
        'scriptwriterWomen': 'Scénariste',
        'authorMen': 'Auteur',
        'authorWomen': 'Auteure',
        'mangakaMen': 'Mangaka',
        'mangakaWomen': 'Mangaka',
        'charaDesignMen': 'Chara Design',
        'charaDesignWomen': 'Chara Design',
        'other': 'Other',
      },
    );
    return '$_temp0';
  }

  @override
  String seriesCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Séries',
      one: 'Série',
      zero: 'Série',
    );
    return '$_temp0';
  }

  @override
  String get authorDoesNotExist => 'L\'auteur n\'existe pas.';

  @override
  String get seriesDoesNotExist => 'La série n\'existe pas.';

  @override
  String get subSeriesDoesNotExist => 'La sous-série n\'existe pas.';

  @override
  String get volumeDoesNotExist => 'Le tome n\'existe pas.';

  @override
  String get editorDoesNotExist => 'L\'éditeur n\'existe pas.';

  @override
  String get genres => 'Genres';

  @override
  String get editors => 'Éditeurs';

  @override
  String get authors => 'Auteurs';

  @override
  String get volumes => 'Tomes';

  @override
  String get follow => 'Suivre';

  @override
  String get followed => 'Suivi';

  @override
  String get add => 'Ajouter';

  @override
  String get remove => 'Retirer';

  @override
  String get read => 'Lire';

  @override
  String get readed => 'Lu';

  @override
  String get summary => 'Résumé';

  @override
  String get seeMore => 'Voir plus';

  @override
  String get seeLess => 'Voir moins';

  @override
  String get volumeNotAvailableAnymore =>
      'Malheureusement, ce volume n\'est plus disponible.';

  @override
  String get volumeNotAvailableForSale =>
      'Malheureusement, ce volume n\'est pas disponible à la vente.';

  @override
  String get price => 'Prix';

  @override
  String availability(String availability) {
    String _temp0 = intl.Intl.selectLogic(
      availability,
      {
        'inStock': 'En Stock',
        'available': 'Disponible',
        'unavailable': 'Indisponible',
        'onPreorder': 'En Précommande',
        'other': '$availability',
      },
    );
    return '$_temp0';
  }

  @override
  String shippingUnderDays(num days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    return 'Expédition sous $daysString jours';
  }

  @override
  String shippingUnderWeeks(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '0': '0 semaine',
        '1': '1 semaine',
        'other': '$count semaines',
      },
    );
    return 'Expédition sous $_temp0';
  }

  @override
  String soldAndShippedBy(String seller) {
    return 'Vendu et expédié par $seller';
  }

  @override
  String buyOn(String store) {
    return 'Acheter sur $store';
  }

  @override
  String get informations => 'Informations';

  @override
  String get ean => 'EAN';

  @override
  String get numberOfPages => 'Nombre de pages';

  @override
  String volumeOwnedOverX(num owned, num total) {
    final intl.NumberFormat ownedNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String ownedString = ownedNumberFormat.format(owned);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String totalString = totalNumberFormat.format(total);

    String _temp0 = intl.Intl.pluralLogic(
      owned,
      locale: localeName,
      other: '$ownedString tomes possédés',
      one: '1 tome possédé',
      zero: '0 tome possédé',
    );
    String _temp1 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$totalString tomes',
      one: '1 tome',
      zero: '0 tome',
    );
    return '$_temp0 sur $_temp1';
  }

  @override
  String volumeReadedOverX(num readed, num total) {
    final intl.NumberFormat readedNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String readedString = readedNumberFormat.format(readed);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String totalString = totalNumberFormat.format(total);

    String _temp0 = intl.Intl.pluralLogic(
      readed,
      locale: localeName,
      other: '$readedString tomes lus',
      one: '1 tome lu',
      zero: '0 tome lu',
    );
    String _temp1 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$totalString tomes possédés',
      one: '1 tome possédé',
      zero: '0 tome possédé',
    );
    return '$_temp0 sur $_temp1.';
  }

  @override
  String volumeReadedOverSeriesX(num readed, num total) {
    final intl.NumberFormat readedNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String readedString = readedNumberFormat.format(readed);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String totalString = totalNumberFormat.format(total);

    String _temp0 = intl.Intl.pluralLogic(
      readed,
      locale: localeName,
      other: '$readedString tomes lus',
      one: '1 tome lu',
      zero: '0 tome lu',
    );
    String _temp1 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$totalString tomes',
      one: '1 tome',
      zero: '0 tome',
    );
    return '$_temp0 sur $_temp1.';
  }

  @override
  String get zeroVolumesOwned => 'Vous ne possédez aucun tome.';

  @override
  String get allVolumesReaded => 'Vous avez lu tous les tomes possédés.';

  @override
  String get preamble => 'Préambule';

  @override
  String get preambleLane1 =>
      'Les informations et recommandations ( « Informations » ) disponibles sur ce site web ( ou aussi « le Site » ) vous sont proposées en toute bonne foi. Ces informations sont censées être correctes au moment où vous en prenez connaissance. Toutefois, MyMangatheque ou ses filiales et entités affiliées ne sont pas garantes du caractère exhaustif et de l\'exactitude des Informations. Vous assumez pleinement les risques liés au crédit que vous leur accordez.';

  @override
  String get preambleLane2 =>
      'Les Informations vous sont fournies à la condition que vous, ou toute autre personne les récent, puissiez déterminer leur intérêt pour un objectif précis avant de les utiliser. En aucun cas, MyMangatheque ou ses filiales et entités affiliées ne seront responsables des dommages susceptibles de résultée du crédit accordé à ces informations, de leur utilisation ou de l\'utilisation d\'un produit auquel elles font référence.';

  @override
  String get preambleLane3 =>
      'Les Informations ne doivent pas être considérées comme des recommandations pour l\'utilisation d\'informations, de produits, de procédures, d\'équipements ou de formulations qui seraient en contradiction avec un brevet, un copyright ou une marque déposée.';

  @override
  String get preambleLane4 =>
      'MyMangatheque ou ses filiales et entités affiliées déclineraient toute responsabilité si l\'utilisation des Informations venait de contrevenir à un brevet, une marque déposée ou plus généralement un droit de propriété intellectuelle quelconque.';

  @override
  String get preambleLane5 =>
      'Aucune garantit, expresse ou implicite, n\'est donnée quant à la nature marchande des informations fournies, ni quant à leur adéquation à une finalité déterminée, ainsi qu\'en ce qui concerne les produits auxquels il est fait référence dans ces informations.';

  @override
  String get preambleLane6 =>
      'En aucun cas, MyMangatheque ou ses filiales et entités affiliées ne s\'engagent à mettre à jour ou à corriger les Informations qui seront diffusées par elles sur Internet ou sur leurs serveurs web. De même, MyMangatheque ou ses filiales et entités affiliées se réservent le droit de modifier ou de corriger le contenu de leurs sites à tout moment et sans préavis.';

  @override
  String get intellectualProperty => 'Propriété intellectuelle';

  @override
  String get authorRights => 'Droits d\'auteur';

  @override
  String get authorRightsLane1 =>
      'MyMangatheque et son contenu (textes, images, vidéos, etc.) sont protégés par les lois sur la propriété intellectuelle en vigueur en France. Toute reproduction, représentation, modification, publication, adaptation de tout ou partie des éléments du site, quel que soit le moyen ou le procédé utilisé, est interdite, sauf autorisation écrite préalable ou à titre personnel comme challenge de code mais sans publication.';

  @override
  String get thirdPartyContent => 'Contenu tiers';

  @override
  String get thirdPartyContentLane1 =>
      'Les contenus tiers utilisés sur le site MyMangatheque appartiennent à leurs auteurs respectifs.';

  @override
  String get personalData => 'Données personnelles';

  @override
  String get userContent => 'Contenu utilisateur';

  @override
  String get userContentLane1 =>
      'L’Utilisateur est seul responsable du Contenu Utilisateur qu’il met en ligne via le Service, ainsi que des textes et/ou opinions qu’il formule. L\'Utilisateur cède expressément et gracieusement à MyMangatheque tout droits de propriété intellectuelle y afférant et notamment le droit de reproduction, de représentation et d\'adaptation, pour la durée légale de protection des droits d\'auteur. Il s’engage notamment à ce que ces données ne soient pas de nature à porter atteinte aux intérêts légitimes de tiers quels qu’ils soient. À ce titre, il garantit MyMangatheque contre tout recours, fondés directement ou indirectement sur ces propos et/ou données, susceptibles d’être intentés par quiconque à l’encontre de MyMangatheque. Il s’engage en particulier à prendre en charge le paiement des sommes, quelles qu’elles soient, résultant du recours d\'un tiers à l\'encontre de MyMangatheque, y compris les honoraires d’avocat et frais de justice.';

  @override
  String get userContentLane2 =>
      'MyMangatheque se réserve le droit de supprimer tout ou partie du Contenu Utilisateur, à tout moment et pour quelque raison que ce soit, sans avertissement ou justification préalable. L\'Utilisateur ne pourra faire valoir aucune réclamation à ce titre.';

  @override
  String get userContentLane3 =>
      'MyMangatheque collecte et traite des données personnelles dans le respect de la réglementation en vigueur, notamment du Règlement Général sur la Protection des Données (RGPD).';

  @override
  String get protectionOfPersonalData => 'Protection des données personnelles';

  @override
  String get protectionOfPersonalDataLane1 =>
      'Vos données personnelles sont uniquement destinées à MyMangatheque. Elles ne seront en aucun cas communiquées à des tiers. Au regard des règles de protection des données personnelles (article 34 de Loi « Informatiques et Libertés » du 6 Janvier 1978, directives 95/46 et 97/66), vous disposez d\'un droit d\'accès, de rectification et de suppression des données qui vous concernent. Pour l\'exercer, pour vous opposer à la réception de tout message commercial ou pour toute rectification, adressez-vous par mail, présent dans la rubrique contact.';

  @override
  String get cookieUsage => 'Utilisation des cookies';

  @override
  String get cookieUsageLane1 =>
      'L\'utilisateur est informé, qu’à l’occasion d’une visite sur le Site, un cookie peut s\'installer automatiquement sur son logiciel de navigation. Un cookie consiste en un bloc de données qui ne permet pas d\'identifier l\'utilisateur mais permet d’enregistrer des informations relatives à la navigation de celui-ci sur le Site afin de procéder à des analyses de fréquentation du Site, le tout pour améliorer la qualité du Site.';

  @override
  String get cookieUsageLane2 =>
      'L\'utilisateur dispose d\'un droit d\'accès, de rectification ou de suppression des données personnelles communiquées par le biais d’un cookie dans les conditions indiquées ci-dessus.';

  @override
  String get externalLinks => 'Liens externes';

  @override
  String get externalLinksLane1 =>
      'Le site web MyMangatheque peut contenir des liens vers des sites externes. Nous déclinons toute responsabilité quant au contenu et aux pratiques de confidentialité de ces sites. Ces liens sont proposés aux utilisateurs du Site ou des sites web de ses filiales et entités affiliées en tant que service. La décision d\'activer les liens appartient exclusivement aux utilisateurs.';

  @override
  String get contactRightsAndUpdateDate =>
      'Contact, Droit et Date de Mise à Jour';

  @override
  String get contact => 'Contact';

  @override
  String get contactLane1 =>
      'Pour toute question ou réclamation, veuillez nous contacter à l\'une des adresses mail suivante : mymangatheque@gmail.com ou contact@mymangatheque.com .';

  @override
  String get applicableLawAndCompetentJurisdiction =>
      'Droit applicable et Juridiction compétente';

  @override
  String get applicableLawAndCompetentJurisdictionLane1 =>
      'Les présentes mentions légales sont soumises au droit français. En cas de litige, les tribunaux français seront seuls compétents.';

  @override
  String get lastUpdateDate => 'Date de dernière mise à jour';

  @override
  String get scanEAN => 'Scan EAN';

  @override
  String get openScan => 'Ouvrir le scan';
}
