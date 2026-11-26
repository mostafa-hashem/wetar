import 'package:material_ui/material_ui.dart';

/// Hand-crafted geometric Oud-string emblem representing Wetar.
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

  static const Color _bgEspresso = Color(0xFF16120F);
  static const Color _amberOud = Color(0xFFE69B3A);
  static const Color _ivoryString = Color(0xFFF6EFE6);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 1024.0;
    canvas.save();
    canvas.scale(s, s);

    if (showTileBackground) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 1024, 1024),
          const Radius.circular(224),
        ),
        Paint()..color = _bgEspresso,
      );
    }

    final bodyPath = Path()
      ..moveTo(452, 184)
      ..lineTo(572, 184)
      ..cubicTo(574, 252, 578, 308, 622, 362)
      ..cubicTo(684, 432, 756, 480, 756, 560)
      ..cubicTo(756, 724, 650, 832, 512, 832)
      ..cubicTo(374, 832, 268, 724, 268, 560)
      ..cubicTo(268, 480, 340, 432, 402, 362)
      ..cubicTo(446, 308, 450, 252, 452, 184)
      ..close();

    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = _amberOud
        ..style = PaintingStyle.fill,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(466, 208, 92, 16),
        const Radius.circular(8),
      ),
      Paint()..color = _bgEspresso,
    );

    canvas.drawCircle(
      const Offset(512, 536),
      128,
      Paint()
        ..color = _bgEspresso
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    canvas.drawCircle(
      const Offset(512, 536),
      104,
      Paint()..color = _bgEspresso,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(422, 708, 180, 26),
        const Radius.circular(13),
      ),
      Paint()..color = _bgEspresso,
    );

    final stringPaint = Paint()
      ..color = _ivoryString
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      const Offset(476, 224),
      const Offset(476, 708),
      stringPaint,
    );
    final centerString = Path()
      ..moveTo(512, 224)
      ..lineTo(512, 406)
      ..cubicTo(512, 456, 530, 492, 530, 536)
      ..cubicTo(530, 580, 512, 616, 512, 666)
      ..lineTo(512, 708);
    canvas.drawPath(centerString, stringPaint);
    canvas.drawLine(
      const Offset(548, 224),
      const Offset(548, 708),
      stringPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WetarLogoPainter oldDelegate) =>
      oldDelegate.showTileBackground != showTileBackground;
}
