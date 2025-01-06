import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

class AudioVisualizerWidget extends StatefulWidget {
  final AudioHandler? audioHandler;

  const AudioVisualizerWidget({
    super.key,
    required this.audioHandler,
  });

  @override
  State<AudioVisualizerWidget> createState() => _AudioVisualizerWidgetState();
}

class _AudioVisualizerWidgetState extends State<AudioVisualizerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<double> _barHeights = List.generate(30, (_) => 0.0);
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(_updateBars);

    widget.audioHandler?.playbackState.listen((state) {
      if (state.playing) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateBars() {
    if (mounted) {
      setState(() {
        for (int i = 0; i < _barHeights.length; i++) {
          if (_random.nextBool()) {
            _barHeights[i] = _random.nextDouble();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Visualizer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                _barHeights.length,
                (index) => _buildBar(_barHeights[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 8,
      height: 200 * height,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.3),
          ],
        ),
      ),
    );
  }
}
