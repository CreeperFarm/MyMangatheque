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
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(
      _current != null,
      'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
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
    assert(
      instance != null,
      'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `French`
  String get french {
    return Intl.message('French', name: 'french', desc: '', args: []);
  }

  /// `Spanish`
  String get spanish {
    return Intl.message('Spanish', name: 'spanish', desc: '', args: []);
  }

  /// `Italian`
  String get italian {
    return Intl.message('Italian', name: 'italian', desc: '', args: []);
  }

  /// `German`
  String get german {
    return Intl.message('German', name: 'german', desc: '', args: []);
  }

  /// `Japanese`
  String get japanese {
    return Intl.message('Japanese', name: 'japanese', desc: '', args: []);
  }

  /// `Hello World!`
  String get helloWorld {
    return Intl.message('Hello World!', name: 'helloWorld', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Collection`
  String get collection {
    return Intl.message('Collection', name: 'collection', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
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

  /// `Alphabetical Order`
  String get alphabeticalOrder {
    return Intl.message(
      'Alphabetical Order',
      name: 'alphabeticalOrder',
      desc: '',
      args: [],
    );
  }

  /// `Last Release`
  String get lastRelease {
    return Intl.message(
      'Last Release',
      name: 'lastRelease',
      desc: '',
      args: [],
    );
  }

  /// `Complete`
  String get completeLibrary {
    return Intl.message(
      'Complete',
      name: 'completeLibrary',
      desc: '',
      args: [],
    );
  }

  /// `Desired`
  String get desiredLibrary {
    return Intl.message('Desired', name: 'desiredLibrary', desc: '', args: []);
  }

  /// `Read Pile`
  String get readPile {
    return Intl.message('Read Pile', name: 'readPile', desc: '', args: []);
  }

  /// `Favorite`
  String get favorite {
    return Intl.message('Favorite', name: 'favorite', desc: '', args: []);
  }

  /// `Discover`
  String get discover {
    return Intl.message('Discover', name: 'discover', desc: '', args: []);
  }

  /// `data`
  String get dataUndercase {
    return Intl.message('data', name: 'dataUndercase', desc: '', args: []);
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

  /// `The password must be at least 6 characters long.`
  String get passwordTooShort {
    return Intl.message(
      'The password must be at least 6 characters long.',
      name: 'passwordTooShort',
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

  /// `An error occurred while initializing {object}, please try again later.`
  String errorInitializing(String object) {
    return Intl.message(
      'An error occurred while initializing $object, please try again later.',
      name: 'errorInitializing',
      desc:
          'An error message indicating that an object could not be initialized',
      args: [object],
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
    return Intl.message('Log In', name: 'logIn', desc: '', args: []);
  }

  /// `Log In with Google`
  String get logInWithGoogle {
    return Intl.message(
      'Log In with Google',
      name: 'logInWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Log In with Apple`
  String get logInWithApple {
    return Intl.message(
      'Log In with Apple',
      name: 'logInWithApple',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully logged in.`
  String get logInSuccess {
    return Intl.message(
      'You have successfully logged in.',
      name: 'logInSuccess',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred, you have not been connected to your account.`
  String get logInFailed {
    return Intl.message(
      'An error occurred, you have not been connected to your account.',
      name: 'logInFailed',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logOut {
    return Intl.message('Log Out', name: 'logOut', desc: '', args: []);
  }

  /// `You have successfully logged out.`
  String get logOutSuccess {
    return Intl.message(
      'You have successfully logged out.',
      name: 'logOutSuccess',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred, you have not been logged out.`
  String get logOutFailed {
    return Intl.message(
      'An error occurred, you have not been logged out.',
      name: 'logOutFailed',
      desc: '',
      args: [],
    );
  }

  /// `The minimum required number of characters is {minLength}.`
  String minLengthNotReached(num minLength) {
    final NumberFormat minLengthNumberFormat = NumberFormat.compact(
      locale: Intl.getCurrentLocale(),
    );
    final String minLengthString = minLengthNumberFormat.format(minLength);

    return Intl.message(
      'The minimum required number of characters is $minLengthString.',
      name: 'minLengthNotReached',
      desc:
          'An error message indicating that the minimum length has not been met',
      args: [minLengthString],
    );
  }

  /// `The maximum allowed number of characters is {maxLength}.`
  String maxLengthExceeded(num maxLength) {
    final NumberFormat maxLengthNumberFormat = NumberFormat.compact(
      locale: Intl.getCurrentLocale(),
    );
    final String maxLengthString = maxLengthNumberFormat.format(maxLength);

    return Intl.message(
      'The maximum allowed number of characters is $maxLengthString.',
      name: 'maxLengthExceeded',
      desc:
          'An error message indicating that the maximum length has been exceeded',
      args: [maxLengthString],
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
    return Intl.message('January', name: 'january', desc: '', args: []);
  }

  /// `February`
  String get february {
    return Intl.message('February', name: 'february', desc: '', args: []);
  }

  /// `March`
  String get march {
    return Intl.message('March', name: 'march', desc: '', args: []);
  }

  /// `April`
  String get april {
    return Intl.message('April', name: 'april', desc: '', args: []);
  }

  /// `May`
  String get may {
    return Intl.message('May', name: 'may', desc: '', args: []);
  }

  /// `June`
  String get june {
    return Intl.message('June', name: 'june', desc: '', args: []);
  }

  /// `July`
  String get july {
    return Intl.message('July', name: 'july', desc: '', args: []);
  }

  /// `August`
  String get august {
    return Intl.message('August', name: 'august', desc: '', args: []);
  }

  /// `September`
  String get september {
    return Intl.message('September', name: 'september', desc: '', args: []);
  }

  /// `October`
  String get october {
    return Intl.message('October', name: 'october', desc: '', args: []);
  }

  /// `November`
  String get november {
    return Intl.message('November', name: 'november', desc: '', args: []);
  }

  /// `December`
  String get december {
    return Intl.message('December', name: 'december', desc: '', args: []);
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
  String emailIs(String email) {
    return Intl.message(
      'Your email is $email',
      name: 'emailIs',
      desc: 'A message that includes the user\'s email',
      args: [email],
    );
  }

  /// `Your username is {username}`
  String usernameIs(String username) {
    return Intl.message(
      'Your username is $username',
      name: 'usernameIs',
      desc: 'A message that includes the user\'s username',
      args: [username],
    );
  }

  /// `Account created on {date}`
  String accountCreatedOn(String date) {
    return Intl.message(
      'Account created on $date',
      name: 'accountCreatedOn',
      desc: 'A message that includes the account creation date',
      args: [date],
    );
  }

  /// `Your birthday is on {date}`
  String birthdayDateIs(String date) {
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
      desc:
          'A message that indicates the number of favorite series of the user',
      args: [count],
    );
  }

  /// `Light Mode`
  String get lightMode {
    return Intl.message('Light Mode', name: 'lightMode', desc: '', args: []);
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message('Dark Mode', name: 'darkMode', desc: '', args: []);
  }

  /// `System Mode`
  String get systemMode {
    return Intl.message('System Mode', name: 'systemMode', desc: '', args: []);
  }

  /// `Clear Cache`
  String get clearCache {
    return Intl.message('Clear Cache', name: 'clearCache', desc: '', args: []);
  }

  /// `Cache successfully cleared.`
  String get clearCacheSuccess {
    return Intl.message(
      'Cache successfully cleared.',
      name: 'clearCacheSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Modify Password`
  String get modifyPassword {
    return Intl.message(
      'Modify Password',
      name: 'modifyPassword',
      desc: '',
      args: [],
    );
  }

  /// `Danger Zone`
  String get dangerZone {
    return Intl.message('Danger Zone', name: 'dangerZone', desc: '', args: []);
  }

  /// `Delete Account`
  String get deleteAccount {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account? This action cannot be undone.`
  String get deleteAccountConfirmation {
    return Intl.message(
      'Are you sure you want to delete your account? This action cannot be undone.',
      name: 'deleteAccountConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Your account has been successfully deleted.`
  String get deleteAccountSuccess {
    return Intl.message(
      'Your account has been successfully deleted.',
      name: 'deleteAccountSuccess',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred, your account has not been deleted, you have been log out of your account.`
  String get deleteAccountFailed {
    return Intl.message(
      'An error occurred, your account has not been deleted, you have been log out of your account.',
      name: 'deleteAccountFailed',
      desc: '',
      args: [],
    );
  }

  /// `App Version: {appVersion} & Build Version: {buildVersion}`
  String appVersionAndAppBuildVersion(String appVersion, String buildVersion) {
    return Intl.message(
      'App Version: $appVersion & Build Version: $buildVersion',
      name: 'appVersionAndAppBuildVersion',
      desc: 'A message that includes the app version and build version',
      args: [appVersion, buildVersion],
    );
  }

  /// `Volume {count}`
  String volumeNum(num count) {
    final NumberFormat countNumberFormat = NumberFormat.compact(
      locale: Intl.getCurrentLocale(),
    );
    final String countString = countNumberFormat.format(count);

    return Intl.message(
      'Volume $countString',
      name: 'volumeNum',
      desc: 'A message that indicates the volume number',
      args: [countString],
    );
  }

  /// `Owned`
  String get owned {
    return Intl.message('Owned', name: 'owned', desc: '', args: []);
  }

  /// `Volume`
  String get volume {
    return Intl.message('Volume', name: 'volume', desc: '', args: []);
  }

  /// `Series`
  String get series {
    return Intl.message('Series', name: 'series', desc: '', args: []);
  }

  /// `Edition`
  String get edition {
    return Intl.message('Edition', name: 'edition', desc: '', args: []);
  }

  /// `Author`
  String get author {
    return Intl.message('Author', name: 'author', desc: '', args: []);
  }

  /// `Publisher`
  String get publisher {
    return Intl.message('Publisher', name: 'publisher', desc: '', args: []);
  }

  /// `Publication Date`
  String get publicationDate {
    return Intl.message(
      'Publication Date',
      name: 'publicationDate',
      desc: '',
      args: [],
    );
  }

  /// `ISBN`
  String get isbn {
    return Intl.message('ISBN', name: 'isbn', desc: '', args: []);
  }

  /// `Scanner`
  String get scanner {
    return Intl.message('Scanner', name: 'scanner', desc: '', args: []);
  }

  /// `Scan the barcode of your volume to add it to your collection.`
  String get scannerDescription {
    return Intl.message(
      'Scan the barcode of your volume to add it to your collection.',
      name: 'scannerDescription',
      desc: '',
      args: [],
    );
  }

  /// `Create Author`
  String get createAuthor {
    return Intl.message(
      'Create Author',
      name: 'createAuthor',
      desc: '',
      args: [],
    );
  }

  /// `Author Name`
  String get authorName {
    return Intl.message('Author Name', name: 'authorName', desc: '', args: []);
  }

  /// `Please provide the author's name`
  String get provideAuthorName {
    return Intl.message(
      'Please provide the author\'s name',
      name: 'provideAuthorName',
      desc: '',
      args: [],
    );
  }

  /// `Author Jobs (separated by commas)`
  String get authorJobs {
    return Intl.message(
      'Author Jobs (separated by commas)',
      name: 'authorJobs',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the author's jobs (separated by commas)`
  String get provideAuthorJobs {
    return Intl.message(
      'Please provide the author\'s jobs (separated by commas)',
      name: 'provideAuthorJobs',
      desc: '',
      args: [],
    );
  }

  /// `Series ID of the Author`
  String get seriesIdOfAuthor {
    return Intl.message(
      'Series ID of the Author',
      name: 'seriesIdOfAuthor',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the series ID(s) of the author`
  String get provideSeriesIdOfAuthor {
    return Intl.message(
      'Please provide the series ID(s) of the author',
      name: 'provideSeriesIdOfAuthor',
      desc: '',
      args: [],
    );
  }

  /// `Add Author`
  String get authorAdd {
    return Intl.message('Add Author', name: 'authorAdd', desc: '', args: []);
  }

  /// `Author successfully added.`
  String get authorAddSuccess {
    return Intl.message(
      'Author successfully added.',
      name: 'authorAddSuccess',
      desc: '',
      args: [],
    );
  }

  /// `An author with this name already exists.`
  String get authorDuplicate {
    return Intl.message(
      'An author with this name already exists.',
      name: 'authorDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Create Genre`
  String get createGenre {
    return Intl.message(
      'Create Genre',
      name: 'createGenre',
      desc: '',
      args: [],
    );
  }

  /// `Genre Name`
  String get genreName {
    return Intl.message('Genre Name', name: 'genreName', desc: '', args: []);
  }

  /// `Please provide the genre name`
  String get provideGenreName {
    return Intl.message(
      'Please provide the genre name',
      name: 'provideGenreName',
      desc: '',
      args: [],
    );
  }

  /// `Add Genre`
  String get genreAdd {
    return Intl.message('Add Genre', name: 'genreAdd', desc: '', args: []);
  }

  /// `Genre successfully added.`
  String get genreAddSuccess {
    return Intl.message(
      'Genre successfully added.',
      name: 'genreAddSuccess',
      desc: '',
      args: [],
    );
  }

  /// `A genre with this name already exists.`
  String get genreDuplicate {
    return Intl.message(
      'A genre with this name already exists.',
      name: 'genreDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Create Volume`
  String get createVolume {
    return Intl.message(
      'Create Volume',
      name: 'createVolume',
      desc: '',
      args: [],
    );
  }

  /// `Volume Title`
  String get volumeTitle {
    return Intl.message(
      'Volume Title',
      name: 'volumeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the volume title`
  String get provideVolumeTitle {
    return Intl.message(
      'Please provide the volume title',
      name: 'provideVolumeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Volume Number`
  String get volumeNumber {
    return Intl.message(
      'Volume Number',
      name: 'volumeNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the volume number`
  String get provideVolumeNumber {
    return Intl.message(
      'Please provide the volume number',
      name: 'provideVolumeNumber',
      desc: '',
      args: [],
    );
  }

  /// `EAN of the Volume`
  String get volumeEAN {
    return Intl.message(
      'EAN of the Volume',
      name: 'volumeEAN',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the EAN of the volume`
  String get provideVolumeEAN {
    return Intl.message(
      'Please provide the EAN of the volume',
      name: 'provideVolumeEAN',
      desc: '',
      args: [],
    );
  }

  /// `Volume Price`
  String get volumePrice {
    return Intl.message(
      'Volume Price',
      name: 'volumePrice',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the price of the volume`
  String get provideVolumePrice {
    return Intl.message(
      'Please provide the price of the volume',
      name: 'provideVolumePrice',
      desc: '',
      args: [],
    );
  }

  /// `Volume Summary`
  String get volumeSummary {
    return Intl.message(
      'Volume Summary',
      name: 'volumeSummary',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the summary of the volume`
  String get provideVolumeSummary {
    return Intl.message(
      'Please provide the summary of the volume',
      name: 'provideVolumeSummary',
      desc: '',
      args: [],
    );
  }

  /// `Volume Link`
  String get volumeLink {
    return Intl.message('Volume Link', name: 'volumeLink', desc: '', args: []);
  }

  /// `Please provide the link of the volume`
  String get provideVolumeLink {
    return Intl.message(
      'Please provide the link of the volume',
      name: 'provideVolumeLink',
      desc: '',
      args: [],
    );
  }

  /// `Volume Information`
  String get volumeInfo {
    return Intl.message(
      'Volume Information',
      name: 'volumeInfo',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the information about the volume`
  String get provideVolumeInfo {
    return Intl.message(
      'Please provide the information about the volume',
      name: 'provideVolumeInfo',
      desc: '',
      args: [],
    );
  }

  /// `Adult Content`
  String get adultContent {
    return Intl.message(
      'Adult Content',
      name: 'adultContent',
      desc: '',
      args: [],
    );
  }

  /// `Warning: Adult Content`
  String get adultContentWarning {
    return Intl.message(
      'Warning: Adult Content',
      name: 'adultContentWarning',
      desc: '',
      args: [],
    );
  }

  /// `Volume Language`
  String get volumeLanguage {
    return Intl.message(
      'Volume Language',
      name: 'volumeLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Please choose the language of the volume`
  String get chooseVolumeLanguage {
    return Intl.message(
      'Please choose the language of the volume',
      name: 'chooseVolumeLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Manga`
  String get manga {
    return Intl.message('Manga', name: 'manga', desc: '', args: []);
  }

  /// `Novel`
  String get novel {
    return Intl.message('Novel', name: 'novel', desc: '', args: []);
  }

  /// `Artbook`
  String get artbook {
    return Intl.message('Artbook', name: 'artbook', desc: '', args: []);
  }

  /// `Light Novel`
  String get lightNovel {
    return Intl.message('Light Novel', name: 'lightNovel', desc: '', args: []);
  }

  /// `Box Set`
  String get boxSet {
    return Intl.message('Box Set', name: 'boxSet', desc: '', args: []);
  }

  /// `Other`
  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  /// `{support, select, manga{Manga} novel{Novel} artbook{Artbook} lightNovel{Light Novel} boxSet{Box Set} other{Other}}`
  String supportIs(String support) {
    return Intl.select(
      support,
      {
        'manga': 'Manga',
        'novel': 'Novel',
        'artbook': 'Artbook',
        'lightNovel': 'Light Novel',
        'boxSet': 'Box Set',
        'other': 'Other',
      },
      name: 'supportIs',
      desc: 'A message that indicates the type of support for the volume',
      args: [support],
    );
  }

  /// `Volume Support`
  String get volumeSupport {
    return Intl.message(
      'Volume Support',
      name: 'volumeSupport',
      desc: '',
      args: [],
    );
  }

  /// `Please choose the support of the volume`
  String get chooseVolumeSupport {
    return Intl.message(
      'Please choose the support of the volume',
      name: 'chooseVolumeSupport',
      desc: '',
      args: [],
    );
  }

  /// `Select Date`
  String get selectDate {
    return Intl.message('Select Date', name: 'selectDate', desc: '', args: []);
  }

  /// `Please select a date`
  String get pleaseSelectDate {
    return Intl.message(
      'Please select a date',
      name: 'pleaseSelectDate',
      desc: '',
      args: [],
    );
  }

  /// `Volume Series ID`
  String get volumeSeriesId {
    return Intl.message(
      'Volume Series ID',
      name: 'volumeSeriesId',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the series ID of the volume`
  String get provideVolumeSeriesId {
    return Intl.message(
      'Please provide the series ID of the volume',
      name: 'provideVolumeSeriesId',
      desc: '',
      args: [],
    );
  }

  /// `Please provide a valid series ID for the volume`
  String get provideValidVolumeSeriesId {
    return Intl.message(
      'Please provide a valid series ID for the volume',
      name: 'provideValidVolumeSeriesId',
      desc: '',
      args: [],
    );
  }

  /// `Volume Sub-Series ID`
  String get volumeSubSeriesId {
    return Intl.message(
      'Volume Sub-Series ID',
      name: 'volumeSubSeriesId',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the sub-series ID of the volume`
  String get provideVolumeSubSeriesId {
    return Intl.message(
      'Please provide the sub-series ID of the volume',
      name: 'provideVolumeSubSeriesId',
      desc: '',
      args: [],
    );
  }

  /// `Please provide a valid sub-series ID for the volume`
  String get provideValidVolumeSubSeriesId {
    return Intl.message(
      'Please provide a valid sub-series ID for the volume',
      name: 'provideValidVolumeSubSeriesId',
      desc: '',
      args: [],
    );
  }

  /// `Volume Editor ID`
  String get volumeEditorId {
    return Intl.message(
      'Volume Editor ID',
      name: 'volumeEditorId',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the editor ID of the volume`
  String get provideVolumeEditorId {
    return Intl.message(
      'Please provide the editor ID of the volume',
      name: 'provideVolumeEditorId',
      desc: '',
      args: [],
    );
  }

  /// `Please provide a valid editor ID for the volume`
  String get provideValidVolumeEditorId {
    return Intl.message(
      'Please provide a valid editor ID for the volume',
      name: 'provideValidVolumeEditorId',
      desc: '',
      args: [],
    );
  }

  /// `Volume Authors IDs`
  String get volumeAuthorsIds {
    return Intl.message(
      'Volume Authors IDs',
      name: 'volumeAuthorsIds',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the author IDs of the volume`
  String get provideVolumeAuthorsIds {
    return Intl.message(
      'Please provide the author IDs of the volume',
      name: 'provideVolumeAuthorsIds',
      desc: '',
      args: [],
    );
  }

  /// `Content of Box Set`
  String get contentOfBoxSet {
    return Intl.message(
      'Content of Box Set',
      name: 'contentOfBoxSet',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the content of the box set`
  String get provideContentOfBoxSet {
    return Intl.message(
      'Please provide the content of the box set',
      name: 'provideContentOfBoxSet',
      desc: '',
      args: [],
    );
  }

  /// `Add Volume`
  String get volumeAdd {
    return Intl.message('Add Volume', name: 'volumeAdd', desc: '', args: []);
  }

  /// `Volume successfully added.`
  String get volumeAddSuccess {
    return Intl.message(
      'Volume successfully added.',
      name: 'volumeAddSuccess',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred, the volume has not been added.`
  String get volumeAddError {
    return Intl.message(
      'An error occurred, the volume has not been added.',
      name: 'volumeAddError',
      desc: '',
      args: [],
    );
  }

  /// `Sub-Series`
  String get subSeries {
    return Intl.message('Sub-Series', name: 'subSeries', desc: '', args: []);
  }

  /// `Editor`
  String get editor {
    return Intl.message('Editor', name: 'editor', desc: '', args: []);
  }

  /// `Genre`
  String get genre {
    return Intl.message('Genre', name: 'genre', desc: '', args: []);
  }

  /// `Admin Home Page`
  String get adminHomePage {
    return Intl.message(
      'Admin Home Page',
      name: 'adminHomePage',
      desc: '',
      args: [],
    );
  }

  /// `Welcome on the admin home page. This is the admin home page where you can manage authors, genres, and volumes.`
  String get adminHomePageDescription {
    return Intl.message(
      'Welcome on the admin home page. This is the admin home page where you can manage authors, genres, and volumes.',
      name: 'adminHomePageDescription',
      desc: '',
      args: [],
    );
  }

  /// `Admin Login Page`
  String get adminLoginPage {
    return Intl.message(
      'Admin Login Page',
      name: 'adminLoginPage',
      desc: '',
      args: [],
    );
  }

  /// `Your Email`
  String get yourEmail {
    return Intl.message('Your Email', name: 'yourEmail', desc: '', args: []);
  }

  /// `Please provide your email`
  String get provideYourEmail {
    return Intl.message(
      'Please provide your email',
      name: 'provideYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Your Password`
  String get yourPassword {
    return Intl.message(
      'Your Password',
      name: 'yourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please provide your password`
  String get provideYourPassword {
    return Intl.message(
      'Please provide your password',
      name: 'provideYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully logged in as an admin.`
  String get adminLoginSuccess {
    return Intl.message(
      'You have successfully logged in as an admin.',
      name: 'adminLoginSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get passwordForgot {
    return Intl.message(
      'Forgot Password?',
      name: 'passwordForgot',
      desc: '',
      args: [],
    );
  }

  /// `Password Reset`
  String get passwordReset {
    return Intl.message(
      'Password Reset',
      name: 'passwordReset',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email to receive a link to reset your password.`
  String get enterEmailForSendingEmailReset {
    return Intl.message(
      'Enter your email to receive a link to reset your password.',
      name: 'enterEmailForSendingEmailReset',
      desc: '',
      args: [],
    );
  }

  /// `Email of the Account`
  String get accountEmail {
    return Intl.message(
      'Email of the Account',
      name: 'accountEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the email of the account`
  String get provideAccountEmail {
    return Intl.message(
      'Please provide the email of the account',
      name: 'provideAccountEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please provide a valid account email`
  String get provideValidAccountEmail {
    return Intl.message(
      'Please provide a valid account email',
      name: 'provideValidAccountEmail',
      desc: '',
      args: [],
    );
  }

  /// `Old Password`
  String get oldPassword {
    return Intl.message(
      'Old Password',
      name: 'oldPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please provide your old password`
  String get provideOldPassword {
    return Intl.message(
      'Please provide your old password',
      name: 'provideOldPassword',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get newPassword {
    return Intl.message(
      'New Password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please provide your new password`
  String get provideNewPassword {
    return Intl.message(
      'Please provide your new password',
      name: 'provideNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm New Password`
  String get confirmNewPassword {
    return Intl.message(
      'Confirm New Password',
      name: 'confirmNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm your new password`
  String get provideConfirmNewPassword {
    return Intl.message(
      'Please confirm your new password',
      name: 'provideConfirmNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `The new password and confirmation do not match.`
  String get passwordsDoNotMatch {
    return Intl.message(
      'The new password and confirmation do not match.',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Sign In Page`
  String get signInPage {
    return Intl.message('Sign In Page', name: 'signInPage', desc: '', args: []);
  }

  /// `Sign In`
  String get signIn {
    return Intl.message('Sign In', name: 'signIn', desc: '', args: []);
  }

  /// `Sign Up Page`
  String get signUpPage {
    return Intl.message('Sign Up Page', name: 'signUpPage', desc: '', args: []);
  }

  /// `Sign Up`
  String get signUp {
    return Intl.message('Sign Up', name: 'signUp', desc: '', args: []);
  }

  /// `Log in to access your collection, manage your profile, and enjoy personalized features.`
  String get whyLogInDescription {
    return Intl.message(
      'Log in to access your collection, manage your profile, and enjoy personalized features.',
      name: 'whyLogInDescription',
      desc: '',
      args: [],
    );
  }

  /// `Create an account to start building your collection, track your favorite series, and connect with other manga enthusiasts.`
  String get whySignUpDescription {
    return Intl.message(
      'Create an account to start building your collection, track your favorite series, and connect with other manga enthusiasts.',
      name: 'whySignUpDescription',
      desc: '',
      args: [],
    );
  }

  /// `Or continue with`
  String get orContinueWith {
    return Intl.message(
      'Or continue with',
      name: 'orContinueWith',
      desc: '',
      args: [],
    );
  }

  /// `Create an Account`
  String get createAccount {
    return Intl.message(
      'Create an Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account yet?`
  String get noAccountYet {
    return Intl.message(
      'Don\'t have an account yet?',
      name: 'noAccountYet',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get alreadyHaveAnAccount {
    return Intl.message(
      'Already have an account?',
      name: 'alreadyHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 8 characters long.`
  String get passwordMinLength {
    return Intl.message(
      'Password must be at least 8 characters long.',
      name: 'passwordMinLength',
      desc: '',
      args: [],
    );
  }

  /// `Username must be at least 3 characters long.`
  String get usernameMinLength {
    return Intl.message(
      'Username must be at least 3 characters long.',
      name: 'usernameMinLength',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Please provide your username`
  String get provideUsername {
    return Intl.message(
      'Please provide your username',
      name: 'provideUsername',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm your password`
  String get pleaseConfirmPassword {
    return Intl.message(
      'Please confirm your password',
      name: 'pleaseConfirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Your Password`
  String get confirmYourPassword {
    return Intl.message(
      'Confirm Your Password',
      name: 'confirmYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Your Birthday`
  String get yourBirthday {
    return Intl.message(
      'Your Birthday',
      name: 'yourBirthday',
      desc: '',
      args: [],
    );
  }

  /// `Please provide your birthday`
  String get provideYourBirthday {
    return Intl.message(
      'Please provide your birthday',
      name: 'provideYourBirthday',
      desc: '',
      args: [],
    );
  }

  /// `Your gender`
  String get yourGender {
    return Intl.message('Your gender', name: 'yourGender', desc: '', args: []);
  }

  /// `Please provide your gender`
  String get provideYourGender {
    return Intl.message(
      'Please provide your gender',
      name: 'provideYourGender',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get male {
    return Intl.message('Male', name: 'male', desc: '', args: []);
  }

  /// `Female`
  String get female {
    return Intl.message('Female', name: 'female', desc: '', args: []);
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Loading data, please wait...`
  String get loadingData {
    return Intl.message(
      'Loading data, please wait...',
      name: 'loadingData',
      desc: '',
      args: [],
    );
  }

  /// `No connection`
  String get noConnection {
    return Intl.message(
      'No connection',
      name: 'noConnection',
      desc: '',
      args: [],
    );
  }

  /// `{job, select, writerMen{Writer} writerWomen{Writer} artistMen{Artist} artistWomen{Artist} editorMen{Editor} editorWomen{Editor} illustratorMen{Illustrator} illustratorWomen{Illustrator} scriptwriterMen{Scriptwriter} scriptwriterWomen{Scriptwriter} authorMen{Author} authorWomen{Author} mangakaMen{Mangaka} mangakaWomen{Mangaka} charaDesignMen{Chara Design} charaDesignWomen{Chara Design} other{Other}}`
  String jobsName(String job) {
    return Intl.select(
      job,
      {
        'writerMen': 'Writer',
        'writerWomen': 'Writer',
        'artistMen': 'Artist',
        'artistWomen': 'Artist',
        'editorMen': 'Editor',
        'editorWomen': 'Editor',
        'illustratorMen': 'Illustrator',
        'illustratorWomen': 'Illustrator',
        'scriptwriterMen': 'Scriptwriter',
        'scriptwriterWomen': 'Scriptwriter',
        'authorMen': 'Author',
        'authorWomen': 'Author',
        'mangakaMen': 'Mangaka',
        'mangakaWomen': 'Mangaka',
        'charaDesignMen': 'Chara Design',
        'charaDesignWomen': 'Chara Design',
        'other': 'Other',
      },
      name: 'jobsName',
      desc: 'A placeholder for jobs name',
      args: [job],
    );
  }

  /// `{count, plural, =0 {Series} =1{Series} other {Series}}`
  String seriesCount(num count) {
    return Intl.plural(
      count,
      zero: 'Series',
      one: 'Series',
      other: 'Series',
      name: 'seriesCount',
      desc: 'A message that indicates the number of series',
      args: [count],
    );
  }

  /// `The author does not exist.`
  String get authorDoesNotExist {
    return Intl.message(
      'The author does not exist.',
      name: 'authorDoesNotExist',
      desc: '',
      args: [],
    );
  }

  /// `The series does not exist.`
  String get seriesDoesNotExist {
    return Intl.message(
      'The series does not exist.',
      name: 'seriesDoesNotExist',
      desc: '',
      args: [],
    );
  }

  /// `The sub-series does not exist.`
  String get subSeriesDoesNotExist {
    return Intl.message(
      'The sub-series does not exist.',
      name: 'subSeriesDoesNotExist',
      desc: '',
      args: [],
    );
  }

  /// `The volume does not exist.`
  String get volumeDoesNotExist {
    return Intl.message(
      'The volume does not exist.',
      name: 'volumeDoesNotExist',
      desc: '',
      args: [],
    );
  }

  /// `The editor does not exist.`
  String get editorDoesNotExist {
    return Intl.message(
      'The editor does not exist.',
      name: 'editorDoesNotExist',
      desc: '',
      args: [],
    );
  }

  /// `Genres`
  String get genres {
    return Intl.message('Genres', name: 'genres', desc: '', args: []);
  }

  /// `Editors`
  String get editors {
    return Intl.message('Editors', name: 'editors', desc: '', args: []);
  }

  /// `Authors`
  String get authors {
    return Intl.message('Authors', name: 'authors', desc: '', args: []);
  }

  /// `Volumes`
  String get volumes {
    return Intl.message('Volumes', name: 'volumes', desc: '', args: []);
  }

  /// `Follow`
  String get follow {
    return Intl.message('Follow', name: 'follow', desc: '', args: []);
  }

  /// `Followed`
  String get followed {
    return Intl.message('Followed', name: 'followed', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `Read`
  String get read {
    return Intl.message('Read', name: 'read', desc: '', args: []);
  }

  /// `Readed`
  String get readed {
    return Intl.message('Readed', name: 'readed', desc: '', args: []);
  }

  /// `Summary`
  String get summary {
    return Intl.message('Summary', name: 'summary', desc: '', args: []);
  }

  /// `See More`
  String get seeMore {
    return Intl.message('See More', name: 'seeMore', desc: '', args: []);
  }

  /// `See Less`
  String get seeLess {
    return Intl.message('See Less', name: 'seeLess', desc: '', args: []);
  }

  /// `Sadly, this volume is no longer available.`
  String get volumeNotAvailableAnymore {
    return Intl.message(
      'Sadly, this volume is no longer available.',
      name: 'volumeNotAvailableAnymore',
      desc: '',
      args: [],
    );
  }

  /// `This volume is not available for sale.`
  String get volumeNotAvailableForSale {
    return Intl.message(
      'This volume is not available for sale.',
      name: 'volumeNotAvailableForSale',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get price {
    return Intl.message('Price', name: 'price', desc: '', args: []);
  }

  /// `{availability, select, inStock{In Stock} available{Available} unavailable{Unavailable} onPreorder{On Preorder} other{{availability}}}`
  String availability(String availability) {
    return Intl.select(
      availability,
      {
        'inStock': 'In Stock',
        'available': 'Available',
        'unavailable': 'Unavailable',
        'onPreorder': 'On Preorder',
        'other': '$availability',
      },
      name: 'availability',
      desc: 'A message that indicates the availability of a volume',
      args: [availability],
    );
  }

  /// `Shipping under {days} days`
  String shippingUnderDays(num days) {
    final NumberFormat daysNumberFormat = NumberFormat.compact(
      locale: Intl.getCurrentLocale(),
    );
    final String daysString = daysNumberFormat.format(days);

    return Intl.message(
      'Shipping under $daysString days',
      name: 'shippingUnderDays',
      desc: 'A message that indicates the shipping time',
      args: [daysString],
    );
  }

  /// `Shipping under {count, select, 0 {0 weeks} 1{1 week} other{{count} weeks}}`
  String shippingUnderWeeks(String count) {
    return Intl.message(
      'Shipping under {count, select, 0 {0 weeks} 1{1 week} other{$count weeks}}',
      name: 'shippingUnderWeeks',
      desc: 'A message that indicates the shipping time in weeks',
      args: [count],
    );
  }

  /// `Sold and shipped by {seller}`
  String soldAndShippedBy(String seller) {
    return Intl.message(
      'Sold and shipped by $seller',
      name: 'soldAndShippedBy',
      desc: 'A message that indicates the seller of a volume',
      args: [seller],
    );
  }

  /// `Buy on {store}`
  String buyOn(String store) {
    return Intl.message(
      'Buy on $store',
      name: 'buyOn',
      desc: 'A message that indicates where to buy a volume',
      args: [store],
    );
  }

  /// `Informations`
  String get informations {
    return Intl.message(
      'Informations',
      name: 'informations',
      desc: '',
      args: [],
    );
  }

  /// `EAN`
  String get ean {
    return Intl.message('EAN', name: 'ean', desc: '', args: []);
  }

  /// `Number of Pages`
  String get numberOfPages {
    return Intl.message(
      'Number of Pages',
      name: 'numberOfPages',
      desc: '',
      args: [],
    );
  }

  /// `{owned, plural, =0{0 volume} =1{1 volume} other{{owned} volumes}} owned over {total, plural, =0{0 volume} =1{1 volume} other{{total} volumes}}`
  String volumeOwnedOverX(num owned, num total) {
    return Intl.message(
      '${Intl.plural(owned, zero: '0 volume', one: '1 volume', other: '$owned volumes')} owned over ${Intl.plural(total, zero: '0 volume', one: '1 volume', other: '$total volumes')}',
      name: 'volumeOwnedOverX',
      desc:
          'A message that indicates the number of volumes owned over the total number of volumes',
      args: [owned, total],
    );
  }

  /// `{readed, plural, =0{0 volume} =1{1 volume} other{{readed} volumes}} read over {total, plural, =0{0 volume} =1{1 volume} other{{total} volumes}} you own.`
  String volumeReadedOverX(num readed, num total) {
    return Intl.message(
      '${Intl.plural(readed, zero: '0 volume', one: '1 volume', other: '$readed volumes')} read over ${Intl.plural(total, zero: '0 volume', one: '1 volume', other: '$total volumes')} you own.',
      name: 'volumeReadedOverX',
      desc:
          'A message that indicates the number of volumes read over the total number of volumes owned',
      args: [readed, total],
    );
  }

  /// `{readed, plural, =0{0 volume} =1{1 volume} other{{readed} volumes}} read over {total, plural, =0{0 volume} =1{1 volume} other{{total} volumes}}.`
  String volumeReadedOverSeriesX(num readed, num total) {
    return Intl.message(
      '${Intl.plural(readed, zero: '0 volume', one: '1 volume', other: '$readed volumes')} read over ${Intl.plural(total, zero: '0 volume', one: '1 volume', other: '$total volumes')}.',
      name: 'volumeReadedOverSeriesX',
      desc:
          'A message that indicates the number of volumes read over the total number of volumes in a series',
      args: [readed, total],
    );
  }

  /// `You own 0 volumes.`
  String get zeroVolumesOwned {
    return Intl.message(
      'You own 0 volumes.',
      name: 'zeroVolumesOwned',
      desc: '',
      args: [],
    );
  }

  /// `You have read all the volumes you own.`
  String get allVolumesReaded {
    return Intl.message(
      'You have read all the volumes you own.',
      name: 'allVolumesReaded',
      desc: '',
      args: [],
    );
  }

  /// `Preamble`
  String get preamble {
    return Intl.message('Preamble', name: 'preamble', desc: '', args: []);
  }

  /// `The information and recommendations ("Information") available on this website (also known as "the Site") are offered to you in good faith. This information is believed to be correct at the time you read it. However, MyMangatheque or its subsidiaries and affiliated entities do not guarantee the completeness and accuracy of the Information. You assume full risk of relying on it.`
  String get preambleLane1 {
    return Intl.message(
      'The information and recommendations ("Information") available on this website (also known as "the Site") are offered to you in good faith. This information is believed to be correct at the time you read it. However, MyMangatheque or its subsidiaries and affiliated entities do not guarantee the completeness and accuracy of the Information. You assume full risk of relying on it.',
      name: 'preambleLane1',
      desc: '',
      args: [],
    );
  }

  /// `The Information is provided to you on the condition that you, or any other person reviewing it, may determine its suitability for a specific purpose before using it. Under no circumstances shall MyMangatheque or its subsidiaries and affiliated entities be liable for any damages that may result from the reliance on this information, its use, or the use of any product to which it refers.`
  String get preambleLane2 {
    return Intl.message(
      'The Information is provided to you on the condition that you, or any other person reviewing it, may determine its suitability for a specific purpose before using it. Under no circumstances shall MyMangatheque or its subsidiaries and affiliated entities be liable for any damages that may result from the reliance on this information, its use, or the use of any product to which it refers.',
      name: 'preambleLane2',
      desc: '',
      args: [],
    );
  }

  /// `The Information should not be construed as recommendations for the use of any information, product, procedure, equipment or formulation that would be inconsistent with any patent, copyright or trademark.`
  String get preambleLane3 {
    return Intl.message(
      'The Information should not be construed as recommendations for the use of any information, product, procedure, equipment or formulation that would be inconsistent with any patent, copyright or trademark.',
      name: 'preambleLane3',
      desc: '',
      args: [],
    );
  }

  /// `MyMangatheque or its subsidiaries and affiliated entities shall not be liable if the use of the Information infringes any patent, trademark or, more generally, any intellectual property right.`
  String get preambleLane4 {
    return Intl.message(
      'MyMangatheque or its subsidiaries and affiliated entities shall not be liable if the use of the Information infringes any patent, trademark or, more generally, any intellectual property right.',
      name: 'preambleLane4',
      desc: '',
      args: [],
    );
  }

  /// `No warranty, express or implied, is given as to the merchantability of the information provided, nor as to its suitability for a particular purpose, nor as to the products referred to in this information.`
  String get preambleLane5 {
    return Intl.message(
      'No warranty, express or implied, is given as to the merchantability of the information provided, nor as to its suitability for a particular purpose, nor as to the products referred to in this information.',
      name: 'preambleLane5',
      desc: '',
      args: [],
    );
  }

  /// `Under no circumstances do MyMangatheque or its subsidiaries and affiliated entities undertake to update or correct the Information that will be disseminated by them on the Internet or on their web servers. Similarly, MyMangatheque or its subsidiaries and affiliated entities reserve the right to modify or correct the content of their sites at any time and without notice.`
  String get preambleLane6 {
    return Intl.message(
      'Under no circumstances do MyMangatheque or its subsidiaries and affiliated entities undertake to update or correct the Information that will be disseminated by them on the Internet or on their web servers. Similarly, MyMangatheque or its subsidiaries and affiliated entities reserve the right to modify or correct the content of their sites at any time and without notice.',
      name: 'preambleLane6',
      desc: '',
      args: [],
    );
  }

  /// `Intellectual Property`
  String get intellectualProperty {
    return Intl.message(
      'Intellectual Property',
      name: 'intellectualProperty',
      desc: '',
      args: [],
    );
  }

  /// `Author Rights`
  String get authorRights {
    return Intl.message(
      'Author Rights',
      name: 'authorRights',
      desc: '',
      args: [],
    );
  }

  /// `MyMangatheque and its content (texts, images, videos, etc.) are protected by intellectual property laws in force in France. Any reproduction, representation, modification, publication, or adaptation of all or part of the elements of the site, regardless of the means or process used, is prohibited without prior written authorization or for personal use as a code challenge but without publication.`
  String get authorRightsLane1 {
    return Intl.message(
      'MyMangatheque and its content (texts, images, videos, etc.) are protected by intellectual property laws in force in France. Any reproduction, representation, modification, publication, or adaptation of all or part of the elements of the site, regardless of the means or process used, is prohibited without prior written authorization or for personal use as a code challenge but without publication.',
      name: 'authorRightsLane1',
      desc: '',
      args: [],
    );
  }

  /// `Third-Party Content`
  String get thirdPartyContent {
    return Intl.message(
      'Third-Party Content',
      name: 'thirdPartyContent',
      desc: '',
      args: [],
    );
  }

  /// `Third-party content used on the MyMangatheque site belongs to their respective author.`
  String get thirdPartyContentLane1 {
    return Intl.message(
      'Third-party content used on the MyMangatheque site belongs to their respective author.',
      name: 'thirdPartyContentLane1',
      desc: '',
      args: [],
    );
  }

  /// `Personal Data`
  String get personalData {
    return Intl.message(
      'Personal Data',
      name: 'personalData',
      desc: '',
      args: [],
    );
  }

  /// `User Content`
  String get userContent {
    return Intl.message(
      'User Content',
      name: 'userContent',
      desc: '',
      args: [],
    );
  }

  /// `The User is solely responsible for the User Content that he/she posts online via the Service, as well as the texts and/or opinions that he/she expresses. The User expressly and graciously assigns to MyMangatheque all intellectual property rights relating thereto, including the right of reproduction, representation and adaptation, for the legal duration of copyright protection. He/she undertakes in particular to ensure that this data is not of a nature to harm the legitimate interests of any third party whatsoever. In this respect, he/she guarantees MyMangatheque against any action, based directly or indirectly on these comments and/or data, that may be brought by anyone against MyMangatheque. He/she undertakes in particular to take charge of the payment of any sums resulting from the action of a third party against MyMangatheque, including lawyers' fees and court costs.`
  String get userContentLane1 {
    return Intl.message(
      'The User is solely responsible for the User Content that he/she posts online via the Service, as well as the texts and/or opinions that he/she expresses. The User expressly and graciously assigns to MyMangatheque all intellectual property rights relating thereto, including the right of reproduction, representation and adaptation, for the legal duration of copyright protection. He/she undertakes in particular to ensure that this data is not of a nature to harm the legitimate interests of any third party whatsoever. In this respect, he/she guarantees MyMangatheque against any action, based directly or indirectly on these comments and/or data, that may be brought by anyone against MyMangatheque. He/she undertakes in particular to take charge of the payment of any sums resulting from the action of a third party against MyMangatheque, including lawyers\' fees and court costs.',
      name: 'userContentLane1',
      desc: '',
      args: [],
    );
  }

  /// `MyMangatheque reserves the right to remove all or part of the User Content, at any time and for any reason, without prior warning or justification. The User may not make any claim in this regard.`
  String get userContentLane2 {
    return Intl.message(
      'MyMangatheque reserves the right to remove all or part of the User Content, at any time and for any reason, without prior warning or justification. The User may not make any claim in this regard.',
      name: 'userContentLane2',
      desc: '',
      args: [],
    );
  }

  /// `MyMangatheque collects and processes personal data in compliance with current regulations, in particular the General Data Protection Regulation (GDPR).`
  String get userContentLane3 {
    return Intl.message(
      'MyMangatheque collects and processes personal data in compliance with current regulations, in particular the General Data Protection Regulation (GDPR).',
      name: 'userContentLane3',
      desc: '',
      args: [],
    );
  }

  /// `Protection of Personal Data`
  String get protectionOfPersonalData {
    return Intl.message(
      'Protection of Personal Data',
      name: 'protectionOfPersonalData',
      desc: '',
      args: [],
    );
  }

  /// `Your personal data is intended solely for MyMangatheque. It will under no circumstances be communicated to third parties. In accordance with the rules on the protection of personal data (Article 34 of the French Data Protection Act of 6 January 1978, Directives 95/46 and 97/66), you have the right to access, rectify, and delete data concerning you. To exercise this right, to object to receiving any commercial messages, or for any rectification, please contact us by email, available in the contact section.`
  String get protectionOfPersonalDataLane1 {
    return Intl.message(
      'Your personal data is intended solely for MyMangatheque. It will under no circumstances be communicated to third parties. In accordance with the rules on the protection of personal data (Article 34 of the French Data Protection Act of 6 January 1978, Directives 95/46 and 97/66), you have the right to access, rectify, and delete data concerning you. To exercise this right, to object to receiving any commercial messages, or for any rectification, please contact us by email, available in the contact section.',
      name: 'protectionOfPersonalDataLane1',
      desc: '',
      args: [],
    );
  }

  /// `Cookie Usage`
  String get cookieUsage {
    return Intl.message(
      'Cookie Usage',
      name: 'cookieUsage',
      desc: '',
      args: [],
    );
  }

  /// `The user is informed that when visiting the Site, a cookie may be automatically installed on their browser software. A cookie consists of a block of data that does not allow the user to be identified but allows information relating to the user's navigation on the Site to be recorded in order to carry out analyses of Site traffic, all with the aim of improving the quality of the Site.`
  String get cookieUsageLane1 {
    return Intl.message(
      'The user is informed that when visiting the Site, a cookie may be automatically installed on their browser software. A cookie consists of a block of data that does not allow the user to be identified but allows information relating to the user\'s navigation on the Site to be recorded in order to carry out analyses of Site traffic, all with the aim of improving the quality of the Site.',
      name: 'cookieUsageLane1',
      desc: '',
      args: [],
    );
  }

  /// `The user has the right to access, rectify or delete personal data communicated via a cookie under the conditions indicated above.`
  String get cookieUsageLane2 {
    return Intl.message(
      'The user has the right to access, rectify or delete personal data communicated via a cookie under the conditions indicated above.',
      name: 'cookieUsageLane2',
      desc: '',
      args: [],
    );
  }

  /// `External Links`
  String get externalLinks {
    return Intl.message(
      'External Links',
      name: 'externalLinks',
      desc: '',
      args: [],
    );
  }

  /// `The MyMangatheque website may contain links to external sites. We are not responsible for the content and privacy practices of these sites. These links are provided as a service to users of the Site or the websites of its subsidiaries and affiliated entities. The decision to activate links is solely up to the users.`
  String get externalLinksLane1 {
    return Intl.message(
      'The MyMangatheque website may contain links to external sites. We are not responsible for the content and privacy practices of these sites. These links are provided as a service to users of the Site or the websites of its subsidiaries and affiliated entities. The decision to activate links is solely up to the users.',
      name: 'externalLinksLane1',
      desc: '',
      args: [],
    );
  }

  /// `Contact, Rights and Update Date`
  String get contactRightsAndUpdateDate {
    return Intl.message(
      'Contact, Rights and Update Date',
      name: 'contactRightsAndUpdateDate',
      desc: '',
      args: [],
    );
  }

  /// `Contact`
  String get contact {
    return Intl.message('Contact', name: 'contact', desc: '', args: []);
  }

  /// `For any questions or complaints, please contact us at one of the following email addresses: mymangatheque@gmail.com or contact@mymangatheque.com .`
  String get contactLane1 {
    return Intl.message(
      'For any questions or complaints, please contact us at one of the following email addresses: mymangatheque@gmail.com or contact@mymangatheque.com .',
      name: 'contactLane1',
      desc: '',
      args: [],
    );
  }

  /// `Applicable Law and Competent Jurisdiction`
  String get applicableLawAndCompetentJurisdiction {
    return Intl.message(
      'Applicable Law and Competent Jurisdiction',
      name: 'applicableLawAndCompetentJurisdiction',
      desc: '',
      args: [],
    );
  }

  /// `These legal notices are subject to French law. In the event of a dispute, the French courts will have sole jurisdiction.`
  String get applicableLawAndCompetentJurisdictionLane1 {
    return Intl.message(
      'These legal notices are subject to French law. In the event of a dispute, the French courts will have sole jurisdiction.',
      name: 'applicableLawAndCompetentJurisdictionLane1',
      desc: '',
      args: [],
    );
  }

  /// `Last Update Date`
  String get lastUpdateDate {
    return Intl.message(
      'Last Update Date',
      name: 'lastUpdateDate',
      desc: '',
      args: [],
    );
  }

  /// `Scan EAN`
  String get scanEAN {
    return Intl.message('Scan EAN', name: 'scanEAN', desc: '', args: []);
  }

  /// `Open Scan`
  String get openScan {
    return Intl.message('Open Scan', name: 'openScan', desc: '', args: []);
  }

  /// `Impossible to retrieve the build and app version.`
  String get buildAppVersionImpossibleToRetreive {
    return Intl.message(
      'Impossible to retrieve the build and app version.',
      name: 'buildAppVersionImpossibleToRetreive',
      desc: '',
      args: [],
    );
  }

  /// `You own all the volumes of your collection.`
  String get allVolumesOwned {
    return Intl.message(
      'You own all the volumes of your collection.',
      name: 'allVolumesOwned',
      desc: '',
      args: [],
    );
  }

  /// `An unknown error occurred.`
  String get unknownError {
    return Intl.message(
      'An unknown error occurred.',
      name: 'unknownError',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred : {message} .`
  String errorOccurredMessage(String message) {
    return Intl.message(
      'An error occurred : $message .',
      name: 'errorOccurredMessage',
      desc: 'An error message indicating that an error occurred',
      args: [message],
    );
  }

  /// `Error 404`
  String get error404 {
    return Intl.message('Error 404', name: 'error404', desc: '', args: []);
  }

  /// `Page Not Found`
  String get pageNotFound {
    return Intl.message(
      'Page Not Found',
      name: 'pageNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Go Home`
  String get goHome {
    return Intl.message('Go Home', name: 'goHome', desc: '', args: []);
  }

  /// `You have read all the volumes of this sub-series.`
  String get allVolumesReadedSubSeries {
    return Intl.message(
      'You have read all the volumes of this sub-series.',
      name: 'allVolumesReadedSubSeries',
      desc: '',
      args: [],
    );
  }

  /// `You do not own any volumes, you can add them buy searching in the search page or by scanning their ean (Comming soon...).`
  String get noVolumeOwned {
    return Intl.message(
      'You do not own any volumes, you can add them buy searching in the search page or by scanning their ean (Comming soon...).',
      name: 'noVolumeOwned',
      desc: '',
      args: [],
    );
  }

  /// `You do not follow any series, you can follow them by searching in the search page.`
  String get noFollowedSubSerie {
    return Intl.message(
      'You do not follow any series, you can follow them by searching in the search page.',
      name: 'noFollowedSubSerie',
      desc: '',
      args: [],
    );
  }

  /// `Total of {count, plural, =0 {Volume} =1{Volume} other {Volumes}}`
  String subSerieVolumeNumber(num count) {
    return Intl.message(
      'Total of ${Intl.plural(count, zero: 'Volume', one: 'Volume', other: 'Volumes')}',
      name: 'subSerieVolumeNumber',
      desc: 'A message that indicates the number of volumes in a sub-series',
      args: [count],
    );
  }

  /// `{author, select, error{} other{By {author}}}`
  String subSerieFromAuthor(String author) {
    return Intl.select(
      author,
      {'error': '', 'other': 'By $author'},
      name: 'subSerieFromAuthor',
      desc: 'A message that indicates the author of a sub-series',
      args: [author],
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
