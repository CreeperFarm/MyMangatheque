import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// A gendered message
  ///
  /// In en, this message translates to:
  /// **'{gender, select, male{he} female{she} other{they}}'**
  String pronoun(String gender);

  /// No description provided for @alphabeticalOrder.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical Order'**
  String get alphabeticalOrder;

  /// No description provided for @lastRelease.
  ///
  /// In en, this message translates to:
  /// **'Last Release'**
  String get lastRelease;

  /// No description provided for @completeLibrary.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeLibrary;

  /// No description provided for @desiredLibrary.
  ///
  /// In en, this message translates to:
  /// **'Desired'**
  String get desiredLibrary;

  /// No description provided for @readPile.
  ///
  /// In en, this message translates to:
  /// **'Read Pile'**
  String get readPile;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @dataUndercase.
  ///
  /// In en, this message translates to:
  /// **'data'**
  String get dataUndercase;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Email or password incorrect.'**
  String get authFailed;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 6 characters long.'**
  String get passwordTooShort;

  /// No description provided for @userLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, you have not been connected to your account.'**
  String get userLoginFailed;

  /// No description provided for @userLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have successfully logged in.'**
  String get userLoginSuccess;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please try again later.'**
  String get errorOccurred;

  /// An error message indicating that an object could not be initialized
  ///
  /// In en, this message translates to:
  /// **'An error occurred while initializing {object}, please try again later.'**
  String errorInitializing(String object);

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @emailResetSent.
  ///
  /// In en, this message translates to:
  /// **'A password reset email has been sent to your email address.'**
  String get emailResetSent;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is invalid.'**
  String get invalidEmail;

  /// No description provided for @modifyPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password successfully changed.'**
  String get modifyPasswordSuccess;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @logInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Log In with Google'**
  String get logInWithGoogle;

  /// No description provided for @logInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Log In with Apple'**
  String get logInWithApple;

  /// No description provided for @logInSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have successfully logged in.'**
  String get logInSuccess;

  /// No description provided for @logInFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, you have not been connected to your account.'**
  String get logInFailed;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have successfully logged out.'**
  String get logOutSuccess;

  /// No description provided for @logOutFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, you have not been logged out.'**
  String get logOutFailed;

  /// An error message indicating that the minimum length has not been met
  ///
  /// In en, this message translates to:
  /// **'The minimum required number of characters is {minLength}.'**
  String minLengthNotReached(num minLength);

  /// An error message indicating that the maximum length has been exceeded
  ///
  /// In en, this message translates to:
  /// **'The maximum allowed number of characters is {maxLength}.'**
  String maxLengthExceeded(num maxLength);

  /// No description provided for @legalNotice.
  ///
  /// In en, this message translates to:
  /// **'Legal Notice'**
  String get legalNotice;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings Page'**
  String get profileSettings;

  /// A message that includes the user's email
  ///
  /// In en, this message translates to:
  /// **'Your email is {email}'**
  String emailIs(String email);

  /// A message that includes the user's username
  ///
  /// In en, this message translates to:
  /// **'Your username is {username}'**
  String usernameIs(String username);

  /// A message that includes the account creation date
  ///
  /// In en, this message translates to:
  /// **'Account created on {date}'**
  String accountCreatedOn(String date);

  /// A message that includes the user's birthday date
  ///
  /// In en, this message translates to:
  /// **'Your birthday is on {date}'**
  String birthdayDateIs(String date);

  /// A message that indicates the number of volumes owned by the user
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {You own 0 volume} =1{You own 1 volume} other {You own {count} volumes}}'**
  String volumeOwnedNumber(num count);

  /// A message that indicates the number of favorite series of the user
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {You have 0 favorite series} =1{You have 1 favorite series} other {You have {count} favorite series}}'**
  String favoriteSeriesNumber(num count);

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'System Mode'**
  String get systemMode;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @clearCacheSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cache successfully cleared.'**
  String get clearCacheSuccess;

  /// No description provided for @modifyPassword.
  ///
  /// In en, this message translates to:
  /// **'Modify Password'**
  String get modifyPassword;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully deleted.'**
  String get deleteAccountSuccess;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, your account has not been deleted, you have been log out of your account.'**
  String get deleteAccountFailed;

  /// A message that includes the app version and build version
  ///
  /// In en, this message translates to:
  /// **'App Version: {appVersion} & Build Version: {buildVersion}'**
  String appVersionAndAppBuildVersion(String appVersion, String buildVersion);

  /// A message that indicates the volume number
  ///
  /// In en, this message translates to:
  /// **'Volume {count}'**
  String volumeNum(num count);

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get owned;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @series.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get series;

  /// No description provided for @edition.
  ///
  /// In en, this message translates to:
  /// **'Edition'**
  String get edition;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @publisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get publisher;

  /// No description provided for @publicationDate.
  ///
  /// In en, this message translates to:
  /// **'Publication Date'**
  String get publicationDate;

  /// No description provided for @isbn.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get isbn;

  /// No description provided for @scanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get scanner;

  /// No description provided for @scannerDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan the barcode of your volume to add it to your collection.'**
  String get scannerDescription;

  /// No description provided for @createAuthor.
  ///
  /// In en, this message translates to:
  /// **'Create Author'**
  String get createAuthor;

  /// No description provided for @authorName.
  ///
  /// In en, this message translates to:
  /// **'Author Name'**
  String get authorName;

  /// No description provided for @provideAuthorName.
  ///
  /// In en, this message translates to:
  /// **'Please provide the author\'s name'**
  String get provideAuthorName;

  /// No description provided for @authorJobs.
  ///
  /// In en, this message translates to:
  /// **'Author Jobs (separated by commas)'**
  String get authorJobs;

  /// No description provided for @provideAuthorJobs.
  ///
  /// In en, this message translates to:
  /// **'Please provide the author\'s jobs (separated by commas)'**
  String get provideAuthorJobs;

  /// No description provided for @seriesIdOfAuthor.
  ///
  /// In en, this message translates to:
  /// **'Series ID of the Author'**
  String get seriesIdOfAuthor;

  /// No description provided for @provideSeriesIdOfAuthor.
  ///
  /// In en, this message translates to:
  /// **'Please provide the series ID(s) of the author'**
  String get provideSeriesIdOfAuthor;

  /// No description provided for @authorAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Author'**
  String get authorAdd;

  /// No description provided for @authorAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Author successfully added.'**
  String get authorAddSuccess;

  /// No description provided for @authorDuplicate.
  ///
  /// In en, this message translates to:
  /// **'An author with this name already exists.'**
  String get authorDuplicate;

  /// No description provided for @createGenre.
  ///
  /// In en, this message translates to:
  /// **'Create Genre'**
  String get createGenre;

  /// No description provided for @genreName.
  ///
  /// In en, this message translates to:
  /// **'Genre Name'**
  String get genreName;

  /// No description provided for @provideGenreName.
  ///
  /// In en, this message translates to:
  /// **'Please provide the genre name'**
  String get provideGenreName;

  /// No description provided for @genreAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Genre'**
  String get genreAdd;

  /// No description provided for @genreAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Genre successfully added.'**
  String get genreAddSuccess;

  /// No description provided for @genreDuplicate.
  ///
  /// In en, this message translates to:
  /// **'A genre with this name already exists.'**
  String get genreDuplicate;

  /// No description provided for @createVolume.
  ///
  /// In en, this message translates to:
  /// **'Create Volume'**
  String get createVolume;

  /// No description provided for @volumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Volume Title'**
  String get volumeTitle;

  /// No description provided for @provideVolumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Please provide the volume title'**
  String get provideVolumeTitle;

  /// No description provided for @volumeNumber.
  ///
  /// In en, this message translates to:
  /// **'Volume Number'**
  String get volumeNumber;

  /// No description provided for @provideVolumeNumber.
  ///
  /// In en, this message translates to:
  /// **'Please provide the volume number'**
  String get provideVolumeNumber;

  /// No description provided for @volumeEAN.
  ///
  /// In en, this message translates to:
  /// **'EAN of the Volume'**
  String get volumeEAN;

  /// No description provided for @provideVolumeEAN.
  ///
  /// In en, this message translates to:
  /// **'Please provide the EAN of the volume'**
  String get provideVolumeEAN;

  /// No description provided for @volumePrice.
  ///
  /// In en, this message translates to:
  /// **'Volume Price'**
  String get volumePrice;

  /// No description provided for @provideVolumePrice.
  ///
  /// In en, this message translates to:
  /// **'Please provide the price of the volume'**
  String get provideVolumePrice;

  /// No description provided for @volumeSummary.
  ///
  /// In en, this message translates to:
  /// **'Volume Summary'**
  String get volumeSummary;

  /// No description provided for @provideVolumeSummary.
  ///
  /// In en, this message translates to:
  /// **'Please provide the summary of the volume'**
  String get provideVolumeSummary;

  /// No description provided for @volumeLink.
  ///
  /// In en, this message translates to:
  /// **'Volume Link'**
  String get volumeLink;

  /// No description provided for @provideVolumeLink.
  ///
  /// In en, this message translates to:
  /// **'Please provide the link of the volume'**
  String get provideVolumeLink;

  /// No description provided for @volumeInfo.
  ///
  /// In en, this message translates to:
  /// **'Volume Information'**
  String get volumeInfo;

  /// No description provided for @provideVolumeInfo.
  ///
  /// In en, this message translates to:
  /// **'Please provide the information about the volume'**
  String get provideVolumeInfo;

  /// No description provided for @adultContent.
  ///
  /// In en, this message translates to:
  /// **'Adult Content'**
  String get adultContent;

  /// No description provided for @adultContentWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Adult Content'**
  String get adultContentWarning;

  /// No description provided for @volumeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Volume Language'**
  String get volumeLanguage;

  /// No description provided for @chooseVolumeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Please choose the language of the volume'**
  String get chooseVolumeLanguage;

  /// No description provided for @manga.
  ///
  /// In en, this message translates to:
  /// **'Manga'**
  String get manga;

  /// No description provided for @novel.
  ///
  /// In en, this message translates to:
  /// **'Novel'**
  String get novel;

  /// No description provided for @artbook.
  ///
  /// In en, this message translates to:
  /// **'Artbook'**
  String get artbook;

  /// No description provided for @lightNovel.
  ///
  /// In en, this message translates to:
  /// **'Light Novel'**
  String get lightNovel;

  /// No description provided for @boxSet.
  ///
  /// In en, this message translates to:
  /// **'Box Set'**
  String get boxSet;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// A message that indicates the type of support for the volume
  ///
  /// In en, this message translates to:
  /// **'{support, select, manga{Manga} novel{Novel} artbook{Artbook} lightNovel{Light Novel} boxSet{Box Set} other{Other}}'**
  String supportIs(String support);

  /// No description provided for @volumeSupport.
  ///
  /// In en, this message translates to:
  /// **'Volume Support'**
  String get volumeSupport;

  /// No description provided for @chooseVolumeSupport.
  ///
  /// In en, this message translates to:
  /// **'Please choose the support of the volume'**
  String get chooseVolumeSupport;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @pleaseSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectDate;

  /// No description provided for @volumeSeriesId.
  ///
  /// In en, this message translates to:
  /// **'Volume Series ID'**
  String get volumeSeriesId;

  /// No description provided for @provideVolumeSeriesId.
  ///
  /// In en, this message translates to:
  /// **'Please provide the series ID of the volume'**
  String get provideVolumeSeriesId;

  /// No description provided for @provideValidVolumeSeriesId.
  ///
  /// In en, this message translates to:
  /// **'Please provide a valid series ID for the volume'**
  String get provideValidVolumeSeriesId;

  /// No description provided for @volumeSubSeriesId.
  ///
  /// In en, this message translates to:
  /// **'Volume Sub-Series ID'**
  String get volumeSubSeriesId;

  /// No description provided for @provideVolumeSubSeriesId.
  ///
  /// In en, this message translates to:
  /// **'Please provide the sub-series ID of the volume'**
  String get provideVolumeSubSeriesId;

  /// No description provided for @provideValidVolumeSubSeriesId.
  ///
  /// In en, this message translates to:
  /// **'Please provide a valid sub-series ID for the volume'**
  String get provideValidVolumeSubSeriesId;

  /// No description provided for @volumeEditorId.
  ///
  /// In en, this message translates to:
  /// **'Volume Editor ID'**
  String get volumeEditorId;

  /// No description provided for @provideVolumeEditorId.
  ///
  /// In en, this message translates to:
  /// **'Please provide the editor ID of the volume'**
  String get provideVolumeEditorId;

  /// No description provided for @provideValidVolumeEditorId.
  ///
  /// In en, this message translates to:
  /// **'Please provide a valid editor ID for the volume'**
  String get provideValidVolumeEditorId;

  /// No description provided for @volumeAuthorsIds.
  ///
  /// In en, this message translates to:
  /// **'Volume Authors IDs'**
  String get volumeAuthorsIds;

  /// No description provided for @provideVolumeAuthorsIds.
  ///
  /// In en, this message translates to:
  /// **'Please provide the author IDs of the volume'**
  String get provideVolumeAuthorsIds;

  /// No description provided for @contentOfBoxSet.
  ///
  /// In en, this message translates to:
  /// **'Content of Box Set'**
  String get contentOfBoxSet;

  /// No description provided for @provideContentOfBoxSet.
  ///
  /// In en, this message translates to:
  /// **'Please provide the content of the box set'**
  String get provideContentOfBoxSet;

  /// No description provided for @volumeAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Volume'**
  String get volumeAdd;

  /// No description provided for @volumeAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Volume successfully added.'**
  String get volumeAddSuccess;

  /// No description provided for @volumeAddError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, the volume has not been added.'**
  String get volumeAddError;

  /// No description provided for @subSeries.
  ///
  /// In en, this message translates to:
  /// **'Sub-Series'**
  String get subSeries;

  /// No description provided for @editor.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get editor;

  /// No description provided for @genre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get genre;

  /// No description provided for @adminHomePage.
  ///
  /// In en, this message translates to:
  /// **'Admin Home Page'**
  String get adminHomePage;

  /// No description provided for @adminHomePageDescription.
  ///
  /// In en, this message translates to:
  /// **'Welcome on the admin home page. This is the admin home page where you can manage authors, genres, and volumes.'**
  String get adminHomePageDescription;

  /// No description provided for @adminLoginPage.
  ///
  /// In en, this message translates to:
  /// **'Admin Login Page'**
  String get adminLoginPage;

  /// No description provided for @yourEmail.
  ///
  /// In en, this message translates to:
  /// **'Your Email'**
  String get yourEmail;

  /// No description provided for @provideYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please provide your email'**
  String get provideYourEmail;

  /// No description provided for @yourPassword.
  ///
  /// In en, this message translates to:
  /// **'Your Password'**
  String get yourPassword;

  /// No description provided for @provideYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please provide your password'**
  String get provideYourPassword;

  /// No description provided for @adminLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have successfully logged in as an admin.'**
  String get adminLoginSuccess;

  /// No description provided for @passwordForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get passwordForgot;

  /// No description provided for @passwordReset.
  ///
  /// In en, this message translates to:
  /// **'Password Reset'**
  String get passwordReset;

  /// No description provided for @enterEmailForSendingEmailReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a link to reset your password.'**
  String get enterEmailForSendingEmailReset;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Email of the Account'**
  String get accountEmail;

  /// No description provided for @provideAccountEmail.
  ///
  /// In en, this message translates to:
  /// **'Please provide the email of the account'**
  String get provideAccountEmail;

  /// No description provided for @provideValidAccountEmail.
  ///
  /// In en, this message translates to:
  /// **'Please provide a valid account email'**
  String get provideValidAccountEmail;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @provideOldPassword.
  ///
  /// In en, this message translates to:
  /// **'Please provide your old password'**
  String get provideOldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @provideNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please provide your new password'**
  String get provideNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @provideConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get provideConfirmNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'The new password and confirmation do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @signInPage.
  ///
  /// In en, this message translates to:
  /// **'Sign In Page'**
  String get signInPage;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUpPage.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Page'**
  String get signUpPage;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @whyLogInDescription.
  ///
  /// In en, this message translates to:
  /// **'Log in to access your collection, manage your profile, and enjoy personalized features.'**
  String get whyLogInDescription;

  /// No description provided for @whySignUpDescription.
  ///
  /// In en, this message translates to:
  /// **'Create an account to start building your collection, track your favorite series, and connect with other manga enthusiasts.'**
  String get whySignUpDescription;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAccount;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet?'**
  String get noAccountYet;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long.'**
  String get passwordMinLength;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters long.'**
  String get usernameMinLength;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @provideUsername.
  ///
  /// In en, this message translates to:
  /// **'Please provide your username'**
  String get provideUsername;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your Password'**
  String get confirmYourPassword;

  /// No description provided for @yourBirthday.
  ///
  /// In en, this message translates to:
  /// **'Your Birthday'**
  String get yourBirthday;

  /// No description provided for @provideYourBirthday.
  ///
  /// In en, this message translates to:
  /// **'Please provide your birthday'**
  String get provideYourBirthday;

  /// No description provided for @yourGender.
  ///
  /// In en, this message translates to:
  /// **'Your gender'**
  String get yourGender;

  /// No description provided for @provideYourGender.
  ///
  /// In en, this message translates to:
  /// **'Please provide your gender'**
  String get provideYourGender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data, please wait...'**
  String get loadingData;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get noConnection;

  /// A placeholder for jobs name
  ///
  /// In en, this message translates to:
  /// **'{job, select, writerMen{Writer} writerWomen{Writer} artistMen{Artist} artistWomen{Artist} editorMen{Editor} editorWomen{Editor} illustratorMen{Illustrator} illustratorWomen{Illustrator} scriptwriterMen{Scriptwriter} scriptwriterWomen{Scriptwriter} authorMen{Author} authorWomen{Author} mangakaMen{Mangaka} mangakaWomen{Mangaka} charaDesignMen{Chara Design} charaDesignWomen{Chara Design} other{Other}}'**
  String jobsName(String job);

  /// A message that indicates the number of series
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {Series} =1{Series} other {Series}}'**
  String seriesCount(num count);

  /// No description provided for @authorDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'The author does not exist.'**
  String get authorDoesNotExist;

  /// No description provided for @seriesDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'The series does not exist.'**
  String get seriesDoesNotExist;

  /// No description provided for @subSeriesDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'The sub-series does not exist.'**
  String get subSeriesDoesNotExist;

  /// No description provided for @volumeDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'The volume does not exist.'**
  String get volumeDoesNotExist;

  /// No description provided for @editorDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'The editor does not exist.'**
  String get editorDoesNotExist;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @editors.
  ///
  /// In en, this message translates to:
  /// **'Editors'**
  String get editors;

  /// No description provided for @authors.
  ///
  /// In en, this message translates to:
  /// **'Authors'**
  String get authors;

  /// No description provided for @volumes.
  ///
  /// In en, this message translates to:
  /// **'Volumes'**
  String get volumes;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @followed.
  ///
  /// In en, this message translates to:
  /// **'Followed'**
  String get followed;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @readed.
  ///
  /// In en, this message translates to:
  /// **'Readed'**
  String get readed;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get seeLess;

  /// No description provided for @volumeNotAvailableAnymore.
  ///
  /// In en, this message translates to:
  /// **'Sadly, this volume is no longer available.'**
  String get volumeNotAvailableAnymore;

  /// No description provided for @volumeNotAvailableForSale.
  ///
  /// In en, this message translates to:
  /// **'This volume is not available for sale.'**
  String get volumeNotAvailableForSale;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// A message that indicates the availability of a volume
  ///
  /// In en, this message translates to:
  /// **'{availability, select, inStock{In Stock} available{Available} unavailable{Unavailable} onPreorder{On Preorder} other{{availability}}}'**
  String availability(String availability);

  /// A message that indicates the shipping time
  ///
  /// In en, this message translates to:
  /// **'Shipping under {days} days'**
  String shippingUnderDays(num days);

  /// A message that indicates the shipping time in weeks
  ///
  /// In en, this message translates to:
  /// **'Shipping under {count, select, 0 {0 weeks} 1{1 week} other{{count} weeks}}'**
  String shippingUnderWeeks(String count);

  /// A message that indicates the seller of a volume
  ///
  /// In en, this message translates to:
  /// **'Sold and shipped by {seller}'**
  String soldAndShippedBy(String seller);

  /// A message that indicates where to buy a volume
  ///
  /// In en, this message translates to:
  /// **'Buy on {store}'**
  String buyOn(String store);

  /// No description provided for @informations.
  ///
  /// In en, this message translates to:
  /// **'Informations'**
  String get informations;

  /// No description provided for @ean.
  ///
  /// In en, this message translates to:
  /// **'EAN'**
  String get ean;

  /// No description provided for @numberOfPages.
  ///
  /// In en, this message translates to:
  /// **'Number of Pages'**
  String get numberOfPages;

  /// A message that indicates the number of volumes owned over the total number of volumes
  ///
  /// In en, this message translates to:
  /// **'{owned, plural, =0{0 volume} =1{1 volume} other{{owned} volumes}} owned over {total, plural, =0{0 volume} =1{1 volume} other{{total} volumes}}'**
  String volumeOwnedOverX(num owned, num total);

  /// A message that indicates the number of volumes read over the total number of volumes owned
  ///
  /// In en, this message translates to:
  /// **'{readed, plural, =0{0 volume} =1{1 volume} other{{readed} volumes}} read over {total, plural, =0{0 volume} =1{1 volume} other{{total} volumes}} you own.'**
  String volumeReadedOverX(num readed, num total);

  /// A message that indicates the number of volumes read over the total number of volumes in a series
  ///
  /// In en, this message translates to:
  /// **'{readed, plural, =0{0 volume} =1{1 volume} other{{readed} volumes}} read over {total, plural, =0{0 volume} =1{1 volume} other{{total} volumes}}.'**
  String volumeReadedOverSeriesX(num readed, num total);

  /// No description provided for @zeroVolumesOwned.
  ///
  /// In en, this message translates to:
  /// **'You own 0 volumes.'**
  String get zeroVolumesOwned;

  /// No description provided for @allVolumesReaded.
  ///
  /// In en, this message translates to:
  /// **'You have read all the volumes you own.'**
  String get allVolumesReaded;

  /// No description provided for @preamble.
  ///
  /// In en, this message translates to:
  /// **'Preamble'**
  String get preamble;

  /// No description provided for @preambleLane1.
  ///
  /// In en, this message translates to:
  /// **'The information and recommendations (\"Information\") available on this website (also known as \"the Site\") are offered to you in good faith. This information is believed to be correct at the time you read it. However, MyMangatheque or its subsidiaries and affiliated entities do not guarantee the completeness and accuracy of the Information. You assume full risk of relying on it.'**
  String get preambleLane1;

  /// No description provided for @preambleLane2.
  ///
  /// In en, this message translates to:
  /// **'The Information is provided to you on the condition that you, or any other person reviewing it, may determine its suitability for a specific purpose before using it. Under no circumstances shall MyMangatheque or its subsidiaries and affiliated entities be liable for any damages that may result from the reliance on this information, its use, or the use of any product to which it refers.'**
  String get preambleLane2;

  /// No description provided for @preambleLane3.
  ///
  /// In en, this message translates to:
  /// **'The Information should not be construed as recommendations for the use of any information, product, procedure, equipment or formulation that would be inconsistent with any patent, copyright or trademark.'**
  String get preambleLane3;

  /// No description provided for @preambleLane4.
  ///
  /// In en, this message translates to:
  /// **'MyMangatheque or its subsidiaries and affiliated entities shall not be liable if the use of the Information infringes any patent, trademark or, more generally, any intellectual property right.'**
  String get preambleLane4;

  /// No description provided for @preambleLane5.
  ///
  /// In en, this message translates to:
  /// **'No warranty, express or implied, is given as to the merchantability of the information provided, nor as to its suitability for a particular purpose, nor as to the products referred to in this information.'**
  String get preambleLane5;

  /// No description provided for @preambleLane6.
  ///
  /// In en, this message translates to:
  /// **'Under no circumstances do MyMangatheque or its subsidiaries and affiliated entities undertake to update or correct the Information that will be disseminated by them on the Internet or on their web servers. Similarly, MyMangatheque or its subsidiaries and affiliated entities reserve the right to modify or correct the content of their sites at any time and without notice.'**
  String get preambleLane6;

  /// No description provided for @intellectualProperty.
  ///
  /// In en, this message translates to:
  /// **'Intellectual Property'**
  String get intellectualProperty;

  /// No description provided for @authorRights.
  ///
  /// In en, this message translates to:
  /// **'Author Rights'**
  String get authorRights;

  /// No description provided for @authorRightsLane1.
  ///
  /// In en, this message translates to:
  /// **'MyMangatheque and its content (texts, images, videos, etc.) are protected by intellectual property laws in force in France. Any reproduction, representation, modification, publication, or adaptation of all or part of the elements of the site, regardless of the means or process used, is prohibited without prior written authorization or for personal use as a code challenge but without publication.'**
  String get authorRightsLane1;

  /// No description provided for @thirdPartyContent.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Content'**
  String get thirdPartyContent;

  /// No description provided for @thirdPartyContentLane1.
  ///
  /// In en, this message translates to:
  /// **'Third-party content used on the MyMangatheque site belongs to their respective author.'**
  String get thirdPartyContentLane1;

  /// No description provided for @personalData.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get personalData;

  /// No description provided for @userContent.
  ///
  /// In en, this message translates to:
  /// **'User Content'**
  String get userContent;

  /// No description provided for @userContentLane1.
  ///
  /// In en, this message translates to:
  /// **'The User is solely responsible for the User Content that he/she posts online via the Service, as well as the texts and/or opinions that he/she expresses. The User expressly and graciously assigns to MyMangatheque all intellectual property rights relating thereto, including the right of reproduction, representation and adaptation, for the legal duration of copyright protection. He/she undertakes in particular to ensure that this data is not of a nature to harm the legitimate interests of any third party whatsoever. In this respect, he/she guarantees MyMangatheque against any action, based directly or indirectly on these comments and/or data, that may be brought by anyone against MyMangatheque. He/she undertakes in particular to take charge of the payment of any sums resulting from the action of a third party against MyMangatheque, including lawyers\' fees and court costs.'**
  String get userContentLane1;

  /// No description provided for @userContentLane2.
  ///
  /// In en, this message translates to:
  /// **'MyMangatheque reserves the right to remove all or part of the User Content, at any time and for any reason, without prior warning or justification. The User may not make any claim in this regard.'**
  String get userContentLane2;

  /// No description provided for @userContentLane3.
  ///
  /// In en, this message translates to:
  /// **'MyMangatheque collects and processes personal data in compliance with current regulations, in particular the General Data Protection Regulation (GDPR).'**
  String get userContentLane3;

  /// No description provided for @protectionOfPersonalData.
  ///
  /// In en, this message translates to:
  /// **'Protection of Personal Data'**
  String get protectionOfPersonalData;

  /// No description provided for @protectionOfPersonalDataLane1.
  ///
  /// In en, this message translates to:
  /// **'Your personal data is intended solely for MyMangatheque. It will under no circumstances be communicated to third parties. In accordance with the rules on the protection of personal data (Article 34 of the French Data Protection Act of 6 January 1978, Directives 95/46 and 97/66), you have the right to access, rectify, and delete data concerning you. To exercise this right, to object to receiving any commercial messages, or for any rectification, please contact us by email, available in the contact section.'**
  String get protectionOfPersonalDataLane1;

  /// No description provided for @cookieUsage.
  ///
  /// In en, this message translates to:
  /// **'Cookie Usage'**
  String get cookieUsage;

  /// No description provided for @cookieUsageLane1.
  ///
  /// In en, this message translates to:
  /// **'The user is informed that when visiting the Site, a cookie may be automatically installed on their browser software. A cookie consists of a block of data that does not allow the user to be identified but allows information relating to the user\'s navigation on the Site to be recorded in order to carry out analyses of Site traffic, all with the aim of improving the quality of the Site.'**
  String get cookieUsageLane1;

  /// No description provided for @cookieUsageLane2.
  ///
  /// In en, this message translates to:
  /// **'The user has the right to access, rectify or delete personal data communicated via a cookie under the conditions indicated above.'**
  String get cookieUsageLane2;

  /// No description provided for @externalLinks.
  ///
  /// In en, this message translates to:
  /// **'External Links'**
  String get externalLinks;

  /// No description provided for @externalLinksLane1.
  ///
  /// In en, this message translates to:
  /// **'The MyMangatheque website may contain links to external sites. We are not responsible for the content and privacy practices of these sites. These links are provided as a service to users of the Site or the websites of its subsidiaries and affiliated entities. The decision to activate links is solely up to the users.'**
  String get externalLinksLane1;

  /// No description provided for @contactRightsAndUpdateDate.
  ///
  /// In en, this message translates to:
  /// **'Contact, Rights and Update Date'**
  String get contactRightsAndUpdateDate;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactLane1.
  ///
  /// In en, this message translates to:
  /// **'For any questions or complaints, please contact us at one of the following email addresses: mymangatheque@gmail.com or contact@mymangatheque.com .'**
  String get contactLane1;

  /// No description provided for @applicableLawAndCompetentJurisdiction.
  ///
  /// In en, this message translates to:
  /// **'Applicable Law and Competent Jurisdiction'**
  String get applicableLawAndCompetentJurisdiction;

  /// No description provided for @applicableLawAndCompetentJurisdictionLane1.
  ///
  /// In en, this message translates to:
  /// **'These legal notices are subject to French law. In the event of a dispute, the French courts will have sole jurisdiction.'**
  String get applicableLawAndCompetentJurisdictionLane1;

  /// No description provided for @lastUpdateDate.
  ///
  /// In en, this message translates to:
  /// **'Last Update Date'**
  String get lastUpdateDate;

  /// No description provided for @scanEAN.
  ///
  /// In en, this message translates to:
  /// **'Scan EAN'**
  String get scanEAN;

  /// No description provided for @openScan.
  ///
  /// In en, this message translates to:
  /// **'Open Scan'**
  String get openScan;

  /// No description provided for @buildAppVersionImpossibleToRetreive.
  ///
  /// In en, this message translates to:
  /// **'Impossible to retrieve the build and app version.'**
  String get buildAppVersionImpossibleToRetreive;

  /// No description provided for @allVolumesOwned.
  ///
  /// In en, this message translates to:
  /// **'You own all the volumes of your collection.'**
  String get allVolumesOwned;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get unknownError;

  /// An error message indicating that an error occurred
  ///
  /// In en, this message translates to:
  /// **'An error occurred : {message} .'**
  String errorOccurredMessage(String message);

  /// No description provided for @error404.
  ///
  /// In en, this message translates to:
  /// **'Error 404'**
  String get error404;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get pageNotFound;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @allVolumesReadedSubSeries.
  ///
  /// In en, this message translates to:
  /// **'You have read all the volumes of this sub-series.'**
  String get allVolumesReadedSubSeries;

  /// No description provided for @noVolumeOwned.
  ///
  /// In en, this message translates to:
  /// **'You do not own any volumes, you can add them buy searching in the search page or by scanning their ean (Comming soon...).'**
  String get noVolumeOwned;

  /// No description provided for @noFollowedSubSerie.
  ///
  /// In en, this message translates to:
  /// **'You do not follow any series, you can follow them by searching in the search page.'**
  String get noFollowedSubSerie;

  /// A message that indicates the number of volumes in a sub-series
  ///
  /// In en, this message translates to:
  /// **'Total of {count, plural, =0 {Volume} =1{Volume} other {Volumes}}'**
  String subSerieVolumeNumber(num count);

  /// A message that indicates the author of a sub-series
  ///
  /// In en, this message translates to:
  /// **'{author, select, error{} other{By {author}}}'**
  String subSerieFromAuthor(String author);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
