import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../../../core/database/wetar_database.dart';
import '../../../core/utils/arabic_normalizer.dart';
import '../../../core/utils/artist_splitter.dart';
import '../domain/library_models.dart';

/// Reads tracks, albums, artists, genres, years, and search results strictly
/// scoped to available rows in `selected_folders`.
class LibraryRepository {
  LibraryRepository(this._db);

  final WetarDatabase _db;

  /// Reactive stream of all playable tracks strictly inside available selected folders.
  Stream<List<WetarTrack>> watchLibraryTracks({int minDurationSec = 30}) {
    const sql = '''
      SELECT t.*,
             COALESCE(m.is_favorite, 0) AS meta_is_favorite,
             COALESCE(m.play_count, 0) AS meta_play_count,
             m.last_played_at AS meta_last_played_at,
             m.remembered_position_ms AS meta_remembered_position_ms,
             m.attached_lrc_path AS meta_attached_lrc_path,
             COALESCE(m.lyric_offset_ms, 0) AS meta_lyric_offset_ms,
             m.custom_art_path AS meta_custom_art_path
      FROM tracks t
      INNER JOIN selected_folders sf ON sf.id = t.folder_id
      LEFT JOIN track_user_meta m ON m.stable_key = t.stable_key
      WHERE sf.is_available = 1
        AND t.duration_ms >= ?
      ORDER BY t.title COLLATE NOCASE ASC
    ''';

    return _db
        .customSelect(
          sql,
          variables: <Variable<Object>>[
            Variable.withInt(minDurationSec * 1000),
          ],
          readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
            _db.tracks,
            _db.selectedFolders,
            _db.trackUserMeta,
          },
        )
        .watch()
        .map((rows) => rows.map(_mapRowToTrack).toList());
  }

  Future<List<WetarTrack>> fetchLibraryTracks({int minDurationSec = 30}) {
    return watchLibraryTracks(minDurationSec: minDurationSec).first;
  }

  Future<WetarTrack?> findTrackByStableKey(String stableKey) async {
    const sql = '''
      SELECT t.*,
             COALESCE(m.is_favorite, 0) AS meta_is_favorite,
             COALESCE(m.play_count, 0) AS meta_play_count,
             m.last_played_at AS meta_last_played_at,
             m.remembered_position_ms AS meta_remembered_position_ms,
             m.attached_lrc_path AS meta_attached_lrc_path,
             COALESCE(m.lyric_offset_ms, 0) AS meta_lyric_offset_ms,
             m.custom_art_path AS meta_custom_art_path
      FROM tracks t
      INNER JOIN selected_folders sf ON sf.id = t.folder_id
      LEFT JOIN track_user_meta m ON m.stable_key = t.stable_key
      WHERE sf.is_available = 1
        AND t.stable_key = ?
      LIMIT 1
    ''';
    final row = await _db
        .customSelect(
          sql,
          variables: <Variable<Object>>[Variable.withString(stableKey)],
          readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
            _db.tracks,
            _db.selectedFolders,
            _db.trackUserMeta,
          },
        )
        .getSingleOrNull();
    return row == null ? null : _mapRowToTrack(row);
  }

  Future<List<WetarTrack>> findTracksByStableKeys(
    List<String> stableKeys,
  ) async {
    if (stableKeys.isEmpty) return const <WetarTrack>[];
    final placeholders = List<String>.filled(stableKeys.length, '?').join(',');
    final sql =
        '''
      SELECT t.*,
             COALESCE(m.is_favorite, 0) AS meta_is_favorite,
             COALESCE(m.play_count, 0) AS meta_play_count,
             m.last_played_at AS meta_last_played_at,
             m.remembered_position_ms AS meta_remembered_position_ms,
             m.attached_lrc_path AS meta_attached_lrc_path,
             COALESCE(m.lyric_offset_ms, 0) AS meta_lyric_offset_ms,
             m.custom_art_path AS meta_custom_art_path
      FROM tracks t
      INNER JOIN selected_folders sf ON sf.id = t.folder_id
      LEFT JOIN track_user_meta m ON m.stable_key = t.stable_key
      WHERE sf.is_available = 1
        AND t.stable_key IN ($placeholders)
    ''';
    final rows = await _db
        .customSelect(
          sql,
          variables: stableKeys.map(Variable.withString).toList(),
          readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
            _db.tracks,
            _db.selectedFolders,
            _db.trackUserMeta,
          },
        )
        .get();
    final byKey = <String, WetarTrack>{
      for (final row in rows)
        row.read<String>('stable_key'): _mapRowToTrack(row),
    };
    return <WetarTrack>[
      for (final k in stableKeys)
        if (byKey[k] != null) byKey[k]!,
    ];
  }

  Future<List<WetarTrack>> searchTracks(
    String rawQuery, {
    int minDurationSec = 30,
  }) async {
    final norm = ArabicNormalizer.normalize(rawQuery);
    if (norm.isEmpty) return const <WetarTrack>[];
    final pattern = '%$norm%';
    const sql = '''
      SELECT t.*,
             COALESCE(m.is_favorite, 0) AS meta_is_favorite,
             COALESCE(m.play_count, 0) AS meta_play_count,
             m.last_played_at AS meta_last_played_at,
             m.remembered_position_ms AS meta_remembered_position_ms,
             m.attached_lrc_path AS meta_attached_lrc_path,
             COALESCE(m.lyric_offset_ms, 0) AS meta_lyric_offset_ms,
             m.custom_art_path AS meta_custom_art_path
      FROM tracks t
      INNER JOIN selected_folders sf ON sf.id = t.folder_id
      LEFT JOIN track_user_meta m ON m.stable_key = t.stable_key
      WHERE sf.is_available = 1
        AND t.duration_ms >= ?
        AND (
          t.title_normalized LIKE ?
          OR t.artist_normalized LIKE ?
          OR t.album_normalized LIKE ?
        )
      ORDER BY t.title COLLATE NOCASE ASC
      LIMIT 300
    ''';
    final rows = await _db
        .customSelect(
          sql,
          variables: <Variable<Object>>[
            Variable.withInt(minDurationSec * 1000),
            Variable.withString(pattern),
            Variable.withString(pattern),
            Variable.withString(pattern),
          ],
        )
        .get();
    return rows.map(_mapRowToTrack).toList();
  }

  Future<void> saveRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    await _db
        .into(_db.recentSearches)
        .insert(
          RecentSearchesCompanion.insert(
            query: trimmed,
            normalizedQuery: ArabicNormalizer.normalize(trimmed),
            searchedAt: DateTime.now().millisecondsSinceEpoch,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Stream<List<String>> watchRecentSearches() {
    return (_db.select(_db.recentSearches)
          ..orderBy(<OrderingTerm Function(RecentSearches)>[
            (t) => OrderingTerm.desc(t.searchedAt),
          ])
          ..limit(12))
        .watch()
        .map((rows) => rows.map((r) => r.query).toList());
  }

  Future<void> clearRecentSearches() async {
    await _db.delete(_db.recentSearches).go();
  }

  Future<void> toggleFavorite(String stableKey, {bool? value}) async {
    final current = await (_db.select(
      _db.trackUserMeta,
    )..where((t) => t.stableKey.equals(stableKey))).getSingleOrNull();
    final nextVal = value ?? !(current?.isFavorite ?? false);
    await _db
        .into(_db.trackUserMeta)
        .insert(
          TrackUserMetaCompanion.insert(
            stableKey: stableKey,
            isFavorite: Value(nextVal),
            playCount: Value(current?.playCount ?? 0),
            lastPlayedAt: Value(current?.lastPlayedAt),
            rememberedPositionMs: Value(current?.rememberedPositionMs),
            attachedLrcPath: Value(current?.attachedLrcPath),
            lyricOffsetMs: Value(current?.lyricOffsetMs ?? 0),
            customArtPath: Value(current?.customArtPath),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Creates or updates a single play history row with real listened duration.
  Future<int?> upsertPlayHistorySession({
    int? eventId,
    required WetarTrack track,
    required int playedAtMs,
    required int listenedMs,
  }) async {
    if (track.isTemporaryExternal) return null;
    final safeMs = math.max(0, listenedMs);
    if (eventId != null) {
      final updatedRows =
          await (_db.update(_db.playHistoryEvents)
                ..where((t) => t.id.equals(eventId)))
              .write(PlayHistoryEventsCompanion(listenedMs: Value(safeMs)));
      if (updatedRows > 0) return eventId;
    }
    return _db
        .into(_db.playHistoryEvents)
        .insert(
          PlayHistoryEventsCompanion.insert(
            trackStableKey: track.stableKey,
            trackTitle: track.title,
            artistName: track.displayArtist,
            albumName: track.displayAlbum,
            playedAt: playedAtMs,
            listenedMs: safeMs,
          ),
        );
  }

  /// Increments a track's play counter once a listening session qualifies.
  Future<void> incrementTrackPlayCount(
    WetarTrack track, {
    required int playedAtMs,
  }) async {
    if (track.isTemporaryExternal) return;
    final current = await (_db.select(
      _db.trackUserMeta,
    )..where((t) => t.stableKey.equals(track.stableKey))).getSingleOrNull();
    await _db
        .into(_db.trackUserMeta)
        .insert(
          TrackUserMetaCompanion.insert(
            stableKey: track.stableKey,
            isFavorite: Value(current?.isFavorite ?? track.isFavorite),
            playCount: Value((current?.playCount ?? 0) + 1),
            lastPlayedAt: Value(playedAtMs),
            rememberedPositionMs: Value(current?.rememberedPositionMs),
            attachedLrcPath: Value(current?.attachedLrcPath),
            lyricOffsetMs: Value(current?.lyricOffsetMs ?? 0),
            customArtPath: Value(current?.customArtPath),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Clears listening recap events and play counts while keeping user library prefs.
  Future<void> clearListeningHistory() async {
    await _db.transaction(() async {
      await _db.delete(_db.playHistoryEvents).go();
      await _db
          .update(_db.trackUserMeta)
          .write(
            const TrackUserMetaCompanion(
              playCount: Value(0),
              lastPlayedAt: Value(null),
            ),
          );
    });
  }

  Future<void> recordTrackPlay(WetarTrack track, {int listenedMs = 0}) async {
    if (track.isTemporaryExternal) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await incrementTrackPlayCount(track, playedAtMs: now);
    await upsertPlayHistorySession(
      track: track,
      playedAtMs: now,
      listenedMs: math.max(0, listenedMs),
    );
  }

  Future<void> setRememberedPosition(String stableKey, int? positionMs) async {
    final current = await (_db.select(
      _db.trackUserMeta,
    )..where((t) => t.stableKey.equals(stableKey))).getSingleOrNull();
    await _db
        .into(_db.trackUserMeta)
        .insert(
          TrackUserMetaCompanion.insert(
            stableKey: stableKey,
            isFavorite: Value(current?.isFavorite ?? false),
            playCount: Value(current?.playCount ?? 0),
            lastPlayedAt: Value(current?.lastPlayedAt),
            rememberedPositionMs: Value(positionMs),
            attachedLrcPath: Value(current?.attachedLrcPath),
            lyricOffsetMs: Value(current?.lyricOffsetMs ?? 0),
            customArtPath: Value(current?.customArtPath),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> setAttachedLrc(String stableKey, String? lrcPath) async {
    final current = await (_db.select(
      _db.trackUserMeta,
    )..where((t) => t.stableKey.equals(stableKey))).getSingleOrNull();
    await _db
        .into(_db.trackUserMeta)
        .insert(
          TrackUserMetaCompanion.insert(
            stableKey: stableKey,
            isFavorite: Value(current?.isFavorite ?? false),
            playCount: Value(current?.playCount ?? 0),
            lastPlayedAt: Value(current?.lastPlayedAt),
            rememberedPositionMs: Value(current?.rememberedPositionMs),
            attachedLrcPath: Value(lrcPath),
            lyricOffsetMs: Value(current?.lyricOffsetMs ?? 0),
            customArtPath: Value(current?.customArtPath),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> setLyricOffset(String stableKey, int offsetMs) async {
    final current = await (_db.select(
      _db.trackUserMeta,
    )..where((t) => t.stableKey.equals(stableKey))).getSingleOrNull();
    await _db
        .into(_db.trackUserMeta)
        .insert(
          TrackUserMetaCompanion.insert(
            stableKey: stableKey,
            isFavorite: Value(current?.isFavorite ?? false),
            playCount: Value(current?.playCount ?? 0),
            lastPlayedAt: Value(current?.lastPlayedAt),
            rememberedPositionMs: Value(current?.rememberedPositionMs),
            attachedLrcPath: Value(current?.attachedLrcPath),
            lyricOffsetMs: Value(offsetMs),
            customArtPath: Value(current?.customArtPath),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> setCustomArtPath(String stableKey, String? artPath) async {
    final current = await (_db.select(
      _db.trackUserMeta,
    )..where((t) => t.stableKey.equals(stableKey))).getSingleOrNull();
    await _db
        .into(_db.trackUserMeta)
        .insert(
          TrackUserMetaCompanion.insert(
            stableKey: stableKey,
            isFavorite: Value(current?.isFavorite ?? false),
            playCount: Value(current?.playCount ?? 0),
            lastPlayedAt: Value(current?.lastPlayedAt),
            rememberedPositionMs: Value(current?.rememberedPositionMs),
            attachedLrcPath: Value(current?.attachedLrcPath),
            lyricOffsetMs: Value(current?.lyricOffsetMs ?? 0),
            customArtPath: Value(artPath),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> markCorruptOrMissing(String stableKey, bool corrupt) async {
    await (_db.update(_db.tracks)..where((t) => t.stableKey.equals(stableKey)))
        .write(TracksCompanion(isCorruptOrMissing: Value(corrupt)));
  }

  Future<void> markCloudPending(String stableKey, bool pending) async {
    await (_db.update(_db.tracks)..where((t) => t.stableKey.equals(stableKey)))
        .write(TracksCompanion(isCloudPending: Value(pending)));
  }

  static List<AlbumGroup> groupAlbums(
    List<WetarTrack> tracks, {
    String fallbackAlbum = 'Unknown Album',
    String fallbackArtist = 'Unknown Artist',
  }) {
    final map = <String, List<WetarTrack>>{};
    for (final t in tracks) {
      map.putIfAbsent(t.albumKey, () => <WetarTrack>[]).add(t);
    }
    final groups = <AlbumGroup>[];
    for (final entry in map.entries) {
      final sorted = List<WetarTrack>.from(entry.value)
        ..sort((a, b) {
          final discCmp = a.discNumber.compareTo(b.discNumber);
          return discCmp != 0
              ? discCmp
              : a.trackNumber.compareTo(b.trackNumber);
        });
      final first = sorted.first;
      groups.add(
        AlbumGroup(
          albumKey: entry.key,
          name: first.resolvedAlbum(fallbackAlbum),
          artist: first.hasKnownAlbumArtist
              ? first.albumArtist.trim()
              : first.resolvedArtist(fallbackArtist),
          year: first.year,
          tracks: sorted,
        ),
      );
    }
    groups.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return groups;
  }

  static List<ArtistGroup> groupArtists(
    List<WetarTrack> tracks, {
    List<String> separators = ArtistSplitter.defaultSeparators,
    bool useAlbumArtist = false,
    String fallbackArtist = 'Unknown Artist',
  }) {
    final map = <String, List<WetarTrack>>{};
    for (final t in tracks) {
      if (useAlbumArtist) {
        final raw = t.hasKnownAlbumArtist
            ? t.albumArtist.trim()
            : t.resolvedArtist(fallbackArtist);
        map.putIfAbsent(raw, () => <WetarTrack>[]).add(t);
      } else {
        final split = ArtistSplitter.split(
          t.artist,
          separators: separators,
          fallback: fallbackArtist,
        );
        for (final name in split) {
          map.putIfAbsent(name, () => <WetarTrack>[]).add(t);
        }
      }
    }
    final groups = map.entries.map((entry) {
      final albums = entry.value.map((e) => e.albumKey).toSet().length;
      return ArtistGroup(
        name: entry.key,
        tracks: entry.value,
        albumCount: albums,
      );
    }).toList();
    groups.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return groups;
  }

  static List<FacetGroup> groupGenres(
    List<WetarTrack> tracks, {
    String fallbackGenre = 'Unknown Genre',
  }) {
    final map = <String, List<WetarTrack>>{};
    for (final t in tracks) {
      final key = t.genre.trim().isNotEmpty ? t.genre.trim() : fallbackGenre;
      map.putIfAbsent(key, () => <WetarTrack>[]).add(t);
    }
    return map.entries
        .map((e) => FacetGroup(label: e.key, tracks: e.value))
        .toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
  }

  static List<FacetGroup> groupYears(List<WetarTrack> tracks) {
    final map = <int, List<WetarTrack>>{};
    for (final t in tracks) {
      final decade = t.year > 1900 ? (t.year ~/ 10) * 10 : 0;
      map.putIfAbsent(decade, () => <WetarTrack>[]).add(t);
    }
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys
        .map(
          (decade) => FacetGroup(
            label: decade > 0 ? '${decade}s' : '—',
            tracks: map[decade]!,
          ),
        )
        .toList();
  }

  WetarTrack _mapRowToTrack(QueryRow row) {
    return WetarTrack(
      stableKey: row.read<String>('stable_key'),
      folderId: row.read<int>('folder_id'),
      uri: row.read<String>('uri'),
      filePath: row.read<String>('file_path'),
      folderPath: row.read<String>('folder_path'),
      title: row.read<String>('title'),
      artist: row.read<String>('artist'),
      album: row.read<String>('album'),
      albumArtist: row.read<String>('album_artist'),
      genre: row.read<String>('genre'),
      year: row.read<int>('year'),
      trackNumber: row.read<int>('track_number'),
      discNumber: row.read<int>('disc_number'),
      durationMs: row.read<int>('duration_ms'),
      bitrateKbps: row.read<int>('bitrate_kbps'),
      sampleRateHz: row.read<int>('sample_rate_hz'),
      channels: row.read<int>('channels'),
      sizeBytes: row.read<int>('size_bytes'),
      mimeType: row.read<String>('mime_type'),
      dateModifiedSec: row.read<int>('date_modified_sec'),
      dateAddedSec: row.read<int>('date_added_sec'),
      artworkUri: row.readNullable<String>('artwork_uri'),
      embeddedLyrics: row.readNullable<String>('embedded_lyrics'),
      replayGainTrackDb: row.readNullable<double>('replay_gain_track_db'),
      replayGainAlbumDb: row.readNullable<double>('replay_gain_album_db'),
      isFavorite: row.read<int>('meta_is_favorite') != 0,
      playCount: row.read<int>('meta_play_count'),
      lastPlayedAt: row.readNullable<int>('meta_last_played_at'),
      rememberedPositionMs: row.readNullable<int>(
        'meta_remembered_position_ms',
      ),
      attachedLrcPath: row.readNullable<String>('meta_attached_lrc_path'),
      lyricOffsetMs: row.read<int>('meta_lyric_offset_ms'),
      customArtPath: row.readNullable<String>('meta_custom_art_path'),
      isCloudPending: row.read<bool>('is_cloud_pending'),
      isCorruptOrMissing: row.read<bool>('is_corrupt_or_missing'),
    );
  }
}
