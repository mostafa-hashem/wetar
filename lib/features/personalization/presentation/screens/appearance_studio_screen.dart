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
import 'package:wetar/features/personalization/data/custom_font_loader_service.dart';
import 'package:wetar/features/personalization/data/custom_image_processor.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
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
                    value: hsv.hue,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final caps = sl<PlatformCapabilities>();
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
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: tokens.accentPrimary,
                tabs: <Widget>[
                  Tab(text: l10n.personalizationLooks),
                  Tab(text: l10n.personalizationColors),
                  Tab(text: l10n.personalizationFonts),
                  Tab(text: l10n.personalizationPlayer),
                  Tab(text: l10n.personalizationBackgrounds),
                  Tab(text: l10n.personalizationLayout),
                  Tab(text: l10n.personalizationMotion),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                // 1. Looks
                ListView(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  children: <Widget>[
                    Wrap(
                      spacing: tokens.spacingSm,
                      runSpacing: tokens.spacingSm,
                      children: <Widget>[
                        FilledButton.tonalIcon(
                          onPressed: () => _saveCurrentLookDialog(context),
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: Text(l10n.personalizationSaveLook),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _exportLook(context, s),
                          icon: const Icon(Icons.ios_share_rounded),
                          label: Text(l10n.personalizationExportLook),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _importLook(context),
                          icon: const Icon(Icons.file_open_outlined),
                          label: Text(l10n.personalizationImportLook),
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.spacingMd),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          BuiltInLooks.all.length + pState.savedLooks.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.55,
                          ),
                      itemBuilder: (context, idx) {
                        final all = <WetarLookPreset>[
                          ...pState.savedLooks,
                          ...BuiltInLooks.all,
                        ];
                        final look = all[idx];
                        final dark =
                            look.settings.themeMode != WetarThemeMode.light;
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
                              color: dark
                                  ? const Color(0xFF1A1512)
                                  : const Color(0xFFF6EFE4),
                              borderRadius: BorderRadius.circular(
                                tokens.radiusCard,
                              ),
                              border: Border.all(
                                color: look.settings.accentColor,
                                width: 1.4,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: look.settings.accentColor,
                                ),
                                Text(
                                  isArabic ? look.nameAr : look.nameEn,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: dark
                                            ? Colors.white
                                            : Colors.black87,
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
                  padding: EdgeInsets.all(tokens.spacingMd),
                  children: <Widget>[
                    Text(
                      l10n.personalizationThemeMode,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: tokens.spacingSm),
                    SegmentedButton<WetarThemeMode>(
                      segments: <ButtonSegment<WetarThemeMode>>[
                        ButtonSegment(
                          value: WetarThemeMode.system,
                          label: Text(l10n.personalizationThemeSystem),
                        ),
                        ButtonSegment(
                          value: WetarThemeMode.light,
                          label: Text(l10n.personalizationThemeLight),
                        ),
                        ButtonSegment(
                          value: WetarThemeMode.dark,
                          label: Text(l10n.personalizationThemeDark),
                        ),
                        ButtonSegment(
                          value: WetarThemeMode.amoled,
                          label: Text(l10n.personalizationThemeAmoled),
                        ),
                      ],
                      selected: <WetarThemeMode>{s.themeMode},
                      onSelectionChanged: (set) => cubit.updateSettings(
                        s.copyWith(themeMode: set.first),
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
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ActionChip(
                          avatar: const Icon(Icons.colorize_rounded),
                          label: Text(l10n.personalizationCustomColor),
                          onPressed: () => _showCustomColorDialog(context, s),
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
                        title: Text(l10n.personalizationSystemDynamicColor),
                        value: s.useSystemDynamicColor,
                        activeTrackColor: tokens.accentPrimary,
                        onChanged: (v) => cubit.updateSettings(
                          s.copyWith(useSystemDynamicColor: v),
                        ),
                      ),
                    ListTile(
                      title: Text(l10n.personalizationContrast),
                      trailing: DropdownButton<WetarContrastLevel>(
                        value: s.contrastLevel,
                        underline: const SizedBox.shrink(),
                        items: <DropdownMenuItem<WetarContrastLevel>>[
                          DropdownMenuItem(
                            value: WetarContrastLevel.standard,
                            child: Text(l10n.personalizationContrastStandard),
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
                            cubit.updateSettings(s.copyWith(contrastLevel: v));
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.personalizationSurfaceTint),
                      subtitle: Slider(
                        value: s.surfaceTintIntensity,
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
                        value: s.textEmphasis,
                        onChanged: (v) =>
                            cubit.updateSettings(s.copyWith(textEmphasis: v)),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => cubit.updateSettings(s.resetColors()),
                        child: Text(l10n.personalizationResetSection),
                      ),
                    ),
                  ],
                ),

                // 3. Fonts
                ListView(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  children: <Widget>[
                    SwitchListTile.adaptive(
                      title: Text(l10n.personalizationFontSystem),
                      value: s.useSystemFont,
                      activeTrackColor: tokens.accentPrimary,
                      onChanged: (v) =>
                          cubit.updateSettings(s.copyWith(useSystemFont: v)),
                    ),
                    ListTile(
                      title: Text(l10n.personalizationFontArabic),
                      trailing: DropdownButton<String>(
                        value: s.arabicFontFamily,
                        underline: const SizedBox.shrink(),
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
                    ),
                    ListTile(
                      title: Text(l10n.personalizationFontLatin),
                      trailing: DropdownButton<String>(
                        value: s.latinFontFamily,
                        underline: const SizedBox.shrink(),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem(
                            value: 'PlusJakartaSans',
                            child: Text(
                              'Plus Jakarta Sans',
                              style: TextStyle(fontFamily: 'PlusJakartaSans'),
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
                    ),
                    ListTile(
                      title: Text(l10n.personalizationFontScale),
                      subtitle: Slider(
                        min: 0.85,
                        max: 1.35,
                        divisions: 10,
                        value: s.fontScale,
                        onChanged: (v) =>
                            cubit.updateSettings(s.copyWith(fontScale: v)),
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.personalizationFontWeight),
                      subtitle: Slider(
                        min: -1,
                        max: 2,
                        divisions: 3,
                        value: s.fontWeightStep.toDouble(),
                        onChanged: (v) => cubit.updateSettings(
                          s.copyWith(fontWeightStep: v.round()),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await sl<FolderPickerService>().pickFile(
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
                  padding: EdgeInsets.all(tokens.spacingMd),
                  children: <Widget>[
                    ListTile(
                      title: Text(l10n.personalizationPlayerLayout),
                      trailing: DropdownButton<PlayerLayoutVariant>(
                        value: s.playerLayout,
                        underline: const SizedBox.shrink(),
                        items: <DropdownMenuItem<PlayerLayoutVariant>>[
                          DropdownMenuItem(
                            value: PlayerLayoutVariant.oudStrings,
                            child: Text(l10n.personalizationLayoutOudStrings),
                          ),
                          DropdownMenuItem(
                            value: PlayerLayoutVariant.classicCard,
                            child: Text(l10n.personalizationLayoutClassic),
                          ),
                          DropdownMenuItem(
                            value: PlayerLayoutVariant.immersiveBleed,
                            child: Text(l10n.personalizationLayoutImmersive),
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
                            cubit.updateSettings(s.copyWith(playerLayout: v));
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.personalizationSeekBarStyle),
                      trailing: DropdownButton<SeekBarStyle>(
                        value: s.seekBarStyle,
                        underline: const SizedBox.shrink(),
                        items: SeekBarStyle.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            cubit.updateSettings(s.copyWith(seekBarStyle: v));
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.personalizationArtShape),
                      trailing: DropdownButton<ArtworkShapeStyle>(
                        value: s.artworkShape,
                        underline: const SizedBox.shrink(),
                        items: ArtworkShapeStyle.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            cubit.updateSettings(s.copyWith(artworkShape: v));
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.personalizationCornerRadius),
                      subtitle: Slider(
                        min: 4,
                        max: 40,
                        value: s.artworkCornerRadius,
                        onChanged: (v) => cubit.updateSettings(
                          s.copyWith(artworkCornerRadius: v),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.personalizationMiniPlayerStyle),
                      trailing: SegmentedButton<MiniPlayerStyle>(
                        segments: <ButtonSegment<MiniPlayerStyle>>[
                          ButtonSegment(
                            value: MiniPlayerStyle.floatingPill,
                            label: Text(l10n.personalizationMiniPlayerFloating),
                          ),
                          ButtonSegment(
                            value: MiniPlayerStyle.dockedBar,
                            label: Text(l10n.personalizationMiniPlayerDocked),
                          ),
                        ],
                        selected: <MiniPlayerStyle>{s.miniPlayerStyle},
                        onSelectionChanged: (set) => cubit.updateSettings(
                          s.copyWith(miniPlayerStyle: set.first),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => cubit.updateSettings(s.resetPlayer()),
                        child: Text(l10n.personalizationResetSection),
                      ),
                    ),
                  ],
                ),

                // 5. Backgrounds
                ListView(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  children: <Widget>[
                    ListTile(
                      title: Text(l10n.personalizationBackgroundMode),
                      trailing: DropdownButton<BackgroundMode>(
                        value: s.backgroundMode,
                        underline: const SizedBox.shrink(),
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
                            child: Text(l10n.personalizationBgAnimatedGradient),
                          ),
                          DropdownMenuItem(
                            value: BackgroundMode.proceduralAurora,
                            child: Text(l10n.personalizationBgProceduralAurora),
                          ),
                          DropdownMenuItem(
                            value: BackgroundMode.proceduralWaves,
                            child: Text(l10n.personalizationBgProceduralWaves),
                          ),
                          DropdownMenuItem(
                            value: BackgroundMode.proceduralGrain,
                            child: Text(l10n.personalizationBgProceduralGrain),
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
                            cubit.updateSettings(s.copyWith(backgroundMode: v));
                          }
                        },
                      ),
                    ),
                    if (s.backgroundMode == BackgroundMode.customImage)
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await sl<FolderPickerService>()
                              .pickFile(mimeTypes: const <String>['image/*']);
                          if (picked == null) return;
                          final stored = await sl<CustomImageProcessor>()
                              .processAndStoreBackground(picked);
                          if (stored != null) {
                            await cubit.updateSettings(
                              s.copyWith(
                                customBackgroundImagePath: stored,
                                backgroundMode: BackgroundMode.customImage,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.image_outlined),
                        label: Text(l10n.personalizationBgCustomImage),
                      ),
                    ListTile(
                      title: Text(l10n.personalizationBgScope),
                      trailing: DropdownButton<BackgroundScope>(
                        value: s.backgroundScope,
                        underline: const SizedBox.shrink(),
                        items: <DropdownMenuItem<BackgroundScope>>[
                          DropdownMenuItem(
                            value: BackgroundScope.playerOnly,
                            child: Text(l10n.personalizationBgScopePlayer),
                          ),
                          DropdownMenuItem(
                            value: BackgroundScope.homeAndPlayer,
                            child: Text(l10n.personalizationBgScopeHomePlayer),
                          ),
                          DropdownMenuItem(
                            value: BackgroundScope.wholeApp,
                            child: Text(l10n.personalizationBgScopeWholeApp),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            cubit.updateSettings(
                              s.copyWith(backgroundScope: v),
                            );
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.personalizationBgBlur),
                      subtitle: Slider(
                        min: 0,
                        max: 48,
                        value: s.backgroundBlur,
                        onChanged: (v) =>
                            cubit.updateSettings(s.copyWith(backgroundBlur: v)),
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.personalizationBgDim),
                      subtitle: Slider(
                        min: 0,
                        max: 0.85,
                        value: s.backgroundDim,
                        onChanged: (v) =>
                            cubit.updateSettings(s.copyWith(backgroundDim: v)),
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.personalizationBgSaturation),
                      subtitle: Slider(
                        min: 0.4,
                        max: 1.6,
                        value: s.backgroundSaturation,
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
                  padding: EdgeInsets.all(tokens.spacingMd),
                  children: <Widget>[
                    ListTile(
                      title: Text(l10n.personalizationListDensity),
                      trailing: SegmentedButton<ListDensity>(
                        segments: ListDensity.values
                            .map(
                              (d) =>
                                  ButtonSegment(value: d, label: Text(d.name)),
                            )
                            .toList(),
                        selected: <ListDensity>{s.listDensity},
                        onSelectionChanged: (set) => cubit.updateSettings(
                          s.copyWith(listDensity: set.first),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.personalizationGridColumns),
                      trailing: SegmentedButton<int>(
                        segments: const <ButtonSegment<int>>[
                          ButtonSegment(value: 2, label: Text('2')),
                          ButtonSegment(value: 3, label: Text('3')),
                          ButtonSegment(value: 4, label: Text('4')),
                        ],
                        selected: <int>{s.gridColumns},
                        onSelectionChanged: (set) => cubit.updateSettings(
                          s.copyWith(gridColumns: set.first),
                        ),
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
                      padding: EdgeInsets.symmetric(vertical: tokens.spacingSm),
                      child: Text(
                        l10n.homeCustomizeBlocks,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onReorderItem: (oldIndex, newIndex) {
                        final list = List<HomeBlockKind>.from(
                          s.homeBlocksOrder,
                        );
                        final moved = list.removeAt(oldIndex);
                        list.insert(newIndex, moved);
                        cubit.updateSettings(s.copyWith(homeBlocksOrder: list));
                      },
                      children: s.homeBlocksOrder.map((block) {
                        final hidden = s.hiddenHomeBlocks.contains(block);
                        return CheckboxListTile(
                          key: ValueKey<HomeBlockKind>(block),
                          value: !hidden,
                          title: Text(block.name),
                          secondary: const Icon(Icons.drag_handle_rounded),
                          onChanged: (show) {
                            final next = Set<HomeBlockKind>.from(
                              s.hiddenHomeBlocks,
                            );
                            if (show == true) {
                              next.remove(block);
                            } else {
                              next.add(block);
                            }
                            cubit.updateSettings(
                              s.copyWith(hiddenHomeBlocks: next.toList()),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => cubit.updateSettings(s.resetLayout()),
                        child: Text(l10n.personalizationResetSection),
                      ),
                    ),
                  ],
                ),

                // 7. Motion, Gestures & Lite Mode
                ListView(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  children: <Widget>[
                    ListTile(
                      title: Text(l10n.personalizationLiteMode),
                      trailing: DropdownButton<LiteModePreference>(
                        value: s.liteModePreference,
                        underline: const SizedBox.shrink(),
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
                    ),
                    ListTile(
                      title: Text(l10n.personalizationMotionIntensity),
                      trailing: DropdownButton<MotionIntensity>(
                        value: s.motionIntensity,
                        underline: const SizedBox.shrink(),
                        items: MotionIntensity.values
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(m.name),
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
                    ),
                    ListTile(
                      title: Text(l10n.personalizationHapticsIntensity),
                      trailing: DropdownButton<HapticsIntensity>(
                        value: s.hapticsIntensity,
                        underline: const SizedBox.shrink(),
                        items: HapticsIntensity.values
                            .map(
                              (h) => DropdownMenuItem(
                                value: h,
                                child: Text(h.name),
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
                    ),
                    ListTile(
                      title: Text(l10n.personalizationShadowIntensity),
                      subtitle: Slider(
                        value: s.shadowIntensity,
                        onChanged: (v) => cubit.updateSettings(
                          s.copyWith(shadowIntensity: v),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.personalizationBlurIntensity),
                      subtitle: Slider(
                        value: s.glassBlurIntensity,
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
                        value: s.cornerRadiusScale,
                        onChanged: (v) => cubit.updateSettings(
                          s.copyWith(cornerRadiusScale: v),
                        ),
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
                        onPressed: () =>
                            cubit.updateSettings(s.resetMotionAndGestures()),
                        child: Text(l10n.personalizationResetSection),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
