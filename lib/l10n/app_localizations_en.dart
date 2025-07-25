// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get home => 'Home';

  @override
  String get collection => 'Collection';

  @override
  String get search => 'Search';

  @override
  String get profile => 'Profile';

  @override
  String pronoun(String gender) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'male': 'he',
        'female': 'she',
        'other': 'they',
      },
    );
    return '$_temp0';
  }

  @override
  String get authFailed => 'Email or password incorrect.';

  @override
  String get userLoginFailed =>
      'An error occurred, you have not been connected to your account.';

  @override
  String get userLoginSuccess => 'You have successfully logged in.';

  @override
  String get errorOccurred => 'An error occurred, please try again later.';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get emailResetSent =>
      'A password reset email has been sent to your email address.';

  @override
  String get invalidEmail => 'The email address is invalid.';

  @override
  String get modifyPasswordSuccess => 'Password successfully changed.';

  @override
  String get logIn => 'Log In';

  @override
  String get legalNotice => 'Legal Notice';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get profileSettings => 'Profile & Settings Page';

  @override
  String emailIs(String email) {
    return 'Your email is $email';
  }

  @override
  String usernameIs(String username) {
    return 'Your username is $username';
  }

  @override
  String accountCreatedOn(String date) {
    return 'Account created on $date';
  }

  @override
  String birthdayDateIs(String date) {
    return 'Your birthday is on $date';
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
      other: 'You own $countString volumes',
      one: 'You own 1 volume',
      zero: 'You own 0 volume',
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
      other: 'You have $countString favorite series',
      one: 'You have 1 favorite series',
      zero: 'You have 0 favorite series',
    );
    return '$_temp0';
  }

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemMode => 'System Mode';

  @override
  String get english => 'English';

  @override
  String get french => 'French';
}
