import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class PlaylistService {
  static const String _playlistsKey = 'playlists';
  static const String _favoritesKey = 'favorites';
  late final SharedPreferences _prefs;

  PlaylistService() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Playlist>> getPlaylists() async {
    final playlistsJson = _prefs.getStringList(_playlistsKey) ?? [];
    final List<Playlist> playlists = [];
    
    for (final json in playlistsJson) {
      try {
        final Map<String, dynamic> playlistMap = jsonDecode(json);
        final playlist = Playlist.fromJson(playlistMap, await _getAllSongs());
        playlists.add(playlist);
      } catch (e) {
        print('Error loading playlist: $e');
      }
    }
    
    return playlists;
  }

  Future<void> savePlaylist(Playlist playlist) async {
    final playlists = await getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlist.id);
    
    if (index >= 0) {
      playlists[index] = playlist;
    } else {
      playlists.add(playlist);
    }
    
    await _savePlaylists(playlists);
  }

  Future<void> deletePlaylist(String playlistId) async {
    final playlists = await getPlaylists();
    playlists.removeWhere((p) => p.id == playlistId);
    await _savePlaylists(playlists);
  }

  Future<void> _savePlaylists(List<Playlist> playlists) async {
    final playlistsJson = playlists.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_playlistsKey, playlistsJson);
  }

  Future<List<Song>> getFavorites() async {
    final favoriteIds = _prefs.getStringList(_favoritesKey) ?? [];
    final allSongs = await _getAllSongs();
    return allSongs.where((song) => favoriteIds.contains(song.id)).toList();
  }

  Future<void> toggleFavorite(Song song) async {
    final favoriteIds = _prefs.getStringList(_favoritesKey) ?? [];
    
    if (favoriteIds.contains(song.id)) {
      favoriteIds.remove(song.id);
    } else {
      favoriteIds.add(song.id);
    }
    
    await _prefs.setStringList(_favoritesKey, favoriteIds);
  }

  Future<bool> isFavorite(String songId) async {
    final favoriteIds = _prefs.getStringList(_favoritesKey) ?? [];
    return favoriteIds.contains(songId);
  }

  Future<List<Song>> _getAllSongs() async {
    // This should be implemented to return all songs from your storage service
    // For now, returning an empty list
    return [];
  }

  Future<void> reorderPlaylist(String playlistId, int oldIndex, int newIndex) async {
    final playlists = await getPlaylists();
    final playlistIndex = playlists.indexWhere((p) => p.id == playlistId);
    
    if (playlistIndex >= 0) {
      final playlist = playlists[playlistIndex];
      final songs = List<Song>.from(playlist.songs);
      
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      final item = songs.removeAt(oldIndex);
      songs.insert(newIndex, item);
      
      final updatedPlaylist = playlist.copyWith(
        songs: songs,
        updatedAt: DateTime.now(),
      );
      
      playlists[playlistIndex] = updatedPlaylist;
      await _savePlaylists(playlists);
    }
  }

  Future<void> addSongsToPlaylist(String playlistId, List<Song> songs) async {
    final playlists = await getPlaylists();
    final playlistIndex = playlists.indexWhere((p) => p.id == playlistId);
    
    if (playlistIndex >= 0) {
      final playlist = playlists[playlistIndex];
      final updatedSongs = List<Song>.from(playlist.songs)..addAll(songs);
      
      final updatedPlaylist = playlist.copyWith(
        songs: updatedSongs,
        updatedAt: DateTime.now(),
      );
      
      playlists[playlistIndex] = updatedPlaylist;
      await _savePlaylists(playlists);
    }
  }

  Future<void> removeSongsFromPlaylist(String playlistId, List<String> songIds) async {
    final playlists = await getPlaylists();
    final playlistIndex = playlists.indexWhere((p) => p.id == playlistId);
    
    if (playlistIndex >= 0) {
      final playlist = playlists[playlistIndex];
      final updatedSongs = playlist.songs.where((song) => !songIds.contains(song.id)).toList();
      
      final updatedPlaylist = playlist.copyWith(
        songs: updatedSongs,
        updatedAt: DateTime.now(),
      );
      
      playlists[playlistIndex] = updatedPlaylist;
      await _savePlaylists(playlists);
    }
  }
}
