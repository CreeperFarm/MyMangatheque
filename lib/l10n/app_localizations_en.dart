// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get spanish => 'Spanish';

  @override
  String get italian => 'Italian';

  @override
  String get german => 'German';

  @override
  String get japanese => 'Japanese';

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
  String get passwordTooShort =>
      'The password must be at least 6 characters long.';

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
  String get logInWithGoogle => 'Log In with Google';

  @override
  String get logInWithApple => 'Log In with Apple';

  @override
  String get logInSuccess => 'You have successfully logged in.';

  @override
  String get logInFailed =>
      'An error occurred, you have not been connected to your account.';

  @override
  String get logOut => 'Log Out';

  @override
  String get logOutSuccess => 'You have successfully logged out.';

  @override
  String get logOutFailed => 'An error occurred, you have not been logged out.';

  @override
  String minLengthNotReached(num minLength) {
    final intl.NumberFormat minLengthNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String minLengthString = minLengthNumberFormat.format(minLength);

    return 'The minimum required number of characters is $minLengthString.';
  }

  @override
  String maxLengthExceeded(num maxLength) {
    final intl.NumberFormat maxLengthNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String maxLengthString = maxLengthNumberFormat.format(maxLength);

    return 'The maximum allowed number of characters is $maxLengthString.';
  }

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
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheSuccess => 'Cache successfully cleared.';

  @override
  String get modifyPassword => 'Modify Password';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get deleteAccountSuccess =>
      'Your account has been successfully deleted.';

  @override
  String get deleteAccountFailed =>
      'An error occurred, your account has not been deleted, you have been log out of your account.';

  @override
  String appVersionAndAppBuildVersion(String appVersion, String buildVersion) {
    return 'App Version: $appVersion & Build Version: $buildVersion';
  }

  @override
  String volumeNum(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Volume $countString';
  }

  @override
  String get owned => 'Owned';

  @override
  String get volume => 'Volume';

  @override
  String get series => 'Series';

  @override
  String get edition => 'Edition';

  @override
  String get author => 'Author';

  @override
  String get publisher => 'Publisher';

  @override
  String get publicationDate => 'Publication Date';

  @override
  String get isbn => 'ISBN';

  @override
  String get scanner => 'Scanner';

  @override
  String get scannerDescription =>
      'Scan the barcode of your volume to add it to your collection.';

  @override
  String get createAuthor => 'Create Author';

  @override
  String get authorName => 'Author Name';

  @override
  String get provideAuthorName => 'Please provide the author\'s name';

  @override
  String get authorJobs => 'Author Jobs (separated by commas)';

  @override
  String get provideAuthorJobs =>
      'Please provide the author\'s jobs (separated by commas)';

  @override
  String get seriesIdOfAuthor => 'Series ID of the Author';

  @override
  String get provideSeriesIdOfAuthor =>
      'Please provide the series ID(s) of the author';

  @override
  String get authorAdd => 'Add Author';

  @override
  String get authorAddSuccess => 'Author successfully added.';

  @override
  String get authorDuplicate => 'An author with this name already exists.';

  @override
  String get createGenre => 'Create Genre';

  @override
  String get genreName => 'Genre Name';

  @override
  String get provideGenreName => 'Please provide the genre name';

  @override
  String get genreAdd => 'Add Genre';

  @override
  String get genreAddSuccess => 'Genre successfully added.';

  @override
  String get genreDuplicate => 'A genre with this name already exists.';

  @override
  String get createVolume => 'Create Volume';

  @override
  String get volumeTitle => 'Volume Title';

  @override
  String get provideVolumeTitle => 'Please provide the volume title';

  @override
  String get volumeNumber => 'Volume Number';

  @override
  String get provideVolumeNumber => 'Please provide the volume number';

  @override
  String get volumeEAN => 'EAN of the Volume';

  @override
  String get provideVolumeEAN => 'Please provide the EAN of the volume';

  @override
  String get volumePrice => 'Volume Price';

  @override
  String get provideVolumePrice => 'Please provide the price of the volume';

  @override
  String get volumeSummary => 'Volume Summary';

  @override
  String get provideVolumeSummary => 'Please provide the summary of the volume';

  @override
  String get volumeLink => 'Volume Link';

  @override
  String get provideVolumeLink => 'Please provide the link of the volume';

  @override
  String get volumeInfo => 'Volume Information';

  @override
  String get provideVolumeInfo =>
      'Please provide the information about the volume';

  @override
  String get adultContent => 'Adult Content';

  @override
  String get adultContentWarning => 'Warning: Adult Content';

  @override
  String get volumeLanguage => 'Volume Language';

  @override
  String get chooseVolumeLanguage => 'Please choose the language of the volume';

  @override
  String get manga => 'Manga';

  @override
  String get novel => 'Novel';

  @override
  String get artbook => 'Artbook';

  @override
  String get lightNovel => 'Light Novel';

  @override
  String get boxSet => 'Box Set';

  @override
  String get other => 'Other';

  @override
  String supportIs(String support) {
    String _temp0 = intl.Intl.selectLogic(
      support,
      {
        'manga': 'Manga',
        'novel': 'Novel',
        'artbook': 'Artbook',
        'lightNovel': 'Light Novel',
        'boxSet': 'Box Set',
        'other': 'Other',
      },
    );
    return '$_temp0';
  }

  @override
  String get volumeSupport => 'Volume Support';

  @override
  String get chooseVolumeSupport => 'Please choose the support of the volume';

  @override
  String get selectDate => 'Select Date';

  @override
  String get pleaseSelectDate => 'Please select a date';

  @override
  String get volumeSeriesId => 'Volume Series ID';

  @override
  String get provideVolumeSeriesId =>
      'Please provide the series ID of the volume';

  @override
  String get provideValidVolumeSeriesId =>
      'Please provide a valid series ID for the volume';

  @override
  String get volumeSubSeriesId => 'Volume Sub-Series ID';

  @override
  String get provideVolumeSubSeriesId =>
      'Please provide the sub-series ID of the volume';

  @override
  String get provideValidVolumeSubSeriesId =>
      'Please provide a valid sub-series ID for the volume';

  @override
  String get volumeEditorId => 'Volume Editor ID';

  @override
  String get provideVolumeEditorId =>
      'Please provide the editor ID of the volume';

  @override
  String get provideValidVolumeEditorId =>
      'Please provide a valid editor ID for the volume';

  @override
  String get volumeAuthorsIds => 'Volume Authors IDs';

  @override
  String get provideVolumeAuthorsIds =>
      'Please provide the author IDs of the volume';

  @override
  String get contentOfBoxSet => 'Content of Box Set';

  @override
  String get provideContentOfBoxSet =>
      'Please provide the content of the box set';

  @override
  String get volumeAdd => 'Add Volume';

  @override
  String get volumeAddSuccess => 'Volume successfully added.';

  @override
  String get volumeAddError =>
      'An error occurred, the volume has not been added.';

  @override
  String get subSeries => 'Sub-Series';

  @override
  String get editor => 'Editor';

  @override
  String get genre => 'Genre';

  @override
  String get adminHomePage => 'Admin Home Page';

  @override
  String get adminHomePageDescription =>
      'Welcome on the admin home page. This is the admin home page where you can manage authors, genres, and volumes.';

  @override
  String get adminLoginPage => 'Admin Login Page';

  @override
  String get yourEmail => 'Your Email';

  @override
  String get provideYourEmail => 'Please provide your email';

  @override
  String get yourPassword => 'Your Password';

  @override
  String get provideYourPassword => 'Please provide your password';

  @override
  String get adminLoginSuccess =>
      'You have successfully logged in as an admin.';

  @override
  String get passwordForgot => 'Forgot Password?';

  @override
  String get passwordReset => 'Password Reset';

  @override
  String get enterEmailForSendingEmailReset =>
      'Enter your email to receive a link to reset your password.';

  @override
  String get accountEmail => 'Email of the Account';

  @override
  String get provideAccountEmail => 'Please provide the email of the account';

  @override
  String get provideValidAccountEmail => 'Please provide a valid account email';

  @override
  String get oldPassword => 'Old Password';

  @override
  String get provideOldPassword => 'Please provide your old password';

  @override
  String get newPassword => 'New Password';

  @override
  String get provideNewPassword => 'Please provide your new password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get provideConfirmNewPassword => 'Please confirm your new password';

  @override
  String get passwordsDoNotMatch =>
      'The new password and confirmation do not match.';

  @override
  String get signInPage => 'Sign In Page';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUpPage => 'Sign Up Page';

  @override
  String get signUp => 'Sign Up';

  @override
  String get whyLogInDescription =>
      'Log in to access your collection, manage your profile, and enjoy personalized features.';

  @override
  String get whySignUpDescription =>
      'Create an account to start building your collection, track your favorite series, and connect with other manga enthusiasts.';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get createAccount => 'Create an Account';

  @override
  String get noAccountYet => 'Don\'t have an account yet?';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get passwordMinLength =>
      'Password must be at least 8 characters long.';

  @override
  String get usernameMinLength =>
      'Username must be at least 3 characters long.';

  @override
  String get username => 'Username';

  @override
  String get provideUsername => 'Please provide your username';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get confirmYourPassword => 'Confirm Your Password';

  @override
  String get yourBirthday => 'Your Birthday';

  @override
  String get provideYourBirthday => 'Please provide your birthday';

  @override
  String get yourGender => 'Your gender';

  @override
  String get provideYourGender => 'Please provide your gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingData => 'Loading data, please wait...';

  @override
  String get noConnection => 'No connection';

  @override
  String jobsName(String job) {
    String _temp0 = intl.Intl.selectLogic(
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
      other: 'Series',
      one: 'Series',
      zero: 'Series',
    );
    return '$_temp0';
  }

  @override
  String get authorDoesNotExist => 'The author does not exist.';

  @override
  String get seriesDoesNotExist => 'The series does not exist.';

  @override
  String get subSeriesDoesNotExist => 'The sub-series does not exist.';

  @override
  String get volumeDoesNotExist => 'The volume does not exist.';

  @override
  String get editorDoesNotExist => 'The editor does not exist.';

  @override
  String get genres => 'Genres';

  @override
  String get editors => 'Editors';

  @override
  String get authors => 'Authors';

  @override
  String get volumes => 'Volumes';

  @override
  String get follow => 'Follow';

  @override
  String get followed => 'Followed';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get read => 'Read';

  @override
  String get readed => 'Readed';

  @override
  String get summary => 'Summary';

  @override
  String get seeMore => 'See More';

  @override
  String get seeLess => 'See Less';

  @override
  String get volumeNotAvailableAnymore =>
      'Sadly, this volume is no longer available.';

  @override
  String get volumeNotAvailableForSale =>
      'This volume is not available for sale.';

  @override
  String get price => 'Price';

  @override
  String availability(String availability) {
    String _temp0 = intl.Intl.selectLogic(
      availability,
      {
        'inStock': 'In Stock',
        'available': 'Available',
        'unavailable': 'Unavailable',
        'onPreorder': 'On Preorder',
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

    return 'Shipping under $daysString days';
  }

  @override
  String shippingUnderWeeks(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '0': '0 weeks',
        '1': '1 week',
        'other': '$count weeks',
      },
    );
    return 'Shipping under $_temp0';
  }

  @override
  String soldAndShippedBy(String seller) {
    return 'Sold and shipped by $seller';
  }

  @override
  String buyOn(String store) {
    return 'Buy on $store';
  }

  @override
  String get informations => 'Informations';

  @override
  String get ean => 'EAN';

  @override
  String get numberOfPages => 'Number of Pages';
}
