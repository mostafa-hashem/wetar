import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/features/library/data/library_repository.dart';
import 'package:wetar/features/music_folders/data/music_folders_repository.dart';
import 'package:wetar/features/music_folders/domain/scan_diff_engine.dart';

class _FakeLibrarySource implements LibrarySource {
  List<ScannedTrackDto> nextTracks = <ScannedTrackDto>[];
  Set<int> availableIds = <int>{};

  @override
  Future<List<DiscoveredAudioFolder>> listAudioFolders() async =>
      const <DiscoveredAudioFolder>[
        DiscoveredAudioFolder(
          rootPath: '/storage/emulated/0/Music',
          displayName: 'Music',
          volumeLabel: 'Internal Storage',
          trackCount: 2,
          sourceKind: 'mediastore',
        ),
      ];

  @override
  Future<FolderScanResult> scanSelectedFolders({
    required List<FolderScanRequest> folders,
    required Map<String, int> existingModifiedByStableKey,
  }) async {
    return FolderScanResult(
      availableFolderIds: availableIds,
      activeStableKeys: nextTracks.map((t) => t.stableKey).toSet(),
      changedTracks: nextTracks,
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

class _FakePicker implements FolderPickerService {
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
  late _FakeLibrarySource fakeSource;
  late MusicFoldersRepository foldersRepo;
  late LibraryRepository libraryRepo;

  setUp(() {
    db = WetarDatabase(NativeDatabase.memory());
    fakeSource = _FakeLibrarySource();
    foldersRepo = MusicFoldersRepository(db, fakeSource, _FakePicker());
    libraryRepo = LibraryRepository(db);
  });

  tearDown(() async {
    await foldersRepo.dispose();
    await db.close();
  });

  test('folder-whitelist isolates tracks and preserves favorites when folder removed/restored', () async {
    fakeSource.availableIds = <int>{1};
    fakeSource.nextTracks = <ScannedTrackDto>[
      const ScannedTrackDto(
        stableKey: '/music/oud.mp3',
        folderId: 1,
        uri: 'file:///music/oud.mp3',
        filePath: '/music/oud.mp3',
        folderPath: '/music',
        title: 'تقاسيم عود',
        artist: 'Farid',
        durationMs: 120000,
        dateModifiedSec: 100,
      ),
    ];

    final folder = await foldersRepo.addOrReactivateFolder(
      rootPath: '/music',
      displayName: 'Music',
    );
    var tracks = await libraryRepo.fetchLibraryTracks(minDurationSec: 30);
    expect(tracks, hasLength(1));
    expect(tracks.first.title, 'تقاسيم عود');

    await libraryRepo.toggleFavorite('/music/oud.mp3', value: true);
    tracks = await libraryRepo.fetchLibraryTracks(minDurationSec: 30);
    expect(tracks.first.isFavorite, isTrue);

    // Removing the folder drops tracks immediately while keeping TrackUserMeta safe.
    await foldersRepo.removeFolder(folder.id);
    expect(await libraryRepo.fetchLibraryTracks(minDurationSec: 30), isEmpty);

    // Re-adding the folder restores the track AND its hidden favorite flag!
    fakeSource.availableIds = <int>{2};
    fakeSource.nextTracks = <ScannedTrackDto>[
      const ScannedTrackDto(
        stableKey: '/music/oud.mp3',
        folderId: 2,
        uri: 'file:///music/oud.mp3',
        filePath: '/music/oud.mp3',
        folderPath: '/music',
        title: 'تقاسيم عود',
        artist: 'Farid',
        durationMs: 120000,
        dateModifiedSec: 100,
      ),
    ];
    await foldersRepo.addOrReactivateFolder(
      rootPath: '/music',
      displayName: 'Music',
    );
    final restored = await libraryRepo.fetchLibraryTracks(minDurationSec: 30);
    expect(restored, hasLength(1));
    expect(restored.first.isFavorite, isTrue);
  });

  test('ScanDiffEngine computes incremental upserts and deletes', () {
    final plan = ScanDiffEngine.compute(
      scannedFolderIds: <int>{1},
      existing: const <ExistingTrackSignature>[
        ExistingTrackSignature(
          stableKey: 'a.mp3',
          folderId: 1,
          dateModifiedSec: 10,
          sizeBytes: 1000,
        ),
        ExistingTrackSignature(
          stableKey: 'deleted.mp3',
          folderId: 1,
          dateModifiedSec: 10,
          sizeBytes: 1000,
        ),
      ],
      scannedResult: const FolderScanResult(
        availableFolderIds: <int>{1},
        activeStableKeys: <String>{'a.mp3', 'new.mp3'},
        changedTracks: <ScannedTrackDto>[
          ScannedTrackDto(
            stableKey: 'new.mp3',
            folderId: 1,
            uri: 'file:///new.mp3',
            filePath: '/new.mp3',
            folderPath: '/',
            title: 'New Track',
          ),
        ],
      ),
    );
    expect(plan.tracksToUpsert.map((e) => e.stableKey), <String>['new.mp3']);
    expect(plan.staleStableKeysToDelete, <String>['deleted.mp3']);
  });

  test('purgeNonAudioTracks removes stale video rows and updates folder track count', () async {
    fakeSource.availableIds = <int>{1};
    fakeSource.nextTracks = <ScannedTrackDto>[
      const ScannedTrackDto(
        stableKey: '/music/song.opus',
        folderId: 1,
        uri: 'file:///music/song.opus',
        filePath: '/music/song.opus',
        folderPath: '/music',
        title: 'Opus Song',
        durationMs: 0,
        mimeType: 'audio/opus',
        dateModifiedSec: 100,
      ),
      const ScannedTrackDto(
        stableKey: '/music/short_notif.mp3',
        folderId: 1,
        uri: 'file:///music/short_notif.mp3',
        filePath: '/music/short_notif.mp3',
        folderPath: '/music',
        title: 'Short Notification',
        durationMs: 10000,
        mimeType: 'audio/mpeg',
        dateModifiedSec: 100,
      ),
      const ScannedTrackDto(
        stableKey: '/music/video.mp4',
        folderId: 1,
        uri: 'file:///music/video.mp4',
        filePath: '/music/video.mp4',
        folderPath: '/music',
        title: 'Music Video',
        durationMs: 180000,
        mimeType: 'video/mp4',
        dateModifiedSec: 100,
      ),
    ];

    await foldersRepo.addOrReactivateFolder(
      rootPath: '/music',
      displayName: 'Music',
    );

    // Purge removes the video row and keeps both audio rows in the folder count.
    await foldersRepo.purgeNonAudioTracks();
    final folders = await foldersRepo.getSelectedFolders();
    expect(folders.single.trackCount, 2);

    // LibraryRepository includes durationMs == 0 audio tracks while filtering out 10s clips.
    final visibleTracks = await libraryRepo.fetchLibraryTracks(
      minDurationSec: 30,
    );
    expect(visibleTracks.map((t) => t.stableKey), <String>['/music/song.opus']);
  });
}
