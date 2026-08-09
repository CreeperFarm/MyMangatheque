import 'package:riverpod/riverpod.dart';

class SearchOrderNotifier extends Notifier<String> {
  @override
  String build() => 'manga';

  void changeSearchOrder(String newSearchOrder) {
    state = newSearchOrder;
  }
}

final searchOrderProvider = NotifierProvider<SearchOrderNotifier, String>(() {
  return SearchOrderNotifier();
});
