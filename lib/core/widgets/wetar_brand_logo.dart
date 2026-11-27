import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Minimalist geometric Harmonic Ring & Ivory Play Plectrum emblem for Wetar.
class WetarBrandLogo extends StatelessWidget {
  const WetarBrandLogo({
    super.key,
    this.size = 64,
    this.showTileBackground = true,
  });

  final double size;
  final bool showTileBackground;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Wetar logo',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _WetarLogoPainter(showTileBackground: showTileBackground),
        ),
      ),
    );
  }
}

class _WetarLogoPainter extends CustomPainter {
  const _WetarLogoPainter({required this.showTileBackground});

  final bool showTileBackground;

  static const Color _bgTop = Color(0xFF1A1822);
  static const Color _bgMid = Color(0xFF100E15);
  static const Color _bgBottom = Color(0xFF08070B);

  static const Color _ringLight = Color(0xFFFFE8A3);
  static const Color _ringMid = Color(0xFFF59E0B);
  static const Color _ringDeep = Color(0xFFEA580C);
  static const Color _innerArcLight = Color(0xFFFCD34D);

  static const Color _ivoryTop = Color(0xFFFFFFFF);
  static const Color _ivoryMid = Color(0xFFFFF7E6);
  static const Color _ivoryBottom = Color(0xFFFDE2A3);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 1024.0;
    canvas.save();
    canvas.scale(s, s);

    const tileRect = Rect.fromLTWH(0, 0, 1024, 1024);
    if (showTileBackground) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(tileRect, const Radius.circular(228)),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[_bgTop, _bgMid, _bgBottom],
            stops: <double>[0.0, 0.55, 1.0],
          ).createShader(tileRect),
      );

      // Warm ambient amber glow behind the concentric harmonic mark.
      canvas.drawCircle(
        const Offset(512, 512),
        440,
        Paint()
          ..shader =
              RadialGradient(
                colors: <Color>[
                  _ringMid.withValues(alpha: 0.20),
                  _ringDeep.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const <double>[0.0, 0.55, 1.0],
              ).createShader(
                Rect.fromCircle(center: const Offset(512, 512), radius: 440),
              ),
      );

      // Crisp inner glass rim bevel around tile edge.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(4, 4, 1016, 1016),
          const Radius.circular(224),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Colors.white.withValues(alpha: 0.16),
              Colors.transparent,
              _ringMid.withValues(alpha: 0.12),
            ],
          ).createShader(tileRect),
      );
    }

    const center = Offset(512, 512);
    final outerRect = Rect.fromCircle(center: center, radius: 304);
    final innerRect = Rect.fromCircle(center: center, radius: 212);

    const outerStartRad = 52 * math.pi / 180.0;
    const outerSweepRad = 256 * math.pi / 180.0;
    const innerStartRad = 124 * math.pi / 180.0;
    const innerSweepRad = 112 * math.pi / 180.0;

    // Exact tangent-smooth Minkowski-rounded equilateral Play plectrum.
    const rPlay = 52.0;
    final playPath = Path()
      ..moveTo(400.0, 624.0)
      ..lineTo(400.0, 400.0)
      ..arcTo(
        Rect.fromCircle(center: const Offset(452, 400), radius: rPlay),
        math.pi,
        2 * math.pi / 3,
        false,
      )
      ..lineTo(672.0, 466.97)
      ..arcTo(
        Rect.fromCircle(center: const Offset(646, 512), radius: rPlay),
        -math.pi / 3,
        2 * math.pi / 3,
        false,
      )
      ..lineTo(478.0, 669.03)
      ..arcTo(
        Rect.fromCircle(center: const Offset(452, 624), radius: rPlay),
        math.pi / 3,
        2 * math.pi / 3,
        false,
      )
      ..close();

    // Soft elevation shadow under all 3 foreground geometric shapes.
    canvas.save();
    canvas.translate(0, 18);
    final strokeShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawArc(
      outerRect,
      outerStartRad,
      outerSweepRad,
      false,
      strokeShadow..strokeWidth = 48,
    );
    canvas.drawArc(
      innerRect,
      innerStartRad,
      innerSweepRad,
      false,
      strokeShadow..strokeWidth = 28,
    );
    canvas.drawPath(
      playPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.44)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.restore();

    // 1. Bold outer 256-degree harmonic golden C-ring.
    canvas.drawArc(
      outerRect,
      outerStartRad,
      outerSweepRad,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 48
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[_ringLight, _ringMid, _ringDeep],
          stops: <double>[0.0, 0.50, 1.0],
        ).createShader(const Rect.fromLTWH(208, 208, 608, 608)),
    );

    // 2. Inner 112-degree sympathetic string wave arc.
    canvas.drawArc(
      innerRect,
      innerStartRad,
      innerSweepRad,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            _innerArcLight.withValues(alpha: 0.90),
            _ringMid.withValues(alpha: 0.86),
          ],
        ).createShader(const Rect.fromLTWH(300, 336, 120, 352)),
    );

    // 3. Crisp ivory-champagne rounded Play plectrum.
    canvas.drawPath(
      playPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[_ivoryTop, _ivoryMid, _ivoryBottom],
          stops: <double>[0.0, 0.60, 1.0],
        ).createShader(const Rect.fromLTWH(400, 348, 298, 328)),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WetarLogoPainter oldDelegate) =>
      oldDelegate.showTileBackground != showTileBackground;
}
