import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompteurProvider extends Notifier<int> {
  @override
  int build() => 0;

  void incrementer() {
    state = state + 1;
  }
}

final compteurProvider = NotifierProvider<CompteurProvider, int>(CompteurProvider.new);
