import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import '../providers/favorites_provider.dart';
import '../providers/recent_searches_provider.dart';
import '../widgets/song_card.dart';
import 'now_playing_screen.dart';
import '../theme/text_styles.dart';
import '../models/music_data.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final recent = ref.watch(recentSearchesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Favorites', style: subHeadingStyle(context)),
          const SizedBox(height: 8),
          favorites.isEmpty
              ? const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('No favorites yet'))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) => _buildSongTile(context, ref, favorites[index], isFavorite: true),
                ),
          const SizedBox(height: 24),
          Text('Recently Played', style: subHeadingStyle(context)),
          const SizedBox(height: 8),
          recent.isEmpty
              ? const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('No recent plays'))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recent.length,
                  itemBuilder: (context, index) => _buildSongTile(context, ref, recent[index]),
                ),
        ],
      ),
    );
  }

  Widget _buildSongTile(BuildContext context, WidgetRef ref, MusicData song, {bool isFavorite = false}) {
    return SongCard(
      song: song,
      trailing: isFavorite
          ? IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => ref.read(favoritesProvider.notifier).toggle(song))
          : null,
      onTap: () {
        if (song.subscription) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscription required')));
        } else {
          Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: NowPlayingScreen(song: song)));
        }
      },
    );
  }
}
