import 'package:shared_preferences.dart';

class SettingsService {
  static const String _keyGaplessPlayback = 'gapless_playback';
  static const String _keyCrossfade = 'crossfade';
  static const String _keyCrossfadeDuration = 'crossfade_duration';
  static const String _keyEqualizer = 'equalizer';
  static const String _keyEqualizerBands = 'equalizer_bands';
  static const String _keyPlaybackSpeed = 'playback_speed';
  static const String _keyVisualization = 'visualization';
  static const String _keyLyrics = 'lyrics';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // Save settings
  Future<void> saveSettings({
    required bool enableGaplessPlayback,
    required bool enableCrossfade,
    required Duration crossfadeDuration,
    required bool enableEqualizer,
    required Map<int, double> equalizerBands,
    required double playbackSpeed,
    required bool enableVisualization,
    required bool enableLyrics,
  }) async {
    await _prefs.setBool(_keyGaplessPlayback, enableGaplessPlayback);
    await _prefs.setBool(_keyCrossfade, enableCrossfade);
    await _prefs.setInt(_keyCrossfadeDuration, crossfadeDuration.inMilliseconds);
    await _prefs.setBool(_keyEqualizer, enableEqualizer);
    await _prefs.setString(_keyEqualizerBands, equalizerBands.toString());
    await _prefs.setDouble(_keyPlaybackSpeed, playbackSpeed);
    await _prefs.setBool(_keyVisualization, enableVisualization);
    await _prefs.setBool(_keyLyrics, enableLyrics);
  }

  // Load settings
  Map<String, dynamic> loadSettings() {
    return {
      'enableGaplessPlayback': _prefs.getBool(_keyGaplessPlayback) ?? true,
      'enableCrossfade': _prefs.getBool(_keyCrossfade) ?? false,
      'crossfadeDuration': Duration(milliseconds: _prefs.getInt(_keyCrossfadeDuration) ?? 2000),
      'enableEqualizer': _prefs.getBool(_keyEqualizer) ?? false,
      'equalizerBands': _parseEqualizerBands(_prefs.getString(_keyEqualizerBands)),
      'playbackSpeed': _prefs.getDouble(_keyPlaybackSpeed) ?? 1.0,
      'enableVisualization': _prefs.getBool(_keyVisualization) ?? true,
      'enableLyrics': _prefs.getBool(_keyLyrics) ?? true,
    };
  }

  Map<int, double> _parseEqualizerBands(String? bandsString) {
    if (bandsString == null) {
      return {}; // Return default empty map if no saved bands
    }
    try {
      // Parse the string representation back to a Map
      // This is a simple implementation and might need to be adjusted based on your needs
      final Map<String, double> parsed = Map<String, double>.from(
        bandsString.split(',').map((band) {
          final parts = band.split(':');
          return MapEntry(int.parse(parts[0]), double.parse(parts[1]));
        }).toList(),
      );
      return parsed.map((key, value) => MapEntry(int.parse(key), value));
    } catch (e) {
      return {}; // Return default empty map if parsing fails
    }
  }
}
