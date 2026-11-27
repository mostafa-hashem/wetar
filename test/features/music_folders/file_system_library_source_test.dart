import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/features/music_folders/data/file_system_library_source.dart';

void main() {
  test('FileSystemLibrarySource scans folder incrementally, respects exclusions, and flags .icloud files', () async {
    final tempRoot = Directory.systemTemp.createTempSync('wetar_fs_test_');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final includedSub = Directory(p.join(tempRoot.path, 'Albums'))
      ..createSync();
    final excludedSub = Directory(p.join(tempRoot.path, 'VoiceNotes'))
      ..createSync();

    final track1 = File(p.join(tempRoot.path, 'Oud Solo.mp3'))
      ..writeAsBytesSync(<int>[0, 1, 2, 3]);
    final track2 = File(p.join(includedSub.path, 'Andalusian Night.flac'))
      ..writeAsBytesSync(<int>[4, 5, 6, 7]);
    File(p.join(excludedSub.path, 'Note.m4a'))
        .writeAsBytesSync(<int>[8, 9, 10]);
    File(p.join(tempRoot.path, '.hidden.mp3')).writeAsBytesSync(<int>[11, 12]);
    File(p.join(tempRoot.path, '.Samai Bayati.m4a.icloud'))
        .writeAsBytesSync(<int>[1, 2]);
    File(p.join(tempRoot.path, 'readme.txt')).writeAsStringSync('ignore');

    final source = FileSystemLibrarySource();
    final request = FolderScanRequest(
      id: 1,
      rootPath: tempRoot.path,
      sourceKind: 'bookmark',
      includeSubfolders: true,
      excludedSubfolders: <String>[excludedSub.path],
    );

    final firstResult = await source.scanSelectedFolders(
      folders: <FolderScanRequest>[request],
      existingModifiedByStableKey: const <String, int>{},
    );

    expect(firstResult.availableFolderIds, contains(1));
    expect(firstResult.activeStableKeys, hasLength(3));
    expect(firstResult.changedTracks, hasLength(3));

    final titles = firstResult.changedTracks.map((t) => t.title).toSet();
    expect(titles, contains('Oud Solo'));
    expect(titles, contains('Andalusian Night'));
    expect(titles, contains('Samai Bayati'));
    expect(titles, isNot(contains('Note')));
    expect(titles, isNot(contains('hidden')));

    final icloudTrack = firstResult.changedTracks.firstWhere(
      (t) => t.title == 'Samai Bayati',
    );
    expect(icloudTrack.isCloudPending, isTrue);

    // Verify existing mtimes skip redundant parsing on second scan.
    final existingMap = <String, int>{
      for (final t in firstResult.changedTracks) t.stableKey: t.dateModifiedSec,
    };
    final secondResult = await source.scanSelectedFolders(
      folders: <FolderScanRequest>[request],
      existingModifiedByStableKey: existingMap,
    );
    expect(secondResult.activeStableKeys, hasLength(3));
    expect(secondResult.changedTracks, isEmpty);

    // Files on disk must remain untouched.
    expect(track1.existsSync(), isTrue);
    expect(track2.existsSync(), isTrue);
  });

  test('FileSystemLibrarySource includes wide audio formats and strictly excludes video files', () async {
    final tempRoot = Directory.systemTemp.createTempSync('wetar_formats_test_');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final expectedAudioNames = <String>[
      'track.opus',
      'audiobook.m4b',
      'windows.wma',
      'voice.amr',
      'matroska.mka',
      'core.caf',
      'sacd.dsf',
      'pcm.wav',
      'vorbis.ogg',
      'stream.aac',
    ];
    for (final name in expectedAudioNames) {
      File(p.join(tempRoot.path, name)).writeAsBytesSync(<int>[1, 2, 3, 4]);
    }

    const ignoredVideoNames = <String>[
      'clip.mp4',
      'movie.mkv',
      'video.webm',
      'iphone.mov',
      'legacy.avi',
      'cam.3gp',
      'apple.m4v',
      '.CloudClip.mp4.icloud',
    ];
    for (final name in ignoredVideoNames) {
      File(p.join(tempRoot.path, name)).writeAsBytesSync(<int>[5, 6, 7, 8]);
    }

    final source = FileSystemLibrarySource();
    final result = await source.scanSelectedFolders(
      folders: <FolderScanRequest>[
        FolderScanRequest(
          id: 1,
          rootPath: tempRoot.path,
          sourceKind: 'bookmark',
          includeSubfolders: true,
          excludedSubfolders: const <String>[],
        ),
      ],
      existingModifiedByStableKey: const <String, int>{},
    );

    expect(result.activeStableKeys, hasLength(expectedAudioNames.length));
    expect(result.changedTracks, hasLength(expectedAudioNames.length));
    final scannedNames = result.changedTracks
        .map((t) => p.basename(t.filePath))
        .toSet();
    for (final audio in expectedAudioNames) {
      expect(scannedNames, contains(audio));
    }
    for (final video in ignoredVideoNames) {
      expect(scannedNames, isNot(contains(video)));
    }
  });
}
