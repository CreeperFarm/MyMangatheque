import 'package:get_it/get_it.dart';
import 'package:mymangatheque/src/local_storage/local_storage.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<LocalStorage>(() => LocalStorage());
}
