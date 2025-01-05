import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/logger.dart';

class SongMetadata {
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String filePath;
  final DateTime dateAdded;

  SongMetadata({
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.filePath,
    required this.dateAdded,
  });

  factory SongMetadata.fromFile(FileSystemEntity file) {
    try {
      final filePath = file.path;
      final fileName = path.basename(filePath);
      final fileStats = file.statSync();

      // For now, we'll just use the filename as the title
      // In a production app, you'd want to use a proper metadata extraction library
      final title = path.basenameWithoutExtension(fileName);

      return SongMetadata(
        title: title,
        artist: 'Unknown Artist', // This would come from metadata
        album: 'Unknown Album',   // This would come from metadata
        duration: const Duration(minutes: 3), // This would come from metadata
        filePath: filePath,
        dateAdded: fileStats.modified,
      );
    } catch (e, stack) {
      Logger.e('Error creating metadata from file', error: e, stackTrace: stack);
      rethrow;
    }
  }

  SongMetadata copyWith({
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    String? filePath,
    DateTime? dateAdded,
  }) {
    return SongMetadata(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}

class MetadataService {
  static final MetadataService _instance = MetadataService._internal();
  
  factory MetadataService() {
    return _instance;
  }
  
  MetadataService._internal();

  Future<List<SongMetadata>> extractMetadataFromDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        throw Exception('Directory does not exist: $directoryPath');
      }

      final List<SongMetadata> metadata = [];
      
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File && _isSupportedAudioFile(entity.path)) {
          try {
            final songMetadata = SongMetadata.fromFile(entity);
            metadata.add(songMetadata);
          } catch (e, stack) {
            Logger.e(
              'Error extracting metadata from file: ${entity.path}',
              error: e,
              stackTrace: stack,
            );
            // Continue with next file
            continue;
          }
        }
      }

      return metadata;
    } catch (e, stack) {
      Logger.e(
        'Error scanning directory for metadata: $directoryPath',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  bool _isSupportedAudioFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.mp3', '.m4a', '.aac', '.wav', '.ogg'].contains(extension);
  }

  Future<SongMetadata?> extractMetadataFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      if (!_isSupportedAudioFile(filePath)) {
        throw Exception('Unsupported file type: $filePath');
      }

      return SongMetadata.fromFile(file);
    } catch (e, stack) {
      Logger.e(
        'Error extracting metadata from file: $filePath',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }
}
