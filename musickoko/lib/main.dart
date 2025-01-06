import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/music_list_screen.dart';
import 'screens/player_screen.dart';
import 'screens/playlist_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/audio_service.dart';
import 'services/playlist_service.dart';
import 'services/lyrics_service.dart';
import 'utils/logger.dart';
import 'models/song.dart';
import 'models/playlist.dart';
import 'models/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  final audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.musickoko.channel.audio',
      androidNotificationChannelName: 'Music playback',
    ),
  );
  final playlistService = PlaylistService();
  final lyricsService = LyricsService();

  // Run app with providers
  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        audioHandlerProvider.overrideWithValue(audioHandler),
        playlistServiceProvider.overrideWithValue(playlistService),
        lyricsServiceProvider.overrideWithValue(lyricsService),
      ],
      child: const MyApp(),
    ),
  );
}

// Providers
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError();
});

final audioHandlerProvider = Provider<AudioHandler>((ref) {
  throw UnimplementedError();
});

final playlistServiceProvider = Provider<PlaylistService>((ref) {
  throw UnimplementedError();
});

final lyricsServiceProvider = Provider<LyricsService>((ref) {
  throw UnimplementedError();
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final savedTheme = storageService.getThemeMode();
  switch (savedTheme) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
});

final currentSongProvider = StateProvider<Song?>((ref) => null);
final playlistsProvider = StateNotifierProvider<PlaylistNotifier, List<Playlist>>((ref) {
  final playlistService = ref.watch(playlistServiceProvider);
  return PlaylistNotifier(playlistService);
});

final playerSettingsProvider = StateNotifierProvider<SettingsNotifier, PlayerSettings>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return SettingsNotifier(storageService);
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Koko',
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const OnboardingScreen(),
      routes: {
        '/music_list': (context) => const MusicListScreen(),
        '/player': (context) => const PlayerScreen(),
        '/playlists': (context) => const PlaylistScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
