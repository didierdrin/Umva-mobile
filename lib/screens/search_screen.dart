import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recent_searches_provider.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recent = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Search', style: headingStyle(context))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search music',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SearchResultsScreen(query: _searchController.text)),
                      );
                      _searchController.clear();
                    }
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Recent Searches', style: subHeadingStyle(context)),
            Expanded(
              child: recent.isEmpty
                  ? const Center(child: Text('No recent searches'))
                  : ListView.builder(
                      itemCount: recent.length,
                      itemBuilder: (context, index) {
                        final song = recent[index];
                        return ListTile(
                          leading: Image.network(song.image, width: 50),
                          title: Text(song.title, style: bodyStyle(context)),
                          subtitle: Text(song.channelTitle, style: captionStyle(context)),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NowPlayingScreen(song: song))),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}