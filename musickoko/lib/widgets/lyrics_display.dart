import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song.dart';
import '../services/lyrics_service.dart';

class LyricsDisplayWidget extends ConsumerStatefulWidget {
  final Song song;

  const LyricsDisplayWidget({
    super.key,
    required this.song,
  });

  @override
  ConsumerState<LyricsDisplayWidget> createState() => _LyricsDisplayWidgetState();
}

class _LyricsDisplayWidgetState extends ConsumerState<LyricsDisplayWidget> {
  String? _lyrics;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLyrics();
  }

  Future<void> _fetchLyrics() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final lyricsService = ref.read(lyricsServiceProvider);
      final lyrics = await lyricsService.getLyrics(widget.song);
      
      if (mounted) {
        setState(() {
          _lyrics = lyrics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lyrics = null;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading lyrics: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.song.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.song.artist,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _buildLyricsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_lyrics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No lyrics found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchLyrics,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Text(
        _lyrics!,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }
}
