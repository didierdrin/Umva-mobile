import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';
import 'services/audio_handler.dart';
import 'globals.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Not worth blocking startup for. If init fails the app must still reach
  // runApp(), otherwise the process dies before drawing a frame and the
  // launcher icon simply does nothing.
  try {
    audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.umva_v1_0_1.channel.audio',
        androidNotificationChannelName: 'Umva Audio Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  } catch (e, s) {
    // Falls back to a plain handler so the UI still runs (without background
    // playback / notification controls) instead of showing nothing at all.
    debugPrint('AudioService.init failed: $e\n$s');
    audioHandler = AudioPlayerHandler();
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Umva',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const SplashScreen(),
    );
  }
}