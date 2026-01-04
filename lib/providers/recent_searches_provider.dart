import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/music_data.dart';

class RecentSearchesNotifier extends StateNotifier<List<MusicData>> {
  RecentSearchesNotifier() : super([]);

  void add(MusicData data) {
    if (!state.any((item) => item.url == data.url)) {
      state = [...state, data];
    }
  }

  void remove(MusicData data) {
    state = state.where((item) => item.url != data.url).toList();
  }
}

final recentSearchesProvider = StateNotifierProvider<RecentSearchesNotifier, List<MusicData>>((ref) => RecentSearchesNotifier());
