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

  static String m6(object) =>
      "An error occurred while initializing ${object}, please try again later.";

  static String m7(count) =>
      "${Intl.plural(count, zero: 'You have 0 favorite series', one: 'You have 1 favorite series', other: 'You have ${count} favorite series')}";

  static String m8(job) =>
      "${Intl.select(job, {'writerMen': 'Writer', 'writerWomen': 'Writer', 'artistMen': 'Artist', 'artistWomen': 'Artist', 'editorMen': 'Editor', 'editorWomen': 'Editor', 'illustratorMen': 'Illustrator', 'illustratorWomen': 'Illustrator', 'scriptwriterMen': 'Scriptwriter', 'scriptwriterWomen': 'Scriptwriter', 'authorMen': 'Author', 'authorWomen': 'Author', 'mangakaMen': 'Mangaka', 'mangakaWomen': 'Mangaka', 'charaDesignMen': 'Chara Design', 'charaDesignWomen': 'Chara Design', 'other': 'Other'})}";

  static String m9(maxLength) =>
      "The maximum allowed number of characters is ${maxLength}.";

  static String m10(minLength) =>
      "The minimum required number of characters is ${minLength}.";

  static String m11(gender) =>
      "${Intl.gender(gender, female: 'she', male: 'he', other: 'they')}";

  static String m12(count) =>
      "${Intl.plural(count, zero: 'Series', one: 'Series', other: 'Series')}";

  static String m13(days) => "Shipping under ${days} days";

  static String m14(count) =>
      "Shipping under {count, select, 0 {0 weeks} 1{1 week} other{${count} weeks}}";

  static String m15(seller) => "Sold and shipped by ${seller}";

  static String m16(support) =>
      "${Intl.select(support, {'manga': 'Manga', 'novel': 'Novel', 'artbook': 'Artbook', 'lightNovel': 'Light Novel', 'boxSet': 'Box Set', 'other': 'Other'})}";

  static String m17(username) => "Your username is ${username}";

  static String m18(count) => "Volume ${count}";

  static String m19(count) =>
      "${Intl.plural(count, zero: 'You own 0 volume', one: 'You own 1 volume', other: 'You own ${count} volumes')}";

  static String m20(owned, total) =>
      "${Intl.plural(owned, zero: '0 volume', one: '1 volume', other: '${owned} volumes')} owned over ${Intl.plural(total, zero: '0 volume', one: '1 volume', other: '${total} volumes')}";

  static String m21(readed, total) =>
      "${Intl.plural(readed, zero: '0 volume', one: '1 volume', other: '${readed} volumes')} read over ${Intl.plural(total, zero: '0 volume', one: '1 volume', other: '${total} volumes')}.";

  static String m22(readed, total) =>
      "${Intl.plural(readed, zero: '0 volume', one: '1 volume', other: '${readed} volumes')} read over ${Intl.plural(total, zero: '0 volume', one: '1 volume', other: '${total} volumes')} you own.";

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
    "allVolumesOwned": MessageLookupByLibrary.simpleMessage(
      "You own all the volumes of your collection.",
    ),
    "allVolumesReaded": MessageLookupByLibrary.simpleMessage(
      "You have read all the volumes you own.",
    ),
    "alphabeticalOrder": MessageLookupByLibrary.simpleMessage(
      "Alphabetical Order",
    ),
    "alreadyHaveAnAccount": MessageLookupByLibrary.simpleMessage(
      "Already have an account?",
    ),
    "appVersionAndAppBuildVersion": m1,
    "applicableLawAndCompetentJurisdiction":
        MessageLookupByLibrary.simpleMessage(
          "Applicable Law and Competent Jurisdiction",
        ),
    "applicableLawAndCompetentJurisdictionLane1":
        MessageLookupByLibrary.simpleMessage(
          "These legal notices are subject to French law. In the event of a dispute, the French courts will have sole jurisdiction.",
        ),
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
    "authorRights": MessageLookupByLibrary.simpleMessage("Author Rights"),
    "authorRightsLane1": MessageLookupByLibrary.simpleMessage(
      "MyMangatheque and its content (texts, images, videos, etc.) are protected by intellectual property laws in force in France. Any reproduction, representation, modification, publication, or adaptation of all or part of the elements of the site, regardless of the means or process used, is prohibited without prior written authorization or for personal use as a code challenge but without publication.",
    ),
    "authors": MessageLookupByLibrary.simpleMessage("Authors"),
    "availability": m2,
    "birthdayDateIs": m3,
    "boxSet": MessageLookupByLibrary.simpleMessage("Box Set"),
    "buildAppVersionImpossibleToRetreive": MessageLookupByLibrary.simpleMessage(
      "Impossible to retrieve the build and app version.",
    ),
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
    "completeLibrary": MessageLookupByLibrary.simpleMessage("Complete"),
    "confirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm New Password",
    ),
    "confirmYourPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm Your Password",
    ),
    "contact": MessageLookupByLibrary.simpleMessage("Contact"),
    "contactLane1": MessageLookupByLibrary.simpleMessage(
      "For any questions or complaints, please contact us at one of the following email addresses: mymangatheque@gmail.com or contact@mymangatheque.com .",
    ),
    "contactRightsAndUpdateDate": MessageLookupByLibrary.simpleMessage(
      "Contact, Rights and Update Date",
    ),
    "contentOfBoxSet": MessageLookupByLibrary.simpleMessage(
      "Content of Box Set",
    ),
    "cookieUsage": MessageLookupByLibrary.simpleMessage("Cookie Usage"),
    "cookieUsageLane1": MessageLookupByLibrary.simpleMessage(
      "The user is informed that when visiting the Site, a cookie may be automatically installed on their browser software. A cookie consists of a block of data that does not allow the user to be identified but allows information relating to the user\'s navigation on the Site to be recorded in order to carry out analyses of Site traffic, all with the aim of improving the quality of the Site.",
    ),
    "cookieUsageLane2": MessageLookupByLibrary.simpleMessage(
      "The user has the right to access, rectify or delete personal data communicated via a cookie under the conditions indicated above.",
    ),
    "createAccount": MessageLookupByLibrary.simpleMessage("Create an Account"),
    "createAuthor": MessageLookupByLibrary.simpleMessage("Create Author"),
    "createGenre": MessageLookupByLibrary.simpleMessage("Create Genre"),
    "createVolume": MessageLookupByLibrary.simpleMessage("Create Volume"),
    "dangerZone": MessageLookupByLibrary.simpleMessage("Danger Zone"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "dataUndercase": MessageLookupByLibrary.simpleMessage("data"),
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
    "desiredLibrary": MessageLookupByLibrary.simpleMessage("Desired"),
    "discover": MessageLookupByLibrary.simpleMessage("Discover"),
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
    "errorInitializing": m6,
    "errorOccurred": MessageLookupByLibrary.simpleMessage(
      "An error occurred, please try again later.",
    ),
    "externalLinks": MessageLookupByLibrary.simpleMessage("External Links"),
    "externalLinksLane1": MessageLookupByLibrary.simpleMessage(
      "The MyMangatheque website may contain links to external sites. We are not responsible for the content and privacy practices of these sites. These links are provided as a service to users of the Site or the websites of its subsidiaries and affiliated entities. The decision to activate links is solely up to the users.",
    ),
    "favorite": MessageLookupByLibrary.simpleMessage("Favorite"),
    "favoriteSeriesNumber": m7,
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
    "intellectualProperty": MessageLookupByLibrary.simpleMessage(
      "Intellectual Property",
    ),
    "invalidEmail": MessageLookupByLibrary.simpleMessage(
      "The email address is invalid.",
    ),
    "isbn": MessageLookupByLibrary.simpleMessage("ISBN"),
    "italian": MessageLookupByLibrary.simpleMessage("Italian"),
    "january": MessageLookupByLibrary.simpleMessage("January"),
    "japanese": MessageLookupByLibrary.simpleMessage("Japanese"),
    "jobsName": m8,
    "july": MessageLookupByLibrary.simpleMessage("July"),
    "june": MessageLookupByLibrary.simpleMessage("June"),
    "lastRelease": MessageLookupByLibrary.simpleMessage("Last Release"),
    "lastUpdateDate": MessageLookupByLibrary.simpleMessage("Last Update Date"),
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
    "maxLengthExceeded": m9,
    "may": MessageLookupByLibrary.simpleMessage("May"),
    "minLengthNotReached": m10,
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
    "openScan": MessageLookupByLibrary.simpleMessage("Open Scan"),
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
    "personalData": MessageLookupByLibrary.simpleMessage("Personal Data"),
    "pleaseConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "Please confirm your password",
    ),
    "pleaseSelectDate": MessageLookupByLibrary.simpleMessage(
      "Please select a date",
    ),
    "pleaseWait": MessageLookupByLibrary.simpleMessage("Please wait..."),
    "preamble": MessageLookupByLibrary.simpleMessage("Preamble"),
    "preambleLane1": MessageLookupByLibrary.simpleMessage(
      "The information and recommendations (\"Information\") available on this website (also known as \"the Site\") are offered to you in good faith. This information is believed to be correct at the time you read it. However, MyMangatheque or its subsidiaries and affiliated entities do not guarantee the completeness and accuracy of the Information. You assume full risk of relying on it.",
    ),
    "preambleLane2": MessageLookupByLibrary.simpleMessage(
      "The Information is provided to you on the condition that you, or any other person reviewing it, may determine its suitability for a specific purpose before using it. Under no circumstances shall MyMangatheque or its subsidiaries and affiliated entities be liable for any damages that may result from the reliance on this information, its use, or the use of any product to which it refers.",
    ),
    "preambleLane3": MessageLookupByLibrary.simpleMessage(
      "The Information should not be construed as recommendations for the use of any information, product, procedure, equipment or formulation that would be inconsistent with any patent, copyright or trademark.",
    ),
    "preambleLane4": MessageLookupByLibrary.simpleMessage(
      "MyMangatheque or its subsidiaries and affiliated entities shall not be liable if the use of the Information infringes any patent, trademark or, more generally, any intellectual property right.",
    ),
    "preambleLane5": MessageLookupByLibrary.simpleMessage(
      "No warranty, express or implied, is given as to the merchantability of the information provided, nor as to its suitability for a particular purpose, nor as to the products referred to in this information.",
    ),
    "preambleLane6": MessageLookupByLibrary.simpleMessage(
      "Under no circumstances do MyMangatheque or its subsidiaries and affiliated entities undertake to update or correct the Information that will be disseminated by them on the Internet or on their web servers. Similarly, MyMangatheque or its subsidiaries and affiliated entities reserve the right to modify or correct the content of their sites at any time and without notice.",
    ),
    "price": MessageLookupByLibrary.simpleMessage("Price"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileSettings": MessageLookupByLibrary.simpleMessage(
      "Profile & Settings Page",
    ),
    "pronoun": m11,
    "protectionOfPersonalData": MessageLookupByLibrary.simpleMessage(
      "Protection of Personal Data",
    ),
    "protectionOfPersonalDataLane1": MessageLookupByLibrary.simpleMessage(
      "Your personal data is intended solely for MyMangatheque. It will under no circumstances be communicated to third parties. In accordance with the rules on the protection of personal data (Article 34 of the French Data Protection Act of 6 January 1978, Directives 95/46 and 97/66), you have the right to access, rectify, and delete data concerning you. To exercise this right, to object to receiving any commercial messages, or for any rectification, please contact us by email, available in the contact section.",
    ),
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
    "readPile": MessageLookupByLibrary.simpleMessage("Read Pile"),
    "readed": MessageLookupByLibrary.simpleMessage("Readed"),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "scanEAN": MessageLookupByLibrary.simpleMessage("Scan EAN"),
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
    "seriesCount": m12,
    "seriesDoesNotExist": MessageLookupByLibrary.simpleMessage(
      "The series does not exist.",
    ),
    "seriesIdOfAuthor": MessageLookupByLibrary.simpleMessage(
      "Series ID of the Author",
    ),
    "shippingUnderDays": m13,
    "shippingUnderWeeks": m14,
    "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
    "signInPage": MessageLookupByLibrary.simpleMessage("Sign In Page"),
    "signUp": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "signUpPage": MessageLookupByLibrary.simpleMessage("Sign Up Page"),
    "soldAndShippedBy": m15,
    "spanish": MessageLookupByLibrary.simpleMessage("Spanish"),
    "subSeries": MessageLookupByLibrary.simpleMessage("Sub-Series"),
    "subSeriesDoesNotExist": MessageLookupByLibrary.simpleMessage(
      "The sub-series does not exist.",
    ),
    "summary": MessageLookupByLibrary.simpleMessage("Summary"),
    "supportIs": m16,
    "systemMode": MessageLookupByLibrary.simpleMessage("System Mode"),
    "thirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "Third-Party Content",
    ),
    "thirdPartyContentLane1": MessageLookupByLibrary.simpleMessage(
      "Third-party content used on the MyMangatheque site belongs to their respective author.",
    ),
    "userContent": MessageLookupByLibrary.simpleMessage("User Content"),
    "userContentLane1": MessageLookupByLibrary.simpleMessage(
      "The User is solely responsible for the User Content that he/she posts online via the Service, as well as the texts and/or opinions that he/she expresses. The User expressly and graciously assigns to MyMangatheque all intellectual property rights relating thereto, including the right of reproduction, representation and adaptation, for the legal duration of copyright protection. He/she undertakes in particular to ensure that this data is not of a nature to harm the legitimate interests of any third party whatsoever. In this respect, he/she guarantees MyMangatheque against any action, based directly or indirectly on these comments and/or data, that may be brought by anyone against MyMangatheque. He/she undertakes in particular to take charge of the payment of any sums resulting from the action of a third party against MyMangatheque, including lawyers\' fees and court costs.",
    ),
    "userContentLane2": MessageLookupByLibrary.simpleMessage(
      "MyMangatheque reserves the right to remove all or part of the User Content, at any time and for any reason, without prior warning or justification. The User may not make any claim in this regard.",
    ),
    "userContentLane3": MessageLookupByLibrary.simpleMessage(
      "MyMangatheque collects and processes personal data in compliance with current regulations, in particular the General Data Protection Regulation (GDPR).",
    ),
    "userLoginFailed": MessageLookupByLibrary.simpleMessage(
      "An error occurred, you have not been connected to your account.",
    ),
    "userLoginSuccess": MessageLookupByLibrary.simpleMessage(
      "You have successfully logged in.",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "usernameIs": m17,
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
    "volumeNum": m18,
    "volumeNumber": MessageLookupByLibrary.simpleMessage("Volume Number"),
    "volumeOwnedNumber": m19,
    "volumeOwnedOverX": m20,
    "volumePrice": MessageLookupByLibrary.simpleMessage("Volume Price"),
    "volumeReadedOverSeriesX": m21,
    "volumeReadedOverX": m22,
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
    "zeroVolumesOwned": MessageLookupByLibrary.simpleMessage(
      "You own 0 volumes.",
    ),
  };
}
