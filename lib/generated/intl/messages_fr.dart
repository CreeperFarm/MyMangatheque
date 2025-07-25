// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'fr';

  static m0(date) => "Compte créé le ${date}";

  static m1(date) => "Votre anniversaire est le ${date}";

  static m2(email) => "Votre email est ${email}";

  static m3(count) => "${Intl.plural(count, zero: 'Vous avez 0 série', one: 'Vous avez une série', other: 'Vous avez ${count} séries')}";

  static m4(gender) => "${Intl.gender(gender, female: 'elle', male: 'il', other: 'iel')}";

  static m5(username) => "Votre pseudo est ${username}";

  static m6(count) => "${Intl.plural(count, zero: 'Vous possédez 0 volume', one: 'Vous possédez un volume', other: 'Vous possédez ${count} volumes')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountCreatedOn" : m0,
    "april" : MessageLookupByLibrary.simpleMessage("Avril"),
    "august" : MessageLookupByLibrary.simpleMessage("Août"),
    "authFailed" : MessageLookupByLibrary.simpleMessage("Email ou mot de passe incorrect."),
    "birthdayDateIs" : m1,
    "collection" : MessageLookupByLibrary.simpleMessage("Collection"),
    "darkMode" : MessageLookupByLibrary.simpleMessage("Thème sombre"),
    "december" : MessageLookupByLibrary.simpleMessage("Décembre"),
    "emailIs" : m2,
    "emailResetSent" : MessageLookupByLibrary.simpleMessage("Un email de réinitialisation de mot de passe a été envoyé à votre adresse email."),
    "english" : MessageLookupByLibrary.simpleMessage("Anglais"),
    "errorOccurred" : MessageLookupByLibrary.simpleMessage("Une erreur est survenue, veuillez réessayer plus tard."),
    "favoriteSeriesNumber" : m3,
    "february" : MessageLookupByLibrary.simpleMessage("Février"),
    "french" : MessageLookupByLibrary.simpleMessage("Français"),
    "helloWorld" : MessageLookupByLibrary.simpleMessage("Bonjour le monde !"),
    "home" : MessageLookupByLibrary.simpleMessage("Accueil"),
    "invalidEmail" : MessageLookupByLibrary.simpleMessage("L\'adresse email est invalide."),
    "january" : MessageLookupByLibrary.simpleMessage("Janvier"),
    "july" : MessageLookupByLibrary.simpleMessage("Juillet"),
    "june" : MessageLookupByLibrary.simpleMessage("Juin"),
    "legalNotice" : MessageLookupByLibrary.simpleMessage("Mentions légales"),
    "lightMode" : MessageLookupByLibrary.simpleMessage("Thème clair"),
    "logIn" : MessageLookupByLibrary.simpleMessage("Se connecter"),
    "march" : MessageLookupByLibrary.simpleMessage("Mars"),
    "may" : MessageLookupByLibrary.simpleMessage("Mai"),
    "modifyPasswordSuccess" : MessageLookupByLibrary.simpleMessage("Mot de passe modifié avec succès."),
    "november" : MessageLookupByLibrary.simpleMessage("Novembre"),
    "october" : MessageLookupByLibrary.simpleMessage("Octobre"),
    "pleaseWait" : MessageLookupByLibrary.simpleMessage("Veuillez patienter..."),
    "profile" : MessageLookupByLibrary.simpleMessage("Profil"),
    "profileSettings" : MessageLookupByLibrary.simpleMessage("Page de profil et réglages"),
    "pronoun" : m4,
    "search" : MessageLookupByLibrary.simpleMessage("Recherche"),
    "september" : MessageLookupByLibrary.simpleMessage("Septembre"),
    "systemMode" : MessageLookupByLibrary.simpleMessage("Thème du système"),
    "userLoginFailed" : MessageLookupByLibrary.simpleMessage("Une erreur est survenue, vous n\\\'avez pas été connecter à votre compte."),
    "userLoginSuccess" : MessageLookupByLibrary.simpleMessage("Vous êtes connecté avec succès."),
    "usernameIs" : m5,
    "volumeOwnedNumber" : m6
  };
}
