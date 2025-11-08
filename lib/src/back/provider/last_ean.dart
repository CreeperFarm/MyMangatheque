import 'package:riverpod/riverpod.dart';

class LastEANNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setLastEAN(String ean) {
    state = ean;
  }

  void clearLastEAN() {
    state = '';
  }
}

final lastEANProvider = NotifierProvider<LastEANNotifier, String>(() {
  return LastEANNotifier();
});
