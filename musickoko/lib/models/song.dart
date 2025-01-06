import 'package:just_audio/just_audio.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String path;
  final Duration duration;
  final String? artworkPath;
  final Map<String, dynamic>? metadata;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.duration,
    this.artworkPath,
    this.metadata,
  });

  factory Song.fromAudioSource(AudioSource source, {Map<String, dynamic>? metadata}) {
    if (source is UriAudioSource) {
      return Song(
        id: source.uri.toString(),
        title: metadata?['title'] ?? 'Unknown Title',
        artist: metadata?['artist'] ?? 'Unknown Artist',
        album: metadata?['album'] ?? 'Unknown Album',
        path: source.uri.toString(),
        duration: metadata?['duration'] ?? Duration.zero,
        artworkPath: metadata?['artworkPath'],
        metadata: metadata,
      );
    }
    throw UnimplementedError('Unsupported audio source type');
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? path,
    Duration? duration,
    String? artworkPath,
    Map<String, dynamic>? metadata,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      path: path ?? this.path,
      duration: duration ?? this.duration,
      artworkPath: artworkPath ?? this.artworkPath,
      metadata: metadata ?? this.metadata,
    );
  }
}
