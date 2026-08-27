import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import '../providers/recent_searches_provider.dart';
import '../services/neon_song_service.dart';
import '../models/music_data.dart';
import '../widgets/song_card.dart';
import 'search_results_screen.dart';
import 'now_playing_screen.dart';
import '../theme/text_styles.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  late Future<List<MusicData>> _browseFuture;

  @override
  void initState() {
    super.initState();
    _browseFuture = NeonSongService().listSongs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    if (_searchController.text.isEmpty) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => SearchResultsScreen(query: _searchController.text)));
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final recent = ref.watch(recentSearchesProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Search music',
              suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 24, bottom: 140),
              children: [
                if (recent.isNotEmpty) ...[
                  Text('Recent Searches', style: subHeadingStyle(context)),
                  const SizedBox(height: 8),
                  ...recent.map((song) => SongCard(
                        song: song,
                        onTap: () => Navigator.push(
                          context,
                          PageTransition(type: PageTransitionType.bottomToTop, child: NowPlayingScreen(song: song)),
                        ),
                      )),
                  const SizedBox(height: 24),
                ],
                Text('Browse', style: subHeadingStyle(context)),
                const SizedBox(height: 8),
                FutureBuilder<List<MusicData>>(
                  future: _browseFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('Could not load songs: ${snapshot.error}'),
                      );
                    }
                    final songs = snapshot.data ?? const [];
                    if (songs.isEmpty) {
                      return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('No songs yet'));
                    }
                    return Column(
                      children: songs
                          .map((song) => SongCard(
                                song: song,
                                onTap: () {
                                  ref.read(recentSearchesProvider.notifier).add(song);
                                  Navigator.push(
                                    context,
                                    PageTransition(type: PageTransitionType.bottomToTop, child: NowPlayingScreen(song: song)),
                                  );
                                },
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
