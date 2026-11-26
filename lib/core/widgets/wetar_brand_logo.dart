import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Luxury Golden Soundhole & Harmonic Strings emblem representing Wetar.
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

  static const Color _bgTop = Color(0xFF1E1612);
  static const Color _bgMid = Color(0xFF0E0B09);
  static const Color _bgBottom = Color(0xFF060504);
  static const Color _voidWell = Color(0xFF080605);
  static const Color _goldLight = Color(0xFFFFF2C2);
  static const Color _goldMid = Color(0xFFEAA038);
  static const Color _goldDeep = Color(0xFF9E4B0D);

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

      // Warm radial acoustic halo behind the soundhole.
      canvas.drawCircle(
        const Offset(512, 512),
        430,
        Paint()
          ..shader =
              RadialGradient(
                colors: <Color>[
                  _goldMid.withValues(alpha: 0.20),
                  _goldDeep.withValues(alpha: 0.06),
                  Colors.transparent,
                ],
                stops: const <double>[0.0, 0.52, 1.0],
              ).createShader(
                Rect.fromCircle(center: const Offset(512, 512), radius: 430),
              ),
      );

      // Subtle inner champagne rim highlight.
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

    canvas.translate(512, 512);
    canvas.rotate(-math.pi / 6);

    const metallicShaderRect = Rect.fromLTWH(-300, -320, 600, 640);
    final metallicGoldShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[_goldLight, _goldMid, _goldDeep],
      stops: <double>[0.0, 0.52, 1.0],
    ).createShader(metallicShaderRect);

    // Sculpted crescent soundhole bezel (outer offset from inner aperture).
    final outerCircle = Path()
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: 290));
    final innerAperture = Path()
      ..addOval(Rect.fromCircle(center: const Offset(12, -10), radius: 244));
    final crescentRing = Path.combine(
      PathOperation.difference,
      outerCircle,
      innerAperture,
    );

    canvas.drawPath(
      crescentRing,
      Paint()
        ..shader = metallicGoldShader
        ..style = PaintingStyle.fill,
    );

    // Deep velvet-obsidian soundhole interior & subtle concentric rosette line.
    canvas.drawCircle(const Offset(12, -10), 242, Paint()..color = _voidWell);
    canvas.drawCircle(
      const Offset(12, -10),
      204,
      Paint()
        ..color = _goldMid.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    // Top & bottom tapered metallic gold bridge capsules anchoring the strings.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero.translate(0, -304),
          width: 236,
          height: 22,
        ),
        const Radius.circular(11),
      ),
      Paint()..shader = metallicGoldShader,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero.translate(0, 304),
          width: 236,
          height: 22,
        ),
        const Radius.circular(11),
      ),
      Paint()..shader = metallicGoldShader,
    );

    // Secondary harmonic strings.
    final secondaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFF5DCAA), Color(0xFFD4882A)],
      ).createShader(const Rect.fromLTWH(-120, -292, 240, 584));

    canvas.drawLine(
      const Offset(-90, -292),
      const Offset(-90, 292),
      secondaryPaint,
    );

    final sympatheticString = Path()
      ..moveTo(-32, -292)
      ..lineTo(-32, -150)
      ..cubicTo(-32, -70, -56, -20, -56, 30)
      ..cubicTo(-56, 80, -32, 130, -32, 190)
      ..lineTo(-32, 292);
    canvas.drawPath(sympatheticString, secondaryPaint);

    canvas.drawLine(
      const Offset(90, -292),
      const Offset(90, 292),
      secondaryPaint,
    );

    // Hero plucked harmonic wave string with warm glow + champagne core.
    final heroString = Path()
      ..moveTo(32, -292)
      ..lineTo(32, -155)
      ..cubicTo(32, -88, 88, -66, 88, -20)
      ..cubicTo(88, 26, -12, 46, -12, 92)
      ..cubicTo(-12, 134, 32, 155, 32, 205)
      ..lineTo(32, 292);

    canvas.drawPath(
      heroString,
      Paint()
        ..color = _goldMid.withValues(alpha: 0.48)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 34
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.drawPath(
      heroString,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFFFFFFF),
            Color(0xFFFFEBB7),
            Color(0xFFF0A83C),
          ],
          stops: <double>[0.0, 0.45, 1.0],
        ).createShader(const Rect.fromLTWH(-40, -292, 140, 584)),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WetarLogoPainter oldDelegate) =>
      oldDelegate.showTileBackground != showTileBackground;
}
