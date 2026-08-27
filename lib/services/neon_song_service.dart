// lib/services/neon_song_service.dart
//
// Dart mirror of umva-dashboard/src/lib/dataApi.js, talking to the same Neon
// Data API (PostgREST-compatible HTTP) the dashboard uses. Access is
// enforced server-side by RLS (umva-dashboard/db/002_songs_rls.sql):
// anonymous can SELECT every row, so browsing/searching works without a
// signed-in user. Replaces the old lib/services/supabase_service.dart, which
// pointed at a Supabase project that no longer holds data.
//
// Unlike the dashboard (a browser, which the Data API happily serves with no
// Authorization header at all), this API rejects headerless requests
// outright - it wants a JWT even for the `anonymous` role, not just "no
// token". So every request here carries a bearer token: the signed-in
// user's session token when available, otherwise a short-lived anonymous
// token fetched from Neon Auth's `/token/anonymous` (see
// NeonAuthService.getAnonymousToken).

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'neon_config.dart';
import 'neon_auth_service.dart';
import '../providers/auth_provider.dart';
import '../models/music_data.dart';

class NeonSongServiceException implements Exception {
  final String message;
  NeonSongServiceException(this.message);
  @override
  String toString() => message;
}

class NeonSongService {
  final http.Client _client;
  final NeonAuthService _authService;

  NeonSongService({http.Client? client, NeonAuthService? authService})
      : _client = client ?? http.Client(),
        _authService = authService ?? NeonAuthService();

  Future<String?> _bearerToken() async {
    final sessionToken = await _authService.getToken();
    if (sessionToken != null) return sessionToken;
    return _authService.getAnonymousToken();
  }

  Future<List<MusicData>> _get(String query) async {
    final token = await _bearerToken();
    http.Response res;
    try {
      res = await _client.get(
        Uri.parse('${NeonConfig.dataApiUrl}/songs$query'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
    } catch (_) {
      throw NeonSongServiceException('Cannot reach the database. Check your connection.');
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      // Surface the API's own message (e.g. a PostgREST/RLS error) instead of
      // a bare status code - that detail is what actually explains a 400/403.
      String detail = 'Request failed (${res.statusCode})';
      try {
        final body = jsonDecode(res.body);
        if (body is Map && body['message'] is String) detail = body['message'] as String;
      } catch (_) {}
      throw NeonSongServiceException(detail);
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

final neonSongServiceProvider = Provider<NeonSongService>(
  (ref) => NeonSongService(authService: ref.read(neonAuthServiceProvider)),
);
