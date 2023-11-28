import 'package:flutter_riverpod/flutter_riverpod.dart';

//TODO: Create a provider for manga owned and get the data from firebase into a list
class MangaOwned extends Notifier<int> {
  @override
  int build() => 0;

  void incrementer() {
    state = state + 1;
  }
}

final mangaOwnedProvider = NotifierProvider<MangaOwned, int>(MangaOwned.new);
