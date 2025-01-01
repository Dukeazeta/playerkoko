import 'package:flutter/material.dart';

class MediaControls extends StatelessWidget {
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool isPlaying;
  final Duration? position;
  final Duration? duration;
  final ValueChanged<Duration>? onSeek;

  const MediaControls({
    super.key,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.isPlaying = false,
    this.position,
    this.duration,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Seek bar
        if (position != null && duration != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 16),
                    activeTrackColor: Colors.black,
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: Colors.black,
                    overlayColor: Colors.black.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: position!.inMilliseconds.toDouble(),
                    max: duration!.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      onSeek?.call(Duration(milliseconds: value.toInt()));
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

        // Media control buttons
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.skip_previous, size: 24),
                    onPressed: onPrevious,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(
                      isPlaying ? 'Pause' : 'Play',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.skip_next, size: 24),
                    onPressed: onNext,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
