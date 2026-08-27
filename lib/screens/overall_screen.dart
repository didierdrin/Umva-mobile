import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import '../providers/player_provider.dart';
import '../providers/recent_searches_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/floating_pill_nav.dart';
import '../widgets/profile_drawer.dart';
import 'library_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'now_playing_screen.dart';
import '../theme/text_styles.dart';
import '../models/music_data.dart';

const _tabTitles = ['Library', 'Search', 'Settings'];

/// Shared with ProfileDrawer so its "Settings" tile can switch tabs in the
/// already-mounted OverallScreen instead of pushing a second Settings route
/// (which would need its own Scaffold, conflicting with the tab pages now
/// being body-only content owned by OverallScreen's single Scaffold).
final selectedTabProvider = StateProvider<int>((ref) => 0);

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

  void _goToTab(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final recent = ref.watch(recentSearchesProvider);
    final auth = ref.watch(authProvider);
    final currentSong = recent.isNotEmpty ? recent.last : null;

    ref.listen<int>(selectedTabProvider, (previous, next) {
      if (next != _selectedIndex) _goToTab(next);
    });

    final pages = [
      const LibraryScreen(),
      const SearchScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_selectedIndex], style: headingStyle(context)),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  auth.user != null ? auth.user!.initials : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: const ProfileDrawer(),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
              ref.read(selectedTabProvider.notifier).state = index;
            },
            children: pages,
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 0,
            // minimum keeps a 16px gap above the system gesture bar / home
            // indicator instead of the pill sitting flush against (or under)
            // it on devices with a large bottom inset.
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showMiniPlayer && currentSong != null) ...[
                    _buildMiniPlayer(playerState, currentSong),
                    const SizedBox(height: 12),
                  ],
                  FloatingPillNav(
                    currentIndex: _selectedIndex,
                    onTap: (index) => ref.read(selectedTabProvider.notifier).state = index,
                    items: const [
                      PillNavItem(icon: Icons.library_music, label: 'Library'),
                      PillNavItem(icon: Icons.search, label: 'Search'),
                      PillNavItem(icon: Icons.settings, label: 'Settings'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(PlayerState playerState, MusicData song) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade600]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.2))],
      ),
      child: ListTile(
        leading: Hero(
          tag: song.heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(song.image, width: 44, height: 44, fit: BoxFit.cover),
          ),
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
