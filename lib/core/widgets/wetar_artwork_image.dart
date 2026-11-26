import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import '../../features/personalization/presentation/theme/wetar_tokens.dart';
import '../platform/platform_interfaces.dart';
import '../storage/cache_manager.dart';

/// Bounded in-memory index mapping track/album keys to cached local thumbnail paths.
class ThumbnailPathCache {
  ThumbnailPathCache(this._librarySource, this._cacheManager);

  final LibrarySource _librarySource;
  final CacheManager _cacheManager;

  final LinkedHashMap<String, String?> _resolvedPaths =
      LinkedHashMap<String, String?>();
  final Map<String, Future<String?>> _inFlight = <String, Future<String?>>{};
  static const int _maxEntries = 1200;

  String? peek(String cacheKey) => _resolvedPaths[cacheKey];

  Future<String?> resolve({
    required String cacheKey,
    required String? customArtPath,
    required String? artworkUri,
    required String? filePath,
    int sizePx = 256,
  }) {
    if (customArtPath != null && File(customArtPath).existsSync()) {
      return Future<String?>.value(customArtPath);
    }
    if (_resolvedPaths.containsKey(cacheKey)) {
      final value = _resolvedPaths.remove(cacheKey);
      _resolvedPaths[cacheKey] = value;
      return Future<String?>.value(value);
    }
    return _inFlight.putIfAbsent(cacheKey, () async {
      try {
        await _cacheManager.init();
        final fileName = '${cacheKey.hashCode.toUnsigned(32)}_$sizePx.jpg';
        final outPath = p.join(_cacheManager.thumbnailsDir.path, fileName);
        if (File(outPath).existsSync()) {
          _remember(cacheKey, outPath);
          return outPath;
        }
        final generated = await _librarySource.loadAlbumArtThumbnail(
          uri: artworkUri,
          filePath: filePath,
          outputPath: outPath,
          sizePx: sizePx,
        );
        _remember(cacheKey, generated);
        return generated;
      } finally {
        final removed = _inFlight.remove(cacheKey);
        if (removed != null) {
          unawaited(removed);
        }
      }
    });
  }

  void invalidate(String cacheKey) {
    _resolvedPaths.remove(cacheKey);
  }

  void _remember(String key, String? path) {
    if (_resolvedPaths.length >= _maxEntries) {
      _resolvedPaths.remove(_resolvedPaths.keys.first);
    }
    _resolvedPaths[key] = path;
  }
}

/// Tokenized, memory-sized album cover image with Oud-string fallback placeholder.
class WetarArtworkImage extends StatefulWidget {
  const WetarArtworkImage({
    super.key,
    required this.cacheKey,
    required this.size,
    this.artworkUri,
    this.filePath,
    this.customArtPath,
    this.borderRadius,
    this.thumbnailCache,
    this.decodeSizePx = 256,
  });

  final String cacheKey;
  final double size;
  final String? artworkUri;
  final String? filePath;
  final String? customArtPath;
  final BorderRadius? borderRadius;
  final ThumbnailPathCache? thumbnailCache;
  final int decodeSizePx;

  @override
  State<WetarArtworkImage> createState() => _WetarArtworkImageState();
}

class _WetarArtworkImageState extends State<WetarArtworkImage> {
  String? _resolvedPath;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant WetarArtworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cacheKey != widget.cacheKey ||
        oldWidget.customArtPath != widget.customArtPath ||
        oldWidget.artworkUri != widget.artworkUri) {
      _resolvedPath = null;
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    final custom = widget.customArtPath;
    if (custom != null && File(custom).existsSync()) {
      if (mounted) setState(() => _resolvedPath = custom);
      return;
    }
    final cache = widget.thumbnailCache;
    if (cache == null) return;
    final peeked = cache.peek(widget.cacheKey);
    if (peeked != null) {
      if (mounted) setState(() => _resolvedPath = peeked);
      return;
    }
    final resolved = await cache.resolve(
      cacheKey: widget.cacheKey,
      customArtPath: widget.customArtPath,
      artworkUri: widget.artworkUri,
      filePath: widget.filePath,
      sizePx: widget.decodeSizePx,
    );
    if (mounted && resolved != null) {
      setState(() => _resolvedPath = resolved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wetarTokens;
    final radius =
        widget.borderRadius ?? BorderRadius.circular(tokens.radiusCard * 0.75);
    final path = _resolvedPath;

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: path != null && File(path).existsSync()
            ? Image(
                image: ResizeImage(
                  FileImage(File(path)),
                  width: widget.decodeSizePx,
                ),
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) =>
                    _PlaceholderArt(tokens: tokens, size: widget.size),
              )
            : _PlaceholderArt(tokens: tokens, size: widget.size),
      ),
    );
  }
}

class _PlaceholderArt extends StatelessWidget {
  const _PlaceholderArt({required this.tokens, required this.size});

  final WetarTokens tokens;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            tokens.surfaceElevated,
            Color.lerp(tokens.surfaceElevated, tokens.accentPrimary, 0.22)!,
          ],
        ),
      ),
      child: CustomPaint(
        painter: _OudStringsPlaceholderPainter(
          accent: tokens.accentPrimary,
          secondary: tokens.accentSecondary,
        ),
        child: Center(
          child: Icon(
            Icons.music_note_rounded,
            size: (size * 0.42).clamp(18.0, 64.0),
            color: tokens.accentPrimary.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}

class _OudStringsPlaceholderPainter extends CustomPainter {
  const _OudStringsPlaceholderPainter({
    required this.accent,
    required this.secondary,
  });

  final Color accent;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 4; i++) {
      final y = size.height * (0.28 + i * 0.14);
      paint.color = (i.isEven ? accent : secondary).withValues(alpha: 0.18);
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 6), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OudStringsPlaceholderPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.secondary != secondary;
  }
}
