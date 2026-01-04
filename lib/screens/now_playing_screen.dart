import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '../models/music_data.dart';
import '../providers/player_provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/text_styles.dart';
import '../services/audio_handler.dart';
import '../globals.dart'; 

class NowPlayingScreen extends ConsumerStatefulWidget {
  final MusicData song;

  const NowPlayingScreen({super.key, required this.song});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(playerProvider.notifier).init(widget.song);
  }

  @override
  void dispose() {
    ref.read(playerProvider.notifier).dispose();
    super.dispose();
  }

  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
        audioHandler.mediaItem.stream,
        AudioService.position,
        (mediaItem, position) => MediaState(mediaItem, position),
      );

  @override
  Widget build(BuildContext context) {
    final playerNotifier = ref.read(playerProvider.notifier);
    final playerState = ref.watch(playerProvider);
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.any((f) => f.url == widget.song.url);

    return Scaffold(
      appBar: AppBar(title: Text('Now Playing', style: headingStyle(context))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<MediaState>(
          stream: _mediaStateStream,
          builder: (context, snapshot) {
            final mediaState = snapshot.data;
            final duration = mediaState?.mediaItem?.duration ?? Duration.zero;
            final position = mediaState?.position ?? Duration.zero;

            return Column(
              children: [
                // Album art
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(widget.song.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.song.title,
                  style: subHeadingStyle(context),
                  textAlign: TextAlign.center,
                ),
                Text(
                  widget.song.channelTitle,
                  style: captionStyle(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.fast_rewind),
                      onPressed: () => playerNotifier.seek(
                        position - const Duration(seconds: 10),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                      onPressed: playerNotifier.playPause,
                    ),
                    IconButton(
                      icon: const Icon(Icons.fast_forward),
                      onPressed: () => playerNotifier.seek(
                        position + const Duration(seconds: 10),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: position.inSeconds.toDouble(),
                  max: duration.inSeconds.toDouble(),
                  onChanged: (value) =>
                      playerNotifier.seek(Duration(seconds: value.toInt())),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(position)),
                    Text(_formatDuration(duration)),
                  ],
                ),
                const SizedBox(height: 16),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () =>
                      ref.read(favoritesProvider.notifier).toggle(widget.song),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration d) =>
      '${d.inMinutes.remainder(60)}:${(d.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}
