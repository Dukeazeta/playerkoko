import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class PlayerSettings {
  final bool enableGaplessPlayback;
  final bool enableCrossfade;
  final Duration crossfadeDuration;
  final bool enableEqualizer;
  final Map<int, double> equalizerBands;
  final double playbackSpeed;
  final bool enableVisualization;
  final bool showLyrics;
  final bool enableBackgroundPlay;
  final ThemeMode themeMode;
  final bool enableAutoPlay;
  final bool shuffleOnStart;

  const PlayerSettings({
    this.enableGaplessPlayback = true,
    this.enableCrossfade = false,
    this.crossfadeDuration = const Duration(seconds: 3),
    this.enableEqualizer = false,
    this.equalizerBands = const {},
    this.playbackSpeed = 1.0,
    this.enableVisualization = true,
    this.showLyrics = true,
    this.enableBackgroundPlay = true,
    this.themeMode = ThemeMode.system,
    this.enableAutoPlay = false,
    this.shuffleOnStart = false,
  });

  PlayerSettings copyWith({
    bool? enableGaplessPlayback,
    bool? enableCrossfade,
    Duration? crossfadeDuration,
    bool? enableEqualizer,
    Map<int, double>? equalizerBands,
    double? playbackSpeed,
    bool? enableVisualization,
    bool? showLyrics,
    bool? enableBackgroundPlay,
    ThemeMode? themeMode,
    bool? enableAutoPlay,
    bool? shuffleOnStart,
  }) {
    return PlayerSettings(
      enableGaplessPlayback: enableGaplessPlayback ?? this.enableGaplessPlayback,
      enableCrossfade: enableCrossfade ?? this.enableCrossfade,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      enableEqualizer: enableEqualizer ?? this.enableEqualizer,
      equalizerBands: equalizerBands ?? this.equalizerBands,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      enableVisualization: enableVisualization ?? this.enableVisualization,
      showLyrics: showLyrics ?? this.showLyrics,
      enableBackgroundPlay: enableBackgroundPlay ?? this.enableBackgroundPlay,
      themeMode: themeMode ?? this.themeMode,
      enableAutoPlay: enableAutoPlay ?? this.enableAutoPlay,
      shuffleOnStart: shuffleOnStart ?? this.shuffleOnStart,
    );
  }

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'enableGaplessPlayback': enableGaplessPlayback,
      'enableCrossfade': enableCrossfade,
      'crossfadeDuration': crossfadeDuration.inMilliseconds,
      'enableEqualizer': enableEqualizer,
      'equalizerBands': equalizerBands,
      'playbackSpeed': playbackSpeed,
      'enableVisualization': enableVisualization,
      'showLyrics': showLyrics,
      'enableBackgroundPlay': enableBackgroundPlay,
      'themeMode': themeMode.index,
      'enableAutoPlay': enableAutoPlay,
      'shuffleOnStart': shuffleOnStart,
    };
  }

  factory PlayerSettings.fromJson(Map<String, dynamic> json) {
    return PlayerSettings(
      enableGaplessPlayback: json['enableGaplessPlayback'] as bool? ?? false,
      enableCrossfade: json['enableCrossfade'] as bool? ?? false,
      crossfadeDuration: Duration(milliseconds: json['crossfadeDuration'] as int? ?? 0),
      enableEqualizer: json['enableEqualizer'] as bool? ?? false,
      equalizerBands: (json['equalizerBands'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(int.parse(key), (value as num).toDouble()),
      ) ?? {},
      playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
      enableVisualization: json['enableVisualization'] as bool? ?? true,
      showLyrics: json['showLyrics'] as bool? ?? false,
      enableBackgroundPlay: json['enableBackgroundPlay'] as bool? ?? true,
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      enableAutoPlay: json['enableAutoPlay'] as bool? ?? false,
      shuffleOnStart: json['shuffleOnStart'] as bool? ?? false,
    );
  }
}

class SettingsNotifier extends StateNotifier<PlayerSettings> {
  final StorageService _storage;

  SettingsNotifier(this._storage) : super(const PlayerSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load settings from storage and update state
    final settings = await _storage.getSettings();
    if (settings != null) {
      state = settings;
    }
  }

  Future<void> updateSettings(PlayerSettings settings) async {
    state = settings;
    await _storage.saveSettings(settings);
  }

  Future<void> toggleGaplessPlayback() async {
    final newSettings = state.copyWith(
      enableGaplessPlayback: !state.enableGaplessPlayback,
    );
    await updateSettings(newSettings);
  }

  Future<void> toggleCrossfade() async {
    final newSettings = state.copyWith(
      enableCrossfade: !state.enableCrossfade,
    );
    await updateSettings(newSettings);
  }

  Future<void> setCrossfadeDuration(Duration duration) async {
    final newSettings = state.copyWith(
      crossfadeDuration: duration,
    );
    await updateSettings(newSettings);
  }

  Future<void> toggleEqualizer() async {
    final newSettings = state.copyWith(
      enableEqualizer: !state.enableEqualizer,
    );
    await updateSettings(newSettings);
  }

  Future<void> updateEqualizerBands(Map<int, double> bands) async {
    final newSettings = state.copyWith(
      equalizerBands: bands,
    );
    await updateSettings(newSettings);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    final newSettings = state.copyWith(
      playbackSpeed: speed,
    );
    await updateSettings(newSettings);
  }

  Future<void> toggleVisualization() async {
    final newSettings = state.copyWith(
      enableVisualization: !state.enableVisualization,
    );
    await updateSettings(newSettings);
  }

  Future<void> toggleLyrics() async {
    final newSettings = state.copyWith(
      showLyrics: !state.showLyrics,
    );
    await updateSettings(newSettings);
  }
}

final playerSettingsProvider = StateNotifierProvider<SettingsNotifier, PlayerSettings>((ref) {
  return SettingsNotifier(StorageService());
});
