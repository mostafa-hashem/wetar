import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Sculpted diagonal Oud & resonant harmonic strings emblem for Wetar.
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

  static const Color _bgTop = Color(0xFF1E140F);
  static const Color _bgMid = Color(0xFF100B08);
  static const Color _bgBottom = Color(0xFF060403);
  static const Color _ebonyWell = Color(0xFF120C09);
  static const Color _soundholeVoid = Color(0xFF090605);
  static const Color _goldLight = Color(0xFFFFF0C4);
  static const Color _goldMid = Color(0xFFEB9E38);
  static const Color _goldDeep = Color(0xFFA84E10);
  static const Color _stringIvory = Color(0xFFFFF5DC);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 1024.0;
    canvas.save();
    canvas.scale(s, s);

    const tileRect = Rect.fromLTWH(0, 0, 1024, 1024);
    if (showTileBackground) {
      final tileRRect = RRect.fromRectAndRadius(
        tileRect,
        const Radius.circular(228),
      );
      canvas.drawRRect(
        tileRRect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[_bgTop, _bgMid, _bgBottom],
            stops: <double>[0.0, 0.55, 1.0],
          ).createShader(tileRect),
      );

      // Warm studio radial spotlight behind the soundboard.
      canvas.drawCircle(
        const Offset(490, 500),
        450,
        Paint()
          ..shader =
              RadialGradient(
                colors: <Color>[
                  _goldMid.withValues(alpha: 0.22),
                  _goldDeep.withValues(alpha: 0.06),
                  Colors.transparent,
                ],
                stops: const <double>[0.0, 0.52, 1.0],
              ).createShader(
                Rect.fromCircle(center: const Offset(490, 500), radius: 450),
              ),
      );

      // Subtle champagne specular bevel around tile edge.
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
              _goldLight.withValues(alpha: 0.28),
              Colors.transparent,
              _goldMid.withValues(alpha: 0.14),
            ],
          ).createShader(tileRect),
      );
    }

    canvas.translate(476, 514);
    canvas.scale(1.13, 1.13);
    canvas.rotate(42 * math.pi / 180.0);

    // Subtle acoustic resonance waves flanking the lower bout.
    const boutCenter = Offset(0, 88);
    void drawWaveArc(
      double radius,
      double width,
      double alpha,
      double sweepDeg,
    ) {
      final sweepRad = sweepDeg * math.pi / 180.0;
      final rect = Rect.fromCircle(center: boutCenter, radius: radius);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..color = _goldMid.withValues(alpha: alpha);
      canvas.drawArc(rect, -sweepRad / 2, sweepRad, false, paint);
      canvas.drawArc(rect, math.pi - sweepRad / 2, sweepRad, false, paint);
    }

    drawWaveArc(242, 9, 0.36, 38);
    drawWaveArc(276, 5.5, 0.18, 28);

    // C2-continuous pear soundboard + neck silhouette.
    final pearBody = Path()
      ..moveTo(38, -112)
      ..cubicTo(96, -54, 206, -12, 206, 88)
      ..cubicTo(206, 194, 118, 268, 0, 268)
      ..cubicTo(-118, 268, -206, 194, -206, 88)
      ..cubicTo(-206, -12, -96, -54, -38, -112)
      ..close();

    // Signature slanted Oud pegbox + tapered neck behind body join.
    final neckAndPegbox = Path()
      ..moveTo(-38, -106)
      ..lineTo(-27, -268)
      ..lineTo(20, -310)
      ..lineTo(82, -342)
      ..cubicTo(98, -350, 108, -338, 102, -324)
      ..cubicTo(94, -304, 62, -282, 27, -268)
      ..lineTo(38, -106)
      ..close();

    // Soft ambient studio shadow under the instrument.
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.save();
    canvas.translate(-10, 18);
    canvas.drawPath(neckAndPegbox, shadowPaint);
    canvas.drawPath(pearBody, shadowPaint);
    canvas.restore();

    const goldGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[_goldLight, _goldMid, _goldDeep],
      stops: <double>[0.0, 0.50, 1.0],
    );

    canvas.drawPath(
      neckAndPegbox,
      Paint()
        ..shader = goldGradient.createShader(
          const Rect.fromLTWH(-40, -352, 150, 250),
        ),
    );

    // Subtle ebony pegbox slot channel echoing hand-carved tuning box.
    canvas.drawLine(
      const Offset(18, -286),
      const Offset(74, -322),
      Paint()
        ..color = _ebonyWell
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(
      pearBody,
      Paint()
        ..shader = goldGradient.createShader(
          const Rect.fromLTWH(-206, -112, 412, 380),
        ),
    );

    // Bookmatched luthier right-half tone split on the soundboard.
    canvas.save();
    canvas.clipPath(pearBody);
    canvas.drawRect(
      const Rect.fromLTWH(0, -120, 220, 400),
      Paint()..color = const Color(0xFF4A1E04).withValues(alpha: 0.13),
    );
    canvas.restore();

    // Crisp rim highlight along the pear soundboard edge.
    canvas.drawPath(
      pearBody,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            _stringIvory.withValues(alpha: 0.55),
            Colors.transparent,
            _goldDeep.withValues(alpha: 0.45),
          ],
        ).createShader(const Rect.fromLTWH(-206, -112, 412, 380)),
    );

    // Dark ebony fingerboard inlay tapering into the upper bout.
    final fingerboard = Path()
      ..moveTo(-24, -266)
      ..lineTo(24, -266)
      ..lineTo(32, -62)
      ..quadraticBezierTo(0, -48, -32, -62)
      ..close();
    canvas.drawPath(fingerboard, Paint()..color = _ebonyWell);

    // Subtle champagne-gold nut bar at the top of the fingerboard.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -267), width: 58, height: 9),
        const Radius.circular(4.5),
      ),
      Paint()..color = _goldLight,
    );

    // Shamsa soundhole well, beveled metallic bezel & delicate inner rosette.
    const holeCenter = Offset(0, 36);
    canvas.drawCircle(holeCenter, 76, Paint()..color = _soundholeVoid);
    canvas.drawCircle(
      holeCenter,
      76,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..shader = goldGradient.createShader(
          Rect.fromCircle(center: holeCenter, radius: 80),
        ),
    );
    canvas.drawCircle(
      holeCenter,
      54,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = _goldMid.withValues(alpha: 0.42),
    );
    canvas.drawCircle(
      holeCenter,
      36,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _goldLight.withValues(alpha: 0.20),
    );

    // Sleek ebony bridge & ivory saddle anchoring the strings.
    final bridgeRect = Rect.fromCenter(
      center: const Offset(0, 174),
      width: 162,
      height: 24,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bridgeRect, const Radius.circular(12)),
      Paint()..color = _ebonyWell,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bridgeRect, const Radius.circular(12)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _goldLight.withValues(alpha: 0.35),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 171), width: 108, height: 5.5),
        const Radius.circular(2.75),
      ),
      Paint()..color = _goldLight,
    );

    // Three converging silk-gold strings spanning nut -> soundhole -> bridge.
    final outerStringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round
      ..color = _stringIvory.withValues(alpha: 0.90);
    canvas.drawLine(
      const Offset(-15, -266),
      const Offset(-34, 171),
      outerStringPaint,
    );
    canvas.drawLine(
      const Offset(15, -266),
      const Offset(34, 171),
      outerStringPaint,
    );

    // Center hero string with warm amber aura.
    canvas.drawLine(
      const Offset(0, -266),
      const Offset(0, 171),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..color = _goldMid.withValues(alpha: 0.38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawLine(
      const Offset(0, -266),
      const Offset(0, 171),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.5
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Colors.white, _goldLight],
        ).createShader(const Rect.fromLTWH(-6, -266, 12, 438)),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WetarLogoPainter oldDelegate) =>
      oldDelegate.showTileBackground != showTileBackground;
}
