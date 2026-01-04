import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/music_data.dart';

class FavoritesNotifier extends StateNotifier<List<MusicData>> {
  FavoritesNotifier() : super([]);

  void toggle(MusicData data) {
    if (state.any((item) => item.url == data.url)) {
      state = state.where((item) => item.url != data.url).toList();
    } else {
      state = [...state, data.copyWith(favorite: true)];
    }
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<MusicData>>((ref) => FavoritesNotifier());
