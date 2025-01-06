import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class LyricsService {
  static const String _apiBaseUrl = 'https://api.lyrics.ovh/v1';
  
  Future<String?> getLyrics(Song song) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/${song.artist}/${song.title}'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['lyrics'] as String?;
      }
    } catch (e) {
      print('Error fetching lyrics: $e');
    }
    return null;
  }

  Future<Map<String, String>> getLocalLyrics(String filePath) async {
    // TODO: Implement local lyrics file parsing (e.g., .lrc files)
    return {};
  }

  Future<void> saveLyrics(Song song, String lyrics) async {
    // TODO: Implement lyrics saving to local storage
  }

  Future<void> syncLyrics(Song song, Duration timestamp) async {
    // TODO: Implement lyrics synchronization
  }
}
