import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/storage/cache_manager.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/core/widgets/wetar_responsive.dart';
import 'package:wetar/core/widgets/wetar_setting_control_tile.dart';
import 'package:wetar/features/personalization/data/custom_font_loader_service.dart';
import 'package:wetar/features/personalization/data/custom_image_processor.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/domain/built_in_wallpapers.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Complete live-preview Personalization Studio covering Looks, Colors, Fonts,
/// Now Playing & Mini Player, Backgrounds, Layout, Motion/Gestures, and Lite Mode.
class AppearanceStudioScreen extends StatelessWidget {
  const AppearanceStudioScreen({super.key});

  Future<void> _confirmGlobalReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.personalizationResetAllTitle),
        content: Text(l10n.personalizationResetAllBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: tokens.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<PersonalizationCubit>().resetAll();
    }
  }

  Future<void> _showCustomColorDialog(
    BuildContext context,
    AppearanceSettings current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    var hsv = HSVColor.fromColor(current.accentColor);
    final hexController = TextEditingController(
      text: current.accentArgb
          .toRadixString(16)
          .padLeft(8, '0')
          .substring(2)
          .toUpperCase(),
    );

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final color = hsv.toColor();
          return AlertDialog(
            title: Text(l10n.personalizationCustomColor),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(tokens.radiusCard),
                    ),
                  ),
                  Slider(
                    min: 0,
                    max: 360,
                    value: hsv.hue.clamp(0.0, 360.0),
                    onChanged: (v) {
                      setDialogState(() {
                        hsv = hsv.withHue(v);
                        hexController.text = hsv
                            .toColor()
                            .toARGB32()
                            .toRadixString(16)
                            .padLeft(8, '0')
                            .substring(2)
                            .toUpperCase();
                      });
                    },
                  ),
                  Slider(
                    min: 0.15,
                    max: 1.0,
                    value: hsv.saturation.clamp(0.15, 1.0),
                    onChanged: (v) {
                      setDialogState(() {
                        hsv = hsv.withSaturation(v);
                        hexController.text = hsv
                            .toColor()
                            .toARGB32()
                            .toRadixString(16)
                            .padLeft(8, '0')
                            .substring(2)
                            .toUpperCase();
                      });
                    },
                  ),
                  Slider(
                    min: 0.3,
                    max: 1.0,
                    value: hsv.value.clamp(0.3, 1.0),
                    onChanged: (v) {
                      setDialogState(() {
                        hsv = hsv.withValue(v);
                        hexController.text = hsv
                            .toColor()
                            .toARGB32()
                            .toRadixString(16)
                            .padLeft(8, '0')
                            .substring(2)
                            .toUpperCase();
                      });
                    },
                  ),
                  TextField(
                    controller: hexController,
                    maxLength: 6,
                    decoration: const InputDecoration(prefixText: '#'),
                    onChanged: (val) {
                      if (val.length == 6) {
                        final parsed = int.tryParse('FF$val', radix: 16);
                        if (parsed != null) {
                          setDialogState(
                            () => hsv = HSVColor.fromColor(Color(parsed)),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () {
                  context.read<PersonalizationCubit>().updateSettings(
                    current.copyWith(accentArgb: color.toARGB32()),
                  );
                  Navigator.of(ctx).pop();
                },
                child: Text(l10n.actionApply),
              ),
            ],
          );
        },
      ),
    );
    hexController.dispose();
  }

  Future<void> _saveCurrentLookDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.personalizationSaveLook),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.playlistsNameHint),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (saved != null && saved.isNotEmpty && context.mounted) {
      await context.read<PersonalizationCubit>().saveCurrentAsLook(
        nameEn: saved,
        nameAr: saved,
      );
    }
  }

  Future<void> _exportLook(
    BuildContext context,
    AppearanceSettings settings,
  ) async {
    final preset = WetarLookPreset(
      id: 'export_${DateTime.now().millisecondsSinceEpoch}',
      nameEn: 'Wetar Look',
      nameAr: 'مظهر وتر',
      isBuiltIn: false,
      settings: settings,
    );
    final jsonText = jsonEncode(preset.toExportJson());
    final cache = sl<CacheManager>();
    await cache.init();
    final filePath = p.join(
      cache.exportsDir.path,
      'wetar_look_${DateTime.now().millisecondsSinceEpoch}.wetarlook',
    );
    await File(filePath).writeAsString(jsonText, flush: true);
    await sl<FolderPickerService>().shareFiles(
      paths: <String>[filePath],
      mimeType: 'application/json',
      subject: 'Wetar Look (.wetarlook)',
    );
  }

  Future<void> _importLook(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final picked = await sl<FolderPickerService>().pickFile(
      mimeTypes: const <String>['application/json', 'text/plain', '*/*'],
    );
    if (picked == null || !context.mounted) return;
    final raw = await File(picked).readAsString();
    final parsed = WetarLookPreset.tryParseExport(raw);
    if (!context.mounted) return;
    if (parsed == null) {
      WetarFeedback.showError(context, l10n.personalizationLookInvalid);
      return;
    }
    await context.read<PersonalizationCubit>().importLook(parsed);
    if (context.mounted) {
      WetarFeedback.showSuccess(context, parsed.nameEn);
    }
  }

  String _homeBlockLabel(AppLocalizations l10n, HomeBlockKind kind) {
    return switch (kind) {
      HomeBlockKind.continueListening => l10n.homeContinueListening,
      HomeBlockKind.quickActions => l10n.homeQuickActions,
      HomeBlockKind.recentlyAdded => l10n.homeRecentlyAdded,
      HomeBlockKind.mostPlayed => l10n.homeMostPlayed,
      HomeBlockKind.folders => l10n.homeYourFolders,
      HomeBlockKind.playlists => l10n.homeYourPlaylists,
    };
  }

  String _seekBarStyleLabel(AppLocalizations l10n, SeekBarStyle style) {
    return switch (style) {
      SeekBarStyle.stringWaveform => l10n.personalizationSeekStringWaveform,
      SeekBarStyle.stylizedBars => l10n.personalizationSeekStylizedBars,
      SeekBarStyle.thinLine => l10n.personalizationSeekThinLine,
      SeekBarStyle.thickPill => l10n.personalizationSeekThickPill,
    };
  }

  String _artworkShapeLabel(AppLocalizations l10n, ArtworkShapeStyle shape) {
    return switch (shape) {
      ArtworkShapeStyle.roundedSquare => l10n.personalizationArtRoundedSquare,
      ArtworkShapeStyle.squircle => l10n.personalizationArtSquircle,
      ArtworkShapeStyle.circle => l10n.personalizationArtCircle,
    };
  }

  String _listDensityLabel(AppLocalizations l10n, ListDensity density) {
    return switch (density) {
      ListDensity.compact => l10n.personalizationDensityCompact,
      ListDensity.comfortable => l10n.personalizationDensityComfortable,
      ListDensity.spacious => l10n.personalizationDensitySpacious,
    };
  }

  String _motionIntensityLabel(
    AppLocalizations l10n,
    MotionIntensity intensity,
  ) {
    return switch (intensity) {
      MotionIntensity.off => l10n.personalizationMotionOff,
      MotionIntensity.reduced => l10n.personalizationMotionReduced,
      MotionIntensity.balanced => l10n.personalizationMotionBalanced,
      MotionIntensity.expressive => l10n.personalizationMotionExpressive,
    };
  }

  String _hapticsIntensityLabel(
    AppLocalizations l10n,
    HapticsIntensity intensity,
  ) {
    return switch (intensity) {
      HapticsIntensity.off => l10n.personalizationHapticsOff,
      HapticsIntensity.light => l10n.personalizationHapticsLight,
      HapticsIntensity.medium => l10n.personalizationHapticsMedium,
      HapticsIntensity.strong => l10n.personalizationHapticsStrong,
    };
  }

  Widget _buildStudioTab({required IconData icon, required String label}) {
    return Tab(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 17),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final caps = sl.isRegistered<PlatformCapabilities>()
        ? sl<PlatformCapabilities>()
        : PlatformCapabilities.detect();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return DefaultTabController(
      length: 7,
      child: BlocBuilder<PersonalizationCubit, PersonalizationState>(
        builder: (context, pState) {
          final s = pState.settings;
          final cubit = context.read<PersonalizationCubit>();

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.settingsAppearance),
              actions: <Widget>[
                IconButton(
                  tooltip: l10n.actionResetAll,
                  icon: const Icon(Icons.restart_alt_rounded),
                  onPressed: () => _confirmGlobalReset(context),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(54),
                child: LayoutBuilder(
                  builder: (context, constraints) => Padding(
                    padding: EdgeInsets.only(
                      bottom: tokens.spacingXs,
                      left: WetarResponsive.horizontalInset(
                        constraints.maxWidth,
                        tokens.spacingSm,
                      ),
                      right: WetarResponsive.horizontalInset(
                        constraints.maxWidth,
                        tokens.spacingSm,
                      ),
                    ),
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      dividerColor: Colors.transparent,
                      splashBorderRadius: BorderRadius.circular(
                        tokens.radiusPill,
                      ),
                      labelColor: tokens.accentPrimary,
                      unselectedLabelColor: tokens.inkMuted,
                      labelStyle: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                      unselectedLabelStyle: Theme.of(context)
                          .textTheme
                          .labelLarge,
                      labelPadding: EdgeInsets.symmetric(
                        horizontal: tokens.spacingXs,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 2,
                      ),
                      indicator: BoxDecoration(
                        color: tokens.accentPrimary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                        border: Border.all(
                          color: tokens.accentPrimary.withValues(alpha: 0.55),
                        ),
                      ),
                      tabs: <Widget>[
                        _buildStudioTab(
                          icon: Icons.auto_awesome_outlined,
                          label: l10n.personalizationLooks,
                        ),
                        _buildStudioTab(
                          icon: Icons.palette_outlined,
                          label: l10n.personalizationColors,
                        ),
                        _buildStudioTab(
                          icon: Icons.text_fields_rounded,
                          label: l10n.personalizationFonts,
                        ),
                        _buildStudioTab(
                          icon: Icons.play_circle_outline_rounded,
                          label: l10n.personalizationPlayer,
                        ),
                        _buildStudioTab(
                          icon: Icons.wallpaper_outlined,
                          label: l10n.personalizationBackgrounds,
                        ),
                        _buildStudioTab(
                          icon: Icons.dashboard_customize_outlined,
                          label: l10n.personalizationLayout,
                        ),
                        _buildStudioTab(
                          icon: Icons.animation_rounded,
                          label: l10n.personalizationMotion,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabPadding = WetarResponsive.listPadding(
                    constraints.maxWidth,
                    minHorizontal: tokens.spacingMd,
                    top: tokens.spacingMd,
                    bottom: tokens.spacingLg,
                  );
                  final compactBtnStyle = OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacingMd,
                      vertical: tokens.spacingSm + 2,
                    ),
                  );
                  return TabBarView(
                    children: <Widget>[
                      // 1. Looks
                      ListView(
                        padding: tabPadding,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(tokens.spacingSm + 2),
                            decoration: BoxDecoration(
                              color: tokens.surfaceElevated.withValues(
                                alpha: 0.55,
                              ),
                              borderRadius: BorderRadius.circular(
                                tokens.radiusCard,
                              ),
                              border: Border.all(color: tokens.borderSubtle),
                            ),
                            child: Wrap(
                              spacing: tokens.spacingSm,
                              runSpacing: tokens.spacingSm,
                              children: <Widget>[
                                FilledButton.tonalIcon(
                                  style: FilledButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: tokens.spacingMd,
                                      vertical: tokens.spacingSm + 2,
                                    ),
                                  ),
                                  onPressed: () =>
                                      _saveCurrentLookDialog(context),
                                  icon: const Icon(
                                    Icons.bookmark_add_outlined,
                                    size: 18,
                                  ),
                                  label: Text(l10n.personalizationSaveLook),
                                ),
                                OutlinedButton.icon(
                                  style: compactBtnStyle,
                                  onPressed: () => _exportLook(context, s),
                                  icon: const Icon(
                                    Icons.ios_share_rounded,
                                    size: 18,
                                  ),
                                  label: Text(l10n.personalizationExportLook),
                                ),
                                OutlinedButton.icon(
                                  style: compactBtnStyle,
                                  onPressed: () => _importLook(context),
                                  icon: const Icon(
                                    Icons.file_open_outlined,
                                    size: 18,
                                  ),
                                  label: Text(l10n.personalizationImportLook),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: tokens.spacingMd),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                BuiltInLooks.all.length +
                                pState.savedLooks.length,
                            gridDelegate: WetarResponsive.presetGridDelegate(
                              maxTileExtent: 215,
                              aspectRatio: 1.55,
                            ),
                            itemBuilder: (context, idx) {
                              final all = <WetarLookPreset>[
                                ...pState.savedLooks,
                                ...BuiltInLooks.all,
                              ];
                              final look = all[idx];
                              final selected =
                                  s.accentArgb == look.settings.accentArgb;
                              final cardColor = tokens.isDark
                                  ? tokens.surfaceElevated
                                  : tokens.surface;
                              return InkWell(
                                borderRadius: BorderRadius.circular(
                                  tokens.radiusCard,
                                ),
                                onTap: () => cubit.applyLook(look),
                                onLongPress: look.isBuiltIn
                                    ? null
                                    : () => cubit.deleteSavedLook(look.id),
                                child: Container(
                                  padding: EdgeInsets.all(tokens.spacingMd),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(
                                      tokens.radiusCard,
                                    ),
                                    border: Border.all(
                                      color: look.settings.accentColor,
                                      width: selected ? 2.2 : 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          CircleAvatar(
                                            radius: 10,
                                            backgroundColor:
                                                look.settings.accentColor,
                                          ),
                                          if (selected)
                                            Icon(
                                              Icons.check_circle,
                                              size: 18,
                                              color: look.settings.accentColor,
                                            ),
                                        ],
                                      ),
                                      Text(
                                        isArabic ? look.nameAr : look.nameEn,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: tokens.inkPrimary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // 2. Colors
                      ListView(
                        padding: tabPadding,
                        children: <Widget>[
                          WetarStackedControlTile(
                            title: l10n.personalizationThemeMode,
                            child: WetarOptionChips<WetarThemeMode>(
                              selectedValue: s.themeMode,
                              onSelected: (mode) => cubit.updateSettings(
                                s.copyWith(themeMode: mode),
                              ),
                              options: <WetarOptionItem<WetarThemeMode>>[
                                WetarOptionItem(
                                  value: WetarThemeMode.system,
                                  label: l10n.personalizationThemeSystem,
                                ),
                                WetarOptionItem(
                                  value: WetarThemeMode.light,
                                  label: l10n.personalizationThemeLight,
                                ),
                                WetarOptionItem(
                                  value: WetarThemeMode.dark,
                                  label: l10n.personalizationThemeDark,
                                ),
                                WetarOptionItem(
                                  value: WetarThemeMode.amoled,
                                  label: l10n.personalizationThemeAmoled,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: tokens.spacingMd),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: <Widget>[
                              for (final argb in BuiltInLooks.curatedAccents)
                                InkWell(
                                  onTap: () => cubit.updateSettings(
                                    s.copyWith(accentArgb: argb),
                                  ),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Color(argb),
                                    child: s.accentArgb == argb
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                              ActionChip(
                                avatar: const Icon(Icons.colorize_rounded),
                                label: Text(l10n.personalizationCustomColor),
                                onPressed: () =>
                                    _showCustomColorDialog(context, s),
                              ),
                            ],
                          ),
                          SizedBox(height: tokens.spacingMd),
                          SwitchListTile.adaptive(
                            title: Text(l10n.personalizationScheduledDark),
                            value: s.scheduledDarkEnabled,
                            activeTrackColor: tokens.accentPrimary,
                            onChanged: (v) => cubit.updateSettings(
                              s.copyWith(scheduledDarkEnabled: v),
                            ),
                          ),
                          SwitchListTile.adaptive(
                            title: Text(l10n.personalizationAdaptArtwork),
                            value: s.adaptColorsToArtwork,
                            activeTrackColor: tokens.accentPrimary,
                            onChanged: (v) => cubit.updateSettings(
                              s.copyWith(adaptColorsToArtwork: v),
                            ),
                          ),
                          if (caps.supportsSystemDynamicColor)
                            SwitchListTile.adaptive(
                              title: Text(
                                l10n.personalizationSystemDynamicColor,
                              ),
                              value: s.useSystemDynamicColor,
                              activeTrackColor: tokens.accentPrimary,
                              onChanged: (v) => cubit.updateSettings(
                                s.copyWith(useSystemDynamicColor: v),
                              ),
                            ),
                          WetarDropdownTile<WetarContrastLevel>(
                            title: l10n.personalizationContrast,
                            value: s.contrastLevel,
                            items: <DropdownMenuItem<WetarContrastLevel>>[
                              DropdownMenuItem(
                                value: WetarContrastLevel.standard,
                                child: Text(
                                  l10n.personalizationContrastStandard,
                                ),
                              ),
                              DropdownMenuItem(
                                value: WetarContrastLevel.medium,
                                child: Text(l10n.personalizationContrastMedium),
                              ),
                              DropdownMenuItem(
                                value: WetarContrastLevel.high,
                                child: Text(l10n.personalizationContrastHigh),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                cubit.updateSettings(
                                  s.copyWith(contrastLevel: v),
                                );
                              }
                            },
                          ),
                          ListTile(
                            title: Text(l10n.personalizationSurfaceTint),
                            subtitle: Slider(
                              value: s.surfaceTintIntensity.clamp(0.0, 1.0),
                              onChanged: (v) => cubit.updateSettings(
                                s.copyWith(surfaceTintIntensity: v),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(l10n.personalizationTextEmphasis),
                            subtitle: Slider(
                              min: 0.75,
                              max: 1.25,
                              value: s.textEmphasis.clamp(0.75, 1.25),
                              onChanged: (v) => cubit.updateSettings(
                                s.copyWith(textEmphasis: v),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () =>
                                  cubit.updateSettings(s.resetColors()),
                              child: Text(l10n.personalizationResetSection),
                            ),
                          ),
                        ],
                      ),

                      // 3. Fonts
                      ListView(
                        padding: tabPadding,
                        children: <Widget>[
                          SwitchListTile.adaptive(
                            title: Text(l10n.personalizationFontSystem),
                            value: s.useSystemFont,
                            activeTrackColor: tokens.accentPrimary,
                            onChanged: (v) => cubit.updateSettings(
                              s.copyWith(useSystemFont: v),
                            ),
                          ),
                          WetarDropdownTile<String>(
                            title: l10n.personalizationFontArabic,
                            value: s.arabicFontFamily,
                            items: const <DropdownMenuItem<String>>[
                              DropdownMenuItem(
                                value: 'Cairo',
                                child: Text(
                                  'Cairo / القاهرة',
                                  style: TextStyle(fontFamily: 'Cairo'),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Almarai',
                                child: Text(
                                  'Almarai / المراعي',
                                  style: TextStyle(fontFamily: 'Almarai'),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Alexandria',
                                child: Text(
                                  'Alexandria / الإسكندرية',
                                  style: TextStyle(fontFamily: 'Alexandria'),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                cubit.updateSettings(
                                  s.copyWith(
                                    arabicFontFamily: v,
                                    importedFontFamily: null,
                                    useSystemFont: false,
                                  ),
                                );
                              }
                            },
                          ),
                          WetarDropdownTile<String>(
                            title: l10n.personalizationFontLatin,
                            value: s.latinFontFamily,
                            items: const <DropdownMenuItem<String>>[
                              DropdownMenuItem(
                                value: 'PlusJakartaSans',
                                child: Text(
                                  'Plus Jakarta Sans',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Jost',
                                child: Text(
                                  'Jost',
                                  style: TextStyle(fontFamily: 'Jost'),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                cubit.updateSettings(
                                  s.copyWith(
                                    latinFontFamily: v,
                                    importedFontFamily: null,
                                    useSystemFont: false,
                                  ),
                                );
                              }
                            },
                          ),
                          ListTile(
                            title: Text(l10n.personalizationFontScale),
                            subtitle: Slider(
                              min: 0.85,
                              max: 1.35,
                              divisions: 10,
                              value: s.fontScale.clamp(0.85, 1.35),
                              onChanged: (v) => cubit.updateSettings(
                                s.copyWith(fontScale: v),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(l10n.personalizationFontWeight),
                            subtitle: Slider(
                              min: -1,
                              max: 2,
                              divisions: 3,
                              value: s.fontWeightStep.toDouble().clamp(
                                -1.0,
                                2.0,
                              ),
                              onChanged: (v) => cubit.updateSettings(
                                s.copyWith(fontWeightStep: v.round()),
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await sl<FolderPickerService>()
                                  .pickFile(
                                    mimeTypes: const <String>[
                                      'font/ttf',
                                      'font/otf',
                                      'application/x-font-ttf',
                                      'application/octet-stream',
                                      '*/*',
                                    ],
                                  );
                              if (picked == null || !context.mounted) return;
                              final family = await sl<CustomFontLoaderService>()
                                  .importAndRegisterFont(picked);
                              if (!context.mounted) return;
                              if (family == null) {
                                WetarFeedback.showError(
                                  context,
                                  l10n.personalizationFontInvalid,
                                );
                                return;
                              }
                              await cubit.updateSettings(
                                s.copyWith(
                                  importedFontFamily: family,
                                  useSystemFont: false,
                                ),
                              );
                              if (context.mounted) {
                                WetarFeedback.showSuccess(
                                  context,
                                  l10n.personalizationFontImported(
                                    p.basename(picked),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.font_download_outlined),
                            label: Text(l10n.personalizationImportFont),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () =>
                                  cubit.updateSettings(s.resetTypography()),
                              child: Text(l10n.personalizationResetSection),
                            ),
                          ),
                        ],
                      ),

                      // 4. Player & Mini Player
                      ListView(
                        padding: tabPadding,
                        children: <Widget>[
                          WetarDropdownTile<PlayerLayoutVariant>(
                            title: l10n.personalizationPlayerLayout,
                            value: s.playerLayout,
                            items: <DropdownMenuItem<PlayerLayoutVariant>>[
                              DropdownMenuItem(
                                value: PlayerLayoutVariant.oudStrings,
                                child: Text(
                                  l10n.personalizationLayoutOudStrings,
                                ),
                              ),
                              DropdownMenuItem(
                                value: PlayerLayoutVariant.classicCard,
                                child: Text(l10n.personalizationLayoutClassic),
                              ),
                              DropdownMenuItem(
                                value: PlayerLayoutVariant.immersiveBleed,
                                child: Text(
                                  l10n.personalizationLayoutImmersive,
                                ),
                              ),
                              DropdownMenuItem(
                                value: PlayerLayoutVariant.minimal,
                                child: Text(l10n.personalizationLayoutMinimal),
                              ),
                              DropdownMenuItem(
                                value: PlayerLayoutVariant.vinylDisc,
                                child: Text(l10n.personalizationLayoutVinyl),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                cubit.updateSettings(
                                  s.copyWith(playerLayout: v),
                                );
                              }
                            },
                          ),
                          WetarDropdownTile<SeekBarStyle>(
                            title: l10n.personalizationSeekBarStyle,
                            value: s.seekBarStyle,
                            items: SeekBarStyle.values
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(_seekBarStyleLabel(l10n, e)),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                cubit.updateSettings(
                                  s.copyWith(seekBarStyle: v),
                                );
                              }
                            },
                          ),
                          WetarDropdownTile<ArtworkShapeStyle>(
                            title: l10n.personalizationArtShape,
                            value: s.artworkShape,
                            items: ArtworkShapeStyle.values
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(_artworkShapeLabel(l10n, e)),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                cubit.updateSettings(
                                  s.copyWith(artworkShape: v),
                                );
                              }
                            },
                          ),
                          ListTile(
                            title: Text(l10n.personalizationCornerRadius),
                            subtitle: Slider(
                              min: 4,
                              max: 40,
                              value: s.artworkCornerRadius.clamp(4.0, 40.0),
                              onChanged: (v) => cubit.updateSettings(
                                s.copyWith(artworkCornerRadius: v),
                              ),
                            ),
                          ),
                          WetarStackedControlTile(
                            title: l10n.personalizationMiniPlayerStyle,
                            child: WetarOptionChips<MiniPlayerStyle>(
                              selectedValue: s.miniPlayerStyle,
                              onSelected: (style) => cubit.updateSettings(
                                s.copyWith(miniPlayerStyle: style),
                              ),
                              options: <WetarOptionItem<MiniPlayerStyle>>[
                                WetarOptionItem(
                                  value: MiniPlayerStyle.floatingPill,
                                  label: l10n.personalizationMiniPlayerFloating,
                                ),
                                WetarOptionItem(
                                  value: MiniPlayerStyle.dockedBar,
                                  label: l10n.personalizationMiniPlayerDocked,
                                ),
                              ],
                            ),
                          ),
                          SwitchListTile.adaptive(
                            title: Text(
                              l10n.personalizationMiniPlayerShowProgress,
                            ),
                            value: s.miniPlayerShowProgress,
                            activeTrackColor: tokens.accentPrimary,
                            onChanged: (v) => cubit.updateSettings(
                              s.copyWith(miniPlayerShowProgress: v),
                            ),
                          ),
                          SwitchListTile.adaptive(
                            title: Text(l10n.playbackSwipeDownDismissPaused),
                            subtitle: Text(
                              l10n.playbackSwipeDownDismissPausedSubtitle,
                            ),
                            value: s.miniPlayerSwipeDownDismiss,
                            activeTrackColor: tokens.accentPrimary,
                            onChanged: (v) => cubit.updateSettings(
                              s.copyWith(miniPlayerSwipeDownDismiss: v),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () =>
                                  cubit.updateSettings(s.resetPlayer()),
                              child: Text(l10n.personalizationResetSection),
                            ),
                          ),
                        ],
                      ),

                      // 5. Backgrounds
                      ListView(
                        padding: tabPadding,
                        children: <Widget>[
                          WetarDropdownTile<BackgroundMode>(
                            title: l10n.personalizationBackgroundMode,
                            value: s.backgroundMode,
                            items: <DropdownMenuItem<BackgroundMode>>[
                              DropdownMenuItem(
                                value: BackgroundMode.blurredArtwork,
                                child: Text(l10n.personalizationBgBlurredArt),
                              ),
                              DropdownMenuItem(
                                value: BackgroundMode.artworkGradient,
                                child: Text(l10n.personalizationBgArtGradient),
                              ),
                              DropdownMenuItem(
                                value: BackgroundMode.solidColor,
                                child: Text(l10n.personalizationBgSolid),
                              ),
                              DropdownMenuItem(
                                value: BackgroundMode.animatedGradient,
                                child: Text(
                                  l10n.personalizationBgAnimatedGradient,
                                ),
                              ),
                              DropdownMenuItem(
                                value: BackgroundMode.proceduralAurora,
                                child: Text(
                                  l10n.personalizationBgProceduralAurora,
                                ),
                              ),
                              DropdownMenuItem(
                                value: BackgroundMode.proceduralWaves,
                                child: Text(
                                  l10n.personalizationBgProceduralWaves,
                                ),
                              ),
                              DropdownMenuItem(
                                value: BackgroundMode.proceduralGrain,
                                child: Text(
                                  l10n.personalizationBgProceduralGrain,
                                ),
                              ),
                              DropdownMenuItem(
                                value: BackgroundMode.proceduralStrings,
                                child: Text(
                                  l10n.personalizationBgProceduralStrings,
                                ),
                              ),
                              DropdownMenuItem(
                                value: BackgroundMode.customImage,
                                child: Text(l10n.personalizationBgCustomImage),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                cubit.updateSettings(
                                  s.copyWith(backgroundMode: v),
                                );
                              }
                            },
                          ),
                          if (s.backgroundMode == BackgroundMode.customImage &&
                              s.customBackgroundImagePath != null &&
                              !s.customBackgroundImagePath!.startsWith(
                                BuiltInWallpapers.assetPrefix,
                              ) &&
                              File(s.customBackgroundImagePath!).existsSync())
                            Container(
                              margin: EdgeInsets.only(bottom: tokens.spacingMd),
                              padding: EdgeInsets.all(tokens.spacingSm),
                              decoration: BoxDecoration(
                                color: tokens.surface,
                                borderRadius: BorderRadius.circular(
                                  tokens.radiusCard,
                                ),
                                border: Border.all(color: tokens.accentPrimary),
                              ),
                              child: Row(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      tokens.radiusCard * 0.65,
                                    ),
                                    child: Image.file(
                                      File(s.customBackgroundImagePath!),
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                      cacheWidth: 160,
                                    ),
                                  ),
                                  SizedBox(width: tokens.spacingMd),
                                  Expanded(
                                    child: Text(
                                      l10n.personalizationBgCustomImage,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => cubit.updateSettings(
                                      s.copyWith(
                                        backgroundMode:
                                            BackgroundMode.artworkGradient,
                                        customBackgroundImagePath: null,
                                      ),
                                    ),
                                    child: Text(
                                      l10n.personalizationRemoveWallpaper,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          WetarStackedControlTile(
                            title: l10n.personalizationBgScope,
                            child: WetarOptionChips<BackgroundScope>(
                              selectedValue: s.backgroundScope,
                              onSelected: (scope) => cubit.updateSettings(
                                s.copyWith(backgroundScope: scope),
                              ),
                              options: <WetarOptionItem<BackgroundScope>>[
                                WetarOptionItem(
                                  value: BackgroundScope.playerOnly,
                                  label: l10n.personalizationBgScopePlayer,
                                ),
                                WetarOptionItem(
                                  value: BackgroundScope.homeAndPlayer,
                                  label: l10n.personalizationBgScopeHomePlayer,
                                ),
                                WetarOptionItem(
                                  value: BackgroundScope.wholeApp,
                                  label: l10n.personalizationBgScopeWholeApp,
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: EdgeInsets.only(
                              top: tokens.spacingSm,
                              bottom: tokens.spacingSm,
                            ),
                            child: Text(
                              l10n.personalizationWallpapersTitle,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(color: tokens.accentPrimary),
                            ),
                          ),
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: () async {
                              final picked = await sl<FolderPickerService>()
                                  .pickGalleryImage();
                              if (picked == null || !context.mounted) return;
                              final stored = await sl<CustomImageProcessor>()
                                  .processAndStoreBackground(picked);
                              if (stored != null && context.mounted) {
                                final wasImage =
                                    s.backgroundMode ==
                                    BackgroundMode.customImage;
                                await cubit.updateSettings(
                                  s.copyWith(
                                    customBackgroundImagePath: stored,
                                    backgroundMode: BackgroundMode.customImage,
                                    backgroundBlur: wasImage
                                        ? s.backgroundBlur
                                        : 0.0,
                                    backgroundDim: wasImage
                                        ? s.backgroundDim
                                        : 0.35,
                                    backgroundScope:
                                        s.backgroundScope ==
                                            BackgroundScope.playerOnly
                                        ? BackgroundScope.homeAndPlayer
                                        : s.backgroundScope,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(
                              l10n.personalizationPickGalleryWallpaper,
                            ),
                          ),
                          SizedBox(height: tokens.spacingMd),
                          Text(
                            l10n.personalizationNatureWallpapers,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          SizedBox(height: tokens.spacingSm),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: BuiltInWallpapers.all.length,
                            gridDelegate: WetarResponsive.presetGridDelegate(
                              maxTileExtent: 215,
                              aspectRatio: 1.45,
                              spacing: 10,
                            ),
                            itemBuilder: (context, idx) {
                              final wallpaper = BuiltInWallpapers.all[idx];
                              final active =
                                  s.backgroundMode ==
                                      BackgroundMode.customImage &&
                                  s.customBackgroundImagePath ==
                                      wallpaper.sourceRef;
                              return InkWell(
                                borderRadius: BorderRadius.circular(
                                  tokens.radiusCard,
                                ),
                                onTap: () {
                                  final wasImage =
                                      s.backgroundMode ==
                                      BackgroundMode.customImage;
                                  cubit.updateSettings(
                                    s.copyWith(
                                      backgroundMode:
                                          BackgroundMode.customImage,
                                      customBackgroundImagePath:
                                          wallpaper.sourceRef,
                                      backgroundBlur: wasImage
                                          ? s.backgroundBlur
                                          : 0.0,
                                      backgroundDim: wasImage
                                          ? s.backgroundDim
                                          : 0.35,
                                      backgroundScope:
                                          s.backgroundScope ==
                                              BackgroundScope.playerOnly
                                          ? BackgroundScope.homeAndPlayer
                                          : s.backgroundScope,
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      tokens.radiusCard,
                                    ),
                                    border: Border.all(
                                      color: active
                                          ? tokens.accentPrimary
                                          : tokens.borderSubtle,
                                      width: active ? 2.2 : 1.0,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      Image.asset(
                                        wallpaper.assetPath,
                                        fit: BoxFit.cover,
                                        cacheWidth: 360,
                                      ),
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: <Color>[
                                              Colors.transparent,
                                              Colors.black.withValues(
                                                alpha: 0.72,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (active)
                                        PositionedDirectional(
                                          top: 6,
                                          end: 6,
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor:
                                                tokens.accentPrimary,
                                            child: const Icon(
                                              Icons.check_rounded,
                                              size: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        left: 8,
                                        right: 8,
                                        bottom: 6,
                                        child: Text(
                                          isArabic
                                              ? wallpaper.nameAr
                                              : wallpaper.nameEn,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: tokens.spacingMd),
                          ListTile(
                            title: Text(l10n.personalizationBgBlur),
                            subtitle: Slider(
                              min: 0,
                              max: 48,
                              value: s.backgroundBlur.clamp(0.0, 48.0),
                              onChanged: (v) => cubit.updateSettings(
                                s.copyWith(backgroundBlur: v),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(l10n.personalizationBgDim),
                            subtitle: Slider(
                              min: 0,
                              max: 0.85,
                              value: s.backgroundDim.clamp(0.0, 0.85),
                              onChanged: (v) => cubit.updateSettings(
                                s.copyWith(backgroundDim: v),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(l10n.personalizationBgSaturation),
                            subtitle: Slider(
                              min: 0.4,
                              max: 1.6,
                              value: s.backgroundSaturation.clamp(0.4, 1.6),
                              onChanged: (v) => cubit.updateSettings(
                                s.copyWith(backgroundSaturation: v),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () =>
                                  cubit.updateSettings(s.resetBackgrounds()),
                              child: Text(l10n.personalizationResetSection),
                            ),
                          ),
                        ],
                      ),

                      // 6. Home & Library Layout
                      ListView(
                        padding: tabPadding,
                        children: <Widget>[
                          WetarStackedControlTile(
                            title: l10n.personalizationListDensity,
                            child: WetarOptionChips<ListDensity>(
                              selectedValue: s.listDensity,
                              onSelected: (d) => cubit.updateSettings(
                                s.copyWith(listDensity: d),
                              ),
                              options: ListDensity.values
                                  .map(
                                    (d) => WetarOptionItem<ListDensity>(
                                      value: d,
                                      label: _listDensityLabel(l10n, d),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          WetarStackedControlTile(
                            title: l10n.personalizationGridColumns,
                            child: WetarOptionChips<int>(
                              selectedValue: s.gridColumns.clamp(2, 4),
                              onSelected: (cols) => cubit.updateSettings(
                                s.copyWith(gridColumns: cols),
                              ),
                              options: const <WetarOptionItem<int>>[
                                WetarOptionItem<int>(value: 2, label: '2'),
                                WetarOptionItem<int>(value: 3, label: '3'),
                                WetarOptionItem<int>(value: 4, label: '4'),
                              ],
                            ),
                          ),
                          SwitchListTile.adaptive(
                            title: Text(l10n.personalizationShowArtInLists),
                            value: s.showArtworkInLists,
                            activeTrackColor: tokens.accentPrimary,
                            onChanged: (v) => cubit.updateSettings(
                              s.copyWith(showArtworkInLists: v),
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: tokens.spacingSm,
                            ),
                            child: Text(
                              l10n.homeCustomizeBlocks,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          ReorderableListView(
                            shrinkWrap: true,
                            buildDefaultDragHandles: false,
                            physics: const NeverScrollableScrollPhysics(),
                            onReorderItem: (oldIndex, newIndex) {
                              final list = List<HomeBlockKind>.from(
                                s.homeBlocksOrder,
                              );
                              if (oldIndex < 0 || oldIndex >= list.length) {
                                return;
                              }
                              final moved = list.removeAt(oldIndex);
                              final safeNew = newIndex.clamp(0, list.length);
                              list.insert(safeNew, moved);
                              cubit.updateSettings(
                                s.copyWith(homeBlocksOrder: list),
                              );
                            },
                            children: <Widget>[
                              for (var i = 0; i < s.homeBlocksOrder.length; i++)
                                Material(
                                  key: ValueKey<HomeBlockKind>(
                                    s.homeBlocksOrder[i],
                                  ),
                                  color: Colors.transparent,
                                  child: CheckboxListTile(
                                    value: !s.hiddenHomeBlocks.contains(
                                      s.homeBlocksOrder[i],
                                    ),
                                    title: Text(
                                      _homeBlockLabel(
                                        l10n,
                                        s.homeBlocksOrder[i],
                                      ),
                                    ),
                                    secondary: ReorderableDragStartListener(
                                      index: i,
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(Icons.drag_handle_rounded),
                                      ),
                                    ),
                                    onChanged: (show) {
                                      final block = s.homeBlocksOrder[i];
                                      final next = Set<HomeBlockKind>.from(
                                        s.hiddenHomeBlocks,
                                      );
                                      if (show == true) {
                                        next.remove(block);
                                      } else {
                                        next.add(block);
                                      }
                                      cubit.updateSettings(
                                        s.copyWith(
                                          hiddenHomeBlocks: next.toList(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () =>
                                  cubit.updateSettings(s.resetLayout()),
                              child: Text(l10n.personalizationResetSection),
                            ),
                          ),
                        ],
                      ),

                      // 7. Motion, Gestures & Lite Mode
                      ListView(
                        padding: tabPadding,
                        children: <Widget>[
                          WetarDropdownTile<LiteModePreference>(
                            title: l10n.personalizationLiteMode,
                            value: s.liteModePreference,
                            items: <DropdownMenuItem<LiteModePreference>>[
                              DropdownMenuItem(
                                value: LiteModePreference.auto,
                                child: Text(l10n.personalizationLiteModeAuto),
                              ),
                              DropdownMenuItem(
                                value: LiteModePreference.alwaysOn,
                                child: Text(l10n.personalizationLiteModeOn),
                              ),
                              DropdownMenuItem(
                                value: LiteModePreference.alwaysOff,
                                child: Text(l10n.personalizationLiteModeOff),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                cubit.updateSettings(
                                  s.copyWith(liteModePreference: v),
                                );
                              }
                            },
                          ),
                          WetarDropdownTile<MotionIntensity>(
                            title: l10n.personalizationMotionIntensity,
                            value: s.motionIntensity,
                            items: MotionIntensity.values
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(_motionIntensityLabel(l10n, m)),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                cubit.updateSettings(
                                  s.copyWith(motionIntensity: v),
                                );
                              }
                            },
                          ),
                          WetarDropdownTile<HapticsIntensity>(
                            title: l10n.personalizationHapticsIntensity,
                            value: s.hapticsIntensity,
                            items: HapticsIntensity.values
                                .map(
                                  (h) => DropdownMenuItem(
                                    value: h,
                                    child: Text(
                                      _hapticsIntensityLabel(l10n, h),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                cubit.updateSettings(
                                  s.copyWith(hapticsIntensity: v),
                                );
                              }
                            },
                          ),
                          ListTile(
                            title: Text(l10n.personalizationShadowIntensity),
                            subtitle: Slider(
                              value: s.shadowIntensity.clamp(0.0, 1.0),
                              onChanged: (v) => cubit.updateSettings(
                                s.copyWith(shadowIntensity: v),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(l10n.personalizationBlurIntensity),
                            subtitle: Slider(
                              value: s.glassBlurIntensity.clamp(0.0, 1.0),
                              onChanged: (v) => cubit.updateSettings(
                                s.copyWith(glassBlurIntensity: v),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(l10n.personalizationCornerRadius),
                            subtitle: Slider(
                              min: 0.25,
                              max: 1.6,
                              value: s.cornerRadiusScale.clamp(0.25, 1.6),
                              onChanged: (v) => cubit.updateSettings(
                                s.copyWith(cornerRadiusScale: v),
                              ),
                            ),
                          ),
                          SwitchListTile.adaptive(
                            title: Text(
                              l10n.personalizationSwipeCoverHorizontal,
                            ),
                            value: s.swipeCoverHorizontal,
                            activeTrackColor: tokens.accentPrimary,
                            onChanged: (v) => cubit.updateSettings(
                              s.copyWith(swipeCoverHorizontal: v),
                            ),
                          ),
                          SwitchListTile.adaptive(
                            title: Text(l10n.personalizationMirrorTimelineRtl),
                            value: s.mirrorTimelineInRtl,
                            activeTrackColor: tokens.accentPrimary,
                            onChanged: (v) => cubit.updateSettings(
                              s.copyWith(mirrorTimelineInRtl: v),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () => cubit.updateSettings(
                                s.resetMotionAndGestures(),
                              ),
                              child: Text(l10n.personalizationResetSection),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
