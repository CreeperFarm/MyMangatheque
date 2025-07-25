// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static m0(date) => "Account created on ${date}";

  static m1(date) => "Your birthday is on ${date}";

  static m2(email) => "Your email is ${email}";

  static m3(count) => "${Intl.plural(count, zero: 'You have 0 favorite series', one: 'You have 1 favorite series', other: 'You have ${count} favorite series')}";

  static m4(gender) => "${Intl.gender(gender, female: 'she', male: 'he', other: 'they')}";

  static m5(username) => "Your username is ${username}";

  static m6(count) => "${Intl.plural(count, zero: 'You own 0 volume', one: 'You own 1 volume', other: 'You own ${count} volumes')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountCreatedOn" : m0,
    "april" : MessageLookupByLibrary.simpleMessage("April"),
    "august" : MessageLookupByLibrary.simpleMessage("August"),
    "authFailed" : MessageLookupByLibrary.simpleMessage("Email or password incorrect."),
    "birthdayDateIs" : m1,
    "collection" : MessageLookupByLibrary.simpleMessage("Collection"),
    "darkMode" : MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "december" : MessageLookupByLibrary.simpleMessage("December"),
    "emailIs" : m2,
    "emailResetSent" : MessageLookupByLibrary.simpleMessage("A password reset email has been sent to your email address."),
    "english" : MessageLookupByLibrary.simpleMessage("English"),
    "errorOccurred" : MessageLookupByLibrary.simpleMessage("An error occurred, please try again later."),
    "favoriteSeriesNumber" : m3,
    "february" : MessageLookupByLibrary.simpleMessage("February"),
    "french" : MessageLookupByLibrary.simpleMessage("French"),
    "helloWorld" : MessageLookupByLibrary.simpleMessage("Hello World!"),
    "home" : MessageLookupByLibrary.simpleMessage("Home"),
    "invalidEmail" : MessageLookupByLibrary.simpleMessage("The email address is invalid."),
    "january" : MessageLookupByLibrary.simpleMessage("January"),
    "july" : MessageLookupByLibrary.simpleMessage("July"),
    "june" : MessageLookupByLibrary.simpleMessage("June"),
    "legalNotice" : MessageLookupByLibrary.simpleMessage("Legal Notice"),
    "lightMode" : MessageLookupByLibrary.simpleMessage("Light Mode"),
    "logIn" : MessageLookupByLibrary.simpleMessage("Log In"),
    "march" : MessageLookupByLibrary.simpleMessage("March"),
    "may" : MessageLookupByLibrary.simpleMessage("May"),
    "modifyPasswordSuccess" : MessageLookupByLibrary.simpleMessage("Password successfully changed."),
    "november" : MessageLookupByLibrary.simpleMessage("November"),
    "october" : MessageLookupByLibrary.simpleMessage("October"),
    "pleaseWait" : MessageLookupByLibrary.simpleMessage("Please wait..."),
    "profile" : MessageLookupByLibrary.simpleMessage("Profile"),
    "profileSettings" : MessageLookupByLibrary.simpleMessage("Profile & Settings Page"),
    "pronoun" : m4,
    "search" : MessageLookupByLibrary.simpleMessage("Search"),
    "september" : MessageLookupByLibrary.simpleMessage("September"),
    "systemMode" : MessageLookupByLibrary.simpleMessage("System Mode"),
    "userLoginFailed" : MessageLookupByLibrary.simpleMessage("An error occurred, you have not been connected to your account."),
    "userLoginSuccess" : MessageLookupByLibrary.simpleMessage("You have successfully logged in."),
    "usernameIs" : m5,
    "volumeOwnedNumber" : m6
  };
}
