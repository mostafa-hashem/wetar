import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/database/wetar_database.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/platform/platform_interfaces.dart';
import '../../../core/utils/arabic_normalizer.dart';
import '../domain/audio_format_policy.dart';
import '../domain/music_folder_models.dart';
import '../domain/scan_diff_engine.dart';

/// Owns the user-selected folder whitelist and incremental folder-scoped scanning.
/// Never triggers full-device scans and never modifies or deletes user audio files.
class MusicFoldersRepository {
  MusicFoldersRepository(
    this._db,
    this._librarySource,
    this._folderPickerService,
  );

  final WetarDatabase _db;
  final LibrarySource _librarySource;
  final FolderPickerService _folderPickerService;

  final StreamController<ScanProgress> _scanController =
      StreamController<ScanProgress>.broadcast();
  bool _cancelRequested = false;

  Stream<ScanProgress> get scanProgressStream => _scanController.stream;

  void cancelCurrentScan() {
    _cancelRequested = true;
    _scanController.add(const ScanProgress.idle());
  }

  /// Watches all selected folders with live per-folder track counts.
  Stream<List<SelectedFolderEntity>> watchSelectedFolders() {
    const sql = '''
      SELECT sf.*,
             (SELECT COUNT(*) FROM tracks t WHERE t.folder_id = sf.id) AS track_count
      FROM selected_folders sf
      ORDER BY sf.display_name COLLATE NOCASE ASC
    ''';
    return _db
        .customSelect(
          sql,
          readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
            _db.selectedFolders,
            _db.tracks,
          },
        )
        .watch()
        .map((rows) {
          return rows.map((r) {
            return SelectedFolderEntity(
              id: r.read<int>('id'),
              rootPath: r.read<String>('root_path'),
              sourceKind: r.read<String>('source_kind'),
              bookmarkData: r.readNullable<String>('bookmark_data'),
              displayName: r.read<String>('display_name'),
              volumeLabel: r.read<String>('volume_label'),
              includeSubfolders: r.read<bool>('include_subfolders'),
              excludedSubfolders: SelectedFolderEntity.decodeExcluded(
                r.read<String>('excluded_subfolders_json'),
              ),
              isAvailable: r.read<bool>('is_available'),
              addedAt: r.read<int>('added_at'),
              lastScannedAt: r.read<int>('last_scanned_at'),
              trackCount: r.read<int>('track_count'),
            );
          }).toList();
        });
  }

  Future<List<SelectedFolderEntity>> getSelectedFolders() async {
    return watchSelectedFolders().first;
  }

  Future<List<DiscoveredAudioFolder>> discoverDeviceAudioFolders() {
    return _librarySource.listAudioFolders();
  }

  /// Applies a chosen batch from the in-app picker incrementally:
  /// newly checked folders are added & scanned; unchecked folders are removed immediately.
  Future<void> applyFolderSelection(
    List<DiscoveredAudioFolder> desiredFolders,
  ) async {
    final existing = await (_db.select(_db.selectedFolders)).get();
    final existingByPath = <String, SelectedFolder>{
      for (final f in existing) f.rootPath: f,
    };
    final desiredPaths = desiredFolders.map((d) => d.rootPath).toSet();

    // Remove unselected MediaStore/filesystem folders (preserving SAF/bookmark folders unless removed explicitly).
    for (final folder in existing) {
      if (folder.sourceKind == 'mediastore' &&
          !desiredPaths.contains(folder.rootPath)) {
        await (_db.delete(
          _db.selectedFolders,
        )..where((t) => t.id.equals(folder.id))).go();
      }
    }

    final newlyAddedIds = <int>[];
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final candidate in desiredFolders) {
      if (existingByPath.containsKey(candidate.rootPath)) continue;
      final id = await _db
          .into(_db.selectedFolders)
          .insert(
            SelectedFoldersCompanion.insert(
              rootPath: candidate.rootPath,
              sourceKind: Value(candidate.sourceKind),
              bookmarkData: Value(candidate.bookmarkData),
              displayName: candidate.displayName,
              volumeLabel: Value(candidate.volumeLabel),
              addedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      if (id > 0) newlyAddedIds.add(id);
    }

    if (newlyAddedIds.isNotEmpty) {
      await scanFoldersByIds(newlyAddedIds);
    }
    await _refreshPlatformWatchers();
  }

  Future<SelectedFolderEntity?> addSystemPickedFolder() async {
    final picked = await _folderPickerService.pickSystemFolder();
    if (picked == null) return null;
    final folder = await addOrReactivateFolder(
      rootPath: picked.rootPath,
      displayName: picked.displayName,
      sourceKind: picked.sourceKind,
      bookmarkData: picked.bookmarkData,
    );
    return folder;
  }

  Future<SelectedFolderEntity> addOrReactivateFolder({
    required String rootPath,
    required String displayName,
    String sourceKind = 'mediastore',
    String volumeLabel = 'Device Storage',
    String? bookmarkData,
  }) async {
    final existing = await (_db.select(
      _db.selectedFolders,
    )..where((t) => t.rootPath.equals(rootPath))).getSingleOrNull();
    final now = DateTime.now().millisecondsSinceEpoch;
    final int id;
    if (existing != null) {
      id = existing.id;
      await (_db.update(
        _db.selectedFolders,
      )..where((t) => t.id.equals(id))).write(
        SelectedFoldersCompanion(
          isAvailable: const Value(true),
          bookmarkData: bookmarkData != null
              ? Value(bookmarkData)
              : const Value.absent(),
        ),
      );
    } else {
      id = await _db
          .into(_db.selectedFolders)
          .insert(
            SelectedFoldersCompanion.insert(
              rootPath: rootPath,
              sourceKind: Value(sourceKind),
              bookmarkData: Value(bookmarkData),
              displayName: displayName,
              volumeLabel: Value(volumeLabel),
              addedAt: now,
            ),
          );
    }

    await scanFoldersByIds(<int>[id]);
    await _refreshPlatformWatchers();
    final all = await getSelectedFolders();
    return all.firstWhere((f) => f.id == id);
  }

  Future<void> removeFolder(int folderId) async {
    final existing = await (_db.select(
      _db.selectedFolders,
    )..where((t) => t.id.equals(folderId))).getSingleOrNull();
    if (existing?.bookmarkData != null) {
      await _folderPickerService.stopAccessingBookmark(existing!.bookmarkData!);
    }
    await (_db.delete(
      _db.selectedFolders,
    )..where((t) => t.id.equals(folderId))).go();
    await _refreshPlatformWatchers();
  }

  Future<void> setIncludeSubfolders(int folderId, bool include) async {
    await (_db.update(_db.selectedFolders)..where((t) => t.id.equals(folderId)))
        .write(SelectedFoldersCompanion(includeSubfolders: Value(include)));
    await scanFoldersByIds(<int>[folderId]);
  }

  Future<void> setExcludedSubfolders(
    int folderId,
    List<String> excludedPaths,
  ) async {
    await (_db.update(
      _db.selectedFolders,
    )..where((t) => t.id.equals(folderId))).write(
      SelectedFoldersCompanion(
        excludedSubfoldersJson: Value(
          SelectedFolderEntity.encodeExcluded(excludedPaths),
        ),
      ),
    );
    await scanFoldersByIds(<int>[folderId]);
  }

  /// Removes any previously indexed non-audio/video rows from the tracks table.
  Future<void> purgeNonAudioTracks() async {
    final rows = await _db
        .customSelect('SELECT stable_key, file_path, mime_type FROM tracks')
        .get();
    final invalidKeys = <String>[];
    for (final row in rows) {
      final key = row.read<String>('stable_key');
      final filePath = row.read<String>('file_path');
      final mimeType = row.read<String>('mime_type');
      final isVideo = AudioFormatPolicy.isVideoFile(
        pathOrName: filePath,
        mimeType: mimeType,
      );
      final isUnsupportedLocal =
          !filePath.startsWith('content://') &&
          !AudioFormatPolicy.isSupportedAudioFile(
            pathOrName: filePath,
            mimeType: mimeType,
          );
      if (isVideo || isUnsupportedLocal) {
        invalidKeys.add(key);
      }
    }
    if (invalidKeys.isEmpty) return;
    for (var i = 0; i < invalidKeys.length; i += 400) {
      final chunk = invalidKeys.sublist(
        i,
        (i + 400).clamp(0, invalidKeys.length),
      );
      await (_db.delete(
        _db.tracks,
      )..where((t) => t.stableKey.isIn(chunk))).go();
    }
  }

  /// Resolves bookmarks on Apple platforms and incrementally reconciles all selected folders.
  Future<void> reconcileAllSelectedFolders() async {
    await purgeNonAudioTracks();
    final folders = await (_db.select(_db.selectedFolders)).get();
    if (folders.isEmpty) return;
    for (final folder in folders) {
      if (folder.bookmarkData != null && folder.bookmarkData!.isNotEmpty) {
        await _folderPickerService.resolveBookmark(folder.bookmarkData!);
      }
    }
    await scanFoldersByIds(folders.map((f) => f.id).toList());
    await _refreshPlatformWatchers();
  }

  /// Scans ONLY the specified folder IDs, comparing modification times to minimize I/O.
  Future<void> scanFoldersByIds(List<int> folderIds) async {
    if (folderIds.isEmpty) return;
    _cancelRequested = false;
    await purgeNonAudioTracks();
    final targetRows = await (_db.select(
      _db.selectedFolders,
    )..where((t) => t.id.isIn(folderIds))).get();
    if (targetRows.isEmpty) return;

    try {
      _scanController.add(
        ScanProgress(
          isScanning: true,
          currentFolderName: targetRows.first.displayName,
          processedCount: 0,
          totalCount: targetRows.length,
        ),
      );

      final existingTrackRows = await (_db.select(
        _db.tracks,
      )..where((t) => t.folderId.isIn(folderIds))).get();
      final existingModifiedMap = <String, int>{
        for (final t in existingTrackRows)
          if (t.durationMs > 0 || t.isCloudPending)
            t.stableKey: t.dateModifiedSec,
      };
      final existingSignatures = existingTrackRows
          .map(
            (t) => ExistingTrackSignature(
              stableKey: t.stableKey,
              folderId: t.folderId,
              dateModifiedSec: t.dateModifiedSec,
              sizeBytes: t.sizeBytes,
              durationMs: t.durationMs,
            ),
          )
          .toList();

      final requests = targetRows
          .map(
            (f) => FolderScanRequest(
              id: f.id,
              rootPath: f.rootPath,
              sourceKind: f.sourceKind,
              includeSubfolders: f.includeSubfolders,
              excludedSubfolders: SelectedFolderEntity.decodeExcluded(
                f.excludedSubfoldersJson,
              ),
              bookmarkData: f.bookmarkData,
            ),
          )
          .toList();

      final result = await _librarySource.scanSelectedFolders(
        folders: requests,
        existingModifiedByStableKey: existingModifiedMap,
      );

      if (_cancelRequested) {
        AppLogger.info('MusicFolders', 'Incremental scan cancelled by user');
        return;
      }

      // Preserve unavailable folders safely without erasing their selection or tracks
      // when storage temporarily disconnects; mark availability status explicitly.
      final now = DateTime.now().millisecondsSinceEpoch;
      final availableFolderIds = result.availableFolderIds;
      for (final folder in targetRows) {
        final isAvail = availableFolderIds.contains(folder.id);
        await (_db.update(
          _db.selectedFolders,
        )..where((t) => t.id.equals(folder.id))).write(
          SelectedFoldersCompanion(
            isAvailable: Value(isAvail),
            lastScannedAt: isAvail ? Value(now) : const Value.absent(),
          ),
        );
      }

      // Only prune missing files inside folders confirmed available right now.
      final diff = ScanDiffEngine.compute(
        scannedFolderIds: availableFolderIds,
        existing: existingSignatures,
        scannedResult: result,
      );

      await _db.transaction(() async {
        if (diff.staleStableKeysToDelete.isNotEmpty) {
          for (var i = 0; i < diff.staleStableKeysToDelete.length; i += 400) {
            final chunk = diff.staleStableKeysToDelete.sublist(
              i,
              (i + 400).clamp(0, diff.staleStableKeysToDelete.length),
            );
            await (_db.delete(
              _db.tracks,
            )..where((t) => t.stableKey.isIn(chunk))).go();
          }
        }

        if (diff.tracksToUpsert.isNotEmpty) {
          const chunkSize = 200;
          for (var i = 0; i < diff.tracksToUpsert.length; i += chunkSize) {
            if (_cancelRequested) break;
            final chunk = diff.tracksToUpsert.sublist(
              i,
              (i + chunkSize).clamp(0, diff.tracksToUpsert.length),
            );
            await _db.batch((Batch batch) {
              for (final dto in chunk) {
                batch.insert(
                  _db.tracks,
                  TracksCompanion.insert(
                    stableKey: dto.stableKey,
                    folderId: dto.folderId,
                    uri: dto.uri,
                    filePath: dto.filePath,
                    folderPath: dto.folderPath,
                    title: dto.title,
                    titleNormalized: ArabicNormalizer.normalize(dto.title),
                    artist: Value(dto.artist ?? ''),
                    artistNormalized: Value(
                      ArabicNormalizer.normalize(dto.artist ?? ''),
                    ),
                    album: Value(dto.album ?? ''),
                    albumNormalized: Value(
                      ArabicNormalizer.normalize(dto.album ?? ''),
                    ),
                    albumArtist: Value(dto.albumArtist ?? ''),
                    genre: Value(dto.genre ?? ''),
                    year: Value(dto.year),
                    trackNumber: Value(dto.trackNumber),
                    discNumber: Value(dto.discNumber),
                    durationMs: Value(dto.durationMs),
                    bitrateKbps: Value(dto.bitrateKbps),
                    sampleRateHz: Value(dto.sampleRateHz),
                    channels: Value(dto.channels),
                    sizeBytes: Value(dto.sizeBytes),
                    mimeType: Value(dto.mimeType),
                    dateModifiedSec: Value(dto.dateModifiedSec),
                    dateAddedSec: Value(dto.dateAddedSec),
                    artworkUri: Value(dto.artworkUri),
                    embeddedLyrics: Value(dto.embeddedLyrics),
                    replayGainTrackDb: Value(dto.replayGainTrackDb),
                    replayGainAlbumDb: Value(dto.replayGainAlbumDb),
                    isCloudPending: Value(dto.isCloudPending),
                    isCorruptOrMissing: const Value(false),
                  ),
                  mode: InsertMode.insertOrReplace,
                );
              }
            });
            _scanController.add(
              ScanProgress(
                isScanning: true,
                currentFolderName: targetRows.first.displayName,
                processedCount: (i + chunk.length).clamp(
                  0,
                  diff.tracksToUpsert.length,
                ),
                totalCount: diff.tracksToUpsert.length,
              ),
            );
          }
        }
      });

      AppLogger.info(
        'MusicFolders',
        'Scanned ${targetRows.length} folder(s): upserted=${diff.tracksToUpsert.length}, deleted=${diff.staleStableKeysToDelete.length}',
      );
    } catch (e, st) {
      AppLogger.error(
        'MusicFolders',
        'scanFoldersByIds failed',
        errorObj: e,
        stackTrace: st,
      );
      rethrow;
    } finally {
      _scanController.add(const ScanProgress.idle());
    }
  }

  Future<void> _refreshPlatformWatchers() async {
    if (!Platform.isMacOS) return;
    final available = await (_db.select(
      _db.selectedFolders,
    )..where((t) => t.isAvailable.equals(true))).get();
    await _folderPickerService.startWatchingFolders(
      available.map((e) => e.rootPath).toList(),
    );
  }

  Future<void> dispose() async {
    await _scanController.close();
  }
}
