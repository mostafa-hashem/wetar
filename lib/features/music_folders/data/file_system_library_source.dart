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
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/music_folders/domain/audio_format_policy.dart';

/// Shared filesystem + background-isolate metadata scanner for macOS and iOS.
/// Only traverses folders inside [FolderScanRequest] and never alters user files.
class FileSystemLibrarySource implements LibrarySource {
  FileSystemLibrarySource([this._prober]);

  final AudioMetadataProber? _prober;

  static Set<String> get supportedAudioExtensions =>
      AudioFormatPolicy.supportedAudioExtensions;

  static const List<String> _siblingArtNames = <String>[
    'cover.jpg',
    'cover.png',
    'folder.jpg',
    'folder.png',
    'front.jpg',
    'album.jpg',
  ];

  static String mimeTypeForExtension(String ext) =>
      AudioFormatPolicy.mimeTypeForExtension(ext);

  /// Enriches an external Open-With / drag-and-drop track with tags and duration.
  static Future<WetarTrack> enrichExternalTrack(
    WetarTrack base, {
    AudioMetadataProber? prober,
  }) async {
    final path = base.filePath;
    if (path.isEmpty) return base;
    final file = File(path);
    if (!file.existsSync()) return base;

    final ext = AudioFormatPolicy.normalizedExtension(path);
    var sizeBytes = base.sizeBytes;
    var modifiedSec = base.dateModifiedSec;
    try {
      final stat = file.statSync();
      sizeBytes = stat.size;
      modifiedSec = stat.modified.millisecondsSinceEpoch ~/ 1000;
    } catch (_) {}

    final candidate = _DiscoveredAudioFile(
      stableKey: base.stableKey,
      folderId: base.folderId,
      path: path,
      folderPath: base.folderPath,
      fallbackTitle: p.basenameWithoutExtension(path),
      extension: ext,
      modifiedSec: modifiedSec,
      sizeBytes: sizeBytes,
      isCloudPending: false,
    );

    final parsed = await Isolate.run(
      () => _parseBatchInIsolate(<_DiscoveredAudioFile>[candidate]),
    );
    final dto = parsed.isNotEmpty ? parsed.first : null;

    if (prober != null &&
        (dto == null ||
            dto.durationMs <= 0 ||
            AudioFormatPolicy.probeCandidateExtensions.contains(ext))) {
      final probes = await prober.probeAudioFiles(<String>[path]);
      final probe = probes[path];
      if (probe != null && !probe.isVideo) {
        final nextDuration = (dto?.durationMs ?? 0) > 0
            ? dto!.durationMs
            : probe.durationMs;
        final nextTitle = (dto?.title.trim().isNotEmpty ?? false)
            ? dto!.title
            : (probe.title?.isNotEmpty == true ? probe.title! : base.title);
        final nextArtist = (dto?.artist?.trim().isNotEmpty ?? false)
            ? dto!.artist!
            : (probe.artist ?? base.artist);
        final nextAlbum = (dto?.album?.trim().isNotEmpty ?? false)
            ? dto!.album!
            : (probe.album ?? base.album);
        return WetarTrack(
          stableKey: base.stableKey,
          folderId: base.folderId,
          uri: base.uri,
          filePath: path,
          folderPath: base.folderPath,
          title: nextTitle,
          artist: nextArtist,
          album: nextAlbum,
          albumArtist: dto?.albumArtist ?? base.albumArtist,
          genre: dto?.genre ?? base.genre,
          year: dto?.year ?? base.year,
          trackNumber: dto?.trackNumber ?? base.trackNumber,
          discNumber: dto?.discNumber ?? base.discNumber,
          durationMs: nextDuration,
          bitrateKbps: dto?.bitrateKbps ?? base.bitrateKbps,
          sampleRateHz: dto?.sampleRateHz ?? base.sampleRateHz,
          channels: base.channels,
          sizeBytes: sizeBytes,
          mimeType: ext.isNotEmpty ? mimeTypeForExtension(ext) : base.mimeType,
          dateModifiedSec: modifiedSec,
          dateAddedSec: modifiedSec,
          artworkUri: path,
          embeddedLyrics: dto?.embeddedLyrics,
          isTemporaryExternal: base.isTemporaryExternal,
        );
      }
    }

    if (dto == null) return base;
    return WetarTrack(
      stableKey: base.stableKey,
      folderId: base.folderId,
      uri: base.uri,
      filePath: path,
      folderPath: base.folderPath,
      title: dto.title.isNotEmpty ? dto.title : base.title,
      artist: dto.artist ?? base.artist,
      album: dto.album ?? base.album,
      albumArtist: dto.albumArtist ?? base.albumArtist,
      genre: dto.genre ?? base.genre,
      year: dto.year,
      trackNumber: dto.trackNumber,
      discNumber: dto.discNumber,
      durationMs: dto.durationMs > 0 ? dto.durationMs : base.durationMs,
      bitrateKbps: dto.bitrateKbps,
      sampleRateHz: dto.sampleRateHz,
      channels: base.channels,
      sizeBytes: sizeBytes,
      mimeType: dto.mimeType,
      dateModifiedSec: modifiedSec,
      dateAddedSec: modifiedSec,
      artworkUri: path,
      embeddedLyrics: dto.embeddedLyrics,
      isTemporaryExternal: base.isTemporaryExternal,
    );
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

    if (_prober != null && changedTracks.isNotEmpty) {
      final pathsToProbe = <String>[
        for (final dto in changedTracks)
          if (!dto.isCloudPending &&
              (dto.durationMs <= 0 ||
                  AudioFormatPolicy.probeCandidateExtensions.contains(
                    AudioFormatPolicy.normalizedExtension(dto.filePath),
                  )))
            dto.filePath,
      ];

      if (pathsToProbe.isNotEmpty) {
        final probesByPath = <String, AudioFileProbeResult>{};
        const probeChunk = 50;
        for (var i = 0; i < pathsToProbe.length; i += probeChunk) {
          final slice = pathsToProbe.sublist(
            i,
            (i + probeChunk).clamp(0, pathsToProbe.length),
          );
          final chunkResult = await _prober.probeAudioFiles(slice);
          probesByPath.addAll(chunkResult);
        }

        final verified = <ScannedTrackDto>[];
        for (final dto in changedTracks) {
          final probe = probesByPath[dto.filePath];
          if (probe == null) {
            verified.add(dto);
            continue;
          }
          if (probe.isVideo) {
            activeKeys.remove(dto.stableKey);
            continue;
          }
          final mergedDuration = dto.durationMs > 0
              ? dto.durationMs
              : probe.durationMs;
          final mergedArtist = (dto.artist?.trim().isNotEmpty ?? false)
              ? dto.artist
              : probe.artist;
          final mergedAlbum = (dto.album?.trim().isNotEmpty ?? false)
              ? dto.album
              : probe.album;
          final mergedTitle =
              dto.title == p.basenameWithoutExtension(dto.filePath) &&
                  (probe.title?.isNotEmpty ?? false)
              ? probe.title!
              : dto.title;

          verified.add(
            ScannedTrackDto(
              stableKey: dto.stableKey,
              folderId: dto.folderId,
              uri: dto.uri,
              filePath: dto.filePath,
              folderPath: dto.folderPath,
              title: mergedTitle,
              artist: mergedArtist,
              album: mergedAlbum,
              albumArtist: dto.albumArtist,
              genre: dto.genre,
              year: dto.year,
              trackNumber: dto.trackNumber,
              discNumber: dto.discNumber,
              durationMs: mergedDuration,
              bitrateKbps: dto.bitrateKbps,
              sampleRateHz: dto.sampleRateHz,
              channels: dto.channels,
              sizeBytes: dto.sizeBytes,
              mimeType: dto.mimeType,
              dateModifiedSec: dto.dateModifiedSec,
              dateAddedSec: dto.dateAddedSec,
              artworkUri: dto.artworkUri,
              embeddedLyrics: dto.embeddedLyrics,
              replayGainTrackDb: dto.replayGainTrackDb,
              replayGainAlbumDb: dto.replayGainAlbumDb,
              isCloudPending: dto.isCloudPending,
            ),
          );
        }
        changedTracks
          ..clear()
          ..addAll(verified);
      }
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
          if (!AudioFormatPolicy.isSupportedAudioFile(pathOrName: realName)) {
            continue;
          }
          final ext = AudioFormatPolicy.normalizedExtension(realName);
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
        if (!AudioFormatPolicy.isSupportedAudioFile(pathOrName: name)) {
          continue;
        }
        final ext = AudioFormatPolicy.normalizedExtension(name);
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

    if (durationMs <= 0 &&
        const <String>{
          '.mp3',
          '.mp2',
          '.mp1',
          '.mpga',
          '.mpa',
        }.contains(item.extension)) {
      durationMs = _estimateMp3DurationMs(File(item.path), item.sizeBytes);
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

int _estimateMp3DurationMs(File file, int sizeBytes) {
  RandomAccessFile? raf;
  try {
    if (sizeBytes <= 0) return 0;
    raf = file.openSync(mode: FileMode.read);
    final headerProbe = raf.readSync(16384);
    if (headerProbe.length < 4) return 0;

    var audioStart = 0;
    var buf = headerProbe;
    var offset = 0;

    if (buf.length >= 10 &&
        buf[0] == 0x49 &&
        buf[1] == 0x44 &&
        buf[2] == 0x33) {
      final id3Size =
          ((buf[6] & 0x7F) << 21) |
          ((buf[7] & 0x7F) << 14) |
          ((buf[8] & 0x7F) << 7) |
          (buf[9] & 0x7F);
      audioStart = 10 + id3Size;
      if (audioStart >= buf.length) {
        if (audioStart >= sizeBytes - 4) return 0;
        raf.setPositionSync(audioStart);
        buf = raf.readSync(4096);
        offset = 0;
      } else {
        offset = audioStart;
      }
    }

    const mpeg1L3Bitrates = <int>[
      0,
      32,
      40,
      48,
      56,
      64,
      80,
      96,
      112,
      128,
      160,
      192,
      224,
      256,
      320,
      0,
    ];
    const mpeg2L3Bitrates = <int>[
      0,
      8,
      16,
      24,
      32,
      40,
      48,
      56,
      64,
      80,
      96,
      112,
      128,
      144,
      160,
      0,
    ];
    const mpeg1L2Bitrates = <int>[
      0,
      32,
      48,
      56,
      64,
      80,
      96,
      112,
      128,
      160,
      192,
      224,
      256,
      320,
      384,
      0,
    ];

    for (var i = offset; i <= buf.length - 4; i++) {
      final b0 = buf[i];
      final b1 = buf[i + 1];
      if (b0 != 0xFF || (b1 & 0xE0) != 0xE0) continue;
      final b2 = buf[i + 2];
      final versionBits = (b1 >> 3) & 0x03;
      final layerBits = (b1 >> 1) & 0x03;
      final bitrateIdx = (b2 >> 4) & 0x0F;
      final sampleRateIdx = (b2 >> 2) & 0x03;
      if (versionBits == 1 ||
          layerBits == 0 ||
          bitrateIdx == 0 ||
          bitrateIdx == 15 ||
          sampleRateIdx == 3) {
        continue;
      }
      final bitrateKbps = switch ((versionBits, layerBits)) {
        (3, 1) => mpeg1L3Bitrates[bitrateIdx],
        (3, 2) => mpeg1L2Bitrates[bitrateIdx],
        (_, 1) => mpeg2L3Bitrates[bitrateIdx],
        _ => 0,
      };
      if (bitrateKbps > 0 && sizeBytes > audioStart) {
        return (((sizeBytes - audioStart) * 8) / bitrateKbps).round();
      }
    }
    return 0;
  } catch (_) {
    return 0;
  } finally {
    try {
      raf?.closeSync();
    } catch (_) {}
  }
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
