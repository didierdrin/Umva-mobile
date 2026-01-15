import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/music_data.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<MusicData>> searchSongs(String query) async {
    final response = await supabase
        .from('songs')
        .select('*')
        .or('title.ilike.%$query%,artist.ilike.%$query%');

    return response.map((data) => MusicData(
          data['title'],
          data['artist'],
          data['file_url'],
          data['image_url'] ?? '',
          false,
          data['subscription'] ?? false,
        )).toList();
  }
}