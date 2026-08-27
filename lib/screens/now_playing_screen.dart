import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '../models/music_data.dart';
import '../providers/player_provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/text_styles.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text('Now Playing', style: headingStyle(context).copyWith(color: Colors.white)),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred, darkened backdrop echoing the album art behind it.
          Image.network(widget.song.image, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: StreamBuilder<MediaState>(
                stream: _mediaStateStream,
                builder: (context, snapshot) {
                  final mediaState = snapshot.data;
                  final duration = mediaState?.mediaItem?.duration ?? Duration.zero;
                  final position = mediaState?.position ?? Duration.zero;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: widget.song.heroTag,
                        child: Container(
                          height: 300,
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(blurRadius: 30, color: Colors.black.withOpacity(0.5), offset: const Offset(0, 12))],
                            image: DecorationImage(image: NetworkImage(widget.song.image), fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        widget.song.title,
                        style: subHeadingStyle(context).copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.song.channelTitle,
                        style: captionStyle(context).copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                          overlayColor: Colors.white24,
                        ),
                        child: Slider(
                          value: position.inSeconds.clamp(0, duration.inSeconds).toDouble(),
                          max: duration.inSeconds.toDouble().clamp(1, double.infinity),
                          onChanged: (value) => playerNotifier.seek(Duration(seconds: value.toInt())),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position), style: const TextStyle(color: Colors.white70)),
                            Text(_formatDuration(duration), style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 32,
                            color: Colors.white,
                            icon: const Icon(Icons.fast_rewind),
                            onPressed: () => playerNotifier.seek(position - const Duration(seconds: 10)),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: IconButton(
                              iconSize: 40,
                              color: Colors.black,
                              icon: Icon(playerState.isPlaying ? Icons.pause : Icons.play_arrow),
                              onPressed: playerNotifier.playPause,
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            iconSize: 32,
                            color: Colors.white,
                            icon: const Icon(Icons.fast_forward),
                            onPressed: () => playerNotifier.seek(position + const Duration(seconds: 10)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      IconButton(
                        iconSize: 28,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Theme.of(context).primaryColor : Colors.white,
                        ),
                        onPressed: () => ref.read(favoritesProvider.notifier).toggle(widget.song),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
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
