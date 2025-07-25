// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(_current != null, 'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalizations();
      AppLocalizations._current = instance;
 
      return instance;
    });
  } 

  static AppLocalizations of(BuildContext context) {
    final instance = AppLocalizations.maybeOf(context);
    assert(instance != null, 'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?');
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `Hello World!`
  String get helloWorld {
    return Intl.message(
      'Hello World!',
      name: 'helloWorld',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Collection`
  String get collection {
    return Intl.message(
      'Collection',
      name: 'collection',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `{gender, select, male{he} female{she} other{they}}`
  String pronoun(String gender) {
    return Intl.gender(
      gender,
      male: 'he',
      female: 'she',
      other: 'they',
      name: 'pronoun',
      desc: 'A gendered message',
      args: [gender],
    );
  }

  /// `Email or password incorrect.`
  String get authFailed {
    return Intl.message(
      'Email or password incorrect.',
      name: 'authFailed',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred, you have not been connected to your account.`
  String get userLoginFailed {
    return Intl.message(
      'An error occurred, you have not been connected to your account.',
      name: 'userLoginFailed',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully logged in.`
  String get userLoginSuccess {
    return Intl.message(
      'You have successfully logged in.',
      name: 'userLoginSuccess',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred, please try again later.`
  String get errorOccurred {
    return Intl.message(
      'An error occurred, please try again later.',
      name: 'errorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `Please wait...`
  String get pleaseWait {
    return Intl.message(
      'Please wait...',
      name: 'pleaseWait',
      desc: '',
      args: [],
    );
  }

  /// `A password reset email has been sent to your email address.`
  String get emailResetSent {
    return Intl.message(
      'A password reset email has been sent to your email address.',
      name: 'emailResetSent',
      desc: '',
      args: [],
    );
  }

  /// `The email address is invalid.`
  String get invalidEmail {
    return Intl.message(
      'The email address is invalid.',
      name: 'invalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Password successfully changed.`
  String get modifyPasswordSuccess {
    return Intl.message(
      'Password successfully changed.',
      name: 'modifyPasswordSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Log In`
  String get logIn {
    return Intl.message(
      'Log In',
      name: 'logIn',
      desc: '',
      args: [],
    );
  }

  /// `Legal Notice`
  String get legalNotice {
    return Intl.message(
      'Legal Notice',
      name: 'legalNotice',
      desc: '',
      args: [],
    );
  }

  /// `January`
  String get january {
    return Intl.message(
      'January',
      name: 'january',
      desc: '',
      args: [],
    );
  }

  /// `February`
  String get february {
    return Intl.message(
      'February',
      name: 'february',
      desc: '',
      args: [],
    );
  }

  /// `March`
  String get march {
    return Intl.message(
      'March',
      name: 'march',
      desc: '',
      args: [],
    );
  }

  /// `April`
  String get april {
    return Intl.message(
      'April',
      name: 'april',
      desc: '',
      args: [],
    );
  }

  /// `May`
  String get may {
    return Intl.message(
      'May',
      name: 'may',
      desc: '',
      args: [],
    );
  }

  /// `June`
  String get june {
    return Intl.message(
      'June',
      name: 'june',
      desc: '',
      args: [],
    );
  }

  /// `July`
  String get july {
    return Intl.message(
      'July',
      name: 'july',
      desc: '',
      args: [],
    );
  }

  /// `August`
  String get august {
    return Intl.message(
      'August',
      name: 'august',
      desc: '',
      args: [],
    );
  }

  /// `September`
  String get september {
    return Intl.message(
      'September',
      name: 'september',
      desc: '',
      args: [],
    );
  }

  /// `October`
  String get october {
    return Intl.message(
      'October',
      name: 'october',
      desc: '',
      args: [],
    );
  }

  /// `November`
  String get november {
    return Intl.message(
      'November',
      name: 'november',
      desc: '',
      args: [],
    );
  }

  /// `December`
  String get december {
    return Intl.message(
      'December',
      name: 'december',
      desc: '',
      args: [],
    );
  }

  /// `Profile & Settings Page`
  String get profileSettings {
    return Intl.message(
      'Profile & Settings Page',
      name: 'profileSettings',
      desc: '',
      args: [],
    );
  }

  /// `Your email is {email}`
  String emailIs(Object email) {
    return Intl.message(
      'Your email is $email',
      name: 'emailIs',
      desc: 'A message that includes the user\'s email',
      args: [email],
    );
  }

  /// `Your username is {username}`
  String usernameIs(Object username) {
    return Intl.message(
      'Your username is $username',
      name: 'usernameIs',
      desc: 'A message that includes the user\'s username',
      args: [username],
    );
  }

  /// `Account created on {date}`
  String accountCreatedOn(Object date) {
    return Intl.message(
      'Account created on $date',
      name: 'accountCreatedOn',
      desc: 'A message that includes the account creation date',
      args: [date],
    );
  }

  /// `Your birthday is on {date}`
  String birthdayDateIs(Object date) {
    return Intl.message(
      'Your birthday is on $date',
      name: 'birthdayDateIs',
      desc: 'A message that includes the user\'s birthday date',
      args: [date],
    );
  }

  /// `{count, plural, =0 {You own 0 volume} =1{You own 1 volume} other {You own {count} volumes}}`
  String volumeOwnedNumber(num count) {
    return Intl.plural(
      count,
      zero: 'You own 0 volume',
      one: 'You own 1 volume',
      other: 'You own $count volumes',
      name: 'volumeOwnedNumber',
      desc: 'A message that indicates the number of volumes owned by the user',
      args: [count],
    );
  }

  /// `{count, plural, =0 {You have 0 favorite series} =1{You have 1 favorite series} other {You have {count} favorite series}}`
  String favoriteSeriesNumber(num count) {
    return Intl.plural(
      count,
      zero: 'You have 0 favorite series',
      one: 'You have 1 favorite series',
      other: 'You have $count favorite series',
      name: 'favoriteSeriesNumber',
      desc: 'A message that indicates the number of favorite series of the user',
      args: [count],
    );
  }

  /// `Light Mode`
  String get lightMode {
    return Intl.message(
      'Light Mode',
      name: 'lightMode',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message(
      'Dark Mode',
      name: 'darkMode',
      desc: '',
      args: [],
    );
  }

  /// `System Mode`
  String get systemMode {
    return Intl.message(
      'System Mode',
      name: 'systemMode',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `French`
  String get french {
    return Intl.message(
      'French',
      name: 'french',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}