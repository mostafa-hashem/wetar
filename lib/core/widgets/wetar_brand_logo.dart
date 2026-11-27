import 'package:material_ui/material_ui.dart';

/// Wetar's emblem combines a play symbol with an audio waveform.
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
    final useLightMark =
        showTileBackground || Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Wetar logo',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _WetarLogoPainter(
            showTileBackground: showTileBackground,
            useLightMark: useLightMark,
          ),
        ),
      ),
    );
  }
}

class _WetarLogoPainter extends CustomPainter {
  const _WetarLogoPainter({
    required this.showTileBackground,
    required this.useLightMark,
  });

  final bool showTileBackground;
  final bool useLightMark;

  static const _ink = Color(0xFF123A36);
  static const _ivory = Color(0xFFFFF1D9);
  static const _apricot = Color(0xFFFFAE64);
  static const _burntOrange = Color(0xFFA64C12);

  // Match the paths in docs/branding/wetar_logo.svg.
  static final _play = Path()
    ..moveTo(47, 30)
    ..cubicTo(47, 24, 53, 21, 58, 25)
    ..lineTo(84, 43)
    ..cubicTo(89.5, 46.8, 89.5, 53.2, 84, 57)
    ..lineTo(58, 75)
    ..cubicTo(53, 79, 47, 76, 47, 70)
    ..close();

  static final _wave = Path()
    ..moveTo(17, 54)
    ..lineTo(21, 54)
    ..cubicTo(25, 54, 27, 52, 29, 48)
    ..lineTo(35, 36)
    ..cubicTo(37, 32, 43, 32, 45, 37)
    ..lineTo(51, 51)
    ..cubicTo(52.5, 54.5, 55, 55, 58, 53)
    ..lineTo(64, 50)
    ..quadraticBezierTo(67, 48.5, 65, 51.5)
    ..lineTo(57, 62)
    ..cubicTo(53, 68, 46, 66, 43, 59)
    ..lineTo(39, 50)
    ..cubicTo(34, 60, 30, 65, 21, 65)
    ..lineTo(17, 65)
    ..cubicTo(14, 65, 11.5, 62.5, 11.5, 59.5)
    ..cubicTo(11.5, 56.5, 14, 54, 17, 54)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 100);

    if (showTileBackground) {
      canvas.drawRRect(
        RRect.fromLTRBR(0, 0, 100, 100, const Radius.circular(23)),
        Paint()..color = _ink,
      );
    }

    canvas.drawPath(_play, Paint()..color = useLightMark ? _ivory : _ink);
    canvas.drawPath(
      _wave,
      Paint()..color = useLightMark ? _apricot : _burntOrange,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WetarLogoPainter oldDelegate) =>
      oldDelegate.showTileBackground != showTileBackground ||
      oldDelegate.useLightMark != useLightMark;
}
