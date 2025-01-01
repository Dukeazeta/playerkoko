import 'package:flutter/material.dart';
import '../widgets/media_controls.dart';
import '../widgets/music_card.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isPlaying = false;
  bool _isSoloMode = true;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 3, seconds: 30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back button and Mode toggle row
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  // Back button
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
                  // SOLO | SOCIAL toggle
                  GestureDetector(
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
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _isSoloMode ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.headphones,
                                  size: 16,
                                  color: _isSoloMode ? Colors.black : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'SOLO',
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _isSoloMode ? Colors.black : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: !_isSoloMode ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.groups,
                                  size: 16,
                                  color: !_isSoloMode ? Colors.black : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'SOCIAL',
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: !_isSoloMode ? Colors.black : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
