import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';
import 'services/audio_handler.dart';
import 'services/supabase_service.dart';  
import 'globals.dart';

late AudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ypapbvklobkapggumxct.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwYXBidmtsb2JrYXBnZ3VteGN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk5NjU4NTYsImV4cCI6MjA3NTU0MTg1Nn0.ruuQTnkKjrbl7hRSp17HRvcA_7dYDrdi_tPM3V6yJ5A',
  );

  // Initialize audio handler - yourcompany
  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.umva.channel.audio',
      androidNotificationChannelName: 'Umva Audio Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

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