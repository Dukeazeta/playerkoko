import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musickoko/main.dart';
import '../widgets/media_controls.dart';
import '../widgets/music_card.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/lyrics_display.dart';
import '../widgets/equalizer_widget.dart';
import '../widgets/playback_controls.dart';
import '../models/song.dart';
import '../models/settings.dart';
import '../providers/providers.dart';
import '../services/audio_service.dart';
import '../services/lyrics_service.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPlaying = false;
  bool _isSoloMode = true;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 3, seconds: 30);
  bool _showEqualizer = false;
  bool _showLyrics = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initAudioHandler();
  }

  Future<void> _initAudioHandler() async {
    final audioHandler = ref.read(audioHandlerProvider);
    if (audioHandler != null) {
      audioHandler.playbackState.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            _position = state.position;
          });
        }
      });

      audioHandler.mediaItem.listen((mediaItem) {
        if (mounted && mediaItem != null) {
          setState(() {
            _duration = mediaItem.duration ?? Duration.zero;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(playerSettingsProvider);
    final currentSong = ref.watch(currentSongProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMainView(currentSong, settings),
                  if (settings.enableVisualization) 
                    AudioVisualizerWidget(audioHandler: ref.read(audioHandlerProvider)),
                  if (settings.showLyrics && currentSong != null)
                    LyricsDisplayWidget(song: currentSong),
                ],
              ),
            ),
            _buildBottomControls(settings),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          Material(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Spacer(),
          _buildModeToggle(),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSoloMode = !_isSoloMode;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModeButton(true, 'SOLO', Icons.headphones),
            _buildModeButton(false, 'SOCIAL', Icons.group),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(bool isSolo, String text, IconData icon) {
    final isSelected = _isSoloMode == isSolo;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.black : Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.robotoMono(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView(Song? currentSong, PlayerSettings settings) {
    return Column(
      children: [
        Expanded(
          child: MusicCard(
            artworkPath: currentSong?.artworkPath,
            title: currentSong?.title ?? 'No Song Playing',
            artist: currentSong?.artist ?? 'Unknown Artist',
          ),
        ),
        if (settings.enableEqualizer && _showEqualizer)
          EqualizerWidget(
            audioHandler: ref.read(audioHandlerProvider),
            settings: settings,
          ),
        PlaybackControlsWidget(
          isPlaying: _isPlaying,
          position: _position,
          duration: _duration,
          playbackSpeed: _playbackSpeed,
          onPlayPause: _togglePlayPause,
          onSeek: _seek,
          onSpeedChanged: _updatePlaybackSpeed,
        ),
      ],
    );
  }

  Widget _buildBottomControls(PlayerSettings settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              settings.enableEqualizer ? Icons.equalizer : Icons.equalizer_outlined,
              color: _showEqualizer ? Theme.of(context).primaryColor : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showEqualizer = !_showEqualizer;
              });
            },
          ),
          IconButton(
            icon: Icon(
              settings.showLyrics ? Icons.lyrics : Icons.lyrics_outlined,
              color: _showLyrics ? Theme.of(context).primaryColor : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showLyrics = !_showLyrics;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: () {
              // Show playlist bottom sheet
              _showPlaylistSheet(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.speed),
            onPressed: () {
              // Show playback speed dialog
              _showPlaybackSpeedDialog();
            },
          ),
        ],
      ),
    );
  }

  void _togglePlayPause() {
    final audioHandler = ref.read(audioHandlerProvider);
    if (audioHandler != null) {
      if (_isPlaying) {
        audioHandler.pause();
      } else {
        audioHandler.play();
      }
    }
  }

  void _seek(Duration position) {
    final audioHandler = ref.read(audioHandlerProvider);
    if (audioHandler != null) {
      audioHandler.seek(position);
    }
  }

  void _updatePlaybackSpeed(double speed) {
    final audioHandler = ref.read(audioHandlerProvider);
    if (audioHandler != null) {
      setState(() {
        _playbackSpeed = speed;
      });
      audioHandler.setPlaybackSpeed(speed);
    }
  }

  void _showPlaylistSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PlaylistBottomSheet(),
    );
  }

  void _showPlaybackSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => PlaybackSpeedDialog(
        currentSpeed: _playbackSpeed,
        onSpeedChanged: _updatePlaybackSpeed,
      ),
    );
  }
}
