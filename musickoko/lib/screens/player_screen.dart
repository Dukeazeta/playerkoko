import 'package:flutter/material.dart';
import '../widgets/media_controls.dart';
import '../widgets/music_card.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 3, seconds: 30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Music Card that fills available space
            const Expanded(
              child: MusicCard(
                title: 'One More Cup of Coffee',
                artist: 'Bob Dylan',
                // Add coverUrl when available
              ),
            ),
            // Media Controls at the bottom
            MediaControls(
              isPlaying: _isPlaying,
              position: _position,
              duration: _duration,
              onPlayPause: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
              onNext: () {
                // Implement next functionality
              },
              onPrevious: () {
                // Implement previous functionality
              },
              onSeek: (position) {
                setState(() {
                  _position = position;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
