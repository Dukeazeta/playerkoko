import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';
import '../services/storage_service.dart';

export '../models/settings.dart';

final playerSettingsProvider = StateNotifierProvider<SettingsNotifier, PlayerSettings>((ref) {
  return SettingsNotifier(StorageService());
});
