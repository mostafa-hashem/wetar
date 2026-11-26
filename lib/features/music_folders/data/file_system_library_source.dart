import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wetar/core/logging/app_logger.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';

/// Shared filesystem + background-isolate metadata scanner for macOS and iOS.
/// Only traverses folders inside [FolderScanRequest] and never alters user files.
class FileSystemLibrarySource implements LibrarySource {
  FileSystemLibrarySource();

  static const Set<String> supportedAudioExtensions = <String>{
    '.mp3',
    '.m4a',
    '.aac',
    '.flac',
    '.wav',
    '.ogg',
    '.opus',
    '.aiff',
    '.aif',
    '.wv',
    '.ape',
    '.webm',
    '.alac',
    '.caf',
  };

  static const List<String> _siblingArtNames = <String>[
    'cover.jpg',
    'cover.png',
    'folder.jpg',
    'folder.png',
    'front.jpg',
    'album.jpg',
  ];

  static String mimeTypeForExtension(String ext) {
    return switch (ext.toLowerCase()) {
      '.mp3' => 'audio/mpeg',
      '.m4a' || '.alac' => 'audio/mp4',
      '.aac' => 'audio/aac',
      '.flac' => 'audio/flac',
      '.wav' => 'audio/wav',
      '.ogg' => 'audio/ogg',
      '.opus' => 'audio/opus',
      '.aiff' || '.aif' => 'audio/aiff',
      '.wv' => 'audio/x-wavpack',
      '.ape' => 'audio/x-ape',
      '.webm' => 'audio/webm',
      '.caf' => 'audio/x-caf',
      _ => 'audio/*',
    };
  }

  @override
  Future<List<DiscoveredAudioFolder>> listAudioFolders() async {
    if (!Platform.isIOS) {
      return const <DiscoveredAudioFolder>[];
    }
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      if (!docsDir.existsSync()) return const <DiscoveredAudioFolder>[];
      final files = <_DiscoveredAudioFile>[];
      await _walkDirectory(
        docsDir,
        folderId: 0,
        includeSubfolders: true,
        excludedNormalized: const <String>[],
        outFiles: files,
      );
      if (files.isEmpty) return const <DiscoveredAudioFolder>[];
      return <DiscoveredAudioFolder>[
        DiscoveredAudioFolder(
          rootPath: docsDir.path,
          displayName: 'Wetar Documents',
          volumeLabel: 'Files App',
          trackCount: files.length,
          sourceKind: 'documents',
        ),
      ];
    } catch (e, st) {
      AppLogger.warn(
        'FileSystemLibrarySource',
        'Failed inspecting iOS Documents folder: $e\n$st',
      );
      return const <DiscoveredAudioFolder>[];
    }
  }

  @override
  Future<FolderScanResult> scanSelectedFolders({
    required List<FolderScanRequest> folders,
    required Map<String, int> existingModifiedByStableKey,
  }) async {
    if (folders.isEmpty) {
      return const FolderScanResult(
        availableFolderIds: <int>{},
        activeStableKeys: <String>{},
        changedTracks: <ScannedTrackDto>[],
      );
    }

    final availableIds = <int>{};
    final activeKeys = <String>{};
    final pendingToParse = <_DiscoveredAudioFile>[];
    final changedTracks = <ScannedTrackDto>[];

    for (final folder in folders) {
      final dir = Directory(folder.rootPath);
      if (!dir.existsSync()) {
        continue;
      }
      availableIds.add(folder.id);
      final excludedNorm = folder.excludedSubfolders.map(p.normalize).toList();
      final found = <_DiscoveredAudioFile>[];
      await _walkDirectory(
        dir,
        folderId: folder.id,
        includeSubfolders: folder.includeSubfolders,
        excludedNormalized: excludedNorm,
        outFiles: found,
      );

      for (final file in found) {
        activeKeys.add(file.stableKey);
        final prevMod = existingModifiedByStableKey[file.stableKey];
        if (file.isCloudPending) {
          if (prevMod == null || prevMod != file.modifiedSec) {
            changedTracks.add(
              ScannedTrackDto(
                stableKey: file.stableKey,
                folderId: file.folderId,
                uri: Uri.file(file.path).toString(),
                filePath: file.path,
                folderPath: file.folderPath,
                title: file.fallbackTitle,
                mimeType: mimeTypeForExtension(file.extension),
                dateModifiedSec: file.modifiedSec,
                dateAddedSec: file.modifiedSec,
                isCloudPending: true,
              ),
            );
          }
          continue;
        }
        if (prevMod == null || prevMod != file.modifiedSec) {
          pendingToParse.add(file);
        }
      }
    }

    const batchSize = 40;
    for (var i = 0; i < pendingToParse.length; i += batchSize) {
      final slice = pendingToParse.sublist(
        i,
        (i + batchSize).clamp(0, pendingToParse.length),
      );
      final parsedBatch = await Isolate.run(() => _parseBatchInIsolate(slice));
      changedTracks.addAll(parsedBatch);
    }

    return FolderScanResult(
      availableFolderIds: availableIds,
      activeStableKeys: activeKeys,
      changedTracks: changedTracks,
    );
  }

  @override
  Future<String?> loadAlbumArtThumbnail({
    required String? uri,
    required String? filePath,
    required String outputPath,
    int sizePx = 256,
  }) async {
    var candidatePath = filePath;
    if ((candidatePath == null || candidatePath.isEmpty) &&
        uri != null &&
        uri.startsWith('file://')) {
      candidatePath = Uri.tryParse(uri)?.toFilePath();
    }
    if (candidatePath == null || candidatePath.isEmpty) return null;
    if (!File(candidatePath).existsSync()) return null;

    final pathForIsolate = candidatePath;
    final rawBytes = await Isolate.run<Uint8List?>(
      () => _extractArtworkBytesInIsolate(pathForIsolate),
    );
    if (rawBytes == null || rawBytes.isEmpty) return null;

    try {
      final codec = await ui.instantiateImageCodec(
        rawBytes,
        targetWidth: sizePx,
      );
      final frame = await codec.getNextFrame();
      final encoded = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      frame.image.dispose();
      codec.dispose();
      if (encoded == null) return null;

      final outFile = File(outputPath);
      if (!outFile.parent.existsSync()) {
        outFile.parent.createSync(recursive: true);
      }
      await outFile.writeAsBytes(encoded.buffer.asUint8List(), flush: true);
      return outFile.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> _walkDirectory(
    Directory dir, {
    required int folderId,
    required bool includeSubfolders,
    required List<String> excludedNormalized,
    required List<_DiscoveredAudioFile> outFiles,
  }) async {
    Stream<FileSystemEntity> entries;
    try {
      entries = dir.list(followLinks: false);
    } catch (_) {
      return;
    }

    await for (final entity in entries) {
      final name = p.basename(entity.path);
      if (entity is Directory) {
        if (!includeSubfolders || name.startsWith('.')) continue;
        final normDir = p.normalize(entity.path);
        final isExcluded = excludedNormalized.any(
          (ex) => normDir == ex || p.isWithin(ex, normDir),
        );
        if (isExcluded) continue;
        await _walkDirectory(
          entity,
          folderId: folderId,
          includeSubfolders: true,
          excludedNormalized: excludedNormalized,
          outFiles: outFiles,
        );
      } else if (entity is File) {
        if (name.startsWith('.') && name.endsWith('.icloud')) {
          final realName = name.substring(1, name.length - '.icloud'.length);
          final ext = p.extension(realName).toLowerCase();
          if (!supportedAudioExtensions.contains(ext)) continue;
          final virtualPath = p.join(dir.path, realName);
          var modifiedSec = 0;
          try {
            modifiedSec =
                entity.statSync().modified.millisecondsSinceEpoch ~/ 1000;
          } catch (_) {}
          outFiles.add(
            _DiscoveredAudioFile(
              stableKey: 'fs_$virtualPath',
              folderId: folderId,
              path: entity.path,
              folderPath: dir.path,
              fallbackTitle: p.basenameWithoutExtension(realName),
              extension: ext,
              modifiedSec: modifiedSec,
              sizeBytes: 0,
              isCloudPending: true,
            ),
          );
          continue;
        }

        if (name.startsWith('.')) continue;
        final ext = p.extension(name).toLowerCase();
        if (!supportedAudioExtensions.contains(ext)) continue;
        try {
          final stat = entity.statSync();
          outFiles.add(
            _DiscoveredAudioFile(
              stableKey: 'fs_${entity.path}',
              folderId: folderId,
              path: entity.path,
              folderPath: dir.path,
              fallbackTitle: p.basenameWithoutExtension(name),
              extension: ext,
              modifiedSec: stat.modified.millisecondsSinceEpoch ~/ 1000,
              sizeBytes: stat.size,
              isCloudPending: false,
            ),
          );
        } catch (_) {}
      }
    }
  }
}

class _DiscoveredAudioFile {
  const _DiscoveredAudioFile({
    required this.stableKey,
    required this.folderId,
    required this.path,
    required this.folderPath,
    required this.fallbackTitle,
    required this.extension,
    required this.modifiedSec,
    required this.sizeBytes,
    required this.isCloudPending,
  });

  final String stableKey;
  final int folderId;
  final String path;
  final String folderPath;
  final String fallbackTitle;
  final String extension;
  final int modifiedSec;
  final int sizeBytes;
  final bool isCloudPending;
}

List<ScannedTrackDto> _parseBatchInIsolate(List<_DiscoveredAudioFile> files) {
  final results = <ScannedTrackDto>[];
  for (final item in files) {
    String title = item.fallbackTitle;
    String? artist;
    String? album;
    String? albumArtist;
    String? genre;
    int year = 0;
    int trackNumber = 0;
    int discNumber = 1;
    int durationMs = 0;
    int bitrateKbps = 0;
    int sampleRateHz = 0;
    String? embeddedLyrics;

    try {
      final meta = readMetadata(File(item.path), getImage: false);
      if (meta.title != null && meta.title!.trim().isNotEmpty) {
        title = meta.title!.trim();
      }
      if (meta.artist != null && meta.artist!.trim().isNotEmpty) {
        artist = meta.artist!.trim();
      }
      if (meta.album != null && meta.album!.trim().isNotEmpty) {
        album = meta.album!.trim();
      }
      if (meta.albumArtist != null && meta.albumArtist!.trim().isNotEmpty) {
        albumArtist = meta.albumArtist!.trim();
      }
      if (meta.genres.isNotEmpty) {
        genre = meta.genres.first.trim();
      }
      final rawYear = meta.year?.year ?? 0;
      if (rawYear >= 1900 && rawYear <= 2100) {
        year = rawYear;
      }
      trackNumber = meta.trackNumber ?? 0;
      discNumber = (meta.discNumber ?? 1) < 1 ? 1 : meta.discNumber!;
      durationMs = meta.duration?.inMilliseconds ?? 0;
      final rawBitrate = meta.bitrate ?? 0;
      bitrateKbps = rawBitrate > 2000 ? rawBitrate ~/ 1000 : rawBitrate;
      sampleRateHz = meta.sampleRate ?? 0;
      if (meta.lyrics != null && meta.lyrics!.trim().isNotEmpty) {
        embeddedLyrics = meta.lyrics;
      }
    } catch (_) {
      // Fall back cleanly to filename metadata when a file uses an untagged format.
    }

    results.add(
      ScannedTrackDto(
        stableKey: item.stableKey,
        folderId: item.folderId,
        uri: Uri.file(item.path).toString(),
        filePath: item.path,
        folderPath: item.folderPath,
        title: title,
        artist: artist,
        album: album,
        albumArtist: albumArtist,
        genre: genre,
        year: year,
        trackNumber: trackNumber,
        discNumber: discNumber,
        durationMs: durationMs,
        bitrateKbps: bitrateKbps,
        sampleRateHz: sampleRateHz,
        channels: 2,
        sizeBytes: item.sizeBytes,
        mimeType: FileSystemLibrarySource.mimeTypeForExtension(item.extension),
        dateModifiedSec: item.modifiedSec,
        dateAddedSec: item.modifiedSec,
        artworkUri: item.path,
        embeddedLyrics: embeddedLyrics,
        isCloudPending: false,
      ),
    );
  }
  return results;
}

Uint8List? _extractArtworkBytesInIsolate(String audioPath) {
  try {
    final meta = readMetadata(File(audioPath), getImage: true);
    if (meta.pictures.isNotEmpty) {
      for (final pic in meta.pictures) {
        if (pic.pictureType == PictureType.coverFront && pic.bytes.isNotEmpty) {
          return pic.bytes;
        }
      }
      if (meta.pictures.first.bytes.isNotEmpty) {
        return meta.pictures.first.bytes;
      }
    }
  } catch (_) {}

  final parent = Directory(p.dirname(audioPath));
  if (!parent.existsSync()) return null;
  for (final name in FileSystemLibrarySource._siblingArtNames) {
    final candidate = File(p.join(parent.path, name));
    if (candidate.existsSync()) {
      try {
        return candidate.readAsBytesSync();
      } catch (_) {}
    }
  }
  return null;
}
