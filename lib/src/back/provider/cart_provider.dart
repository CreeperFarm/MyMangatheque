import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/src/models/manga/volume.dart';

class CartNotifier extends Notifier<Set<Volume>> {
  @override
  Set<Volume> build() => {};

  // Add a volume to the cart
  void addVolumeToCart(Volume volume) {
    // Prevent duplicates
    if (!state.contains(volume)) {
      state.add(volume);
    }
  }

  // Remove a volume from the cart
  void removeVolumeToCart(Volume volume) {
    // Prevent errors
    if (state.contains(volume)) {
      state.remove(volume);
    }
  }

  void clear() {
    state.clear();
  }
}

final cartProvider = NotifierProvider<CartNotifier, Set<Volume>>(() {
  return CartNotifier();
});
