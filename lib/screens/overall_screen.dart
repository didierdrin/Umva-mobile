import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import '../providers/player_provider.dart';
import '../providers/recent_searches_provider.dart';
import 'library_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'now_playing_screen.dart';
import '../theme/text_styles.dart';
import '../models/music_data.dart';

class OverallScreen extends ConsumerStatefulWidget {
  const OverallScreen({super.key, required this.showMiniPlayer});

  final bool showMiniPlayer;

  @override
  ConsumerState<OverallScreen> createState() => _OverallScreenState();
}

class _OverallScreenState extends ConsumerState<OverallScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final recent = ref.watch(recentSearchesProvider);
    final currentSong = recent.isNotEmpty ? recent.last : null;

    final pages = [
      const LibraryScreen(),
      const SearchScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: pages,
      ),
      floatingActionButton: widget.showMiniPlayer && currentSong != null
          ? _buildMiniPlayer(playerState, currentSong)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (index) {
          _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(PlayerState playerState, MusicData song) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade600]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.2))],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(song.image, width: 50, height: 50, fit: BoxFit.cover),
        ),
        title: Text(song.title, style: bodyStyle(context).copyWith(color: Colors.white), overflow: TextOverflow.ellipsis),
        subtitle: Text(song.channelTitle, style: captionStyle(context).copyWith(color: Colors.white70), overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: Icon(playerState.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
          onPressed: () => ref.read(playerProvider.notifier).playPause(),
        ),
        onTap: () => Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: NowPlayingScreen(song: song))),
      ),
    );
  }
}