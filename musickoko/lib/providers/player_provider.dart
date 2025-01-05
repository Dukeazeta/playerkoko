import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../utils/logger.dart';

class PlayerState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final ProcessingState processingState;
  final String? currentSongPath;
  final double volume;
  final bool isShuffle;
  final bool isRepeat;

  PlayerState({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.processingState = ProcessingState.idle,
    this.currentSongPath,
    this.volume = 1.0,
    this.isShuffle = false,
    this.isRepeat = false,
  });

  PlayerState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    ProcessingState? processingState,
    String? currentSongPath,
    double? volume,
    bool? isShuffle,
    bool? isRepeat,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      processingState: processingState ?? this.processingState,
      currentSongPath: currentSongPath ?? this.currentSongPath,
      volume: volume ?? this.volume,
      isShuffle: isShuffle ?? this.isShuffle,
      isRepeat: isRepeat ?? this.isRepeat,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final AudioPlayer _player;

  PlayerNotifier() : _player = AudioPlayer(), super(PlayerState()) {
    _init();
  }

  void _init() {
    _player.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        processingState: playerState.processingState,
      );
    });

    _player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _player.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });

    _player.volumeStream.listen((volume) {
      state = state.copyWith(volume: volume);
    });
  }

  Future<void> setAudioSource(String filePath) async {
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.file(filePath)));
      state = state.copyWith(currentSongPath: filePath);
      Logger.i('Audio source set: $filePath');
    } catch (e, stack) {
      Logger.e('Error setting audio source', error: e, stackTrace: stack);
    }
  }

  Future<void> play() async {
    try {
      await _player.play();
    } catch (e, stack) {
      Logger.e('Error playing audio', error: e, stackTrace: stack);
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e, stack) {
      Logger.e('Error pausing audio', error: e, stackTrace: stack);
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e, stack) {
      Logger.e('Error seeking audio', error: e, stackTrace: stack);
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume);
    } catch (e, stack) {
      Logger.e('Error setting volume', error: e, stackTrace: stack);
    }
  }

  void toggleShuffle() {
    state = state.copyWith(isShuffle: !state.isShuffle);
  }

  void toggleRepeat() {
    state = state.copyWith(isRepeat: !state.isRepeat);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier();
});
