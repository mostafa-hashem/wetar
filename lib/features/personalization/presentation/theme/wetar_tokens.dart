import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:wetar/core/widgets/wetar_responsive.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';

/// Resolved visual tokens read by every Wetar widget (never hardcode colors/radii/fonts).
@immutable
class WetarTokens extends ThemeExtension<WetarTokens> {
  const WetarTokens({
    required this.isDark,
    required this.isAmoled,
    required this.isLiteMode,
    required this.canvas,
    required this.surface,
    required this.surfaceElevated,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.inkPrimary,
    required this.inkMuted,
    required this.borderSubtle,
    required this.danger,
    required this.success,
    required this.radiusCard,
    required this.radiusSheet,
    required this.radiusPill,
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    required this.listRowExtent,
    required this.shadowAlpha,
    required this.glassSigma,
    required this.motionDuration,
    required this.motionCurve,
    required this.primaryFontFamily,
    required this.fontFallbacks,
    required this.iconScale,
  });

  final bool isDark;
  final bool isAmoled;
  final bool isLiteMode;
  final Color canvas;
  final Color surface;
  final Color surfaceElevated;
  final Color accentPrimary;
  final Color accentSecondary;
  final Color inkPrimary;
  final Color inkMuted;
  final Color borderSubtle;
  final Color danger;
  final Color success;

  final double radiusCard;
  final double radiusSheet;
  final double radiusPill;

  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double listRowExtent;

  final double shadowAlpha;
  final double glassSigma;
  final Duration motionDuration;
  final Curve motionCurve;
  final String? primaryFontFamily;
  final List<String> fontFallbacks;
  final double iconScale;

  @override
  WetarTokens copyWith({
    bool? isDark,
    bool? isAmoled,
    bool? isLiteMode,
    Color? canvas,
    Color? surface,
    Color? surfaceElevated,
    Color? accentPrimary,
    Color? accentSecondary,
    Color? inkPrimary,
    Color? inkMuted,
    Color? borderSubtle,
    Color? danger,
    Color? success,
    double? radiusCard,
    double? radiusSheet,
    double? radiusPill,
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? listRowExtent,
    double? shadowAlpha,
    double? glassSigma,
    Duration? motionDuration,
    Curve? motionCurve,
    String? primaryFontFamily,
    List<String>? fontFallbacks,
    double? iconScale,
  }) {
    return WetarTokens(
      isDark: isDark ?? this.isDark,
      isAmoled: isAmoled ?? this.isAmoled,
      isLiteMode: isLiteMode ?? this.isLiteMode,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      accentPrimary: accentPrimary ?? this.accentPrimary,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      inkPrimary: inkPrimary ?? this.inkPrimary,
      inkMuted: inkMuted ?? this.inkMuted,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      radiusCard: radiusCard ?? this.radiusCard,
      radiusSheet: radiusSheet ?? this.radiusSheet,
      radiusPill: radiusPill ?? this.radiusPill,
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      listRowExtent: listRowExtent ?? this.listRowExtent,
      shadowAlpha: shadowAlpha ?? this.shadowAlpha,
      glassSigma: glassSigma ?? this.glassSigma,
      motionDuration: motionDuration ?? this.motionDuration,
      motionCurve: motionCurve ?? this.motionCurve,
      primaryFontFamily: primaryFontFamily ?? this.primaryFontFamily,
      fontFallbacks: fontFallbacks ?? this.fontFallbacks,
      iconScale: iconScale ?? this.iconScale,
    );
  }

  @override
  WetarTokens lerp(ThemeExtension<WetarTokens>? other, double t) {
    if (other is! WetarTokens) return this;
    return WetarTokens(
      isDark: t < 0.5 ? isDark : other.isDark,
      isAmoled: t < 0.5 ? isAmoled : other.isAmoled,
      isLiteMode: t < 0.5 ? isLiteMode : other.isLiteMode,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t)!,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
      inkPrimary: Color.lerp(inkPrimary, other.inkPrimary, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      radiusCard: radiusCard + (other.radiusCard - radiusCard) * t,
      radiusSheet: radiusSheet + (other.radiusSheet - radiusSheet) * t,
      radiusPill: radiusPill,
      spacingXs: spacingXs + (other.spacingXs - spacingXs) * t,
      spacingSm: spacingSm + (other.spacingSm - spacingSm) * t,
      spacingMd: spacingMd + (other.spacingMd - spacingMd) * t,
      spacingLg: spacingLg + (other.spacingLg - spacingLg) * t,
      spacingXl: spacingXl + (other.spacingXl - spacingXl) * t,
      listRowExtent: listRowExtent + (other.listRowExtent - listRowExtent) * t,
      shadowAlpha: shadowAlpha + (other.shadowAlpha - shadowAlpha) * t,
      glassSigma: glassSigma + (other.glassSigma - glassSigma) * t,
      motionDuration: t < 0.5 ? motionDuration : other.motionDuration,
      motionCurve: t < 0.5 ? motionCurve : other.motionCurve,
      primaryFontFamily: t < 0.5 ? primaryFontFamily : other.primaryFontFamily,
      fontFallbacks: t < 0.5 ? fontFallbacks : other.fontFallbacks,
      iconScale: iconScale + (other.iconScale - iconScale) * t,
    );
  }
}

extension WetarTokensContext on BuildContext {
  WetarTokens get wetarTokens =>
      Theme.of(this).extension<WetarTokens>() ??
      WetarTokenResolver.fallbackDark;
}

/// Converts [AppearanceSettings] + optional artwork palette into [ThemeData] & [WetarTokens].
class WetarTokenResolver {
  WetarTokenResolver._();

  static final WetarTokens fallbackDark = resolveTokens(
    const AppearanceSettings(),
    platformBrightness: Brightness.dark,
    systemDisableAnimations: false,
    isArabicLocale: false,
  );

  static bool resolveDarkMode(
    AppearanceSettings settings,
    Brightness platformBrightness,
  ) {
    if (settings.scheduledDarkEnabled) {
      final hour = DateTime.now().hour;
      final start = settings.scheduledDarkStartHour;
      final end = settings.scheduledDarkEndHour;
      if (start < end) {
        return hour >= start && hour < end;
      }
      return hour >= start || hour < end;
    }
    switch (settings.themeMode) {
      case WetarThemeMode.light:
        return false;
      case WetarThemeMode.dark:
      case WetarThemeMode.amoled:
        return true;
      case WetarThemeMode.system:
        return platformBrightness == Brightness.dark;
    }
  }

  static bool resolveLiteMode(
    AppearanceSettings settings, {
    required bool systemDisableAnimations,
  }) {
    switch (settings.liteModePreference) {
      case LiteModePreference.alwaysOn:
        return true;
      case LiteModePreference.alwaysOff:
        return false;
      case LiteModePreference.auto:
        return systemDisableAnimations ||
            settings.motionIntensity == MotionIntensity.off;
    }
  }

  static WetarTokens resolveTokens(
    AppearanceSettings settings, {
    required Brightness platformBrightness,
    required bool systemDisableAnimations,
    required bool isArabicLocale,
    Color? artworkPrimary,
    Color? artworkSecondary,
    Color? systemAccent,
  }) {
    final isDark = resolveDarkMode(settings, platformBrightness);
    final isAmoled = isDark && settings.themeMode == WetarThemeMode.amoled;
    final isLite = resolveLiteMode(
      settings,
      systemDisableAnimations: systemDisableAnimations,
    );

    var primary = settings.useSystemDynamicColor && systemAccent != null
        ? systemAccent
        : settings.accentColor;
    var secondary = settings.secondaryAccentColor;

    if (settings.adaptColorsToArtwork && artworkPrimary != null) {
      primary = Color.lerp(primary, artworkPrimary, 0.72) ?? artworkPrimary;
      if (artworkSecondary != null) {
        secondary =
            Color.lerp(secondary, artworkSecondary, 0.7) ?? artworkSecondary;
      }
    }

    final baseCanvas = isAmoled
        ? const Color(0xFF000000)
        : (isDark ? const Color(0xFF120F0D) : const Color(0xFFF7F3EC));
    final baseSurface = isAmoled
        ? const Color(0xFF0D0B0A)
        : (isDark ? const Color(0xFF1C1714) : const Color(0xFFFFFDF9));
    final baseElevated = isAmoled
        ? const Color(0xFF161210)
        : (isDark ? const Color(0xFF261F1B) : const Color(0xFFF1E9DC));

    final tintStrength =
        settings.surfaceTintIntensity * (isAmoled ? 0.08 : 0.14);
    final canvas = isAmoled
        ? baseCanvas
        : Color.lerp(baseCanvas, primary, tintStrength * 0.45)!;
    final surface = Color.lerp(baseSurface, primary, tintStrength)!;
    final surfaceElevated = Color.lerp(
      baseElevated,
      primary,
      tintStrength * 1.2,
    )!;

    final baseInk = isDark ? const Color(0xFFF6EFE6) : const Color(0xFF1F1915);
    final mutedAlpha = switch (settings.contrastLevel) {
      WetarContrastLevel.standard => 0.68,
      WetarContrastLevel.medium => 0.80,
      WetarContrastLevel.high => 0.92,
    };
    final inkPrimary = baseInk.withValues(
      alpha: settings.textEmphasis.clamp(0.85, 1.0),
    );
    final inkMuted = baseInk.withValues(alpha: mutedAlpha);
    final borderSubtle = isDark
        ? Color.lerp(const Color(0xFF322923), primary, 0.12)!
        : Color.lerp(const Color(0xFFE2D6C4), primary, 0.12)!;

    final spacingScale = switch (settings.listDensity) {
      ListDensity.compact => 0.85,
      ListDensity.comfortable => 1.0,
      ListDensity.spacious => 1.18,
    };
    final listRowExtent = switch (settings.listDensity) {
      ListDensity.compact => 58.0,
      ListDensity.comfortable => 68.0,
      ListDensity.spacious => 78.0,
    };

    final Duration motionDuration;
    if (isLite || settings.motionIntensity == MotionIntensity.off) {
      motionDuration = Duration.zero;
    } else {
      motionDuration = switch (settings.motionIntensity) {
        MotionIntensity.off => Duration.zero,
        MotionIntensity.reduced => const Duration(milliseconds: 120),
        MotionIntensity.balanced => const Duration(milliseconds: 220),
        MotionIntensity.expressive => const Duration(milliseconds: 320),
      };
    }

    final primaryFont = settings.useSystemFont
        ? null
        : (settings.importedFontFamily ??
              (isArabicLocale
                  ? settings.arabicFontFamily
                  : settings.latinFontFamily));
    final fallbacks = settings.useSystemFont
        ? const <String>[]
        : <String>[
            settings.arabicFontFamily,
            settings.latinFontFamily,
            'Cairo',
            'PlusJakartaSans',
          ];

    return WetarTokens(
      isDark: isDark,
      isAmoled: isAmoled,
      isLiteMode: isLite,
      canvas: canvas,
      surface: surface,
      surfaceElevated: surfaceElevated,
      accentPrimary: primary,
      accentSecondary: secondary,
      inkPrimary: inkPrimary,
      inkMuted: inkMuted,
      borderSubtle: borderSubtle,
      danger: isDark ? const Color(0xFFF87171) : const Color(0xFFC2410C),
      success: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
      radiusCard: 16.0 * settings.cornerRadiusScale,
      radiusSheet: 24.0 * settings.cornerRadiusScale,
      radiusPill: 999.0,
      spacingXs: 4.0 * spacingScale,
      spacingSm: 8.0 * spacingScale,
      spacingMd: 16.0 * spacingScale,
      spacingLg: 24.0 * spacingScale,
      spacingXl: 32.0 * spacingScale,
      listRowExtent: listRowExtent,
      shadowAlpha: isLite ? 0.0 : (settings.shadowIntensity * 0.28),
      glassSigma: isLite ? 0.0 : (settings.glassBlurIntensity * 20.0),
      motionDuration: motionDuration,
      motionCurve: const Cubic(0.22, 1.0, 0.36, 1.0),
      primaryFontFamily: primaryFont,
      fontFallbacks: fallbacks,
      iconScale: settings.controlIconScale,
    );
  }

  static SystemUiOverlayStyle systemOverlayStyle(WetarTokens tokens) {
    final iconBrightness = tokens.isDark ? Brightness.light : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: iconBrightness,
      statusBarBrightness: tokens.isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: iconBrightness,
      systemNavigationBarContrastEnforced: false,
    );
  }

  static ThemeData buildThemeData(
    AppearanceSettings settings, {
    required Brightness platformBrightness,
    required bool systemDisableAnimations,
    required bool isArabicLocale,
    Color? artworkPrimary,
    Color? artworkSecondary,
    Color? systemAccent,
  }) {
    final tokens = resolveTokens(
      settings,
      platformBrightness: platformBrightness,
      systemDisableAnimations: systemDisableAnimations,
      isArabicLocale: isArabicLocale,
      artworkPrimary: artworkPrimary,
      artworkSecondary: artworkSecondary,
      systemAccent: systemAccent,
    );

    final brightness = tokens.isDark ? Brightness.dark : Brightness.light;
    final onPrimary =
        ThemeData.estimateBrightnessForColor(tokens.accentPrimary) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: tokens.accentPrimary,
      onPrimary: onPrimary,
      secondary: tokens.accentSecondary,
      onSecondary: onPrimary,
      error: tokens.danger,
      onError: Colors.white,
      surface: tokens.surface,
      onSurface: tokens.inkPrimary,
      surfaceContainerHighest: tokens.surfaceElevated,
      outline: tokens.borderSubtle,
    );

    final baseTextTheme =
        (tokens.isDark ? ThemeData.dark() : ThemeData.light()).textTheme;
    final fontWeightOffset = settings.fontWeightStep;
    FontWeight shiftWeight(FontWeight base) {
      final nextVal = (base.value + fontWeightOffset * 100).clamp(100, 900);
      return FontWeight.values[(nextVal ~/ 100) - 1];
    }

    TextStyle? applyFont(TextStyle? style) {
      if (style == null) return null;
      return style.copyWith(
        fontFamily: tokens.primaryFontFamily,
        fontFamilyFallback: tokens.fontFallbacks,
        color: tokens.inkPrimary,
        fontSize: style.fontSize != null
            ? style.fontSize! * settings.fontScale
            : null,
        fontWeight: style.fontWeight != null
            ? shiftWeight(style.fontWeight!)
            : null,
      );
    }

    final textTheme = TextTheme(
      displaySmall: applyFont(baseTextTheme.displaySmall),
      headlineMedium: applyFont(baseTextTheme.headlineMedium),
      headlineSmall: applyFont(baseTextTheme.headlineSmall),
      titleLarge: applyFont(baseTextTheme.titleLarge),
      titleMedium: applyFont(baseTextTheme.titleMedium),
      titleSmall: applyFont(baseTextTheme.titleSmall),
      bodyLarge: applyFont(baseTextTheme.bodyLarge),
      bodyMedium: applyFont(baseTextTheme.bodyMedium),
      bodySmall: applyFont(baseTextTheme.bodySmall)
          ?.copyWith(color: tokens.inkMuted),
      labelLarge: applyFont(baseTextTheme.labelLarge),
      labelMedium: applyFont(baseTextTheme.labelMedium),
      labelSmall: applyFont(baseTextTheme.labelSmall),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.canvas,
      fontFamily: tokens.primaryFontFamily,
      fontFamilyFallback: tokens.fontFallbacks,
      textTheme: textTheme,
      dividerColor: tokens.borderSubtle,
      cardTheme: CardThemeData(
        color: tokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusCard),
          side: BorderSide(color: tokens.borderSubtle),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surfaceElevated,
        constraints: WetarResponsive.sheetConstraints,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.radiusSheet),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.canvas,
        foregroundColor: tokens.inkPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: systemOverlayStyle(tokens),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontSize: 12 * settings.fontScale.clamp(0.85, 1.15),
            color: isSelected ? tokens.accentPrimary : tokens.inkMuted,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          );
        }),
      ),
      extensions: <ThemeExtension<dynamic>>[tokens],
    );
  }
}
