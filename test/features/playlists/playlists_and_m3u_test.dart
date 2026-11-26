import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/features/library/data/library_repository.dart';
import 'package:wetar/features/music_folders/data/music_folders_repository.dart';
import 'package:wetar/features/playlists/data/playlists_repository.dart';

class _Source implements LibrarySource {
  @override
  Future<List<DiscoveredAudioFolder>> listAudioFolders() async =>
      const <DiscoveredAudioFolder>[];

  @override
  Future<FolderScanResult> scanSelectedFolders({
    required List<FolderScanRequest> folders,
    required Map<String, int> existingModifiedByStableKey,
  }) async {
    final fid = folders.first.id;
    return FolderScanResult(
      availableFolderIds: <int>{fid},
      activeStableKeys: const <String>{'/music/a.mp3', '/music/b.mp3'},
      changedTracks: <ScannedTrackDto>[
        ScannedTrackDto(
          stableKey: '/music/a.mp3',
          folderId: fid,
          uri: 'file:///music/a.mp3',
          filePath: '/music/a.mp3',
          folderPath: '/music',
          title: 'Track A',
          artist: 'Artist A',
          durationMs: 180000,
        ),
        ScannedTrackDto(
          stableKey: '/music/b.mp3',
          folderId: fid,
          uri: 'file:///music/b.mp3',
          filePath: '/music/b.mp3',
          folderPath: '/music',
          title: 'Track B',
          artist: 'Artist B',
          durationMs: 210000,
        ),
      ],
    );
  }

  @override
  Future<String?> loadAlbumArtThumbnail({
    required String? uri,
    required String? filePath,
    required String outputPath,
    int sizePx = 256,
  }) async => null;
}

class _Picker implements FolderPickerService {
  @override
  Future<PickedFolderResult?> pickSystemFolder() async => null;
  @override
  Future<bool> resolveBookmark(String bookmarkData) async => true;
  @override
  Future<void> stopAccessingBookmark(String bookmarkData) async {}
  @override
  Future<void> startWatchingFolders(List<String> paths) async {}
  @override
  Future<String?> pickFile({required List<String> mimeTypes}) async => null;

  @override
  Future<String?> pickGalleryImage() async => null;
  @override
  Future<bool> saveFile({
    required String fileName,
    required String mimeType,
    dynamic bytes,
    String? sourcePath,
  }) async => false;
  @override
  Future<bool> shareFiles({
    required List<String> paths,
    required String mimeType,
    String? subject,
  }) async => false;
}

void main() {
  late WetarDatabase db;
  late MusicFoldersRepository foldersRepo;
  late LibraryRepository libraryRepo;
  late PlaylistsRepository playlistsRepo;

  setUp(() async {
    db = WetarDatabase(NativeDatabase.memory());
    foldersRepo = MusicFoldersRepository(db, _Source(), _Picker());
    libraryRepo = LibraryRepository(db);
    playlistsRepo = PlaylistsRepository(db, libraryRepo);
  });

  tearDown(() async {
    await foldersRepo.dispose();
    await db.close();
  });

  test('playlists hide out-of-scope tracks when folder removed and restore them on re-add', () async {
    final folder = await foldersRepo.addOrReactivateFolder(
      rootPath: '/music',
      displayName: 'Music',
    );
    final tracks = await libraryRepo.fetchLibraryTracks();
    final pid = await playlistsRepo.createPlaylist('Evening Oud');
    await playlistsRepo.addTracksToPlaylist(pid, tracks);
    expect(await playlistsRepo.getPlaylistTracks(pid), hasLength(2));

    // Reorder and encode M3U
    await playlistsRepo.reorderPlaylist(pid, tracks.reversed.toList());
    final reordered = await playlistsRepo.getPlaylistTracks(pid);
    expect(reordered.first.stableKey, '/music/b.mp3');
    final m3u = PlaylistsRepository.encodeM3u('Evening Oud', reordered);
    expect(m3u, contains('#EXTM3U'));
    expect(m3u, contains('/music/b.mp3'));

    // Removing folder hides playlist entries cleanly without deleting them.
    await foldersRepo.removeFolder(folder.id);
    expect(await playlistsRepo.getPlaylistTracks(pid), isEmpty);

    // Re-adding folder restores the playlist entries in order.
    await foldersRepo.addOrReactivateFolder(
      rootPath: '/music',
      displayName: 'Music',
    );
    final restored = await playlistsRepo.getPlaylistTracks(pid);
    expect(restored, hasLength(2));
  });
}
