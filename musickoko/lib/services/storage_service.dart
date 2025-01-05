import 'dart:convert';
import 'package:shared_preferences.dart';
import '../utils/logger.dart';

class StorageService {
  static const String _kFavorites = 'favorites';
  static const String _kRecentlyPlayed = 'recently_played';
  static const String _kThemeMode = 'theme_mode';
  static const String _kVolume = 'volume';
  static const String _kEqualizerSettings = 'equalizer_settings';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Favorites
  Future<bool> addToFavorites(String songPath) async {
    try {
      final favorites = getFavorites();
      if (!favorites.contains(songPath)) {
        favorites.add(songPath);
        await _prefs.setStringList(_kFavorites, favorites);
        Logger.i('Added to favorites: $songPath');
        return true;
      }
      return false;
    } catch (e, stack) {
      Logger.e('Error adding to favorites', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<bool> removeFromFavorites(String songPath) async {
    try {
      final favorites = getFavorites();
      if (favorites.remove(songPath)) {
        await _prefs.setStringList(_kFavorites, favorites);
        Logger.i('Removed from favorites: $songPath');
        return true;
      }
      return false;
    } catch (e, stack) {
      Logger.e('Error removing from favorites', error: e, stackTrace: stack);
      return false;
    }
  }

  List<String> getFavorites() {
    try {
      return _prefs.getStringList(_kFavorites) ?? [];
    } catch (e, stack) {
      Logger.e('Error getting favorites', error: e, stackTrace: stack);
      return [];
    }
  }

  // Recently Played
  Future<void> addToRecentlyPlayed(String songPath) async {
    try {
      final recentlyPlayed = getRecentlyPlayed();
      recentlyPlayed.remove(songPath);
      recentlyPlayed.insert(0, songPath);
      
      // Keep only last 20 songs
      if (recentlyPlayed.length > 20) {
        recentlyPlayed.removeLast();
      }
      
      await _prefs.setStringList(_kRecentlyPlayed, recentlyPlayed);
      Logger.i('Added to recently played: $songPath');
    } catch (e, stack) {
      Logger.e('Error adding to recently played', error: e, stackTrace: stack);
    }
  }

  List<String> getRecentlyPlayed() {
    try {
      return _prefs.getStringList(_kRecentlyPlayed) ?? [];
    } catch (e, stack) {
      Logger.e('Error getting recently played', error: e, stackTrace: stack);
      return [];
    }
  }

  // Theme
  Future<void> setThemeMode(String themeMode) async {
    try {
      await _prefs.setString(_kThemeMode, themeMode);
      Logger.i('Theme mode set to: $themeMode');
    } catch (e, stack) {
      Logger.e('Error setting theme mode', error: e, stackTrace: stack);
    }
  }

  String getThemeMode() {
    try {
      return _prefs.getString(_kThemeMode) ?? 'system';
    } catch (e, stack) {
      Logger.e('Error getting theme mode', error: e, stackTrace: stack);
      return 'system';
    }
  }

  // Volume
  Future<void> setVolume(double volume) async {
    try {
      await _prefs.setDouble(_kVolume, volume);
      Logger.i('Volume set to: $volume');
    } catch (e, stack) {
      Logger.e('Error setting volume', error: e, stackTrace: stack);
    }
  }

  double getVolume() {
    try {
      return _prefs.getDouble(_kVolume) ?? 1.0;
    } catch (e, stack) {
      Logger.e('Error getting volume', error: e, stackTrace: stack);
      return 1.0;
    }
  }

  // Equalizer Settings
  Future<void> saveEqualizerSettings(Map<String, double> settings) async {
    try {
      final jsonString = jsonEncode(settings);
      await _prefs.setString(_kEqualizerSettings, jsonString);
      Logger.i('Equalizer settings saved');
    } catch (e, stack) {
      Logger.e('Error saving equalizer settings', error: e, stackTrace: stack);
    }
  }

  Map<String, double> getEqualizerSettings() {
    try {
      final jsonString = _prefs.getString(_kEqualizerSettings);
      if (jsonString != null) {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        return decoded.map((key, value) => MapEntry(key, value.toDouble()));
      }
      return {};
    } catch (e, stack) {
      Logger.e('Error getting equalizer settings', error: e, stackTrace: stack);
      return {};
    }
  }

  Future<void> clear() async {
    try {
      await _prefs.clear();
      Logger.i('Storage cleared');
    } catch (e, stack) {
      Logger.e('Error clearing storage', error: e, stackTrace: stack);
    }
  }
}
