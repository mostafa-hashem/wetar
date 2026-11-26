import 'dart:io';

import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/features/library/data/library_repository.dart';
import 'package:wetar/features/library/domain/library_models.dart';

enum SmartPlaylistKind { mostPlayed, recentlyAdded, neverPlayed, longTracks }

class WetarPlaylistSummary extends Equatable {
  const WetarPlaylistSummary({
    required this.id,
    required this.name,
    required this.trackCount,
    required this.coverTracks,
    this.smartKind,
    this.customCoverPath,
  });

  final int id;
  final String name;
  final int trackCount;
  final List<WetarTrack> coverTracks;
  final SmartPlaylistKind? smartKind;
  final String? customCoverPath;

  bool get isSmart => smartKind != null;

  @override
  List<Object?> get props => [
    id,
    name,
    trackCount,
    coverTracks,
    smartKind,
    customCoverPath,
  ];
}

/// Manages user playlists and smart playlists while enforcing Wetar's core rule:
/// playlist entries pointing outside active SelectedFolders stay hidden (never deleted).
class PlaylistsRepository {
  PlaylistsRepository(this._db, this._libraryRepo);

  final WetarDatabase _db;
  final LibraryRepository _libraryRepo;

  Stream<List<WetarPlaylistSummary>> watchUserPlaylists() {
    return _db
        .customSelect(
          '''
      SELECT p.id, p.name, p.smart_kind, p.custom_cover_path,
             COUNT(t.stable_key) AS visible_count
      FROM playlists p
      LEFT JOIN playlist_entries pe ON pe.playlist_id = p.id
      LEFT JOIN tracks t ON t.stable_key = pe.track_stable_key
      LEFT JOIN selected_folders sf ON sf.id = t.folder_id AND sf.is_available = 1
      WHERE p.smart_kind IS NULL
      GROUP BY p.id
      ORDER BY p.updated_at DESC
      ''',
          readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
            _db.playlists,
            _db.playlistEntries,
            _db.tracks,
            _db.selectedFolders,
          },
        )
        .watch()
        .asyncMap((rows) async {
          final result = <WetarPlaylistSummary>[];
          for (final r in rows) {
            final pid = r.read<int>('id');
            final tracks = await getPlaylistTracks(pid);
            result.add(
              WetarPlaylistSummary(
                id: pid,
                name: r.read<String>('name'),
                trackCount: tracks.length,
                coverTracks: tracks.take(4).toList(),
                customCoverPath: r.readNullable<String>('custom_cover_path'),
              ),
            );
          }
          return result;
        });
  }

  /// Returns visible tracks inside a user playlist (hidden out-of-scope tracks
  /// remain intact in `playlist_entries` and reappear when their folder returns).
  Future<List<WetarTrack>> getPlaylistTracks(int playlistId) async {
    final entries =
        await (_db.select(_db.playlistEntries)
              ..where((e) => e.playlistId.equals(playlistId))
              ..orderBy(<OrderingTerm Function(PlaylistEntries)>[
                (e) => OrderingTerm.asc(e.position),
              ]))
            .get();
    if (entries.isEmpty) return const <WetarTrack>[];
    return _libraryRepo.findTracksByStableKeys(
      entries.map((e) => e.trackStableKey).toList(),
    );
  }

  Future<List<WetarTrack>> getSmartPlaylistTracks(
    SmartPlaylistKind kind, {
    int minDurationSec = 30,
  }) async {
    final all = await _libraryRepo.fetchLibraryTracks(
      minDurationSec: minDurationSec,
    );
    switch (kind) {
      case SmartPlaylistKind.mostPlayed:
        return (all.where((t) => t.playCount > 0).toList()
              ..sort((a, b) => b.playCount.compareTo(a.playCount)))
            .take(100)
            .toList();
      case SmartPlaylistKind.recentlyAdded:
        return (List<WetarTrack>.from(all)
              ..sort((a, b) => b.dateAddedSec.compareTo(a.dateAddedSec)))
            .take(100)
            .toList();
      case SmartPlaylistKind.neverPlayed:
        return all.where((t) => t.playCount == 0).toList();
      case SmartPlaylistKind.longTracks:
        return all.where((t) => t.durationMs >= 15 * 60 * 1000).toList();
    }
  }

  Future<int> createPlaylist(String name) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _db
        .into(_db.playlists)
        .insert(
          PlaylistsCompanion.insert(
            name: name.trim(),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> renamePlaylist(int playlistId, String newName) async {
    await (_db.update(
      _db.playlists,
    )..where((p) => p.id.equals(playlistId))).write(
      PlaylistsCompanion(
        name: Value(newName.trim()),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> deletePlaylist(int playlistId) async {
    await (_db.delete(
      _db.playlists,
    )..where((p) => p.id.equals(playlistId))).go();
  }

  Future<void> addTracksToPlaylist(
    int playlistId,
    List<WetarTrack> tracks,
  ) async {
    if (tracks.isEmpty) return;
    final existing = await (_db.select(
      _db.playlistEntries,
    )..where((e) => e.playlistId.equals(playlistId))).get();
    final existingKeys = existing.map((e) => e.trackStableKey).toSet();
    var nextPos = existing.isEmpty
        ? 0
        : existing.map((e) => e.position).reduce((a, b) => a > b ? a : b) + 1;
    final now = DateTime.now().millisecondsSinceEpoch;

    await _db.batch((Batch b) {
      for (final track in tracks) {
        if (track.isTemporaryExternal ||
            existingKeys.contains(track.stableKey)) {
          continue;
        }
        existingKeys.add(track.stableKey);
        b.insert(
          _db.playlistEntries,
          PlaylistEntriesCompanion.insert(
            playlistId: playlistId,
            trackStableKey: track.stableKey,
            position: nextPos++,
            addedAt: now,
          ),
        );
      }
    });
    await (_db.update(_db.playlists)..where((p) => p.id.equals(playlistId)))
        .write(PlaylistsCompanion(updatedAt: Value(now)));
  }

  Future<void> removeTrackFromPlaylist(int playlistId, String stableKey) async {
    await (_db.delete(_db.playlistEntries)..where(
          (e) =>
              e.playlistId.equals(playlistId) &
              e.trackStableKey.equals(stableKey),
        ))
        .go();
  }

  Future<void> reorderPlaylist(
    int playlistId,
    List<WetarTrack> orderedTracks,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.transaction(() async {
      await (_db.delete(
        _db.playlistEntries,
      )..where((e) => e.playlistId.equals(playlistId))).go();
      await _db.batch((Batch b) {
        for (var i = 0; i < orderedTracks.length; i++) {
          b.insert(
            _db.playlistEntries,
            PlaylistEntriesCompanion.insert(
              playlistId: playlistId,
              trackStableKey: orderedTracks[i].stableKey,
              position: i,
              addedAt: now,
            ),
          );
        }
      });
    });
  }

  /// Exports a playlist as standard `#EXTM3U` UTF-8 text.
  static String encodeM3u(String playlistName, List<WetarTrack> tracks) {
    final buf = StringBuffer('#EXTM3U\n#PLAYLIST:$playlistName\n');
    for (final t in tracks) {
      final sec = (t.durationMs / 1000).round();
      buf.writeln('#EXTINF:$sec,${t.displayArtist} - ${t.title}');
      buf.writeln(t.filePath);
    }
    return buf.toString();
  }

  /// Imports an M3U / M3U8 file, matching entries strictly against tracks
  /// already inside active SelectedFolders.
  Future<int> importM3uFile(String m3uFilePath) async {
    final file = File(m3uFilePath);
    if (!file.existsSync()) return 0;
    final raw = await file.readAsString();
    final lines = raw.replaceAll('\r\n', '\n').split('\n');
    final baseDir = p.dirname(m3uFilePath);

    final allLibrary = await _libraryRepo.fetchLibraryTracks(minDurationSec: 0);
    final byPath = <String, WetarTrack>{
      for (final t in allLibrary) t.filePath: t,
      for (final t in allLibrary) t.stableKey: t,
    };
    final byBasename = <String, WetarTrack>{
      for (final t in allLibrary) p.basename(t.filePath).toLowerCase(): t,
    };

    var playlistName = p.basenameWithoutExtension(m3uFilePath);
    final matched = <WetarTrack>[];
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('#PLAYLIST:')) {
        final candidate = line.substring('#PLAYLIST:'.length).trim();
        if (candidate.isNotEmpty) playlistName = candidate;
        continue;
      }
      if (line.startsWith('#')) continue;
      final normalized = line.startsWith('/') || line.startsWith('content://')
          ? line
          : p.normalize(p.join(baseDir, line));
      final found =
          byPath[normalized] ??
          byPath[line] ??
          byBasename[p.basename(normalized).toLowerCase()];
      if (found != null) {
        matched.add(found);
      }
    }

    if (matched.isEmpty) return 0;
    final pid = await createPlaylist(playlistName);
    await addTracksToPlaylist(pid, matched);
    return matched.length;
  }
}
