import 'package:flutter/material.dart';

class MediaControls extends StatefulWidget {
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
  State<MediaControls> createState() => _MediaControlsState();
}

class _MediaControlsState extends State<MediaControls> {
  bool _isRepeatActive = false;
  bool _isShuffleActive = false;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Repeat, Favorite and Shuffle buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.repeat,
                    size: 28,
                    color: _isRepeatActive ? Colors.black : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isRepeatActive = !_isRepeatActive;
                    });
                  },
                ),
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.elasticOut,
                          reverseCurve: Curves.easeInBack,
                        ),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey<bool>(_isFavorite),
                      size: 28,
                      color: _isFavorite ? Colors.black : Colors.grey,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    size: 28,
                    color: _isShuffleActive ? Colors.black : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isShuffleActive = !_isShuffleActive;
                    });
                  },
                ),
              ],
            ),
          ),
          // Seek bar
          if (widget.position != null && widget.duration != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 8.0,
                      activeTrackColor: Colors.black,
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: Colors.black,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8.0,
                        elevation: 2.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 0.0,
                      ),
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: widget.position!.inMilliseconds.toDouble(),
                      max: widget.duration!.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        widget.onSeek?.call(Duration(milliseconds: value.toInt()));
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
                      onPressed: widget.onPrevious,
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
                        widget.isPlaying ? 'Pause' : 'Play',
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
                      onPressed: widget.onNext,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
