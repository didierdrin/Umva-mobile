import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/music_data.dart';

class SupabaseService {
  SupabaseService() {
    Supabase.initialize(
      url: 'https://ypapbvklobkapggumxct.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwYXBidmtsb2JrYXBnZ3VteGN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk5NjU4NTYsImV4cCI6MjA3NTU0MTg1Nn0.ruuQTnkKjrbl7hRSp17HRvcA_7dYDrdi_tPM3V6yJ5A',  
    );
  }

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