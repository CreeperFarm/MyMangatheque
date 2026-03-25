class Routes {
  Routes._();

  static const String home = '/';
  static const String library = '/library';
  static const String search = '/search';
  static const String deleteAccount = '/delete_account';

  // Expose the profile routes as a nested const for better organization
  static const profile = _Profile(
    '/profile',
    signin: '/profile/signin',
    signup: '/profile/signup',
    forgotPassword: '/profile/forgot_password',
    modifyPassword: '/profile/modify_password',
    legalNotice: '/profile/legal_notice',
  );

  // Expose the library routes as a nested object for better organization
  static final libraryRoutes = _Library(
    subserie: (String id) => '/library/sub_serie/$id',
    editor: (String id) => '/library/editor/$id',
    author: (String id) => '/library/author/$id',
    serie: (String id) => '/library/serie/$id',
    volume: (String id) => '/library/volume/$id',
  );

  // Convenience static methods for older call sites
  static String librarySubSerie(String id) => libraryRoutes.subserie(id);
  static String libraryEditor(String id) => libraryRoutes.editor(id);
  static String libraryAuthor(String id) => libraryRoutes.author(id);
  static String librarySerie(String id) => libraryRoutes.serie(id);
  static String libraryVolume(String id) => libraryRoutes.volume(id);
}

class _Profile {
  final String base;
  final String signin;
  final String signup;
  final String forgotPassword;
  final String modifyPassword;
  final String legalNotice;

  const _Profile(
    this.base, {
    required this.signin,
    required this.signup,
    required this.forgotPassword,
    required this.modifyPassword,
    required this.legalNotice,
  });
}

class _Library {
  final String Function(String id) subserie;
  final String Function(String id) editor;
  final String Function(String id) author;
  final String Function(String id) serie;
  final String Function(String id) volume;

  const _Library({
    required this.subserie,
    required this.editor,
    required this.author,
    required this.serie,
    required this.volume,
  });
}
