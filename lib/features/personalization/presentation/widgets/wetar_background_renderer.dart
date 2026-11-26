import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';

/// Renders Wetar's 9 customizable background styles with blur, dim, saturation,
/// scope gating, and strict screen-off / Lite Mode ticker suspension.
class WetarBackgroundRenderer extends StatefulWidget {
  const WetarBackgroundRenderer({
    super.key,
    required this.child,
    required this.surfaceLocation,
    this.activeTrack,
    this.isPlaying = false,
  });

  final Widget child;
  final BackgroundScope surfaceLocation;
  final WetarTrack? activeTrack;
  final bool isPlaying;

  @override
  State<WetarBackgroundRenderer> createState() =>
      _WetarBackgroundRendererState();
}

class _WetarBackgroundRendererState extends State<WetarBackgroundRenderer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _shouldRenderHere(AppearanceSettings settings) {
    return switch (settings.backgroundScope) {
      BackgroundScope.wholeApp => true,
      BackgroundScope.homeAndPlayer =>
        widget.surfaceLocation == BackgroundScope.playerOnly ||
            widget.surfaceLocation == BackgroundScope.homeAndPlayer,
      BackgroundScope.playerOnly =>
        widget.surfaceLocation == BackgroundScope.playerOnly,
    };
  }

  bool _isAnimatedMode(BackgroundMode mode) {
    return mode == BackgroundMode.animatedGradient ||
        mode == BackgroundMode.proceduralAurora ||
        mode == BackgroundMode.proceduralWaves ||
        mode == BackgroundMode.proceduralStrings;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wetarTokens;
    final pState = context.watch<PersonalizationCubit>().state;
    final settings = pState.settings;
    final shouldRender = _shouldRenderHere(settings);
    final tickerEnabled = TickerMode.valuesOf(context).enabled;

    final shouldAnimate =
        shouldRender &&
        tickerEnabled &&
        !tokens.isLiteMode &&
        _isAnimatedMode(settings.backgroundMode);

    if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
    }

    if (!shouldRender) {
      return Material(color: tokens.canvas, child: widget.child);
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(
          child: RepaintBoundary(
            child: _buildBackgroundLayer(
              tokens: tokens,
              settings: settings,
              artPrimary: pState.artworkPrimary ?? tokens.accentPrimary,
              artSecondary: pState.artworkSecondary ?? tokens.accentSecondary,
            ),
          ),
        ),
        if (settings.backgroundDim > 0)
          Positioned.fill(
            child: ColoredBox(
              color: (tokens.isDark ? Colors.black : tokens.canvas).withValues(
                alpha: settings.backgroundDim,
              ),
            ),
          ),
        Material(type: MaterialType.transparency, child: widget.child),
      ],
    );
  }

  Widget _buildBackgroundLayer({
    required WetarTokens tokens,
    required AppearanceSettings settings,
    required Color artPrimary,
    required Color artSecondary,
  }) {
    final mode = settings.backgroundMode;
    if (mode == BackgroundMode.solidColor) {
      return ColoredBox(color: tokens.canvas);
    }

    if (mode == BackgroundMode.customImage &&
        settings.customBackgroundImagePath != null &&
        File(settings.customBackgroundImagePath!).existsSync()) {
      return _BlurredAndSaturatedImage(
        filePath: settings.customBackgroundImagePath!,
        blurSigma: tokens.isLiteMode ? 0.0 : settings.backgroundBlur,
        saturation: settings.backgroundSaturation,
      );
    }

    if (mode == BackgroundMode.blurredArtwork && widget.activeTrack != null) {
      final track = widget.activeTrack!;
      final cachedPath =
          track.customArtPath ?? sl<ThumbnailPathCache>().peek(track.albumKey);
      if (cachedPath != null && File(cachedPath).existsSync()) {
        return _BlurredAndSaturatedImage(
          filePath: cachedPath,
          blurSigma: tokens.isLiteMode ? 0.0 : settings.backgroundBlur,
          saturation: settings.backgroundSaturation,
        );
      }
    }

    if (mode == BackgroundMode.artworkGradient ||
        mode == BackgroundMode.blurredArtwork ||
        tokens.isLiteMode) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color.lerp(tokens.canvas, artPrimary, 0.38)!,
              tokens.canvas,
              Color.lerp(tokens.canvas, artSecondary, 0.28)!,
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ProceduralBackgroundPainter(
            mode: mode,
            phase: _controller.value,
            canvasColor: tokens.canvas,
            primary: artPrimary,
            secondary: artSecondary,
            isPlaying: widget.isPlaying,
          ),
        );
      },
    );
  }
}

class _BlurredAndSaturatedImage extends StatelessWidget {
  const _BlurredAndSaturatedImage({
    required this.filePath,
    required this.blurSigma,
    required this.saturation,
  });

  final String filePath;
  final double blurSigma;
  final double saturation;

  @override
  Widget build(BuildContext context) {
    Widget img = Image.file(
      File(filePath),
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
    if ((saturation - 1.0).abs() > 0.03) {
      img = ColorFiltered(
        colorFilter: ColorFilter.matrix(_saturationMatrix(saturation)),
        child: img,
      );
    }
    if (blurSigma > 0.5) {
      img = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: blurSigma,
          sigmaY: blurSigma,
          tileMode: TileMode.mirror,
        ),
        child: img,
      );
    }
    return ClipRect(child: img);
  }

  List<double> _saturationMatrix(double s) {
    final inv = 1.0 - s;
    const r = 0.2126;
    const g = 0.7152;
    const b = 0.0722;
    return <double>[
      inv * r + s,
      inv * g,
      inv * b,
      0,
      0,
      inv * r,
      inv * g + s,
      inv * b,
      0,
      0,
      inv * r,
      inv * g,
      inv * b + s,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}

class _ProceduralBackgroundPainter extends CustomPainter {
  const _ProceduralBackgroundPainter({
    required this.mode,
    required this.phase,
    required this.canvasColor,
    required this.primary,
    required this.secondary,
    required this.isPlaying,
  });

  final BackgroundMode mode;
  final double phase;
  final Color canvasColor;
  final Color primary;
  final Color secondary;
  final bool isPlaying;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = canvasColor);
    final angle = phase * math.pi * 2;

    switch (mode) {
      case BackgroundMode.animatedGradient:
        final dx = math.cos(angle) * 0.4;
        final dy = math.sin(angle) * 0.4;
        final paint = Paint()
          ..shader = LinearGradient(
            begin: Alignment(-0.8 + dx, -0.8 + dy),
            end: Alignment(0.8 - dx, 0.8 - dy),
            colors: <Color>[
              primary.withValues(alpha: 0.36),
              canvasColor,
              secondary.withValues(alpha: 0.28),
            ],
          ).createShader(Offset.zero & size);
        canvas.drawRect(Offset.zero & size, paint);
      case BackgroundMode.proceduralAurora:
        for (var i = 0; i < 3; i++) {
          final cx =
              size.width * (0.25 + 0.5 * math.sin(angle + i * 2.1).abs());
          final cy = size.height * (0.2 + 0.25 * i + 0.08 * math.cos(angle));
          final radius = size.shortestSide * (0.55 + i * 0.12);
          final color = (i.isEven ? primary : secondary).withValues(
            alpha: 0.24,
          );
          final paint = Paint()
            ..shader =
                RadialGradient(
                  colors: <Color>[color, color.withValues(alpha: 0.0)],
                ).createShader(
                  Rect.fromCircle(center: Offset(cx, cy), radius: radius),
                );
          canvas.drawCircle(Offset(cx, cy), radius, paint);
        }
      case BackgroundMode.proceduralWaves:
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        for (var w = 0; w < 6; w++) {
          paint.color = (w.isEven ? primary : secondary).withValues(
            alpha: 0.18 + w * 0.02,
          );
          final path = Path();
          final baseY = size.height * (0.22 + w * 0.12);
          path.moveTo(0, baseY);
          for (var x = 0.0; x <= size.width; x += 18) {
            final y =
                baseY +
                math.sin((x / size.width) * math.pi * 3 + angle + w * 0.7) *
                    (18 + w * 3);
            path.lineTo(x, y);
          }
          canvas.drawPath(path, paint);
        }
      case BackgroundMode.proceduralGrain:
        final wash = Paint()
          ..shader = RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.1,
            colors: <Color>[primary.withValues(alpha: 0.25), canvasColor],
          ).createShader(Offset.zero & size);
        canvas.drawRect(Offset.zero & size, wash);
        final dotPaint = Paint()..color = primary.withValues(alpha: 0.08);
        final rng = math.Random(42);
        for (var i = 0; i < 180; i++) {
          canvas.drawCircle(
            Offset(
              rng.nextDouble() * size.width,
              rng.nextDouble() * size.height,
            ),
            1.1,
            dotPaint,
          );
        }
      case BackgroundMode.proceduralStrings:
        final amp = isPlaying ? 8.0 : 1.5;
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        for (var s = 0; s < 5; s++) {
          paint.color = (s.isEven ? primary : secondary).withValues(
            alpha: 0.26 - s * 0.03,
          );
          final y = size.height * (0.26 + s * 0.11);
          final path = Path()..moveTo(0, y);
          final midY = y + math.sin(angle * 2 + s * 1.3) * amp;
          path.quadraticBezierTo(size.width * 0.5, midY, size.width, y - 14);
          canvas.drawPath(path, paint);
        }
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ProceduralBackgroundPainter oldDelegate) {
    return oldDelegate.mode != mode ||
        oldDelegate.phase != phase ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.isPlaying != isPlaying;
  }
}
