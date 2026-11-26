import 'package:material_ui/material_ui.dart';

import '../../../personalization/presentation/theme/wetar_tokens.dart';

/// Fast alphabetical / Arabic-letter index rail paired with fixed-extent lists.
class WetarFastScrollbar extends StatefulWidget {
  const WetarFastScrollbar({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.itemExtent,
    required this.labelForIndex,
    required this.child,
  });

  final ScrollController controller;
  final int itemCount;
  final double itemExtent;
  final String Function(int index) labelForIndex;
  final Widget child;

  @override
  State<WetarFastScrollbar> createState() => _WetarFastScrollbarState();
}

class _WetarFastScrollbarState extends State<WetarFastScrollbar> {
  String? _activeBubble;
  double _dragYRatio = 0;

  void _jumpToPosition(double dy, double height) {
    if (widget.itemCount <= 0 || height <= 0 || !widget.controller.hasClients) {
      return;
    }
    final ratio = (dy / height).clamp(0.0, 1.0);
    final maxScroll = widget.controller.position.maxScrollExtent;
    final targetOffset = (maxScroll * ratio).clamp(0.0, maxScroll);
    widget.controller.jumpTo(targetOffset);
    final index = (targetOffset / widget.itemExtent).round().clamp(
      0,
      widget.itemCount - 1,
    );
    setState(() {
      _dragYRatio = ratio;
      _activeBubble = widget.labelForIndex(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wetarTokens;
    if (widget.itemCount < 30) {
      return widget.child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return Stack(
          children: <Widget>[
            widget.child,
            PositionedDirectional(
              top: 8,
              bottom: 8,
              end: 2,
              width: 26,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragStart: (d) =>
                    _jumpToPosition(d.localPosition.dy, height - 16),
                onVerticalDragUpdate: (d) =>
                    _jumpToPosition(d.localPosition.dy, height - 16),
                onVerticalDragEnd: (_) => setState(() => _activeBubble = null),
                onVerticalDragCancel: () =>
                    setState(() => _activeBubble = null),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Container(
                    width: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: tokens.inkMuted.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(tokens.radiusPill),
                    ),
                  ),
                ),
              ),
            ),
            if (_activeBubble != null)
              PositionedDirectional(
                top: (_dragYRatio * (height - 80)).clamp(16.0, height - 80),
                end: 40,
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.accentPrimary,
                    borderRadius: BorderRadius.circular(tokens.radiusCard),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Text(
                    _activeBubble!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
