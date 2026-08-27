import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import '../services/neon_song_service.dart';
import '../models/music_data.dart';
import '../providers/recent_searches_provider.dart';
import '../widgets/song_card.dart';
import 'now_playing_screen.dart';
import '../theme/text_styles.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late Future<List<MusicData>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _searchFuture = ref.read(neonSongServiceProvider).searchSongs(widget.query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Results', style: headingStyle(context))),
      body: FutureBuilder<List<MusicData>>(
        future: _searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No results found'));
          }
          final songs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final data = songs[index];
              return SongCard(
                song: data,
                onTap: () {
                  ref.read(recentSearchesProvider.notifier).add(data);
                  Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: NowPlayingScreen(song: data)));
                },
              );
            },
          );
        },
      ),
    );
  }
}
