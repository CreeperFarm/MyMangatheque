class Assets {
  Assets._();

  // Expose `Assets.logo.<name>`
  static const logo = _Logo(
    'assets/logo/logo.jpg',
    'assets/logo/logo_app.png',
    'assets/logo/logo_nobg.png',
    'assets/logo/logow_nobg.png',
    'assets/logo/logo_foreground.png',
  );

  // Expose `Assets.images.<name>`
  static const images = _Images(
    _Theme(
      'assets/images/theme/auto-icon.png',
      'assets/images/theme/dark-icon.png',
      'assets/images/theme/light-icon.png',
    ),
    'assets/images/splash_bg.png',
    'assets/images/google.png',
    'assets/images/apple.png',
    'assets/images/unknown.webp',
    'assets/images/fr.png',
    'assets/images/us.png',
  );

  // Expose `Assets.icons.<name>`
  static const icons = _Icons(
    'assets/icons/arrow-down.svg',
    'assets/icons/arrow-up.svg',
    'assets/icons/arrow-left.svg',
    'assets/icons/arrow-right.svg',
    'assets/icons/book-open.svg',
    'assets/icons/barcode.svg',
    'assets/icons/calendar.svg',
    'assets/icons/calendar-active.svg',
    'assets/icons/collection.svg',
    'assets/icons/collection-active.svg',
    'assets/icons/delete.svg',
    'assets/icons/filter-right.svg',
    'assets/icons/home.svg',
    'assets/icons/home-active.svg',
    'assets/icons/lock.svg',
    'assets/icons/lock-forgot.svg',
    'assets/icons/locker.svg',
    'assets/icons/logout.svg',
    'assets/icons/news.svg',
    'assets/icons/search.svg',
    'assets/icons/search-active.svg',
    'assets/icons/shopping-cart.svg',
    'assets/icons/trash.svg',
    'assets/icons/user.svg',
    'assets/icons/user-active.svg',
  );

  // Expose `Assets.videos.<name>`
  static const videos = _Videos('assets/videos/bad-apple.mp4');
}

// Private class that holds the actual asset paths as final fields and supports const construction.
class _Logo {
  final String whiteAndBlueToneSquare;
  final String blueToneAndWhiteSquare;
  final String blueToneTransparentSquare;
  final String whiteTransparentSquare;
  final String blueToneTransparentForeground;

  const _Logo(
    this.whiteAndBlueToneSquare,
    this.blueToneAndWhiteSquare,
    this.blueToneTransparentSquare,
    this.whiteTransparentSquare,
    this.blueToneTransparentForeground,
  );
}

class _Images {
  final _Theme theme;
  final String splashBg;
  final String google;
  final String apple;
  final String unknown;
  final String fr;
  final String us;

  const _Images(
    this.theme,
    this.splashBg,
    this.google,
    this.apple,
    this.unknown,
    this.fr,
    this.us,
  );
}

class _Theme {
  final String autoIcon;
  final String darkIcon;
  final String lightIcon;

  const _Theme(this.autoIcon, this.darkIcon, this.lightIcon);
}

class _Icons {
  final String arrowDown;
  final String arrowUp;
  final String arrowLeft;
  final String arrowRight;
  final String bookOpen;
  final String barcode;
  final String calendar;
  final String calendarActive;
  final String collection;
  final String collectionActive;
  final String delete;
  final String filterRight;
  final String home;
  final String homeActive;
  final String lock;
  final String lockForgot;
  final String locker;
  final String logOut;
  final String news;
  final String search;
  final String searchActive;
  final String shoppingCart;
  final String trash;
  final String user;
  final String userActive;

  const _Icons(
    this.arrowDown,
    this.arrowUp,
    this.arrowLeft,
    this.arrowRight,
    this.bookOpen,
    this.barcode,
    this.calendar,
    this.calendarActive,
    this.collection,
    this.collectionActive,
    this.delete,
    this.filterRight,
    this.home,
    this.homeActive,
    this.lock,
    this.lockForgot,
    this.locker,
    this.logOut,
    this.news,
    this.search,
    this.searchActive,
    this.shoppingCart,
    this.trash,
    this.user,
    this.userActive,
  );
}

class _Videos {
  final String badApple;

  const _Videos(this.badApple);
}
