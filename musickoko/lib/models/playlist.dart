import 'package:flutter/foundation.dart';
import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final String? description;
  final List<Song> songs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverArtPath;
  final bool isFavorite;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    required this.songs,
    required this.createdAt,
    required this.updatedAt,
    this.coverArtPath,
    this.isFavorite = false,
  });

  Duration get totalDuration {
    return songs.fold(
      Duration.zero,
      (total, song) => total + song.duration,
    );
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    List<Song>? songs,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coverArtPath,
    bool? isFavorite,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'songs': songs.map((song) => song.id).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'coverArtPath': coverArtPath,
      'isFavorite': isFavorite,
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json, List<Song> allSongs) {
    final songIds = List<String>.from(json['songs']);
    final songs = songIds
        .map((id) => allSongs.firstWhere(
              (song) => song.id == id,
              orElse: () => throw Exception('Song not found: $id'),
            ))
        .toList();

    return Playlist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      songs: songs,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      coverArtPath: json['coverArtPath'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
