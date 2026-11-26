import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../logging/app_logger.dart';

/// Breakdown of Wetar's app-private cache and stored customization media.
class CacheStats {
  const CacheStats({
    required this.thumbnailsBytes,
    required this.customArtBytes,
    required this.backgroundsBytes,
    required this.importsBytes,
    required this.fontsBytes,
  });

  final int thumbnailsBytes;
  final int customArtBytes;
  final int backgroundsBytes;
  final int importsBytes;
  final int fontsBytes;

  int get totalBytes =>
      thumbnailsBytes +
      customArtBytes +
      backgroundsBytes +
      importsBytes +
      fontsBytes;

  int get clearableCacheBytes => thumbnailsBytes + importsBytes;
}

/// Manages bounded app-private directories for thumbnails, custom artwork,
/// custom backgrounds, imported fonts, and exported cards/backups.
class CacheManager {
  CacheManager();

  static const int maxThumbnailsCacheBytes = 120 * 1024 * 1024;
  static const int maxImportsCacheBytes = 32 * 1024 * 1024;

  late Directory _supportDir;
  late Directory _cacheDir;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _supportDir = await getApplicationSupportDirectory();
    _cacheDir = await getTemporaryDirectory();
    for (final dir in <Directory>[
      thumbnailsDir,
      customArtDir,
      backgroundsDir,
      fontsDir,
      exportsDir,
      importsDir,
    ]) {
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
    }
    _initialized = true;
  }

  Directory get thumbnailsDir =>
      Directory(p.join(_cacheDir.path, 'thumbnails'));
  Directory get importsDir => Directory(p.join(_cacheDir.path, 'imports'));
  Directory get customArtDir =>
      Directory(p.join(_supportDir.path, 'custom_art'));
  Directory get backgroundsDir =>
      Directory(p.join(_supportDir.path, 'backgrounds'));
  Directory get fontsDir => Directory(p.join(_supportDir.path, 'fonts'));
  Directory get exportsDir => Directory(p.join(_cacheDir.path, 'exports'));

  Future<CacheStats> computeStats() async {
    await init();
    return CacheStats(
      thumbnailsBytes: await _dirSize(thumbnailsDir),
      customArtBytes: await _dirSize(customArtDir),
      backgroundsBytes: await _dirSize(backgroundsDir),
      importsBytes: await _dirSize(importsDir),
      fontsBytes: await _dirSize(fontsDir),
    );
  }

  Future<void> clearTemporaryCaches() async {
    await init();
    await _clearDir(thumbnailsDir);
    await _clearDir(importsDir);
    await _clearDir(exportsDir);
    AppLogger.info(
      'CacheManager',
      'Cleared temporary thumbnails and import caches',
    );
  }

  /// Enforces bounded cache size using oldest-modified-first LRU eviction,
  /// and removes orphaned custom art / thumbnails not referenced by active keys.
  Future<void> enforceBounds({Set<String>? activeThumbNames}) async {
    await init();
    if (activeThumbNames != null && thumbnailsDir.existsSync()) {
      await for (final entity in thumbnailsDir.list()) {
        if (entity is File &&
            !activeThumbNames.contains(p.basename(entity.path))) {
          try {
            await entity.delete();
          } catch (_) {}
        }
      }
    }
    await _trimDirToBudget(thumbnailsDir, maxThumbnailsCacheBytes);
    await _trimDirToBudget(importsDir, maxImportsCacheBytes);
  }

  Future<int> _dirSize(Directory dir) async {
    if (!dir.existsSync()) return 0;
    var total = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        try {
          total += await entity.length();
        } catch (_) {}
      }
    }
    return total;
  }

  Future<void> _clearDir(Directory dir) async {
    if (!dir.existsSync()) return;
    await for (final entity in dir.list()) {
      try {
        await entity.delete(recursive: true);
      } catch (_) {}
    }
  }

  Future<void> _trimDirToBudget(Directory dir, int maxBytes) async {
    if (!dir.existsSync()) return;
    final entries = <(File, DateTime, int)>[];
    var total = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        try {
          final stat = await entity.stat();
          total += stat.size;
          entries.add((entity, stat.modified, stat.size));
        } catch (_) {}
      }
    }
    if (total <= maxBytes) return;
    entries.sort((a, b) => a.$2.compareTo(b.$2));
    for (final entry in entries) {
      if (total <= maxBytes) break;
      try {
        await entry.$1.delete();
        total -= entry.$3;
      } catch (_) {}
    }
  }
}
