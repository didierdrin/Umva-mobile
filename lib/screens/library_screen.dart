import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorites_provider.dart';
import '../providers/recent_searches_provider.dart';
import 'now_playing_screen.dart';
import '../theme/text_styles.dart';
import '../models/music_data.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final recent = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('My Library', style: headingStyle(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Favorites', style: subHeadingStyle(context)),
            favorites.isEmpty
                ? const Center(child: Text('No favorites yet'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) => _buildSongTile(context, ref, favorites[index], isFavorite: true),
                  ),
            const SizedBox(height: 24),
            Text('Recently Played', style: subHeadingStyle(context)),
            recent.isEmpty
                ? const Center(child: Text('No recent plays'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recent.length,
                    itemBuilder: (context, index) => _buildSongTile(context, ref, recent[index]),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongTile(BuildContext context, WidgetRef ref, MusicData song, {bool isFavorite = false}) {
    return Card(
      child: ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(song.image, width: 50, fit: BoxFit.cover)),
        title: Text(song.title, overflow: TextOverflow.ellipsis, style: bodyStyle(context)),
        subtitle: Text('${song.channelTitle} ${song.subscription ? '(Subscription)' : ''}', style: captionStyle(context)),
        trailing: isFavorite
            ? IconButton(icon: const Icon(Icons.delete), onPressed: () => ref.read(favoritesProvider.notifier).toggle(song))
            : null,
        onTap: () {
          if (song.subscription) {
            // Handle subscription logic if needed (e.g., check user sub, show dialog)
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscription required')));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => NowPlayingScreen(song: song)));
          }
        },
      ),
    );
  }
}