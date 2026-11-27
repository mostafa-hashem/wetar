import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Shared responsive layout helpers preventing oversized grids and stretched
/// forms on macOS/desktop while keeping compact mobile ergonomics unchanged.
class WetarResponsive {
  WetarResponsive._();

  static const BoxConstraints sheetConstraints = BoxConstraints(maxWidth: 540);

  static const double defaultFormMaxWidth = 820;
  static const double defaultDashboardMaxWidth = 1040;
  static const double defaultWizardMaxWidth = 680;

  /// Computes outer horizontal padding that centers content within [maxWidth]
  /// on wide desktop viewports while leaving scrollbars at the viewport edge.
  static double horizontalInset(
    double viewportWidth,
    double minPadding, {
    double maxWidth = defaultFormMaxWidth,
  }) {
    if (viewportWidth <= maxWidth + minPadding * 2) {
      return minPadding;
    }
    return math.max(minPadding, (viewportWidth - maxWidth) / 2);
  }

  /// Convenience [EdgeInsets] helper combining desktop centering with top/bottom insets.
  static EdgeInsets listPadding(
    double viewportWidth, {
    required double minHorizontal,
    required double top,
    required double bottom,
    double maxWidth = defaultFormMaxWidth,
  }) {
    final h = horizontalInset(viewportWidth, minHorizontal, maxWidth: maxWidth);
    return EdgeInsets.fromLTRB(h, top, h, bottom);
  }

  /// Responsive grid delegate for Look/Wallpaper preset tiles.
  static SliverGridDelegate presetGridDelegate({
    double maxTileExtent = 215,
    double aspectRatio = 1.65,
    double spacing = 12,
  }) {
    return SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: maxTileExtent,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: aspectRatio,
    );
  }

  /// Responsive media grid delegate honoring user columns on phones while
  /// scaling smoothly to 3–6 columns on wide macOS/desktop windows.
  static SliverGridDelegate mediaGridDelegateForWidth(
    double width, {
    required int preferredColumns,
    double minTileWidth = 178,
    double childAspectRatio = 0.78,
    double spacing = 14,
  }) {
    final cols = width < 600
        ? preferredColumns.clamp(2, 4)
        : math.max(
            preferredColumns,
            (width / minTileWidth).floor().clamp(2, 6),
          );
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: cols,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
    );
  }
}
