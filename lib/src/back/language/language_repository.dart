import 'package:mymangatheque/src/back/language/language.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';
import 'package:mymangatheque/src/models/local_storage/service_locator.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageRepository {
  LanguageRepository({required this.ref});

  final Ref ref;
  final storage = getIt<LocalStorage>();

  Future<void> setLanguage(Language language) async {
    storage.setLanguageCode(language.code);
    ref.read(languageProvider.notifier).update((_) => language);
  }

  Future<Language> getLanguage() async {
    final languageCode = await storage.getLanguageCode();
    if (languageCode == null) {
      final defaultLanguage = ref.read(languageProvider);
      ref.read(languageProvider.notifier).update((_) => defaultLanguage);
      return defaultLanguage;
    }
    return _getLanguageFromCode(languageCode);
  }

  Language _getLanguageFromCode(String code) {
    for (var language in Language.values) {
      if (language.code == code) {
        ref.read(languageProvider.notifier).update((_) => language);
        return language;
      }
    }
    return Language.english; // Fallback to English if no match found
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) => SharedPreferences.getInstance());

final languageRepositoryProvider = Provider<LanguageRepository>((ref) => LanguageRepository(ref: ref));
