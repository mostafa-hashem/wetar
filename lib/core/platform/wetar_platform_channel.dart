import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../logging/app_logger.dart';
import 'platform_interfaces.dart';

/// Unified MethodChannel & EventChannel client for Wetar native platform code.
class WetarPlatformChannel
    implements
        LibrarySource,
        FolderPickerService,
        NativeAudioEffectsService,
        SystemIntegrationService {
  WetarPlatformChannel();

  static const MethodChannel _method = MethodChannel(
    'com.yourname.wetar/platform',
  );
  static const EventChannel _events = EventChannel('com.yourname.wetar/events');

  Stream<PlatformIncomingEvent>? _cachedEvents;

  @override
  Stream<PlatformIncomingEvent> get incomingEvents {
    return _cachedEvents ??= _events
        .receiveBroadcastStream()
        .map((dynamic raw) {
          if (raw is! Map) {
            return const ShortcutIncomingEvent('');
          }
          final map = Map<Object?, Object?>.from(raw);
          final type = map['type'] as String? ?? '';
          switch (type) {
            case 'open_with':
              return OpenWithIncomingEvent(
                uri: map['uri'] as String? ?? '',
                filePath: map['filePath'] as String?,
                parentFolderPath: map['parentFolderPath'] as String?,
                displayName: map['displayName'] as String?,
                mimeType: map['mimeType'] as String?,
              );
            case 'folder_changed':
              return FolderChangedIncomingEvent(
                map['folderPath'] as String? ?? '',
              );
            case 'folder_dropped':
              return FolderDroppedIncomingEvent(
                rootPath: map['rootPath'] as String? ?? '',
                displayName: map['displayName'] as String? ?? '',
                bookmarkData: map['bookmarkData'] as String?,
              );
            case 'shortcut':
            default:
              return ShortcutIncomingEvent(map['target'] as String? ?? '');
          }
        })
        .handleError((Object error, StackTrace stack) {
          AppLogger.warn('PlatformChannel', 'Event stream error: $error');
        });
  }

  @override
  Future<WetarPermissionsStatus> checkPermissions() async {
    if (!Platform.isAndroid) {
      return const WetarPermissionsStatus(
        audioGranted: true,
        notificationsGranted: true,
      );
    }
    try {
      final res = await _method.invokeMapMethod<String, dynamic>(
        'checkPermissions',
      );
      return WetarPermissionsStatus(
        audioGranted: res?['audio'] as bool? ?? false,
        notificationsGranted: res?['notifications'] as bool? ?? true,
      );
    } catch (e, st) {
      AppLogger.error(
        'PlatformChannel',
        'checkPermissions failed',
        errorObj: e,
        stackTrace: st,
      );
      return const WetarPermissionsStatus(
        audioGranted: false,
        notificationsGranted: false,
      );
    }
  }

  @override
  Future<WetarPermissionsStatus> requestPermissions({
    bool includeNotifications = true,
  }) async {
    if (!Platform.isAndroid) {
      return const WetarPermissionsStatus(
        audioGranted: true,
        notificationsGranted: true,
      );
    }
    try {
      final res = await _method.invokeMapMethod<String, dynamic>(
        'requestPermissions',
        <String, Object?>{'includeNotifications': includeNotifications},
      );
      return WetarPermissionsStatus(
        audioGranted: res?['audio'] as bool? ?? false,
        notificationsGranted: res?['notifications'] as bool? ?? true,
      );
    } catch (e, st) {
      AppLogger.error(
        'PlatformChannel',
        'requestPermissions failed',
        errorObj: e,
        stackTrace: st,
      );
      return const WetarPermissionsStatus(
        audioGranted: false,
        notificationsGranted: false,
      );
    }
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      return await _method.invokeMethod<bool>('openAppSettings') ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<DiscoveredAudioFolder>> listAudioFolders() async {
    if (!Platform.isAndroid) return const <DiscoveredAudioFolder>[];
    try {
      final raw = await _method.invokeListMethod<dynamic>('listAudioFolders');
      if (raw == null) return const <DiscoveredAudioFolder>[];
      return raw
          .whereType<Map<Object?, Object?>>()
          .map(
            (m) => DiscoveredAudioFolder(
              rootPath: m['rootPath'] as String? ?? '',
              displayName: m['displayName'] as String? ?? '',
              volumeLabel: m['volumeLabel'] as String? ?? 'Device Storage',
              trackCount: (m['trackCount'] as num?)?.toInt() ?? 0,
              sourceKind: m['sourceKind'] as String? ?? 'mediastore',
              bookmarkData: m['bookmarkData'] as String?,
            ),
          )
          .where((f) => f.rootPath.isNotEmpty)
          .toList();
    } catch (e, st) {
      AppLogger.error(
        'PlatformChannel',
        'listAudioFolders failed',
        errorObj: e,
        stackTrace: st,
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
    final raw = await _method.invokeMapMethod<String, dynamic>(
      'scanSelectedFolders',
      <String, Object?>{
        'folders': folders.map((f) => f.toMap()).toList(),
        'existingModified': existingModifiedByStableKey,
      },
    );
    if (raw == null) {
      return const FolderScanResult(
        availableFolderIds: <int>{},
        activeStableKeys: <String>{},
        changedTracks: <ScannedTrackDto>[],
      );
    }
    final availableIds =
        ((raw['availableFolderIds'] as List<dynamic>?) ?? <dynamic>[])
            .whereType<num>()
            .map((n) => n.toInt())
            .toSet();
    final activeKeys =
        ((raw['activeStableKeys'] as List<dynamic>?) ?? <dynamic>[])
            .whereType<String>()
            .toSet();
    final tracksList = ((raw['tracks'] as List<dynamic>?) ?? <dynamic>[])
        .whereType<Map<Object?, Object?>>()
        .map((m) {
          return ScannedTrackDto(
            stableKey: m['stableKey'] as String? ?? '',
            folderId: (m['folderId'] as num?)?.toInt() ?? 0,
            uri: m['uri'] as String? ?? '',
            filePath: m['filePath'] as String? ?? '',
            folderPath: m['folderPath'] as String? ?? '',
            title: m['title'] as String? ?? 'Untitled',
            artist: m['artist'] as String?,
            album: m['album'] as String?,
            albumArtist: m['albumArtist'] as String?,
            genre: m['genre'] as String?,
            year: (m['year'] as num?)?.toInt() ?? 0,
            trackNumber: (m['trackNumber'] as num?)?.toInt() ?? 0,
            discNumber: (m['discNumber'] as num?)?.toInt() ?? 1,
            durationMs: (m['durationMs'] as num?)?.toInt() ?? 0,
            bitrateKbps: (m['bitrateKbps'] as num?)?.toInt() ?? 0,
            sampleRateHz: (m['sampleRateHz'] as num?)?.toInt() ?? 0,
            channels: (m['channels'] as num?)?.toInt() ?? 2,
            sizeBytes: (m['sizeBytes'] as num?)?.toInt() ?? 0,
            mimeType: m['mimeType'] as String? ?? 'audio/*',
            dateModifiedSec: (m['dateModifiedSec'] as num?)?.toInt() ?? 0,
            dateAddedSec: (m['dateAddedSec'] as num?)?.toInt() ?? 0,
            artworkUri: m['artworkUri'] as String?,
          );
        })
        .where((t) => t.stableKey.isNotEmpty)
        .toList();

    return FolderScanResult(
      availableFolderIds: availableIds,
      activeStableKeys: activeKeys,
      changedTracks: tracksList,
    );
  }

  @override
  Future<String?> loadAlbumArtThumbnail({
    required String? uri,
    required String? filePath,
    required String outputPath,
    int sizePx = 256,
  }) async {
    try {
      final result = await _method.invokeMethod<dynamic>(
        'loadAlbumArtThumbnail',
        <String, Object?>{
          'uri': uri,
          'filePath': filePath,
          'sizePx': sizePx,
          'outputPath': outputPath,
        },
      );
      if (result is String && result.isNotEmpty) return result;
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PickedFolderResult?> pickSystemFolder() async {
    try {
      final methodName = Platform.isAndroid ? 'pickSafFolder' : 'pickFolder';
      final raw = await _method.invokeMapMethod<String, dynamic>(methodName);
      if (raw == null) return null;
      final path = raw['rootPath'] as String?;
      if (path == null || path.isEmpty) return null;
      return PickedFolderResult(
        rootPath: path,
        displayName: raw['displayName'] as String? ?? path,
        sourceKind:
            raw['sourceKind'] as String? ??
            (Platform.isAndroid ? 'saf' : 'bookmark'),
        bookmarkData: raw['bookmarkData'] as String?,
      );
    } catch (e, st) {
      AppLogger.error(
        'PlatformChannel',
        'pickSystemFolder failed',
        errorObj: e,
        stackTrace: st,
      );
      return null;
    }
  }

  @override
  Future<bool> resolveBookmark(String bookmarkData) async {
    if (Platform.isAndroid) return true;
    try {
      return await _method.invokeMethod<bool>(
            'resolveBookmark',
            <String, Object?>{'bookmarkData': bookmarkData},
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> stopAccessingBookmark(String bookmarkData) async {
    if (Platform.isAndroid) return;
    try {
      await _method.invokeMethod<void>(
        'stopAccessingBookmark',
        <String, Object?>{'bookmarkData': bookmarkData},
      );
    } catch (_) {}
  }

  @override
  Future<void> startWatchingFolders(List<String> paths) async {
    if (!Platform.isMacOS) return;
    try {
      await _method.invokeMethod<void>('watchFolders', <String, Object?>{
        'paths': paths,
      });
    } catch (_) {}
  }

  @override
  Future<String?> pickFile({required List<String> mimeTypes}) async {
    try {
      return await _method.invokeMethod<String>('pickFile', <String, Object?>{
        'mimeTypes': mimeTypes,
      });
    } catch (e, st) {
      AppLogger.error(
        'PlatformChannel',
        'pickFile failed',
        errorObj: e,
        stackTrace: st,
      );
      return null;
    }
  }

  @override
  Future<bool> saveFile({
    required String fileName,
    required String mimeType,
    Uint8List? bytes,
    String? sourcePath,
  }) async {
    try {
      return await _method.invokeMethod<bool>('saveFile', <String, Object?>{
            'fileName': fileName,
            'mimeType': mimeType,
            'bytes': bytes,
            'sourcePath': sourcePath,
          }) ??
          false;
    } catch (e, st) {
      AppLogger.error(
        'PlatformChannel',
        'saveFile failed',
        errorObj: e,
        stackTrace: st,
      );
      return false;
    }
  }

  @override
  Future<bool> shareFiles({
    required List<String> paths,
    required String mimeType,
    String? subject,
  }) async {
    try {
      return await _method.invokeMethod<bool>('shareFiles', <String, Object?>{
            'paths': paths,
            'mimeType': mimeType,
            'subject': subject,
          }) ??
          false;
    } catch (e, st) {
      AppLogger.error(
        'PlatformChannel',
        'shareFiles failed',
        errorObj: e,
        stackTrace: st,
      );
      return false;
    }
  }

  @override
  Future<({bool bassBoost, bool virtualizer})> attachSession(
    int sessionId,
  ) async {
    if (!Platform.isAndroid || sessionId <= 0) {
      return (bassBoost: false, virtualizer: false);
    }
    try {
      final res = await _method.invokeMapMethod<String, dynamic>(
        'attachAudioEffects',
        <String, Object?>{'audioSessionId': sessionId},
      );
      return (
        bassBoost: res?['bassBoostSupported'] as bool? ?? false,
        virtualizer: res?['virtualizerSupported'] as bool? ?? false,
      );
    } catch (_) {
      return (bassBoost: false, virtualizer: false);
    }
  }

  @override
  Future<bool> setBassBoost({
    required bool enabled,
    required int strength,
  }) async {
    if (!Platform.isAndroid) return false;
    try {
      return await _method.invokeMethod<bool>('setBassBoost', <String, Object?>{
            'enabled': enabled,
            'strength': strength,
          }) ??
          false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> setVirtualizer({
    required bool enabled,
    required int strength,
  }) async {
    if (!Platform.isAndroid) return false;
    try {
      return await _method.invokeMethod<bool>(
            'setVirtualizer',
            <String, Object?>{'enabled': enabled, 'strength': strength},
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      return await _method.invokeMethod<bool>(
            'isIgnoringBatteryOptimizations',
          ) ??
          true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<bool> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _method.invokeMethod<bool>(
            'openBatteryOptimizationSettings',
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> setKeepScreenOn(bool keepOn) async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      return await _method.invokeMethod<bool>(
            'setKeepScreenOn',
            <String, Object?>{'keepOn': keepOn},
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> setCompactMiniPlayerMode(bool compact) async {
    if (!Platform.isMacOS) return false;
    try {
      return await _method.invokeMethod<bool>(
            'setCompactMiniPlayerMode',
            <String, Object?>{'compact': compact},
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> triggerCloudDownload(String filePath) async {
    if (!Platform.isIOS) return false;
    try {
      return await _method.invokeMethod<bool>(
            'triggerCloudDownload',
            <String, Object?>{'filePath': filePath},
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> updateHomeWidget({
    required String? title,
    required String? artist,
    required String? artworkPath,
    required bool isPlaying,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _method.invokeMethod<void>('updateHomeWidget', <String, Object?>{
        'title': title,
        'artist': artist,
        'artworkPath': artworkPath,
        'isPlaying': isPlaying,
      });
    } catch (_) {}
  }
}
