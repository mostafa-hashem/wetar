import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/settings/domain/playback_settings.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';

/// Local versioned JSON backup & restore of appearance, playback settings,
/// selected folders, playlists, user track meta, and equalizer presets.
class BackupService {
  BackupService(this._db, this._personalizationCubit, this._settingsCubit);

  final WetarDatabase _db;
  final PersonalizationCubit _personalizationCubit;
  final SettingsCubit _settingsCubit;

  static const int currentBackupVersion = 1;

  Future<String> exportToJson() async {
    final folders = await (_db.select(_db.selectedFolders)).get();
    final playlists = await (_db.select(_db.playlists)).get();
    final entries = await (_db.select(_db.playlistEntries)).get();
    final meta = await (_db.select(_db.trackUserMeta)).get();
    final eqPresets = await (_db.select(_db.equalizerPresets)).get();

    final payload = <String, dynamic>{
      'format': 'wetar.backup',
      'version': currentBackupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'appearance': _personalizationCubit.state.settings.toJson(),
      'playback': _settingsCubit.state.toJson(),
      'selectedFolders': folders
          .map(
            (f) => <String, dynamic>{
              'rootPath': f.rootPath,
              'sourceKind': f.sourceKind,
              'displayName': f.displayName,
              'volumeLabel': f.volumeLabel,
              'includeSubfolders': f.includeSubfolders,
              'excludedSubfoldersJson': f.excludedSubfoldersJson,
            },
          )
          .toList(),
      'playlists': playlists
          .map(
            (p) => <String, dynamic>{
              'oldId': p.id,
              'name': p.name,
              'smartKind': p.smartKind,
              'createdAt': p.createdAt,
              'updatedAt': p.updatedAt,
            },
          )
          .toList(),
      'playlistEntries': entries
          .map(
            (e) => <String, dynamic>{
              'oldPlaylistId': e.playlistId,
              'trackStableKey': e.trackStableKey,
              'position': e.position,
              'addedAt': e.addedAt,
            },
          )
          .toList(),
      'trackUserMeta': meta
          .map(
            (m) => <String, dynamic>{
              'stableKey': m.stableKey,
              'isFavorite': m.isFavorite,
              'playCount': m.playCount,
              'lastPlayedAt': m.lastPlayedAt,
              'rememberedPositionMs': m.rememberedPositionMs,
              'lyricOffsetMs': m.lyricOffsetMs,
            },
          )
          .toList(),
      'equalizerPresets': eqPresets
          .map(
            (e) => <String, dynamic>{
              'name': e.name,
              'bandGainsJson': e.bandGainsJson,
              'bassBoostStrength': e.bassBoostStrength,
              'virtualizerStrength': e.virtualizerStrength,
              'loudnessGainMb': e.loudnessGainMb,
            },
          )
          .toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<bool> importFromJson(String rawJson) async {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) return false;
      if (decoded['format'] != 'wetar.backup') return false;

      final appearanceMap = decoded['appearance'];
      if (appearanceMap is Map<String, dynamic>) {
        final appearance = AppearanceSettingsMigration.fromJsonSafe(
          appearanceMap,
        );
        await _personalizationCubit.updateSettings(appearance);
      }

      final playbackMap = decoded['playback'];
      if (playbackMap is Map<String, dynamic>) {
        final playback = PlaybackSettings.fromJsonSafe(playbackMap);
        await _settingsCubit.update(playback);
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final foldersList = decoded['selectedFolders'];
      if (foldersList is List) {
        for (final f in foldersList.whereType<Map<String, dynamic>>()) {
          final rootPath = f['rootPath'] as String?;
          final displayName = f['displayName'] as String?;
          if (rootPath == null || rootPath.isEmpty) continue;
          await _db
              .into(_db.selectedFolders)
              .insert(
                SelectedFoldersCompanion.insert(
                  rootPath: rootPath,
                  sourceKind: Value(f['sourceKind'] as String? ?? 'mediastore'),
                  displayName: Value(displayName ?? rootPath).value,
                  volumeLabel: Value(
                    f['volumeLabel'] as String? ?? 'Device Storage',
                  ),
                  includeSubfolders: Value(
                    f['includeSubfolders'] as bool? ?? true,
                  ),
                  excludedSubfoldersJson: Value(
                    f['excludedSubfoldersJson'] as String? ?? '[]',
                  ),
                  addedAt: now,
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }

      final playlistIdMap = <int, int>{};
      final playlistsList = decoded['playlists'];
      if (playlistsList is List) {
        for (final p in playlistsList.whereType<Map<String, dynamic>>()) {
          final oldId = (p['oldId'] as num?)?.toInt();
          final name = p['name'] as String?;
          if (oldId == null || name == null || name.isEmpty) continue;
          final newId = await _db
              .into(_db.playlists)
              .insert(
                PlaylistsCompanion.insert(
                  name: name,
                  smartKind: Value(p['smartKind'] as String?),
                  createdAt: (p['createdAt'] as num?)?.toInt() ?? now,
                  updatedAt: (p['updatedAt'] as num?)?.toInt() ?? now,
                ),
              );
          playlistIdMap[oldId] = newId;
        }
      }

      final entriesList = decoded['playlistEntries'];
      if (entriesList is List) {
        await _db.batch((Batch b) {
          for (final e in entriesList.whereType<Map<String, dynamic>>()) {
            final oldPid = (e['oldPlaylistId'] as num?)?.toInt();
            final newPid = oldPid != null ? playlistIdMap[oldPid] : null;
            final key = e['trackStableKey'] as String?;
            if (newPid == null || key == null || key.isEmpty) continue;
            b.insert(
              _db.playlistEntries,
              PlaylistEntriesCompanion.insert(
                playlistId: newPid,
                trackStableKey: key,
                position: (e['position'] as num?)?.toInt() ?? 0,
                addedAt: (e['addedAt'] as num?)?.toInt() ?? now,
              ),
            );
          }
        });
      }

      final metaList = decoded['trackUserMeta'];
      if (metaList is List) {
        await _db.batch((Batch b) {
          for (final m in metaList.whereType<Map<String, dynamic>>()) {
            final key = m['stableKey'] as String?;
            if (key == null || key.isEmpty) continue;
            b.insert(
              _db.trackUserMeta,
              TrackUserMetaCompanion.insert(
                stableKey: key,
                isFavorite: Value(m['isFavorite'] as bool? ?? false),
                playCount: Value((m['playCount'] as num?)?.toInt() ?? 0),
                lastPlayedAt: Value((m['lastPlayedAt'] as num?)?.toInt()),
                rememberedPositionMs: Value(
                  (m['rememberedPositionMs'] as num?)?.toInt(),
                ),
                lyricOffsetMs: Value(
                  (m['lyricOffsetMs'] as num?)?.toInt() ?? 0,
                ),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      }

      final eqList = decoded['equalizerPresets'];
      if (eqList is List) {
        for (final eq in eqList.whereType<Map<String, dynamic>>()) {
          final name = eq['name'] as String?;
          final gainsJson = eq['bandGainsJson'] as String?;
          if (name == null || gainsJson == null) continue;
          await _db
              .into(_db.equalizerPresets)
              .insert(
                EqualizerPresetsCompanion.insert(
                  name: name,
                  isCustom: const Value(true),
                  bandGainsJson: gainsJson,
                  bassBoostStrength: Value(
                    (eq['bassBoostStrength'] as num?)?.toInt() ?? 0,
                  ),
                  virtualizerStrength: Value(
                    (eq['virtualizerStrength'] as num?)?.toInt() ?? 0,
                  ),
                  loudnessGainMb: Value(
                    (eq['loudnessGainMb'] as num?)?.toInt() ?? 0,
                  ),
                  updatedAt: now,
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
