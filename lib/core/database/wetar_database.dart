import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'wetar_database.g.dart';

/// User-selected music folders (the sole whitelist source of the Wetar library).
class SelectedFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rootPath => text().unique()();
  TextColumn get sourceKind =>
      text().withDefault(const Constant('mediastore'))();
  TextColumn get bookmarkData => text().nullable()();
  TextColumn get displayName => text()();
  TextColumn get volumeLabel =>
      text().withDefault(const Constant('Device Storage'))();
  BoolColumn get includeSubfolders =>
      boolean().withDefault(const Constant(true))();
  TextColumn get excludedSubfoldersJson =>
      text().withDefault(const Constant('[]'))();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  IntColumn get addedAt => integer()();
  IntColumn get lastScannedAt => integer().withDefault(const Constant(0))();
}

/// Cached track metadata strictly owned by a row in SelectedFolders.
class Tracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get stableKey => text().unique()();
  IntColumn get folderId =>
      integer().references(SelectedFolders, #id, onDelete: KeyAction.cascade)();
  TextColumn get uri => text()();
  TextColumn get filePath => text()();
  TextColumn get folderPath => text()();
  TextColumn get title => text()();
  TextColumn get titleNormalized => text()();
  TextColumn get artist => text().withDefault(const Constant(''))();
  TextColumn get artistNormalized => text().withDefault(const Constant(''))();
  TextColumn get album => text().withDefault(const Constant(''))();
  TextColumn get albumNormalized => text().withDefault(const Constant(''))();
  TextColumn get albumArtist => text().withDefault(const Constant(''))();
  TextColumn get genre => text().withDefault(const Constant(''))();
  IntColumn get year => integer().withDefault(const Constant(0))();
  IntColumn get trackNumber => integer().withDefault(const Constant(0))();
  IntColumn get discNumber => integer().withDefault(const Constant(1))();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get bitrateKbps => integer().withDefault(const Constant(0))();
  IntColumn get sampleRateHz => integer().withDefault(const Constant(0))();
  IntColumn get channels => integer().withDefault(const Constant(2))();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get mimeType => text().withDefault(const Constant('audio/*'))();
  IntColumn get dateModifiedSec => integer().withDefault(const Constant(0))();
  IntColumn get dateAddedSec => integer().withDefault(const Constant(0))();
  TextColumn get artworkUri => text().nullable()();
  TextColumn get embeddedLyrics => text().nullable()();
  RealColumn get replayGainTrackDb => real().nullable()();
  RealColumn get replayGainAlbumDb => real().nullable()();
  BoolColumn get isCloudPending =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isCorruptOrMissing =>
      boolean().withDefault(const Constant(false))();
}

/// Extracted HCT artwork palette cached per album key.
class AlbumPalettes extends Table {
  TextColumn get albumKey => text()();
  IntColumn get primaryArgb => integer()();
  IntColumn get secondaryArgb => integer()();
  IntColumn get backgroundArgb => integer()();
  BoolColumn get isDark => boolean()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {albumKey};
}

/// User metadata (favorites, play counts, remembered positions, lyrics offsets)
/// keyed by stableKey so deselecting a folder hides data without deleting it.
class TrackUserMeta extends Table {
  TextColumn get stableKey => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  IntColumn get lastPlayedAt => integer().nullable()();
  IntColumn get rememberedPositionMs => integer().nullable()();
  TextColumn get attachedLrcPath => text().nullable()();
  IntColumn get lyricOffsetMs => integer().withDefault(const Constant(0))();
  TextColumn get customArtPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {stableKey};
}

/// User and smart playlists.
class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get smartKind => text().nullable()();
  TextColumn get customCoverPath => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

/// Ordered playlist items joined dynamically against active SelectedFolders.
class PlaylistEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playlistId =>
      integer().references(Playlists, #id, onDelete: KeyAction.cascade)();
  TextColumn get trackStableKey => text()();
  IntColumn get position => integer()();
  IntColumn get addedAt => integer()();
}

/// Local listening analytics events strictly scoped to user playback.
class PlayHistoryEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get trackStableKey => text()();
  TextColumn get trackTitle => text()();
  TextColumn get artistName => text()();
  TextColumn get albumName => text()();
  IntColumn get playedAt => integer()();
  IntColumn get listenedMs => integer()();
}

/// Persisted playback queue and position snapshot for crash/process-death restore.
class QueueSnapshots extends Table {
  IntColumn get id => integer()();
  TextColumn get itemsJson => text()();
  IntColumn get currentIndex => integer().withDefault(const Constant(0))();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  BoolColumn get shuffleEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get repeatMode => text().withDefault(const Constant('off'))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Saved custom equalizer & audio effect presets.
class EqualizerPresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(true))();
  TextColumn get bandGainsJson => text()();
  IntColumn get bassBoostStrength => integer().withDefault(const Constant(0))();
  IntColumn get virtualizerStrength =>
      integer().withDefault(const Constant(0))();
  IntColumn get loudnessGainMb => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();
}

/// Persisted recent search terms.
class RecentSearches extends Table {
  TextColumn get query => text()();
  TextColumn get normalizedQuery => text()();
  IntColumn get searchedAt => integer()();

  @override
  Set<Column> get primaryKey => {query};
}

@DriftDatabase(
  tables: [
    SelectedFolders,
    Tracks,
    AlbumPalettes,
    TrackUserMeta,
    Playlists,
    PlaylistEntries,
    PlayHistoryEvents,
    QueueSnapshots,
    EqualizerPresets,
    RecentSearches,
  ],
)
class WetarDatabase extends _$WetarDatabase {
  WetarDatabase([QueryExecutor? executor])
    : super(executor ?? _openDefaultConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createIndexes();
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_folder ON tracks(folder_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_title_norm ON tracks(title_normalized)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_album_norm ON tracks(album_normalized)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_artist_norm ON tracks(artist_normalized)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_added ON tracks(date_added_sec DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_playlist_entries_pid ON playlist_entries(playlist_id, position)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_history_played_at ON play_history_events(played_at DESC)',
    );
  }

  static QueryExecutor _openDefaultConnection() {
    return driftDatabase(
      name: 'wetar_library',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
