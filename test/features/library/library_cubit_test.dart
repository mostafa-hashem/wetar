import 'package:bloc_test/bloc_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/features/library/data/library_repository.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/library/presentation/bloc/library_cubit.dart';
import 'package:wetar/features/music_folders/data/music_folders_repository.dart';

class _SeedSource implements LibrarySource {
  @override
  Future<List<DiscoveredAudioFolder>> listAudioFolders() async =>
      const <DiscoveredAudioFolder>[];

  @override
  Future<FolderScanResult> scanSelectedFolders({
    required List<FolderScanRequest> folders,
    required Map<String, int> existingModifiedByStableKey,
  }) async {
    return const FolderScanResult(
      availableFolderIds: <int>{1},
      activeStableKeys: <String>{'/a.mp3', '/b.mp3'},
      changedTracks: <ScannedTrackDto>[
        ScannedTrackDto(
          stableKey: '/b.mp3',
          folderId: 1,
          uri: 'file:///b.mp3',
          filePath: '/b.mp3',
          folderPath: '/',
          title: 'Zeta Track',
          artist: 'Artist B',
          durationMs: 90000,
        ),
        ScannedTrackDto(
          stableKey: '/a.mp3',
          folderId: 1,
          uri: 'file:///a.mp3',
          filePath: '/a.mp3',
          folderPath: '/',
          title: 'Alpha Track',
          artist: 'Artist A',
          durationMs: 120000,
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

class _StubPicker implements FolderPickerService {
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
  late LibraryRepository repo;
  late MusicFoldersRepository foldersRepo;

  setUp(() async {
    db = WetarDatabase(NativeDatabase.memory());
    foldersRepo = MusicFoldersRepository(db, _SeedSource(), _StubPicker());
    repo = LibraryRepository(db);
    await foldersRepo.addOrReactivateFolder(rootPath: '/', displayName: 'Root');
  });

  tearDown(() async {
    await foldersRepo.dispose();
    await db.close();
  });

  blocTest<LibraryCubit, LibraryState>(
    'toggles sort order and multi-select state cleanly',
    build: () => LibraryCubit(repo, minDurationSec: 30),
    wait: const Duration(milliseconds: 80),
    act: (cubit) {
      cubit.setSort(LibrarySortField.duration, ascending: false);
      cubit.toggleTrackSelection('/a.mp3');
      cubit.selectAllVisible();
      cubit.clearSelection();
    },
    verify: (cubit) {
      expect(cubit.state.allTracks, hasLength(2));
      expect(cubit.state.sortedTracks.first.stableKey, '/a.mp3');
      expect(cubit.state.isSelectionMode, isFalse);
    },
  );
}
