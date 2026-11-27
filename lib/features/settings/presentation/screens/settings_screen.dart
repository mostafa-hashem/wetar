import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_brand_logo.dart';
import 'package:wetar/core/widgets/wetar_responsive.dart';
import 'package:wetar/core/widgets/wetar_setting_control_tile.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/music_folders/presentation/screens/music_folders_settings_screen.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/screens/appearance_studio_screen.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/settings/domain/playback_settings.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Searchable Settings Hub organized per section with progressive Advanced disclosure.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.onOpenEqualizer,
    this.onOpenBackupAndStats,
  });

  final VoidCallback? onOpenEqualizer;
  final VoidCallback? onOpenBackupAndStats;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _query = '';
  bool _showAdvanced = false;

  bool _matches(String title, String subtitle) {
    if (_query.trim().isEmpty) return true;
    final q = _query.trim().toLowerCase();
    return title.toLowerCase().contains(q) ||
        subtitle.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final caps = sl.isRegistered<PlatformCapabilities>()
        ? sl<PlatformCapabilities>()
        : PlatformCapabilities.detect();
    final settings = context.watch<SettingsCubit>().state;
    final appearance = context.watch<PersonalizationCubit>().state.settings;
    final foldersCount = context.select(
      (MusicFoldersCubit c) => c.state.selectedFolders.length,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => ListView(
            padding: WetarResponsive.listPadding(
              constraints.maxWidth,
              minHorizontal: tokens.spacingMd,
              top: tokens.spacingMd,
              bottom: tokens.spacingLg,
            ),
            children: <Widget>[
              TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: l10n.settingsSearchHint,
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusCard),
                    borderSide: BorderSide(color: tokens.borderSubtle),
                  ),
                ),
              ),
              SizedBox(height: tokens.spacingMd),
              if (_matches(
                l10n.settingsAppearance,
                l10n.settingsAppearanceSubtitle,
              ))
                ListTile(
                  leading: Icon(
                    Icons.palette_outlined,
                    color: tokens.accentPrimary,
                  ),
                  title: Text(l10n.settingsAppearance),
                  subtitle: Text(l10n.settingsAppearanceSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AppearanceStudioScreen(),
                    ),
                  ),
                ),
              if (_matches(
                l10n.settingsMusicFolders,
                l10n.settingsMusicFoldersSubtitle,
              ))
                ListTile(
                  leading: Icon(
                    Icons.folder_copy_rounded,
                    color: tokens.accentPrimary,
                  ),
                  title: Text(l10n.settingsMusicFolders),
                  subtitle: Text(
                    '${l10n.settingsMusicFoldersSubtitle} ($foldersCount)',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MusicFoldersSettingsScreen(),
                    ),
                  ),
                ),
              if (caps.supportsAnyAudioEffects &&
                  widget.onOpenEqualizer != null &&
                  _matches(l10n.settingsAudio, l10n.settingsAudioSubtitle))
                ListTile(
                  leading: Icon(
                    Icons.equalizer_rounded,
                    color: tokens.accentSecondary,
                  ),
                  title: Text(l10n.settingsAudio),
                  subtitle: Text(l10n.settingsAudioSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: widget.onOpenEqualizer,
                ),
              if (widget.onOpenBackupAndStats != null &&
                  _matches(l10n.settingsBackup, l10n.settingsBackupSubtitle))
                ListTile(
                  leading: Icon(
                    Icons.analytics_outlined,
                    color: tokens.accentPrimary,
                  ),
                  title: Text(l10n.settingsBackup),
                  subtitle: Text(l10n.settingsBackupSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: widget.onOpenBackupAndStats,
                ),
              const Divider(),
              if (_matches(
                l10n.settingsLanguage,
                l10n.settingsLanguageSubtitle,
              )) ...<Widget>[
                WetarStackedControlTile(
                  leading: Icon(
                    Icons.translate_rounded,
                    color: tokens.accentSecondary,
                  ),
                  title: l10n.settingsLanguage,
                  child: WetarOptionChips<String>(
                    selectedValue: settings.localeCode,
                    onSelected: (code) =>
                        context.read<SettingsCubit>().setLocaleCode(code),
                    options: <WetarOptionItem<String>>[
                      WetarOptionItem<String>(
                        value: 'ar',
                        label: l10n.languageArabic,
                      ),
                      WetarOptionItem<String>(
                        value: 'en',
                        label: l10n.languageEnglish,
                      ),
                    ],
                  ),
                ),
                WetarStackedControlTile(
                  leading: Icon(
                    Icons.pin_outlined,
                    color: tokens.accentPrimary,
                  ),
                  title: l10n.languageNumerals,
                  child: WetarOptionChips<NumeralStyle>(
                    selectedValue: settings.numeralStyle,
                    onSelected: (style) => context.read<SettingsCubit>().update(
                      settings.copyWith(numeralStyle: style),
                    ),
                    options: <WetarOptionItem<NumeralStyle>>[
                      WetarOptionItem<NumeralStyle>(
                        value: NumeralStyle.western,
                        label: l10n.languageNumeralsWestern,
                      ),
                      WetarOptionItem<NumeralStyle>(
                        value: NumeralStyle.arabicIndic,
                        label: l10n.languageNumeralsArabicIndic,
                      ),
                    ],
                  ),
                ),
              ],
              if (_matches(
                    l10n.settingsPlayback,
                    l10n.settingsPlaybackSubtitle,
                  ) ||
                  _matches(
                    l10n.playbackSwipeDownDismissPaused,
                    l10n.playbackSwipeDownDismissPausedSubtitle,
                  )) ...<Widget>[
                SwitchListTile.adaptive(
                  title: Text(l10n.playbackFadePlayPause),
                  value: settings.fadeOnPlayPause,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (v) => context.read<SettingsCubit>().update(
                    settings.copyWith(fadeOnPlayPause: v),
                  ),
                ),
                if (caps.supportsSkipSilence)
                  SwitchListTile.adaptive(
                    title: Text(l10n.playbackSkipSilence),
                    value: settings.skipSilence,
                    activeTrackColor: tokens.accentPrimary,
                    onChanged: (v) => context.read<SettingsCubit>().update(
                      settings.copyWith(skipSilence: v),
                    ),
                  ),
                SwitchListTile.adaptive(
                  title: Text(l10n.playbackRememberLongPos),
                  value: settings.rememberLongTrackPosition,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (v) => context.read<SettingsCubit>().update(
                    settings.copyWith(rememberLongTrackPosition: v),
                  ),
                ),
                SwitchListTile.adaptive(
                  title: Text(l10n.playbackAutoPlayBt),
                  value: settings.autoPlayOnHeadsetConnect,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (v) => context.read<SettingsCubit>().update(
                    settings.copyWith(autoPlayOnHeadsetConnect: v),
                  ),
                ),
                SwitchListTile.adaptive(
                  title: Text(l10n.playbackSwipeDownDismissPaused),
                  subtitle: Text(l10n.playbackSwipeDownDismissPausedSubtitle),
                  value: appearance.miniPlayerSwipeDownDismiss,
                  activeTrackColor: tokens.accentPrimary,
                  onChanged: (v) =>
                      context.read<PersonalizationCubit>().updateSettings(
                        appearance.copyWith(miniPlayerSwipeDownDismiss: v),
                      ),
                ),
              ],
              if (_matches(l10n.settingsLibrary, l10n.settingsLibrarySubtitle))
                ListTile(
                  title: Text(
                    l10n.playbackMinDuration(settings.minTrackDurationSec),
                  ),
                  subtitle: Slider(
                    min: 0,
                    max: 90,
                    divisions: 9,
                    value: settings.minTrackDurationSec.toDouble().clamp(
                      0.0,
                      90.0,
                    ),
                    onChanged: (v) => context.read<SettingsCubit>().update(
                      settings.copyWith(minTrackDurationSec: v.round()),
                    ),
                  ),
                ),
              ExpansionTile(
                initiallyExpanded: _showAdvanced || _query.isNotEmpty,
                onExpansionChanged: (v) => setState(() => _showAdvanced = v),
                title: Text(l10n.settingsAdvanced),
                children: <Widget>[
                  WetarDropdownTile<ReplayGainMode>(
                    title: l10n.playbackReplayGainMode,
                    value: settings.replayGainMode,
                    items: <DropdownMenuItem<ReplayGainMode>>[
                      DropdownMenuItem(
                        value: ReplayGainMode.off,
                        child: Text(l10n.playbackReplayGainOff),
                      ),
                      DropdownMenuItem(
                        value: ReplayGainMode.track,
                        child: Text(l10n.playbackReplayGainTrack),
                      ),
                      DropdownMenuItem(
                        value: ReplayGainMode.album,
                        child: Text(l10n.playbackReplayGainAlbum),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        context.read<SettingsCubit>().update(
                          settings.copyWith(replayGainMode: v),
                        );
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      '${l10n.playbackReplayGainPreamp} (${settings.replayGainPreampDb.toStringAsFixed(1)} dB)',
                    ),
                    subtitle: Slider(
                      min: -12,
                      max: 12,
                      divisions: 24,
                      value: settings.replayGainPreampDb.clamp(-12.0, 12.0),
                      onChanged: (v) => context.read<SettingsCubit>().update(
                        settings.copyWith(replayGainPreampDb: v),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(l10n.playbackArtistSeparators),
                    subtitle: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(settings.artistSeparators.join('   ')),
                    ),
                  ),
                  SwitchListTile.adaptive(
                    title: Text(l10n.personalizationMirrorTimelineRtl),
                    value: appearance.mirrorTimelineInRtl,
                    activeTrackColor: tokens.accentPrimary,
                    onChanged: (v) =>
                        context.read<PersonalizationCubit>().updateSettings(
                          appearance.copyWith(mirrorTimelineInRtl: v),
                        ),
                  ),
                ],
              ),
              ListTile(
                leading: const WetarBrandLogo(size: 36),
                title: Text(l10n.settingsAbout),
                subtitle: Text('${l10n.appName} • ${l10n.appTagline}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
