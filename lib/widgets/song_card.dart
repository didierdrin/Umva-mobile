// lib/widgets/song_card.dart
//
// Single reusable song row used by LibraryScreen, SearchScreen and
// SearchResultsScreen (previously three near-identical Card/ListTile
// blocks). Wraps the artwork in a Hero keyed on the song's database id so
// tapping it animates straight into NowPlayingScreen, and gives the whole
// card a tap-scale-down for a bit of tactile feedback.

import 'package:flutter/material.dart';
import '../models/music_data.dart';
import '../theme/text_styles.dart';

class SongCard extends StatefulWidget {
  final MusicData song;
  final VoidCallback onTap;
  final Widget? trailing;

  const SongCard({super.key, required this.song, required this.onTap, this.trailing});

  @override
  State<SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  double _scale = 1;

  void _setScale(double value) => setState(() => _scale = value);

  @override
  Widget build(BuildContext context) {
    final song = widget.song;

    return GestureDetector(
      onTapDown: (_) => _setScale(0.97),
      onTapCancel: () => _setScale(1),
      onTapUp: (_) => _setScale(1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Hero(
              tag: song.heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  song.image,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 52,
                    height: 52,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.music_note),
                  ),
                ),
              ),
            ),
            title: Text(song.title, style: bodyStyle(context), overflow: TextOverflow.ellipsis),
            subtitle: Text(
              '${song.channelTitle}${song.subscription ? ' · Subscription' : ''}',
              style: captionStyle(context),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: widget.trailing,
          ),
        ),
      ),
    );
  }
}
