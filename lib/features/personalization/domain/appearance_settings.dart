import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/features/personalization/domain/built_in_wallpapers.dart';

enum WetarThemeMode { system, light, dark, amoled }

enum WetarContrastLevel { standard, medium, high }

enum PlayerLayoutVariant {
  oudStrings,
  classicCard,
  immersiveBleed,
  minimal,
  vinylDisc,
}

enum ArtworkShapeStyle { roundedSquare, squircle, circle }

enum SeekBarStyle { stringWaveform, stylizedBars, thinLine, thickPill }

enum MiniPlayerStyle { floatingPill, dockedBar }

enum BackgroundMode {
  blurredArtwork,
  artworkGradient,
  solidColor,
  animatedGradient,
  proceduralAurora,
  proceduralWaves,
  proceduralGrain,
  proceduralStrings,
  customImage,
}

enum BackgroundScope { playerOnly, homeAndPlayer, wholeApp }

enum ListDensity { compact, comfortable, spacious }

enum MotionIntensity { off, reduced, balanced, expressive }

enum HapticsIntensity { off, light, medium, strong }

enum LiteModePreference { auto, alwaysOn, alwaysOff }

enum GestureAction {
  none,
  playPause,
  nextTrack,
  prevTrack,
  toggleFavorite,
  openQueue,
  openLyrics,
}

enum WetarNavTab { home, library, folders, playlists, settings }

enum HomeBlockKind {
  continueListening,
  quickActions,
  recentlyAdded,
  mostPlayed,
  folders,
  playlists,
}

enum PlayerSecondaryAction {
  favorite,
  queue,
  lyrics,
  sleepTimer,
  speedPitch,
  abLoop,
  equalizer,
  carMode,
  details,
}

/// Built-in and user-saved look bundle serializable to `.wetarlook`.
class WetarLookPreset extends Equatable {
  const WetarLookPreset({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.isBuiltIn,
    required this.settings,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final bool isBuiltIn;
  final AppearanceSettings settings;

  Map<String, dynamic> toExportJson() => <String, dynamic>{
    'format': 'wetar.look',
    'formatVersion': 1,
    'id': id,
    'nameEn': nameEn,
    'nameAr': nameAr,
    'settings': settings.toJson(),
  };

  static WetarLookPreset? tryParseExport(String rawJson) {
    if (rawJson.length > 128 * 1024) return null;
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['format'] != 'wetar.look') return null;
      final settingsMap = decoded['settings'];
      if (settingsMap is! Map<String, dynamic>) return null;
      final parsed = AppearanceSettingsMigration.fromJsonSafe(settingsMap);
      final rawNameEn = (decoded['nameEn'] as String?)?.trim() ?? '';
      final rawNameAr = (decoded['nameAr'] as String?)?.trim() ?? '';
      final cleanEn = rawNameEn.isEmpty
          ? 'Imported Look'
          : rawNameEn.substring(0, rawNameEn.length.clamp(0, 40));
      final cleanAr = rawNameAr.isEmpty
          ? cleanEn
          : rawNameAr.substring(0, rawNameAr.length.clamp(0, 40));
      return WetarLookPreset(
        id: 'imported_${DateTime.now().millisecondsSinceEpoch}',
        nameEn: cleanEn,
        nameAr: cleanAr,
        isBuiltIn: false,
        // Drop device-local paths across devices while preserving bundled wallpapers.
        settings: parsed.copyWith(
          customBackgroundImagePath:
              (parsed.customBackgroundImagePath ?? '').startsWith(
                BuiltInWallpapers.assetPrefix,
              )
              ? parsed.customBackgroundImagePath
              : null,
          importedFontFamily: null,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [id, nameEn, nameAr, isBuiltIn, settings];
}

/// Versioned appearance & personalization configuration persisted locally.
class AppearanceSettings extends Equatable {
  const AppearanceSettings({
    this.schemaVersion = currentSchemaVersion,
    this.themeMode = WetarThemeMode.dark,
    this.scheduledDarkEnabled = false,
    this.scheduledDarkStartHour = 19,
    this.scheduledDarkEndHour = 7,
    this.accentArgb = 0xFFE69B3A,
    this.secondaryAccentArgb = 0xFF38B2AC,
    this.adaptColorsToArtwork = true,
    this.useSystemDynamicColor = false,
    this.contrastLevel = WetarContrastLevel.standard,
    this.surfaceTintIntensity = 0.25,
    this.textEmphasis = 1.0,
    this.arabicFontFamily = 'Cairo',
    this.latinFontFamily = 'PlusJakartaSans',
    this.useSystemFont = false,
    this.importedFontFamily,
    this.fontScale = 1.0,
    this.fontWeightStep = 0,
    this.playerLayout = PlayerLayoutVariant.oudStrings,
    this.artworkShape = ArtworkShapeStyle.roundedSquare,
    this.artworkCornerRadius = 22.0,
    this.seekBarStyle = SeekBarStyle.stringWaveform,
    this.controlIconScale = 1.0,
    this.miniPlayerStyle = MiniPlayerStyle.floatingPill,
    this.miniPlayerShowProgress = true,
    this.miniPlayerSwipeDownDismiss = true,
    this.secondaryActions = const <PlayerSecondaryAction>[
      PlayerSecondaryAction.favorite,
      PlayerSecondaryAction.lyrics,
      PlayerSecondaryAction.queue,
      PlayerSecondaryAction.sleepTimer,
      PlayerSecondaryAction.speedPitch,
      PlayerSecondaryAction.equalizer,
    ],
    this.backgroundMode = BackgroundMode.artworkGradient,
    this.backgroundScope = BackgroundScope.playerOnly,
    this.backgroundBlur = 24.0,
    this.backgroundDim = 0.45,
    this.backgroundSaturation = 1.05,
    this.customBackgroundImagePath,
    this.navTabsOrder = const <WetarNavTab>[
      WetarNavTab.home,
      WetarNavTab.library,
      WetarNavTab.folders,
      WetarNavTab.playlists,
      WetarNavTab.settings,
    ],
    this.hiddenNavTabs = const <WetarNavTab>[],
    this.defaultStartTab = WetarNavTab.home,
    this.homeBlocksOrder = const <HomeBlockKind>[
      HomeBlockKind.continueListening,
      HomeBlockKind.quickActions,
      HomeBlockKind.recentlyAdded,
      HomeBlockKind.mostPlayed,
      HomeBlockKind.folders,
      HomeBlockKind.playlists,
    ],
    this.hiddenHomeBlocks = const <HomeBlockKind>[HomeBlockKind.folders],
    this.listDensity = ListDensity.comfortable,
    this.useGridInLibrary = false,
    this.gridColumns = 2,
    this.showArtworkInLists = true,
    this.cornerRadiusScale = 1.0,
    this.shadowIntensity = 0.65,
    this.glassBlurIntensity = 0.7,
    this.motionIntensity = MotionIntensity.balanced,
    this.hapticsIntensity = HapticsIntensity.light,
    this.liteModePreference = LiteModePreference.auto,
    this.swipeCoverHorizontal = true,
    this.doubleTapCoverAction = GestureAction.playPause,
    this.longPressCoverAction = GestureAction.openQueue,
    this.mirrorTimelineInRtl = false,
  });

  static const int currentSchemaVersion = 2;

  final int schemaVersion;
  final WetarThemeMode themeMode;
  final bool scheduledDarkEnabled;
  final int scheduledDarkStartHour;
  final int scheduledDarkEndHour;
  final int accentArgb;
  final int secondaryAccentArgb;
  final bool adaptColorsToArtwork;
  final bool useSystemDynamicColor;
  final WetarContrastLevel contrastLevel;
  final double surfaceTintIntensity;
  final double textEmphasis;

  final String arabicFontFamily;
  final String latinFontFamily;
  final bool useSystemFont;
  final String? importedFontFamily;
  final double fontScale;
  final int fontWeightStep;

  final PlayerLayoutVariant playerLayout;
  final ArtworkShapeStyle artworkShape;
  final double artworkCornerRadius;
  final SeekBarStyle seekBarStyle;
  final double controlIconScale;
  final MiniPlayerStyle miniPlayerStyle;
  final bool miniPlayerShowProgress;
  final bool miniPlayerSwipeDownDismiss;
  final List<PlayerSecondaryAction> secondaryActions;

  final BackgroundMode backgroundMode;
  final BackgroundScope backgroundScope;
  final double backgroundBlur;
  final double backgroundDim;
  final double backgroundSaturation;
  final String? customBackgroundImagePath;

  final List<WetarNavTab> navTabsOrder;
  final List<WetarNavTab> hiddenNavTabs;
  final WetarNavTab defaultStartTab;
  final List<HomeBlockKind> homeBlocksOrder;
  final List<HomeBlockKind> hiddenHomeBlocks;
  final ListDensity listDensity;
  final bool useGridInLibrary;
  final int gridColumns;
  final bool showArtworkInLists;

  final double cornerRadiusScale;
  final double shadowIntensity;
  final double glassBlurIntensity;
  final MotionIntensity motionIntensity;
  final HapticsIntensity hapticsIntensity;
  final LiteModePreference liteModePreference;

  final bool swipeCoverHorizontal;
  final GestureAction doubleTapCoverAction;
  final GestureAction longPressCoverAction;
  final bool mirrorTimelineInRtl;

  Color get accentColor => Color(accentArgb);
  Color get secondaryAccentColor => Color(secondaryAccentArgb);

  List<WetarNavTab> get visibleNavTabs {
    final visible = navTabsOrder
        .where((t) => !hiddenNavTabs.contains(t))
        .toList();
    if (visible.isEmpty) {
      return const <WetarNavTab>[WetarNavTab.home, WetarNavTab.settings];
    }
    return visible.take(5).toList();
  }

  AppearanceSettings resetColors() {
    const d = AppearanceSettings();
    return copyWith(
      themeMode: d.themeMode,
      scheduledDarkEnabled: d.scheduledDarkEnabled,
      scheduledDarkStartHour: d.scheduledDarkStartHour,
      scheduledDarkEndHour: d.scheduledDarkEndHour,
      accentArgb: d.accentArgb,
      secondaryAccentArgb: d.secondaryAccentArgb,
      adaptColorsToArtwork: d.adaptColorsToArtwork,
      useSystemDynamicColor: d.useSystemDynamicColor,
      contrastLevel: d.contrastLevel,
      surfaceTintIntensity: d.surfaceTintIntensity,
      textEmphasis: d.textEmphasis,
    );
  }

  AppearanceSettings resetTypography() {
    const d = AppearanceSettings();
    return copyWith(
      arabicFontFamily: d.arabicFontFamily,
      latinFontFamily: d.latinFontFamily,
      useSystemFont: d.useSystemFont,
      importedFontFamily: null,
      fontScale: d.fontScale,
      fontWeightStep: d.fontWeightStep,
    );
  }

  AppearanceSettings resetPlayer() {
    const d = AppearanceSettings();
    return copyWith(
      playerLayout: d.playerLayout,
      artworkShape: d.artworkShape,
      artworkCornerRadius: d.artworkCornerRadius,
      seekBarStyle: d.seekBarStyle,
      controlIconScale: d.controlIconScale,
      miniPlayerStyle: d.miniPlayerStyle,
      miniPlayerShowProgress: d.miniPlayerShowProgress,
      miniPlayerSwipeDownDismiss: d.miniPlayerSwipeDownDismiss,
      secondaryActions: d.secondaryActions,
    );
  }

  AppearanceSettings resetBackgrounds() {
    const d = AppearanceSettings();
    return copyWith(
      backgroundMode: d.backgroundMode,
      backgroundScope: d.backgroundScope,
      backgroundBlur: d.backgroundBlur,
      backgroundDim: d.backgroundDim,
      backgroundSaturation: d.backgroundSaturation,
      customBackgroundImagePath: null,
    );
  }

  AppearanceSettings resetLayout() {
    const d = AppearanceSettings();
    return copyWith(
      navTabsOrder: d.navTabsOrder,
      hiddenNavTabs: d.hiddenNavTabs,
      defaultStartTab: d.defaultStartTab,
      homeBlocksOrder: d.homeBlocksOrder,
      hiddenHomeBlocks: d.hiddenHomeBlocks,
      listDensity: d.listDensity,
      useGridInLibrary: d.useGridInLibrary,
      gridColumns: d.gridColumns,
      showArtworkInLists: d.showArtworkInLists,
    );
  }

  AppearanceSettings resetMotionAndGestures() {
    const d = AppearanceSettings();
    return copyWith(
      cornerRadiusScale: d.cornerRadiusScale,
      shadowIntensity: d.shadowIntensity,
      glassBlurIntensity: d.glassBlurIntensity,
      motionIntensity: d.motionIntensity,
      hapticsIntensity: d.hapticsIntensity,
      liteModePreference: d.liteModePreference,
      swipeCoverHorizontal: d.swipeCoverHorizontal,
      doubleTapCoverAction: d.doubleTapCoverAction,
      longPressCoverAction: d.longPressCoverAction,
      mirrorTimelineInRtl: d.mirrorTimelineInRtl,
    );
  }

  AppearanceSettings copyWith({
    WetarThemeMode? themeMode,
    bool? scheduledDarkEnabled,
    int? scheduledDarkStartHour,
    int? scheduledDarkEndHour,
    int? accentArgb,
    int? secondaryAccentArgb,
    bool? adaptColorsToArtwork,
    bool? useSystemDynamicColor,
    WetarContrastLevel? contrastLevel,
    double? surfaceTintIntensity,
    double? textEmphasis,
    String? arabicFontFamily,
    String? latinFontFamily,
    bool? useSystemFont,
    Object? importedFontFamily = _sentinel,
    double? fontScale,
    int? fontWeightStep,
    PlayerLayoutVariant? playerLayout,
    ArtworkShapeStyle? artworkShape,
    double? artworkCornerRadius,
    SeekBarStyle? seekBarStyle,
    double? controlIconScale,
    MiniPlayerStyle? miniPlayerStyle,
    bool? miniPlayerShowProgress,
    bool? miniPlayerSwipeDownDismiss,
    List<PlayerSecondaryAction>? secondaryActions,
    BackgroundMode? backgroundMode,
    BackgroundScope? backgroundScope,
    double? backgroundBlur,
    double? backgroundDim,
    double? backgroundSaturation,
    Object? customBackgroundImagePath = _sentinel,
    List<WetarNavTab>? navTabsOrder,
    List<WetarNavTab>? hiddenNavTabs,
    WetarNavTab? defaultStartTab,
    List<HomeBlockKind>? homeBlocksOrder,
    List<HomeBlockKind>? hiddenHomeBlocks,
    ListDensity? listDensity,
    bool? useGridInLibrary,
    int? gridColumns,
    bool? showArtworkInLists,
    double? cornerRadiusScale,
    double? shadowIntensity,
    double? glassBlurIntensity,
    MotionIntensity? motionIntensity,
    HapticsIntensity? hapticsIntensity,
    LiteModePreference? liteModePreference,
    bool? swipeCoverHorizontal,
    GestureAction? doubleTapCoverAction,
    GestureAction? longPressCoverAction,
    bool? mirrorTimelineInRtl,
  }) {
    return AppearanceSettings(
      schemaVersion: schemaVersion,
      themeMode: themeMode ?? this.themeMode,
      scheduledDarkEnabled: scheduledDarkEnabled ?? this.scheduledDarkEnabled,
      scheduledDarkStartHour:
          scheduledDarkStartHour ?? this.scheduledDarkStartHour,
      scheduledDarkEndHour: scheduledDarkEndHour ?? this.scheduledDarkEndHour,
      accentArgb: accentArgb ?? this.accentArgb,
      secondaryAccentArgb: secondaryAccentArgb ?? this.secondaryAccentArgb,
      adaptColorsToArtwork: adaptColorsToArtwork ?? this.adaptColorsToArtwork,
      useSystemDynamicColor:
          useSystemDynamicColor ?? this.useSystemDynamicColor,
      contrastLevel: contrastLevel ?? this.contrastLevel,
      surfaceTintIntensity: (surfaceTintIntensity ?? this.surfaceTintIntensity)
          .clamp(0.0, 1.0),
      textEmphasis: (textEmphasis ?? this.textEmphasis).clamp(0.75, 1.25),
      arabicFontFamily: arabicFontFamily ?? this.arabicFontFamily,
      latinFontFamily: latinFontFamily ?? this.latinFontFamily,
      useSystemFont: useSystemFont ?? this.useSystemFont,
      importedFontFamily: identical(importedFontFamily, _sentinel)
          ? this.importedFontFamily
          : importedFontFamily as String?,
      fontScale: (fontScale ?? this.fontScale).clamp(0.85, 1.35),
      fontWeightStep: (fontWeightStep ?? this.fontWeightStep).clamp(-1, 2),
      playerLayout: playerLayout ?? this.playerLayout,
      artworkShape: artworkShape ?? this.artworkShape,
      artworkCornerRadius: (artworkCornerRadius ?? this.artworkCornerRadius)
          .clamp(4.0, 40.0),
      seekBarStyle: seekBarStyle ?? this.seekBarStyle,
      controlIconScale: (controlIconScale ?? this.controlIconScale).clamp(
        0.8,
        1.3,
      ),
      miniPlayerStyle: miniPlayerStyle ?? this.miniPlayerStyle,
      miniPlayerShowProgress:
          miniPlayerShowProgress ?? this.miniPlayerShowProgress,
      miniPlayerSwipeDownDismiss:
          miniPlayerSwipeDownDismiss ?? this.miniPlayerSwipeDownDismiss,
      secondaryActions: secondaryActions ?? this.secondaryActions,
      backgroundMode: backgroundMode ?? this.backgroundMode,
      backgroundScope: backgroundScope ?? this.backgroundScope,
      backgroundBlur: (backgroundBlur ?? this.backgroundBlur).clamp(0.0, 48.0),
      backgroundDim: (backgroundDim ?? this.backgroundDim).clamp(0.0, 0.85),
      backgroundSaturation: (backgroundSaturation ?? this.backgroundSaturation)
          .clamp(0.4, 1.6),
      customBackgroundImagePath: identical(customBackgroundImagePath, _sentinel)
          ? this.customBackgroundImagePath
          : customBackgroundImagePath as String?,
      navTabsOrder: navTabsOrder ?? this.navTabsOrder,
      hiddenNavTabs: hiddenNavTabs ?? this.hiddenNavTabs,
      defaultStartTab: defaultStartTab ?? this.defaultStartTab,
      homeBlocksOrder: homeBlocksOrder ?? this.homeBlocksOrder,
      hiddenHomeBlocks: hiddenHomeBlocks ?? this.hiddenHomeBlocks,
      listDensity: listDensity ?? this.listDensity,
      useGridInLibrary: useGridInLibrary ?? this.useGridInLibrary,
      gridColumns: (gridColumns ?? this.gridColumns).clamp(2, 4),
      showArtworkInLists: showArtworkInLists ?? this.showArtworkInLists,
      cornerRadiusScale: (cornerRadiusScale ?? this.cornerRadiusScale).clamp(
        0.25,
        1.6,
      ),
      shadowIntensity: (shadowIntensity ?? this.shadowIntensity).clamp(
        0.0,
        1.0,
      ),
      glassBlurIntensity: (glassBlurIntensity ?? this.glassBlurIntensity).clamp(
        0.0,
        1.0,
      ),
      motionIntensity: motionIntensity ?? this.motionIntensity,
      hapticsIntensity: hapticsIntensity ?? this.hapticsIntensity,
      liteModePreference: liteModePreference ?? this.liteModePreference,
      swipeCoverHorizontal: swipeCoverHorizontal ?? this.swipeCoverHorizontal,
      doubleTapCoverAction: doubleTapCoverAction ?? this.doubleTapCoverAction,
      longPressCoverAction: longPressCoverAction ?? this.longPressCoverAction,
      mirrorTimelineInRtl: mirrorTimelineInRtl ?? this.mirrorTimelineInRtl,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'schemaVersion': schemaVersion,
    'themeMode': themeMode.name,
    'scheduledDarkEnabled': scheduledDarkEnabled,
    'scheduledDarkStartHour': scheduledDarkStartHour,
    'scheduledDarkEndHour': scheduledDarkEndHour,
    'accentArgb': accentArgb,
    'secondaryAccentArgb': secondaryAccentArgb,
    'adaptColorsToArtwork': adaptColorsToArtwork,
    'useSystemDynamicColor': useSystemDynamicColor,
    'contrastLevel': contrastLevel.name,
    'surfaceTintIntensity': surfaceTintIntensity,
    'textEmphasis': textEmphasis,
    'arabicFontFamily': arabicFontFamily,
    'latinFontFamily': latinFontFamily,
    'useSystemFont': useSystemFont,
    'importedFontFamily': importedFontFamily,
    'fontScale': fontScale,
    'fontWeightStep': fontWeightStep,
    'playerLayout': playerLayout.name,
    'artworkShape': artworkShape.name,
    'artworkCornerRadius': artworkCornerRadius,
    'seekBarStyle': seekBarStyle.name,
    'controlIconScale': controlIconScale,
    'miniPlayerStyle': miniPlayerStyle.name,
    'miniPlayerShowProgress': miniPlayerShowProgress,
    'miniPlayerSwipeDownDismiss': miniPlayerSwipeDownDismiss,
    'secondaryActions': secondaryActions.map((e) => e.name).toList(),
    'backgroundMode': backgroundMode.name,
    'backgroundScope': backgroundScope.name,
    'backgroundBlur': backgroundBlur,
    'backgroundDim': backgroundDim,
    'backgroundSaturation': backgroundSaturation,
    'customBackgroundImagePath': customBackgroundImagePath,
    'navTabsOrder': navTabsOrder.map((e) => e.name).toList(),
    'hiddenNavTabs': hiddenNavTabs.map((e) => e.name).toList(),
    'defaultStartTab': defaultStartTab.name,
    'homeBlocksOrder': homeBlocksOrder.map((e) => e.name).toList(),
    'hiddenHomeBlocks': hiddenHomeBlocks.map((e) => e.name).toList(),
    'listDensity': listDensity.name,
    'useGridInLibrary': useGridInLibrary,
    'gridColumns': gridColumns,
    'showArtworkInLists': showArtworkInLists,
    'cornerRadiusScale': cornerRadiusScale,
    'shadowIntensity': shadowIntensity,
    'glassBlurIntensity': glassBlurIntensity,
    'motionIntensity': motionIntensity.name,
    'hapticsIntensity': hapticsIntensity.name,
    'liteModePreference': liteModePreference.name,
    'swipeCoverHorizontal': swipeCoverHorizontal,
    'doubleTapCoverAction': doubleTapCoverAction.name,
    'longPressCoverAction': longPressCoverAction.name,
    'mirrorTimelineInRtl': mirrorTimelineInRtl,
  };

  static const Object _sentinel = Object();

  @override
  List<Object?> get props => [
    schemaVersion,
    themeMode,
    scheduledDarkEnabled,
    scheduledDarkStartHour,
    scheduledDarkEndHour,
    accentArgb,
    secondaryAccentArgb,
    adaptColorsToArtwork,
    useSystemDynamicColor,
    contrastLevel,
    surfaceTintIntensity,
    textEmphasis,
    arabicFontFamily,
    latinFontFamily,
    useSystemFont,
    importedFontFamily,
    fontScale,
    fontWeightStep,
    playerLayout,
    artworkShape,
    artworkCornerRadius,
    seekBarStyle,
    controlIconScale,
    miniPlayerStyle,
    miniPlayerShowProgress,
    miniPlayerSwipeDownDismiss,
    secondaryActions,
    backgroundMode,
    backgroundScope,
    backgroundBlur,
    backgroundDim,
    backgroundSaturation,
    customBackgroundImagePath,
    navTabsOrder,
    hiddenNavTabs,
    defaultStartTab,
    homeBlocksOrder,
    hiddenHomeBlocks,
    listDensity,
    useGridInLibrary,
    gridColumns,
    showArtworkInLists,
    cornerRadiusScale,
    shadowIntensity,
    glassBlurIntensity,
    motionIntensity,
    hapticsIntensity,
    liteModePreference,
    swipeCoverHorizontal,
    doubleTapCoverAction,
    longPressCoverAction,
    mirrorTimelineInRtl,
  ];
}

/// Deterministic version migration runner so app updates preserve user looks safely.
class AppearanceSettingsMigration {
  AppearanceSettingsMigration._();

  static AppearanceSettings fromJsonSafe(Map<String, dynamic> raw) {
    final migrated = migrate(Map<String, dynamic>.from(raw));
    T enumValue<T extends Enum>(List<T> values, String key, T fallback) {
      final rawName = migrated[key];
      if (rawName is! String) return fallback;
      for (final v in values) {
        if (v.name == rawName) return v;
      }
      return fallback;
    }

    List<T> enumList<T extends Enum>(
      List<T> values,
      String key,
      List<T> fallback,
    ) {
      final rawList = migrated[key];
      if (rawList is! List) return fallback;
      final out = <T>[];
      for (final item in rawList.whereType<String>()) {
        for (final v in values) {
          if (v.name == item && !out.contains(v)) {
            out.add(v);
            break;
          }
        }
      }
      return out.isEmpty ? fallback : out;
    }

    const d = AppearanceSettings();
    return AppearanceSettings(
      schemaVersion: AppearanceSettings.currentSchemaVersion,
      themeMode: enumValue(WetarThemeMode.values, 'themeMode', d.themeMode),
      scheduledDarkEnabled:
          migrated['scheduledDarkEnabled'] as bool? ?? d.scheduledDarkEnabled,
      scheduledDarkStartHour:
          ((migrated['scheduledDarkStartHour'] as num?)?.toInt() ??
                  d.scheduledDarkStartHour)
              .clamp(0, 23),
      scheduledDarkEndHour:
          ((migrated['scheduledDarkEndHour'] as num?)?.toInt() ??
                  d.scheduledDarkEndHour)
              .clamp(0, 23),
      accentArgb: (migrated['accentArgb'] as num?)?.toInt() ?? d.accentArgb,
      secondaryAccentArgb:
          (migrated['secondaryAccentArgb'] as num?)?.toInt() ??
          d.secondaryAccentArgb,
      adaptColorsToArtwork:
          migrated['adaptColorsToArtwork'] as bool? ?? d.adaptColorsToArtwork,
      useSystemDynamicColor:
          migrated['useSystemDynamicColor'] as bool? ?? d.useSystemDynamicColor,
      contrastLevel: enumValue(
        WetarContrastLevel.values,
        'contrastLevel',
        d.contrastLevel,
      ),
      surfaceTintIntensity:
          ((migrated['surfaceTintIntensity'] as num?)?.toDouble() ??
                  d.surfaceTintIntensity)
              .clamp(0.0, 1.0),
      textEmphasis:
          ((migrated['textEmphasis'] as num?)?.toDouble() ?? d.textEmphasis)
              .clamp(0.75, 1.25),
      arabicFontFamily:
          migrated['arabicFontFamily'] as String? ?? d.arabicFontFamily,
      latinFontFamily:
          migrated['latinFontFamily'] as String? ?? d.latinFontFamily,
      useSystemFont: migrated['useSystemFont'] as bool? ?? d.useSystemFont,
      importedFontFamily: migrated['importedFontFamily'] as String?,
      fontScale: ((migrated['fontScale'] as num?)?.toDouble() ?? d.fontScale)
          .clamp(0.85, 1.35),
      fontWeightStep:
          ((migrated['fontWeightStep'] as num?)?.toInt() ?? d.fontWeightStep)
              .clamp(-1, 2),
      playerLayout: enumValue(
        PlayerLayoutVariant.values,
        'playerLayout',
        d.playerLayout,
      ),
      artworkShape: enumValue(
        ArtworkShapeStyle.values,
        'artworkShape',
        d.artworkShape,
      ),
      artworkCornerRadius:
          ((migrated['artworkCornerRadius'] as num?)?.toDouble() ??
                  d.artworkCornerRadius)
              .clamp(4.0, 40.0),
      seekBarStyle: enumValue(
        SeekBarStyle.values,
        'seekBarStyle',
        d.seekBarStyle,
      ),
      controlIconScale:
          ((migrated['controlIconScale'] as num?)?.toDouble() ??
                  d.controlIconScale)
              .clamp(0.8, 1.3),
      miniPlayerStyle: enumValue(
        MiniPlayerStyle.values,
        'miniPlayerStyle',
        d.miniPlayerStyle,
      ),
      miniPlayerShowProgress:
          migrated['miniPlayerShowProgress'] as bool? ??
          d.miniPlayerShowProgress,
      miniPlayerSwipeDownDismiss:
          migrated['miniPlayerSwipeDownDismiss'] as bool? ??
          d.miniPlayerSwipeDownDismiss,
      secondaryActions: enumList(
        PlayerSecondaryAction.values,
        'secondaryActions',
        d.secondaryActions,
      ),
      backgroundMode: enumValue(
        BackgroundMode.values,
        'backgroundMode',
        d.backgroundMode,
      ),
      backgroundScope: enumValue(
        BackgroundScope.values,
        'backgroundScope',
        d.backgroundScope,
      ),
      backgroundBlur:
          ((migrated['backgroundBlur'] as num?)?.toDouble() ?? d.backgroundBlur)
              .clamp(0.0, 48.0),
      backgroundDim:
          ((migrated['backgroundDim'] as num?)?.toDouble() ?? d.backgroundDim)
              .clamp(0.0, 0.85),
      backgroundSaturation:
          ((migrated['backgroundSaturation'] as num?)?.toDouble() ??
                  d.backgroundSaturation)
              .clamp(0.4, 1.6),
      customBackgroundImagePath:
          migrated['customBackgroundImagePath'] as String?,
      navTabsOrder: enumList(
        WetarNavTab.values,
        'navTabsOrder',
        d.navTabsOrder,
      ),
      hiddenNavTabs: migrated['hiddenNavTabs'] is List
          ? enumList(WetarNavTab.values, 'hiddenNavTabs', const <WetarNavTab>[])
          : d.hiddenNavTabs,
      defaultStartTab: enumValue(
        WetarNavTab.values,
        'defaultStartTab',
        d.defaultStartTab,
      ),
      homeBlocksOrder: enumList(
        HomeBlockKind.values,
        'homeBlocksOrder',
        d.homeBlocksOrder,
      ),
      hiddenHomeBlocks: migrated['hiddenHomeBlocks'] is List
          ? enumList(
              HomeBlockKind.values,
              'hiddenHomeBlocks',
              const <HomeBlockKind>[],
            )
          : d.hiddenHomeBlocks,
      listDensity: enumValue(ListDensity.values, 'listDensity', d.listDensity),
      useGridInLibrary:
          migrated['useGridInLibrary'] as bool? ?? d.useGridInLibrary,
      gridColumns: ((migrated['gridColumns'] as num?)?.toInt() ?? d.gridColumns)
          .clamp(2, 4),
      showArtworkInLists:
          migrated['showArtworkInLists'] as bool? ?? d.showArtworkInLists,
      cornerRadiusScale:
          ((migrated['cornerRadiusScale'] as num?)?.toDouble() ??
                  d.cornerRadiusScale)
              .clamp(0.25, 1.6),
      shadowIntensity:
          ((migrated['shadowIntensity'] as num?)?.toDouble() ??
                  d.shadowIntensity)
              .clamp(0.0, 1.0),
      glassBlurIntensity:
          ((migrated['glassBlurIntensity'] as num?)?.toDouble() ??
                  d.glassBlurIntensity)
              .clamp(0.0, 1.0),
      motionIntensity: enumValue(
        MotionIntensity.values,
        'motionIntensity',
        d.motionIntensity,
      ),
      hapticsIntensity: enumValue(
        HapticsIntensity.values,
        'hapticsIntensity',
        d.hapticsIntensity,
      ),
      liteModePreference: enumValue(
        LiteModePreference.values,
        'liteModePreference',
        d.liteModePreference,
      ),
      swipeCoverHorizontal:
          migrated['swipeCoverHorizontal'] as bool? ?? d.swipeCoverHorizontal,
      doubleTapCoverAction: enumValue(
        GestureAction.values,
        'doubleTapCoverAction',
        d.doubleTapCoverAction,
      ),
      longPressCoverAction: enumValue(
        GestureAction.values,
        'longPressCoverAction',
        d.longPressCoverAction,
      ),
      mirrorTimelineInRtl:
          migrated['mirrorTimelineInRtl'] as bool? ?? d.mirrorTimelineInRtl,
    );
  }

  static Map<String, dynamic> migrate(Map<String, dynamic> raw) {
    final version = (raw['schemaVersion'] as num?)?.toInt() ?? 0;
    final out = Map<String, dynamic>.from(raw);
    if (version < 1) {
      out['schemaVersion'] = 1;
    }
    if (version < 2) {
      final rawHidden = out['hiddenHomeBlocks'];
      final hidden = rawHidden is List
          ? rawHidden.whereType<String>().toList()
          : <String>[];
      if (!hidden.contains(HomeBlockKind.folders.name)) {
        hidden.add(HomeBlockKind.folders.name);
      }
      out['hiddenHomeBlocks'] = hidden;
      out['miniPlayerSwipeDownDismiss'] ??= true;
      out['schemaVersion'] = 2;
    }
    return out;
  }
}

/// 8 built-in code-only Looks (zero image assets).
class BuiltInLooks {
  BuiltInLooks._();

  static const List<WetarLookPreset> all = <WetarLookPreset>[
    WetarLookPreset(
      id: 'oud_nocturne',
      nameEn: 'Oud Nocturne',
      nameAr: 'ليل العود',
      isBuiltIn: true,
      settings: AppearanceSettings(),
    ),
    WetarLookPreset(
      id: 'warm_parchment',
      nameEn: 'Warm Parchment',
      nameAr: 'رق دافئ',
      isBuiltIn: true,
      settings: AppearanceSettings(
        themeMode: WetarThemeMode.light,
        accentArgb: 0xFFB45309,
        secondaryAccentArgb: 0xFF0F766E,
        backgroundMode: BackgroundMode.proceduralGrain,
        playerLayout: PlayerLayoutVariant.classicCard,
      ),
    ),
    WetarLookPreset(
      id: 'pure_resonance',
      nameEn: 'AMOLED Resonance',
      nameAr: 'رنين أسود',
      isBuiltIn: true,
      settings: AppearanceSettings(
        themeMode: WetarThemeMode.amoled,
        accentArgb: 0xFFF0A94D,
        secondaryAccentArgb: 0xFF4FD1C5,
        backgroundMode: BackgroundMode.proceduralStrings,
        playerLayout: PlayerLayoutVariant.oudStrings,
      ),
    ),
    WetarLookPreset(
      id: 'nile_aurora',
      nameEn: 'Nile Aurora',
      nameAr: 'شفق النيل',
      isBuiltIn: true,
      settings: AppearanceSettings(
        themeMode: WetarThemeMode.dark,
        accentArgb: 0xFF2DD4BF,
        secondaryAccentArgb: 0xFF38BDF8,
        arabicFontFamily: 'Alexandria',
        latinFontFamily: 'Jost',
        backgroundMode: BackgroundMode.proceduralAurora,
        backgroundScope: BackgroundScope.homeAndPlayer,
        playerLayout: PlayerLayoutVariant.immersiveBleed,
      ),
    ),
    WetarLookPreset(
      id: 'velvet_vinyl',
      nameEn: 'Velvet Vinyl',
      nameAr: 'فينيل مخملي',
      isBuiltIn: true,
      settings: AppearanceSettings(
        themeMode: WetarThemeMode.dark,
        accentArgb: 0xFFE11D48,
        secondaryAccentArgb: 0xFFFB7185,
        playerLayout: PlayerLayoutVariant.vinylDisc,
        artworkShape: ArtworkShapeStyle.circle,
        seekBarStyle: SeekBarStyle.stylizedBars,
        backgroundMode: BackgroundMode.blurredArtwork,
      ),
    ),
    WetarLookPreset(
      id: 'cairo_minimal',
      nameEn: 'Cairo Minimal',
      nameAr: 'القاهرة البسيط',
      isBuiltIn: true,
      settings: AppearanceSettings(
        themeMode: WetarThemeMode.light,
        accentArgb: 0xFF1D4ED8,
        secondaryAccentArgb: 0xFF0284C7,
        arabicFontFamily: 'Almarai',
        playerLayout: PlayerLayoutVariant.minimal,
        seekBarStyle: SeekBarStyle.thinLine,
        backgroundMode: BackgroundMode.solidColor,
        cornerRadiusScale: 0.75,
      ),
    ),
    WetarLookPreset(
      id: 'desert_waves',
      nameEn: 'Desert Waves',
      nameAr: 'أمواج الصحراء',
      isBuiltIn: true,
      settings: AppearanceSettings(
        themeMode: WetarThemeMode.dark,
        accentArgb: 0xFFF59E0B,
        secondaryAccentArgb: 0xFFD97706,
        backgroundMode: BackgroundMode.proceduralWaves,
        backgroundScope: BackgroundScope.wholeApp,
        seekBarStyle: SeekBarStyle.thickPill,
      ),
    ),
    WetarLookPreset(
      id: 'silk_emerald',
      nameEn: 'Emerald Silk',
      nameAr: 'حرير زمردي',
      isBuiltIn: true,
      settings: AppearanceSettings(
        themeMode: WetarThemeMode.dark,
        accentArgb: 0xFF10B981,
        secondaryAccentArgb: 0xFF34D399,
        arabicFontFamily: 'Almarai',
        latinFontFamily: 'Jost',
        backgroundMode: BackgroundMode.animatedGradient,
        artworkShape: ArtworkShapeStyle.squircle,
      ),
    ),
  ];

  static const List<int> curatedAccents = <int>[
    0xFFE69B3A,
    0xFFB45309,
    0xFF38B2AC,
    0xFF2DD4BF,
    0xFFE11D48,
    0xFF10B981,
    0xFF6366F1,
    0xFFEC4899,
    0xFF0284C7,
  ];
}
