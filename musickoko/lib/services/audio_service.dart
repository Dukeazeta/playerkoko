import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_session/audio_session.dart';
import '../models/settings.dart';

class AudioPlayerHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  final List<MediaItem> _queue = [];
  int _queueIndex = -1;
  bool _shuffleModeEnabled = false;
  PlayerSettings _settings = const PlayerSettings();

  AudioPlayerHandler() {
    _initAudioSession();
    _player.playbackEventStream.listen(_broadcastState);
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handlePlaybackCompletion();
      }
    });
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  Future<void> _handlePlaybackCompletion() async {
    if (_settings.enableAutoPlay) {
      await skipToNext();
    } else {
      await stop();
    }
  }

  Future<void> _broadcastState(PlaybackEvent event) async {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        if (_shuffleModeEnabled) MediaControl.shuffle else MediaControl.shuffleMode,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.setShuffleMode,
        MediaAction.setRepeatMode,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _queueIndex,
      shuffleMode: _shuffleModeEnabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    ));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _queue.length) return;
    
    if (_settings.enableCrossfade && _player.playing) {
      await _crossfadeToIndex(index);
    } else {
      await _skipToIndex(index);
    }
  }

  Future<void> _crossfadeToIndex(int index) async {
    final oldPlayer = _player;
    final newPlayer = AudioPlayer();
    
    // Start fading out current song
    await oldPlayer.setVolume(0.0);
    
    // Prepare and start new song
    _queueIndex = index;
    await newPlayer.setAudioSource(
      AudioSource.uri(Uri.parse(_queue[index].id)),
      preload: true,
    );
    await newPlayer.play();
    
    // Clean up old player
    await oldPlayer.dispose();
  }

  Future<void> _skipToIndex(int index) async {
    _queueIndex = index;
    await _player.setAudioSource(
      AudioSource.uri(Uri.parse(_queue[index].id)),
      preload: true,
    );
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    _queue.add(mediaItem);
    queue.add(_queue);
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = _queue.indexOf(mediaItem);
    if (index != -1) {
      _queue.removeAt(index);
      queue.add(_queue);
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  Future<void> setEqualizer(bool enabled, Map<int, double> bands) async {
    if (enabled) {
      // Apply equalizer settings
      final equalizer = AndroidEqualizer();
      await _player.setAndroidAudioEffect(equalizer);
      
      // Set band levels
      for (final entry in bands.entries) {
        await equalizer.setBandLevel(entry.key, entry.value);
      }
    } else {
      await _player.clearAndroidAudioEffects();
    }
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  Future<void> toggleShuffle() async {
    _shuffleModeEnabled = !_shuffleModeEnabled;
    if (_shuffleModeEnabled) {
      _queue.shuffle();
    } else {
      // Restore original order
      _queue.sort((a, b) => a.id.compareTo(b.id));
    }
    queue.add(_queue);
  }

  Future<void> updateSettings(PlayerSettings settings) async {
    _settings = settings;
    await setEqualizer(settings.enableEqualizer, settings.equalizerBands);
    await setPlaybackSpeed(settings.playbackSpeed);
    
    if (settings.enableGaplessPlayback) {
      await _player.setGaplessPlayback(true);
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

final audioHandlerProvider = StateProvider<AudioHandler?>((ref) => null);

final audioHandlerInitProvider = FutureProvider<AudioHandler>((ref) async {
  final audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.musickoko.channel.audio',
      androidNotificationChannelName: 'Music Koko playback',
      androidNotificationOngoing: true,
    ),
  );
  
  ref.read(audioHandlerProvider.notifier).state = audioHandler;
  return audioHandler;
});
