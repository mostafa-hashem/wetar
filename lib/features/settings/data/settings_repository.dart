import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../personalization/domain/appearance_settings.dart';
import '../domain/playback_settings.dart';

/// Persists typed, versioned AppearanceSettings, PlaybackSettings, and custom Looks
/// in SharedPreferencesWithCache for near-instant cold start loading.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static const String _appearanceKey = 'wetar_appearance_settings_v1';
  static const String _playbackKey = 'wetar_playback_settings_v1';
  static const String _savedLooksKey = 'wetar_saved_looks_v1';

  static Future<SettingsRepository> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{_appearanceKey, _playbackKey, _savedLooksKey},
      ),
    );
    return SettingsRepository(prefs);
  }

  AppearanceSettings loadAppearance() {
    final raw = _prefs.getString(_appearanceKey);
    if (raw == null || raw.isEmpty) return const AppearanceSettings();
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        return AppearanceSettingsMigration.fromJsonSafe(map);
      }
      return const AppearanceSettings();
    } catch (_) {
      return const AppearanceSettings();
    }
  }

  Future<void> saveAppearance(AppearanceSettings settings) async {
    await _prefs.setString(_appearanceKey, jsonEncode(settings.toJson()));
  }

  PlaybackSettings loadPlayback() {
    final raw = _prefs.getString(_playbackKey);
    if (raw == null || raw.isEmpty) return const PlaybackSettings();
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        return PlaybackSettings.fromJsonSafe(map);
      }
      return const PlaybackSettings();
    } catch (_) {
      return const PlaybackSettings();
    }
  }

  Future<void> savePlayback(PlaybackSettings settings) async {
    await _prefs.setString(_playbackKey, jsonEncode(settings.toJson()));
  }

  List<WetarLookPreset> loadSavedLooks() {
    final raw = _prefs.getString(_savedLooksKey);
    if (raw == null || raw.isEmpty) return const <WetarLookPreset>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <WetarLookPreset>[];
      final out = <WetarLookPreset>[];
      for (final entry in decoded.whereType<Map<String, dynamic>>()) {
        final settingsMap = entry['settings'];
        if (settingsMap is! Map<String, dynamic>) continue;
        out.add(
          WetarLookPreset(
            id: entry['id'] as String? ?? 'custom_${out.length}',
            nameEn: entry['nameEn'] as String? ?? 'Custom Look',
            nameAr: entry['nameAr'] as String? ?? 'مظهر مخصص',
            isBuiltIn: false,
            settings: AppearanceSettingsMigration.fromJsonSafe(settingsMap),
          ),
        );
      }
      return out;
    } catch (_) {
      return const <WetarLookPreset>[];
    }
  }

  Future<void> saveCustomLooks(List<WetarLookPreset> looks) async {
    final encoded = jsonEncode(looks.map((l) => l.toExportJson()).toList());
    await _prefs.setString(_savedLooksKey, encoded);
  }
}
