// lib/globals.dart
import 'services/audio_handler.dart';

/// The single app-wide audio handler. Assigned once in `main()` before
/// `runApp()`. Everything else (e.g. player_provider) reads it from here.
late AudioPlayerHandler audioHandler;
