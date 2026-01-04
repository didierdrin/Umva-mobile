import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/music_data.dart';
import '../services/audio_handler.dart';
import '../globals.dart';

class PlayerNotifier extends StateNotifier<PlayerState> {
  PlayerNotifier() : super(const PlayerState());

  void init(MusicData song) async {
    await audioHandler.loadAndPlay(song);
    state = state.copyWith(isPlaying: true, currentUrl: song.url);
  }

  void playPause() {
    if (state.isPlaying) {
      audioHandler.pause();
    } else {
      audioHandler.play();
    }
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void seek(Duration position) {
    audioHandler.seek(position);
  }

  void dispose() {
    audioHandler.stop();
  }
}

class PlayerState {
  final bool isPlaying;
  final String? currentUrl;

  const PlayerState({this.isPlaying = false, this.currentUrl});

  PlayerState copyWith({bool? isPlaying, String? currentUrl}) => PlayerState(
    isPlaying: isPlaying ?? this.isPlaying,
    currentUrl: currentUrl ?? this.currentUrl,
  );
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>(
  (ref) => PlayerNotifier(),
);
