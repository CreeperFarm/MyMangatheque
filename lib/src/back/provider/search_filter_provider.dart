import 'package:riverpod/riverpod.dart';

class SearchFilterNotifier extends Notifier<String> {
  @override
  String build() => 'manga';

  void changeSearchFilter(String newSearchFilter) {
    state = newSearchFilter;
  }
}

final searchFilterProvider = NotifierProvider<SearchFilterNotifier, String>(() {
  return SearchFilterNotifier();
});
