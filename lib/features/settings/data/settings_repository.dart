import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../personalization/domain/appearance_settings.dart';
import '../domain/playback_settings.dart';

/// Persists typed, versioned AppearanceSettings, PlaybackSettings, and custom Looks
/// in SharedPreferencesWithCache for near-instant cold start loading.
class SettingsRepository {
  SettingsRepository(SharedPreferencesWithCache prefs)
    : _store = _SharedPrefsStore(prefs);

  SettingsRepository.inMemory() : _store = _InMemoryStore();

  final _KeyValueStore _store;

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
    final raw = _store.getString(_appearanceKey);
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
    await _store.setString(_appearanceKey, jsonEncode(settings.toJson()));
  }

  PlaybackSettings loadPlayback() {
    final raw = _store.getString(_playbackKey);
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
    await _store.setString(_playbackKey, jsonEncode(settings.toJson()));
  }

  List<WetarLookPreset> loadSavedLooks() {
    final raw = _store.getString(_savedLooksKey);
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
    await _store.setString(_savedLooksKey, encoded);
  }
}

abstract interface class _KeyValueStore {
  String? getString(String key);
  Future<void> setString(String key, String value);
}

class _SharedPrefsStore implements _KeyValueStore {
  _SharedPrefsStore(this._prefs);

  final SharedPreferencesWithCache _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
}

class _InMemoryStore implements _KeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  String? getString(String key) => _values[key];

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }
}
