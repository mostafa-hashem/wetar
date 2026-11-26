import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:path/path.dart' as p;
import 'package:wetar/core/logging/app_logger.dart';
import 'package:wetar/core/storage/cache_manager.dart';

/// Copies and downscales user-chosen images (custom backgrounds or custom album art)
/// to max 1080px on the long side and stores a compact PNG in app-private storage.
class CustomImageProcessor {
  CustomImageProcessor(this._cacheManager);

  final CacheManager _cacheManager;

  Future<String?> processAndStoreBackground(String sourcePath) {
    return _process(
      sourcePath: sourcePath,
      targetDirResolver: () => _cacheManager.backgroundsDir,
      prefix: 'bg',
      maxLongEdge: 1080,
    );
  }

  Future<String?> processAndStoreAlbumArt(String sourcePath, String stableKey) {
    return _process(
      sourcePath: sourcePath,
      targetDirResolver: () => _cacheManager.customArtDir,
      prefix: 'art_${stableKey.hashCode.toUnsigned(32)}',
      maxLongEdge: 720,
    );
  }

  Future<String?> _process({
    required String sourcePath,
    required Directory Function() targetDirResolver,
    required String prefix,
    required int maxLongEdge,
  }) async {
    try {
      await _cacheManager.init();
      final source = File(sourcePath);
      if (!source.existsSync()) return null;
      final rawBytes = await source.readAsBytes();

      final probeCodec = await ui.instantiateImageCodec(rawBytes);
      final probeFrame = await probeCodec.getNextFrame();
      final width = probeFrame.image.width;
      final height = probeFrame.image.height;
      probeFrame.image.dispose();
      probeCodec.dispose();

      final longEdge = math.max(width, height);
      final scale = longEdge > maxLongEdge ? maxLongEdge / longEdge : 1.0;
      final targetW = (width * scale).round().clamp(1, maxLongEdge);
      final targetH = (height * scale).round().clamp(1, maxLongEdge);

      final codec = await ui.instantiateImageCodec(
        rawBytes,
        targetWidth: targetW,
        targetHeight: targetH,
      );
      final frame = await codec.getNextFrame();
      final encoded = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      frame.image.dispose();
      codec.dispose();
      if (encoded == null) return null;

      final dir = targetDirResolver();
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final outPath = p.join(
        dir.path,
        '${prefix}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await File(outPath)
          .writeAsBytes(encoded.buffer.asUint8List(), flush: true);
      return outPath;
    } catch (e, st) {
      AppLogger.error(
        'CustomImageProcessor',
        'Image downscale failed',
        errorObj: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
