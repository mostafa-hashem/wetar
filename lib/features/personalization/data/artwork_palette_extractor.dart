import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drift/drift.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/core/logging/app_logger.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';

class ExtractedAlbumPalette {
  const ExtractedAlbumPalette({
    required this.primaryArgb,
    required this.secondaryArgb,
    required this.backgroundArgb,
    required this.isDark,
  });

  final int primaryArgb;
  final int secondaryArgb;
  final int backgroundArgb;
  final bool isDark;

  ui.Color get primary => ui.Color(primaryArgb);
  ui.Color get secondary => ui.Color(secondaryArgb);
}

/// Extracts album HCT palettes in a background isolate and caches them in Drift.
class ArtworkPaletteExtractor {
  ArtworkPaletteExtractor(this._db, this._thumbCache);

  final WetarDatabase _db;
  final ThumbnailPathCache _thumbCache;
  final Map<String, ExtractedAlbumPalette> _memCache =
      <String, ExtractedAlbumPalette>{};

  Future<ExtractedAlbumPalette?> extractForTrack({
    required String albumKey,
    required String? customArtPath,
    required String? artworkUri,
    required String? filePath,
  }) async {
    final mem = _memCache[albumKey];
    if (mem != null) return mem;

    final cachedRow = await (_db.select(
      _db.albumPalettes,
    )..where((t) => t.albumKey.equals(albumKey))).getSingleOrNull();
    if (cachedRow != null) {
      final palette = ExtractedAlbumPalette(
        primaryArgb: cachedRow.primaryArgb,
        secondaryArgb: cachedRow.secondaryArgb,
        backgroundArgb: cachedRow.backgroundArgb,
        isDark: cachedRow.isDark,
      );
      _memCache[albumKey] = palette;
      return palette;
    }

    try {
      final path = await _thumbCache.resolve(
        cacheKey: albumKey,
        customArtPath: customArtPath,
        artworkUri: artworkUri,
        filePath: filePath,
        sizePx: 192,
      );
      if (path == null) return null;
      final file = File(path);
      if (!file.existsSync()) return null;
      final rawBytes = await file.readAsBytes();
      final rgbaBytes = await _decodeSmallRgba(rawBytes);
      if (rgbaBytes == null || rgbaBytes.isEmpty) return null;

      final computed = await Isolate.run(() => _quantizeRgba(rgbaBytes));
      if (computed == null) return null;

      _memCache[albumKey] = computed;
      await _db
          .into(_db.albumPalettes)
          .insert(
            AlbumPalettesCompanion.insert(
              albumKey: albumKey,
              primaryArgb: computed.primaryArgb,
              secondaryArgb: computed.secondaryArgb,
              backgroundArgb: computed.backgroundArgb,
              isDark: computed.isDark,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
            ),
            mode: InsertMode.insertOrReplace,
          );
      return computed;
    } catch (e) {
      AppLogger.warn('PaletteExtractor', 'Failed extracting palette: $e');
      return null;
    }
  }

  Future<Uint8List?> _decodeSmallRgba(Uint8List imageBytes) async {
    try {
      final codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: 32,
        targetHeight: 32,
      );
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      frame.image.dispose();
      codec.dispose();
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  static Future<ExtractedAlbumPalette?> _quantizeRgba(Uint8List rgba) async {
    final pixelCount = rgba.length ~/ 4;
    if (pixelCount <= 0) return null;
    final argbPixels = Uint32List(pixelCount);
    for (var i = 0; i < pixelCount; i++) {
      final offset = i * 4;
      final r = rgba[offset];
      final g = rgba[offset + 1];
      final b = rgba[offset + 2];
      final a = rgba[offset + 3];
      argbPixels[i] = (a << 24) | (r << 16) | (g << 8) | b;
    }
    final result = await QuantizerCelebi().quantize(argbPixels, 32);
    final ranked = Score.score(
      result.colorToCount,
      desired: 3,
      fallbackColorARGB: 0xFFE69B3A,
    );
    final primary = ranked.first;
    final hct = Hct.fromInt(primary);
    final secondaryHct = Hct.from(
      (hct.hue + 42.0) % 360.0,
      hct.chroma.clamp(24.0, 56.0),
      hct.tone.clamp(45.0, 72.0),
    );
    final bgHct = Hct.from(hct.hue, 18.0, 14.0);
    return ExtractedAlbumPalette(
      primaryArgb: primary,
      secondaryArgb: ranked.length > 1 ? ranked[1] : secondaryHct.toInt(),
      backgroundArgb: bgHct.toInt(),
      isDark: hct.tone < 55.0,
    );
  }
}
