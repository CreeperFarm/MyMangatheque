// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(date) => "Account created on ${date}";

  static String m1(appVersion, buildVersion) =>
      "App Version: ${appVersion} & Build Version: ${buildVersion}";

  static String m2(availability) =>
      "${Intl.select(availability, {'inStock': 'In Stock', 'available': 'Available', 'unavailable': 'Unavailable', 'onPreorder': 'On Preorder', 'other': '${availability}'})}";

  static String m3(date) => "Your birthday is on ${date}";

  static String m4(store) => "Buy on ${store}";

  static String m5(email) => "Your email is ${email}";

  static String m6(count) =>
      "${Intl.plural(count, zero: 'You have 0 favorite series', one: 'You have 1 favorite series', other: 'You have ${count} favorite series')}";

  static String m7(job) =>
      "${Intl.select(job, {'writerMen': 'Writer', 'writerWomen': 'Writer', 'artistMen': 'Artist', 'artistWomen': 'Artist', 'editorMen': 'Editor', 'editorWomen': 'Editor', 'illustratorMen': 'Illustrator', 'illustratorWomen': 'Illustrator', 'scriptwriterMen': 'Scriptwriter', 'scriptwriterWomen': 'Scriptwriter', 'authorMen': 'Author', 'authorWomen': 'Author', 'mangakaMen': 'Mangaka', 'mangakaWomen': 'Mangaka', 'charaDesignMen': 'Chara Design', 'charaDesignWomen': 'Chara Design', 'other': 'Other'})}";

  static String m8(maxLength) =>
      "The maximum allowed number of characters is ${maxLength}.";

  static String m9(minLength) =>
      "The minimum required number of characters is ${minLength}.";

  static String m10(gender) =>
      "${Intl.gender(gender, female: 'she', male: 'he', other: 'they')}";

  static String m11(count) =>
      "${Intl.plural(count, zero: 'Series', one: 'Series', other: 'Series')}";

  static String m12(days) => "Shipping under ${days} days";

  static String m13(count) =>
      "Shipping under {count, select, 0 {0 weeks} 1{1 week} other{${count} weeks}}";

  static String m14(seller) => "Sold and shipped by ${seller}";

  static String m15(support) =>
      "${Intl.select(support, {'manga': 'Manga', 'novel': 'Novel', 'artbook': 'Artbook', 'lightNovel': 'Light Novel', 'boxSet': 'Box Set', 'other': 'Other'})}";

  static String m16(username) => "Your username is ${username}";

  static String m17(count) => "Volume ${count}";

  static String m18(count) =>
      "${Intl.plural(count, zero: 'You own 0 volume', one: 'You own 1 volume', other: 'You own ${count} volumes')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accountCreatedOn": m0,
    "accountEmail": MessageLookupByLibrary.simpleMessage(
      "Email of the Account",
    ),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "adminHomePage": MessageLookupByLibrary.simpleMessage("Admin Home Page"),
    "adminHomePageDescription": MessageLookupByLibrary.simpleMessage(
      "Welcome on the admin home page. This is the admin home page where you can manage authors, genres, and volumes.",
    ),
    "adminLoginPage": MessageLookupByLibrary.simpleMessage("Admin Login Page"),
    "adminLoginSuccess": MessageLookupByLibrary.simpleMessage(
      "You have successfully logged in as an admin.",
    ),
    "adultContent": MessageLookupByLibrary.simpleMessage("Adult Content"),
    "adultContentWarning": MessageLookupByLibrary.simpleMessage(
      "Warning: Adult Content",
    ),
    "alreadyHaveAnAccount": MessageLookupByLibrary.simpleMessage(
      "Already have an account?",
    ),
    "appVersionAndAppBuildVersion": m1,
    "april": MessageLookupByLibrary.simpleMessage("April"),
    "artbook": MessageLookupByLibrary.simpleMessage("Artbook"),
    "august": MessageLookupByLibrary.simpleMessage("August"),
    "authFailed": MessageLookupByLibrary.simpleMessage(
      "Email or password incorrect.",
    ),
    "author": MessageLookupByLibrary.simpleMessage("Author"),
    "authorAdd": MessageLookupByLibrary.simpleMessage("Add Author"),
    "authorAddSuccess": MessageLookupByLibrary.simpleMessage(
      "Author successfully added.",
    ),
    "authorDoesNotExist": MessageLookupByLibrary.simpleMessage(
      "The author does not exist.",
    ),
    "authorDuplicate": MessageLookupByLibrary.simpleMessage(
      "An author with this name already exists.",
    ),
    "authorJobs": MessageLookupByLibrary.simpleMessage(
      "Author Jobs (separated by commas)",
    ),
    "authorName": MessageLookupByLibrary.simpleMessage("Author Name"),
    "authors": MessageLookupByLibrary.simpleMessage("Authors"),
    "availability": m2,
    "birthdayDateIs": m3,
    "boxSet": MessageLookupByLibrary.simpleMessage("Box Set"),
    "buyOn": m4,
    "chooseVolumeLanguage": MessageLookupByLibrary.simpleMessage(
      "Please choose the language of the volume",
    ),
    "chooseVolumeSupport": MessageLookupByLibrary.simpleMessage(
      "Please choose the support of the volume",
    ),
    "clearCache": MessageLookupByLibrary.simpleMessage("Clear Cache"),
    "clearCacheSuccess": MessageLookupByLibrary.simpleMessage(
      "Cache successfully cleared.",
    ),
    "collection": MessageLookupByLibrary.simpleMessage("Collection"),
    "confirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm New Password",
    ),
    "confirmYourPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm Your Password",
    ),
    "contentOfBoxSet": MessageLookupByLibrary.simpleMessage(
      "Content of Box Set",
    ),
    "createAccount": MessageLookupByLibrary.simpleMessage("Create an Account"),
    "createAuthor": MessageLookupByLibrary.simpleMessage("Create Author"),
    "createGenre": MessageLookupByLibrary.simpleMessage("Create Genre"),
    "createVolume": MessageLookupByLibrary.simpleMessage("Create Volume"),
    "dangerZone": MessageLookupByLibrary.simpleMessage("Danger Zone"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "december": MessageLookupByLibrary.simpleMessage("December"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete Account"),
    "deleteAccountConfirmation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete your account? This action cannot be undone.",
    ),
    "deleteAccountFailed": MessageLookupByLibrary.simpleMessage(
      "An error occurred, your account has not been deleted, you have been log out of your account.",
    ),
    "deleteAccountSuccess": MessageLookupByLibrary.simpleMessage(
      "Your account has been successfully deleted.",
    ),
    "ean": MessageLookupByLibrary.simpleMessage("EAN"),
    "edition": MessageLookupByLibrary.simpleMessage("Edition"),
    "editor": MessageLookupByLibrary.simpleMessage("Editor"),
    "editorDoesNotExist": MessageLookupByLibrary.simpleMessage(
      "The editor does not exist.",
    ),
    "editors": MessageLookupByLibrary.simpleMessage("Editors"),
    "emailIs": m5,
    "emailResetSent": MessageLookupByLibrary.simpleMessage(
      "A password reset email has been sent to your email address.",
    ),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enterEmailForSendingEmailReset": MessageLookupByLibrary.simpleMessage(
      "Enter your email to receive a link to reset your password.",
    ),
    "errorOccurred": MessageLookupByLibrary.simpleMessage(
      "An error occurred, please try again later.",
    ),
    "favoriteSeriesNumber": m6,
    "february": MessageLookupByLibrary.simpleMessage("February"),
    "female": MessageLookupByLibrary.simpleMessage("Female"),
    "follow": MessageLookupByLibrary.simpleMessage("Follow"),
    "followed": MessageLookupByLibrary.simpleMessage("Followed"),
    "french": MessageLookupByLibrary.simpleMessage("French"),
    "genre": MessageLookupByLibrary.simpleMessage("Genre"),
    "genreAdd": MessageLookupByLibrary.simpleMessage("Add Genre"),
    "genreAddSuccess": MessageLookupByLibrary.simpleMessage(
      "Genre successfully added.",
    ),
    "genreDuplicate": MessageLookupByLibrary.simpleMessage(
      "A genre with this name already exists.",
    ),
    "genreName": MessageLookupByLibrary.simpleMessage("Genre Name"),
    "genres": MessageLookupByLibrary.simpleMessage("Genres"),
    "german": MessageLookupByLibrary.simpleMessage("German"),
    "helloWorld": MessageLookupByLibrary.simpleMessage("Hello World!"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "informations": MessageLookupByLibrary.simpleMessage("Informations"),
    "invalidEmail": MessageLookupByLibrary.simpleMessage(
      "The email address is invalid.",
    ),
    "isbn": MessageLookupByLibrary.simpleMessage("ISBN"),
    "italian": MessageLookupByLibrary.simpleMessage("Italian"),
    "january": MessageLookupByLibrary.simpleMessage("January"),
    "japanese": MessageLookupByLibrary.simpleMessage("Japanese"),
    "jobsName": m7,
    "july": MessageLookupByLibrary.simpleMessage("July"),
    "june": MessageLookupByLibrary.simpleMessage("June"),
    "legalNotice": MessageLookupByLibrary.simpleMessage("Legal Notice"),
    "lightMode": MessageLookupByLibrary.simpleMessage("Light Mode"),
    "lightNovel": MessageLookupByLibrary.simpleMessage("Light Novel"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "loadingData": MessageLookupByLibrary.simpleMessage(
      "Loading data, please wait...",
    ),
    "logIn": MessageLookupByLibrary.simpleMessage("Log In"),
    "logInFailed": MessageLookupByLibrary.simpleMessage(
      "An error occurred, you have not been connected to your account.",
    ),
    "logInSuccess": MessageLookupByLibrary.simpleMessage(
      "You have successfully logged in.",
    ),
    "logInWithApple": MessageLookupByLibrary.simpleMessage("Log In with Apple"),
    "logInWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Log In with Google",
    ),
    "logOut": MessageLookupByLibrary.simpleMessage("Log Out"),
    "logOutFailed": MessageLookupByLibrary.simpleMessage(
      "An error occurred, you have not been logged out.",
    ),
    "logOutSuccess": MessageLookupByLibrary.simpleMessage(
      "You have successfully logged out.",
    ),
    "male": MessageLookupByLibrary.simpleMessage("Male"),
    "manga": MessageLookupByLibrary.simpleMessage("Manga"),
    "march": MessageLookupByLibrary.simpleMessage("March"),
    "maxLengthExceeded": m8,
    "may": MessageLookupByLibrary.simpleMessage("May"),
    "minLengthNotReached": m9,
    "modifyPassword": MessageLookupByLibrary.simpleMessage("Modify Password"),
    "modifyPasswordSuccess": MessageLookupByLibrary.simpleMessage(
      "Password successfully changed.",
    ),
    "newPassword": MessageLookupByLibrary.simpleMessage("New Password"),
    "noAccountYet": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account yet?",
    ),
    "noConnection": MessageLookupByLibrary.simpleMessage("No connection"),
    "novel": MessageLookupByLibrary.simpleMessage("Novel"),
    "november": MessageLookupByLibrary.simpleMessage("November"),
    "numberOfPages": MessageLookupByLibrary.simpleMessage("Number of Pages"),
    "october": MessageLookupByLibrary.simpleMessage("October"),
    "oldPassword": MessageLookupByLibrary.simpleMessage("Old Password"),
    "orContinueWith": MessageLookupByLibrary.simpleMessage("Or continue with"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "owned": MessageLookupByLibrary.simpleMessage("Owned"),
    "passwordForgot": MessageLookupByLibrary.simpleMessage("Forgot Password?"),
    "passwordMinLength": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 8 characters long.",
    ),
    "passwordReset": MessageLookupByLibrary.simpleMessage("Password Reset"),
    "passwordTooShort": MessageLookupByLibrary.simpleMessage(
      "The password must be at least 6 characters long.",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "The new password and confirmation do not match.",
    ),
    "pleaseConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "Please confirm your password",
    ),
    "pleaseSelectDate": MessageLookupByLibrary.simpleMessage(
      "Please select a date",
    ),
    "pleaseWait": MessageLookupByLibrary.simpleMessage("Please wait..."),
    "price": MessageLookupByLibrary.simpleMessage("Price"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileSettings": MessageLookupByLibrary.simpleMessage(
      "Profile & Settings Page",
    ),
    "pronoun": m10,
    "provideAccountEmail": MessageLookupByLibrary.simpleMessage(
      "Please provide the email of the account",
    ),
    "provideAuthorJobs": MessageLookupByLibrary.simpleMessage(
      "Please provide the author\'s jobs (separated by commas)",
    ),
    "provideAuthorName": MessageLookupByLibrary.simpleMessage(
      "Please provide the author\'s name",
    ),
    "provideConfirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "Please confirm your new password",
    ),
    "provideContentOfBoxSet": MessageLookupByLibrary.simpleMessage(
      "Please provide the content of the box set",
    ),
    "provideGenreName": MessageLookupByLibrary.simpleMessage(
      "Please provide the genre name",
    ),
    "provideNewPassword": MessageLookupByLibrary.simpleMessage(
      "Please provide your new password",
    ),
    "provideOldPassword": MessageLookupByLibrary.simpleMessage(
      "Please provide your old password",
    ),
    "provideSeriesIdOfAuthor": MessageLookupByLibrary.simpleMessage(
      "Please provide the series ID(s) of the author",
    ),
    "provideUsername": MessageLookupByLibrary.simpleMessage(
      "Please provide your username",
    ),
    "provideValidAccountEmail": MessageLookupByLibrary.simpleMessage(
      "Please provide a valid account email",
    ),
    "provideValidVolumeEditorId": MessageLookupByLibrary.simpleMessage(
      "Please provide a valid editor ID for the volume",
    ),
    "provideValidVolumeSeriesId": MessageLookupByLibrary.simpleMessage(
      "Please provide a valid series ID for the volume",
    ),
    "provideValidVolumeSubSeriesId": MessageLookupByLibrary.simpleMessage(
      "Please provide a valid sub-series ID for the volume",
    ),
    "provideVolumeAuthorsIds": MessageLookupByLibrary.simpleMessage(
      "Please provide the author IDs of the volume",
    ),
    "provideVolumeEAN": MessageLookupByLibrary.simpleMessage(
      "Please provide the EAN of the volume",
    ),
    "provideVolumeEditorId": MessageLookupByLibrary.simpleMessage(
      "Please provide the editor ID of the volume",
    ),
    "provideVolumeInfo": MessageLookupByLibrary.simpleMessage(
      "Please provide the information about the volume",
    ),
    "provideVolumeLink": MessageLookupByLibrary.simpleMessage(
      "Please provide the link of the volume",
    ),
    "provideVolumeNumber": MessageLookupByLibrary.simpleMessage(
      "Please provide the volume number",
    ),
    "provideVolumePrice": MessageLookupByLibrary.simpleMessage(
      "Please provide the price of the volume",
    ),
    "provideVolumeSeriesId": MessageLookupByLibrary.simpleMessage(
      "Please provide the series ID of the volume",
    ),
    "provideVolumeSubSeriesId": MessageLookupByLibrary.simpleMessage(
      "Please provide the sub-series ID of the volume",
    ),
    "provideVolumeSummary": MessageLookupByLibrary.simpleMessage(
      "Please provide the summary of the volume",
    ),
    "provideVolumeTitle": MessageLookupByLibrary.simpleMessage(
      "Please provide the volume title",
    ),
    "provideYourBirthday": MessageLookupByLibrary.simpleMessage(
      "Please provide your birthday",
    ),
    "provideYourEmail": MessageLookupByLibrary.simpleMessage(
      "Please provide your email",
    ),
    "provideYourGender": MessageLookupByLibrary.simpleMessage(
      "Please provide your gender",
    ),
    "provideYourPassword": MessageLookupByLibrary.simpleMessage(
      "Please provide your password",
    ),
    "publicationDate": MessageLookupByLibrary.simpleMessage("Publication Date"),
    "publisher": MessageLookupByLibrary.simpleMessage("Publisher"),
    "read": MessageLookupByLibrary.simpleMessage("Read"),
    "readed": MessageLookupByLibrary.simpleMessage("Readed"),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "scanner": MessageLookupByLibrary.simpleMessage("Scanner"),
    "scannerDescription": MessageLookupByLibrary.simpleMessage(
      "Scan the barcode of your volume to add it to your collection.",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "seeLess": MessageLookupByLibrary.simpleMessage("See Less"),
    "seeMore": MessageLookupByLibrary.simpleMessage("See More"),
    "selectDate": MessageLookupByLibrary.simpleMessage("Select Date"),
    "september": MessageLookupByLibrary.simpleMessage("September"),
    "series": MessageLookupByLibrary.simpleMessage("Series"),
    "seriesCount": m11,
    "seriesDoesNotExist": MessageLookupByLibrary.simpleMessage(
      "The series does not exist.",
    ),
    "seriesIdOfAuthor": MessageLookupByLibrary.simpleMessage(
      "Series ID of the Author",
    ),
    "shippingUnderDays": m12,
    "shippingUnderWeeks": m13,
    "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
    "signInPage": MessageLookupByLibrary.simpleMessage("Sign In Page"),
    "signUp": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "signUpPage": MessageLookupByLibrary.simpleMessage("Sign Up Page"),
    "soldAndShippedBy": m14,
    "spanish": MessageLookupByLibrary.simpleMessage("Spanish"),
    "subSeries": MessageLookupByLibrary.simpleMessage("Sub-Series"),
    "subSeriesDoesNotExist": MessageLookupByLibrary.simpleMessage(
      "The sub-series does not exist.",
    ),
    "summary": MessageLookupByLibrary.simpleMessage("Summary"),
    "supportIs": m15,
    "systemMode": MessageLookupByLibrary.simpleMessage("System Mode"),
    "userLoginFailed": MessageLookupByLibrary.simpleMessage(
      "An error occurred, you have not been connected to your account.",
    ),
    "userLoginSuccess": MessageLookupByLibrary.simpleMessage(
      "You have successfully logged in.",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "usernameIs": m16,
    "usernameMinLength": MessageLookupByLibrary.simpleMessage(
      "Username must be at least 3 characters long.",
    ),
    "volume": MessageLookupByLibrary.simpleMessage("Volume"),
    "volumeAdd": MessageLookupByLibrary.simpleMessage("Add Volume"),
    "volumeAddError": MessageLookupByLibrary.simpleMessage(
      "An error occurred, the volume has not been added.",
    ),
    "volumeAddSuccess": MessageLookupByLibrary.simpleMessage(
      "Volume successfully added.",
    ),
    "volumeAuthorsIds": MessageLookupByLibrary.simpleMessage(
      "Volume Authors IDs",
    ),
    "volumeDoesNotExist": MessageLookupByLibrary.simpleMessage(
      "The volume does not exist.",
    ),
    "volumeEAN": MessageLookupByLibrary.simpleMessage("EAN of the Volume"),
    "volumeEditorId": MessageLookupByLibrary.simpleMessage("Volume Editor ID"),
    "volumeInfo": MessageLookupByLibrary.simpleMessage("Volume Information"),
    "volumeLanguage": MessageLookupByLibrary.simpleMessage("Volume Language"),
    "volumeLink": MessageLookupByLibrary.simpleMessage("Volume Link"),
    "volumeNotAvailableAnymore": MessageLookupByLibrary.simpleMessage(
      "Sadly, this volume is no longer available.",
    ),
    "volumeNotAvailableForSale": MessageLookupByLibrary.simpleMessage(
      "This volume is not available for sale.",
    ),
    "volumeNum": m17,
    "volumeNumber": MessageLookupByLibrary.simpleMessage("Volume Number"),
    "volumeOwnedNumber": m18,
    "volumePrice": MessageLookupByLibrary.simpleMessage("Volume Price"),
    "volumeSeriesId": MessageLookupByLibrary.simpleMessage("Volume Series ID"),
    "volumeSubSeriesId": MessageLookupByLibrary.simpleMessage(
      "Volume Sub-Series ID",
    ),
    "volumeSummary": MessageLookupByLibrary.simpleMessage("Volume Summary"),
    "volumeSupport": MessageLookupByLibrary.simpleMessage("Volume Support"),
    "volumeTitle": MessageLookupByLibrary.simpleMessage("Volume Title"),
    "volumes": MessageLookupByLibrary.simpleMessage("Volumes"),
    "whyLogInDescription": MessageLookupByLibrary.simpleMessage(
      "Log in to access your collection, manage your profile, and enjoy personalized features.",
    ),
    "whySignUpDescription": MessageLookupByLibrary.simpleMessage(
      "Create an account to start building your collection, track your favorite series, and connect with other manga enthusiasts.",
    ),
    "yourBirthday": MessageLookupByLibrary.simpleMessage("Your Birthday"),
    "yourEmail": MessageLookupByLibrary.simpleMessage("Your Email"),
    "yourGender": MessageLookupByLibrary.simpleMessage("Your gender"),
    "yourPassword": MessageLookupByLibrary.simpleMessage("Your Password"),
  };
}
