import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Permission snapshot across runtime audio & notification checks.
class WetarPermissionsStatus extends Equatable {
  const WetarPermissionsStatus({
    required this.audioGranted,
    required this.notificationsGranted,
  });

  final bool audioGranted;
  final bool notificationsGranted;

  @override
  List<Object?> get props => [audioGranted, notificationsGranted];
}

/// An audio-containing folder discovered on the device (or selected via SAF/bookmarks).
class DiscoveredAudioFolder extends Equatable {
  const DiscoveredAudioFolder({
    required this.rootPath,
    required this.displayName,
    required this.volumeLabel,
    required this.trackCount,
    required this.sourceKind,
    this.bookmarkData,
  });

  final String rootPath;
  final String displayName;
  final String volumeLabel;
  final int trackCount;
  final String sourceKind;
  final String? bookmarkData;

  @override
  List<Object?> get props => [
    rootPath,
    displayName,
    volumeLabel,
    trackCount,
    sourceKind,
    bookmarkData,
  ];
}

/// Raw track metadata extracted by a platform scanner before Drift normalization.
class ScannedTrackDto {
  const ScannedTrackDto({
    required this.stableKey,
    required this.folderId,
    required this.uri,
    required this.filePath,
    required this.folderPath,
    required this.title,
    this.artist,
    this.album,
    this.albumArtist,
    this.genre,
    this.year = 0,
    this.trackNumber = 0,
    this.discNumber = 1,
    this.durationMs = 0,
    this.bitrateKbps = 0,
    this.sampleRateHz = 0,
    this.channels = 2,
    this.sizeBytes = 0,
    this.mimeType = 'audio/*',
    this.dateModifiedSec = 0,
    this.dateAddedSec = 0,
    this.artworkUri,
    this.embeddedLyrics,
    this.replayGainTrackDb,
    this.replayGainAlbumDb,
    this.isCloudPending = false,
  });

  final String stableKey;
  final int folderId;
  final String uri;
  final String filePath;
  final String folderPath;
  final String title;
  final String? artist;
  final String? album;
  final String? albumArtist;
  final String? genre;
  final int year;
  final int trackNumber;
  final int discNumber;
  final int durationMs;
  final int bitrateKbps;
  final int sampleRateHz;
  final int channels;
  final int sizeBytes;
  final String mimeType;
  final int dateModifiedSec;
  final int dateAddedSec;
  final String? artworkUri;
  final String? embeddedLyrics;
  final double? replayGainTrackDb;
  final double? replayGainAlbumDb;
  final bool isCloudPending;
}

/// Result of an incremental folder scan batch.
class FolderScanResult {
  const FolderScanResult({
    required this.availableFolderIds,
    required this.activeStableKeys,
    required this.changedTracks,
  });

  final Set<int> availableFolderIds;
  final Set<String> activeStableKeys;
  final List<ScannedTrackDto> changedTracks;
}

/// Folder descriptor passed into platform scan routines.
class FolderScanRequest {
  const FolderScanRequest({
    required this.id,
    required this.rootPath,
    required this.sourceKind,
    required this.includeSubfolders,
    required this.excludedSubfolders,
    this.bookmarkData,
  });

  final int id;
  final String rootPath;
  final String sourceKind;
  final bool includeSubfolders;
  final List<String> excludedSubfolders;
  final String? bookmarkData;

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id,
    'rootPath': rootPath,
    'sourceKind': sourceKind,
    'includeSubfolders': includeSubfolders,
    'excludedSubfolders': excludedSubfolders,
    'bookmarkData': bookmarkData,
  };
}

/// Result of picking a folder via a native system folder picker (SAF/macOS/iOS).
class PickedFolderResult {
  const PickedFolderResult({
    required this.rootPath,
    required this.displayName,
    required this.sourceKind,
    this.bookmarkData,
  });

  final String rootPath;
  final String displayName;
  final String sourceKind;
  final String? bookmarkData;
}

/// Incoming native OS event (Open-With, launcher shortcut, FSEvents change).
sealed class PlatformIncomingEvent {
  const PlatformIncomingEvent();
}

class OpenWithIncomingEvent extends PlatformIncomingEvent {
  const OpenWithIncomingEvent({
    required this.uri,
    this.filePath,
    this.parentFolderPath,
    this.displayName,
    this.mimeType,
  });

  final String uri;
  final String? filePath;
  final String? parentFolderPath;
  final String? displayName;
  final String? mimeType;
}

class ShortcutIncomingEvent extends PlatformIncomingEvent {
  const ShortcutIncomingEvent(this.target);
  final String target;
}

class FolderChangedIncomingEvent extends PlatformIncomingEvent {
  const FolderChangedIncomingEvent(this.folderPath);
  final String folderPath;
}

class FolderDroppedIncomingEvent extends PlatformIncomingEvent {
  const FolderDroppedIncomingEvent({
    required this.rootPath,
    required this.displayName,
    this.bookmarkData,
  });

  final String rootPath;
  final String displayName;
  final String? bookmarkData;
}

/// Abstract audio library scanner source (MediaStore/SAF on Android, filesystem on Apple).
abstract interface class LibrarySource {
  Future<List<DiscoveredAudioFolder>> listAudioFolders();

  Future<FolderScanResult> scanSelectedFolders({
    required List<FolderScanRequest> folders,
    required Map<String, int> existingModifiedByStableKey,
  });

  Future<String?> loadAlbumArtThumbnail({
    required String? uri,
    required String? filePath,
    required String outputPath,
    int sizePx = 256,
  });
}

/// Abstract native folder & file picker / bookmark manager.
abstract interface class FolderPickerService {
  Future<PickedFolderResult?> pickSystemFolder();

  Future<bool> resolveBookmark(String bookmarkData);

  Future<void> stopAccessingBookmark(String bookmarkData);

  Future<void> startWatchingFolders(List<String> paths);

  Future<String?> pickFile({required List<String> mimeTypes});

  Future<bool> saveFile({
    required String fileName,
    required String mimeType,
    Uint8List? bytes,
    String? sourcePath,
  });

  Future<bool> shareFiles({
    required List<String> paths,
    required String mimeType,
    String? subject,
  });
}

/// Hardware/native audio effects beyond just_audio's built-in AndroidEqualizer/Loudness.
abstract interface class NativeAudioEffectsService {
  Future<({bool bassBoost, bool virtualizer})> attachSession(int sessionId);
  Future<bool> setBassBoost({required bool enabled, required int strength});
  Future<bool> setVirtualizer({required bool enabled, required int strength});
}

/// OS permissions, battery optimization, desktop window controls, and widgets.
abstract interface class SystemIntegrationService {
  Stream<PlatformIncomingEvent> get incomingEvents;

  Future<WetarPermissionsStatus> checkPermissions();
  Future<WetarPermissionsStatus> requestPermissions({
    bool includeNotifications = true,
  });
  Future<bool> openAppSettings();
  Future<bool> isIgnoringBatteryOptimizations();
  Future<bool> openBatteryOptimizationSettings();
  Future<bool> setKeepScreenOn(bool keepOn);
  Future<bool> setCompactMiniPlayerMode(bool compact);
  Future<bool> triggerCloudDownload(String filePath);
  Future<void> updateHomeWidget({
    required String? title,
    required String? artist,
    required String? artworkPath,
    required bool isPlaying,
  });
}
