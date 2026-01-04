import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../models/music_data.dart';
import '../providers/recent_searches_provider.dart';
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
    final service = SupabaseService();
    _searchFuture = service.searchSongs(widget.query);
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
              return Card(
                child: ListTile(
                  leading: Image.network(data.image, width: 100),
                  title: Text(data.title, style: bodyStyle(context)),
                  subtitle: Text(data.channelTitle, style: captionStyle(context)),
                  onTap: () {
                    ref.read(recentSearchesProvider.notifier).add(data);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => NowPlayingScreen(song: data)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}