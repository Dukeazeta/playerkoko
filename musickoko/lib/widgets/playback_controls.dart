import 'package:flutter/material.dart';

class PlaybackControlsWidget extends StatelessWidget {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<double> onSpeedChanged;

  const PlaybackControlsWidget({
    super.key,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.playbackSpeed,
    required this.onPlayPause,
    required this.onSeek,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildProgressBar(),
        const SizedBox(height: 8),
        _buildTimeLabels(),
        const SizedBox(height: 16),
        _buildControlButtons(),
      ],
    );
  }

  Widget _buildProgressBar() {
    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      child: Slider(
        value: position.inMilliseconds.toDouble(),
        min: 0,
        max: duration.inMilliseconds.toDouble(),
        onChanged: (value) {
          onSeek(Duration(milliseconds: value.round()));
        },
      ),
    );
  }

  Widget _buildTimeLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_formatDuration(position)),
          Text(_formatDuration(duration)),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          iconSize: 32,
          onPressed: () {
            // TODO: Implement previous
          },
        ),
        const SizedBox(width: 16),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            iconSize: 32,
            onPressed: onPlayPause,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: 32,
          onPressed: () {
            // TODO: Implement next
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}

class PlaybackSpeedDialog extends StatelessWidget {
  final double currentSpeed;
  final ValueChanged<double> onSpeedChanged;

  const PlaybackSpeedDialog({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Playback Speed'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSpeedButton(context, 0.5, 'x0.5'),
          _buildSpeedButton(context, 0.75, 'x0.75'),
          _buildSpeedButton(context, 1.0, 'Normal'),
          _buildSpeedButton(context, 1.25, 'x1.25'),
          _buildSpeedButton(context, 1.5, 'x1.5'),
          _buildSpeedButton(context, 2.0, 'x2'),
        ],
      ),
    );
  }

  Widget _buildSpeedButton(BuildContext context, double speed, String label) {
    final isSelected = speed == currentSpeed;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () {
        onSpeedChanged(speed);
        Navigator.pop(context);
      },
    );
  }
}

class PlaylistBottomSheet extends StatelessWidget {
  const PlaylistBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Current Playlist',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // TODO: Implement playlist items
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
