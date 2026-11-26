import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/utils/haptic_service.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/player/domain/sleep_timer_config.dart';

/// Signature Wetar seek bar supporting Oud-string vibrating waveform,
/// stylized bars, thin line, thick pill, and A–B loop pin indicators.
class WetarSeekBar extends StatefulWidget {
  const WetarSeekBar({
    super.key,
    required this.seedKey,
    required this.style,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.abLoop,
    required this.hapticsIntensity,
    required this.onSeek,
  });

  final String seedKey;
  final SeekBarStyle style;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final AbLoopState abLoop;
  final HapticsIntensity hapticsIntensity;
  final ValueChanged<Duration> onSeek;

  @override
  State<WetarSeekBar> createState() => _WetarSeekBarState();
}

class _WetarSeekBarState extends State<WetarSeekBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  double? _dragRatio;
  late List<double> _heights;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _heights = _generateSeedBars(widget.seedKey);
  }

  @override
  void didUpdateWidget(covariant WetarSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seedKey != widget.seedKey) {
      _heights = _generateSeedBars(widget.seedKey);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  List<double> _generateSeedBars(String key) {
    final rng = math.Random(key.hashCode);
    return List<double>.generate(48, (i) {
      final envelope = math.sin((i / 47.0) * math.pi) * 0.45 + 0.4;
      return (0.18 + rng.nextDouble() * 0.72) * envelope;
    });
  }

  void _handleDragUpdate(double localDx, double width) {
    if (width <= 0) return;
    final ratio = (localDx / width).clamp(0.0, 1.0);
    setState(() => _dragRatio = ratio);
  }

  void _commitDrag() {
    final ratio = _dragRatio;
    if (ratio == null) return;
    setState(() => _dragRatio = null);
    final targetMs = (widget.duration.inMilliseconds * ratio).round();
    HapticService.trigger(widget.hapticsIntensity);
    widget.onSeek(Duration(milliseconds: targetMs));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wetarTokens;
    final tickerEnabled = TickerMode.valuesOf(context).enabled;
    final shouldPulse =
        widget.style == SeekBarStyle.stringWaveform &&
        widget.isPlaying &&
        tickerEnabled &&
        !tokens.isLiteMode;

    if (shouldPulse && !_waveController.isAnimating) {
      _waveController.repeat();
    } else if (!shouldPulse && _waveController.isAnimating) {
      _waveController.stop();
    }

    final totalMs = widget.duration.inMilliseconds.clamp(1, 86400000);
    final progress =
        _dragRatio ??
        (widget.position.inMilliseconds / totalMs).clamp(0.0, 1.0);

    if (widget.style == SeekBarStyle.thinLine ||
        widget.style == SeekBarStyle.thickPill) {
      return SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: widget.style == SeekBarStyle.thickPill ? 10 : 3,
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: widget.style == SeekBarStyle.thickPill ? 7 : 6,
          ),
        ),
        child: Slider(
          min: 0,
          max: totalMs.toDouble(),
          value: (progress * totalMs).clamp(0, totalMs).toDouble(),
          activeColor: tokens.accentPrimary,
          inactiveColor: tokens.borderSubtle,
          onChanged: (v) => widget.onSeek(Duration(milliseconds: v.round())),
        ),
      );
    }

    final double? aRatio = widget.abLoop.pointA != null
        ? (widget.abLoop.pointA!.inMilliseconds / totalMs).clamp(0.0, 1.0)
        : null;
    final double? bRatio = widget.abLoop.pointB != null
        ? (widget.abLoop.pointB!.inMilliseconds / totalMs).clamp(0.0, 1.0)
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) {
            _handleDragUpdate(d.localPosition.dx, width);
            _commitDrag();
          },
          onHorizontalDragStart: (d) =>
              _handleDragUpdate(d.localPosition.dx, width),
          onHorizontalDragUpdate: (d) =>
              _handleDragUpdate(d.localPosition.dx, width),
          onHorizontalDragEnd: (_) => _commitDrag(),
          onHorizontalDragCancel: () => setState(() => _dragRatio = null),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _WetarWaveformPainter(
                      bars: _heights,
                      progress: progress,
                      isStringWaveform:
                          widget.style == SeekBarStyle.stringWaveform,
                      isPlaying: shouldPulse,
                      phase: _waveController.value,
                      activeColor: tokens.accentPrimary,
                      secondaryColor: tokens.accentSecondary,
                      inactiveColor: tokens.inkMuted.withValues(alpha: 0.35),
                      aRatio: aRatio,
                      bRatio: bRatio,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WetarWaveformPainter extends CustomPainter {
  const _WetarWaveformPainter({
    required this.bars,
    required this.progress,
    required this.isStringWaveform,
    required this.isPlaying,
    required this.phase,
    required this.activeColor,
    required this.secondaryColor,
    required this.inactiveColor,
    this.aRatio,
    this.bRatio,
  });

  final List<double> bars;
  final double progress;
  final bool isStringWaveform;
  final bool isPlaying;
  final double phase;
  final Color activeColor;
  final Color secondaryColor;
  final Color inactiveColor;
  final double? aRatio;
  final double? bRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final barStep = size.width / bars.length;
    final barWidth = (barStep * 0.56).clamp(2.0, 5.0);

    final paint = Paint()..strokeCap = StrokeCap.round;

    for (var i = 0; i < bars.length; i++) {
      final ratio = i / (bars.length - 1);
      final x = i * barStep + barStep * 0.5;
      final isPassed = ratio <= progress;
      paint
        ..color = isPassed ? activeColor : inactiveColor
        ..strokeWidth = barWidth;

      final amp = bars[i] * (size.height * 0.42);
      canvas.drawLine(
        Offset(x, centerY - amp),
        Offset(x, centerY + amp),
        paint,
      );
    }

    if (isStringWaveform) {
      // Plucked Oud string harmonic overlay along played portion.
      final stringPath = Path();
      final playedX = size.width * progress;
      stringPath.moveTo(0, centerY);
      const samples = 24;
      final waveAmp = isPlaying ? 3.5 : 0.0;
      for (var i = 1; i <= samples; i++) {
        final t = i / samples;
        final x = playedX * t;
        final pluck =
            math.sin(t * math.pi * 4 + phase * math.pi * 2) * waveAmp * (1 - t);
        stringPath.lineTo(x, centerY + pluck);
      }
      canvas.drawPath(
        stringPath,
        Paint()
          ..color = secondaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    // Playhead bead
    final headX = (size.width * progress).clamp(4.0, size.width - 4.0);
    canvas.drawCircle(
      Offset(headX, centerY),
      5.5,
      Paint()..color = activeColor,
    );

    // Optional A-B loop pins
    if (aRatio != null) {
      final ax = size.width * aRatio!;
      canvas.drawLine(
        Offset(ax, 2),
        Offset(ax, size.height - 2),
        Paint()
          ..color = secondaryColor
          ..strokeWidth = 2,
      );
    }
    if (bRatio != null) {
      final bx = size.width * bRatio!;
      canvas.drawLine(
        Offset(bx, 2),
        Offset(bx, size.height - 2),
        Paint()
          ..color = secondaryColor
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WetarWaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.phase != phase ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.aRatio != aRatio ||
        oldDelegate.bRatio != bRatio;
  }
}
