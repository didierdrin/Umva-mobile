// lib/services/neon_song_service.dart
//
// Dart mirror of umva-dashboard/src/lib/dataApi.js, talking to the same Neon
// Data API (PostgREST-compatible HTTP) the dashboard uses. Access is
// enforced server-side by RLS (umva-dashboard/db/002_songs_rls.sql):
// anonymous can SELECT every row, so browsing/searching works without a
// signed-in user. Replaces the old lib/services/supabase_service.dart, which
// pointed at a Supabase project that no longer holds data.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'neon_config.dart';
import '../models/music_data.dart';

class NeonSongServiceException implements Exception {
  final String message;
  NeonSongServiceException(this.message);
  @override
  String toString() => message;
}

class NeonSongService {
  final http.Client _client;

  NeonSongService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<MusicData>> _get(String query) async {
    http.Response res;
    try {
      res = await _client.get(
        Uri.parse('${NeonConfig.dataApiUrl}/songs$query'),
        headers: const {'Content-Type': 'application/json'},
      );
    } catch (_) {
      throw NeonSongServiceException('Cannot reach the database. Check your connection.');
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw NeonSongServiceException('Request failed (${res.statusCode})');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) return const [];
    return decoded.map((row) => MusicData.fromJson(row as Map<String, dynamic>)).toList();
  }

  /// Every public song, newest first - the default catalogue view.
  Future<List<MusicData>> listSongs() => _get('?order=created_at.desc');

  Future<List<MusicData>> searchSongs(String query) {
    final pattern = '*${Uri.encodeComponent(query)}*';
    return _get('?or=(title.ilike.$pattern,artist.ilike.$pattern)&order=created_at.desc');
  }
}
