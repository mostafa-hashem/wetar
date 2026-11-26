import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/numeral_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../music_folders/presentation/bloc/music_folders_cubit.dart';
import '../../../music_folders/presentation/screens/music_folders_settings_screen.dart';
import '../../../personalization/domain/appearance_settings.dart';
import '../../../personalization/presentation/bloc/personalization_cubit.dart';
import '../../../personalization/presentation/theme/wetar_tokens.dart';
import '../bloc/settings_cubit.dart';

/// Phase 1 Settings hub providing language toggle, Music Folders entry,
/// library duration filter, and basic theme switching (expanded in Phases 2–4).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final settings = context.watch<SettingsCubit>().state;
    final appearance = context.watch<PersonalizationCubit>().state.settings;
    final foldersCount = context.select(
      (MusicFoldersCubit c) => c.state.selectedFolders.length,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacingMd),
        children: <Widget>[
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
          const Divider(),
          ListTile(
            leading: Icon(Icons.palette_outlined, color: tokens.accentPrimary),
            title: Text(l10n.personalizationThemeMode),
            subtitle: Text(switch (appearance.themeMode) {
              WetarThemeMode.system => l10n.personalizationThemeSystem,
              WetarThemeMode.light => l10n.personalizationThemeLight,
              WetarThemeMode.dark => l10n.personalizationThemeDark,
              WetarThemeMode.amoled => l10n.personalizationThemeAmoled,
            }),
            trailing: DropdownButton<WetarThemeMode>(
              value: appearance.themeMode,
              underline: const SizedBox.shrink(),
              items: <DropdownMenuItem<WetarThemeMode>>[
                DropdownMenuItem(
                  value: WetarThemeMode.system,
                  child: Text(l10n.personalizationThemeSystem),
                ),
                DropdownMenuItem(
                  value: WetarThemeMode.light,
                  child: Text(l10n.personalizationThemeLight),
                ),
                DropdownMenuItem(
                  value: WetarThemeMode.dark,
                  child: Text(l10n.personalizationThemeDark),
                ),
                DropdownMenuItem(
                  value: WetarThemeMode.amoled,
                  child: Text(l10n.personalizationThemeAmoled),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  context.read<PersonalizationCubit>().updateSettings(
                    appearance.copyWith(themeMode: mode),
                  );
                }
              },
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.translate_rounded,
              color: tokens.accentSecondary,
            ),
            title: Text(l10n.settingsLanguage),
            subtitle: Text(
              settings.localeCode == 'ar'
                  ? l10n.languageArabic
                  : l10n.languageEnglish,
            ),
            trailing: SegmentedButton<String>(
              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: 'ar',
                  label: Text(l10n.languageArabic),
                ),
                ButtonSegment<String>(
                  value: 'en',
                  label: Text(l10n.languageEnglish),
                ),
              ],
              selected: <String>{settings.localeCode},
              onSelectionChanged: (set) {
                context.read<SettingsCubit>().setLocaleCode(set.first);
              },
            ),
          ),
          SwitchListTile.adaptive(
            title: Text(l10n.languageNumeralsArabicIndic),
            subtitle: Text(l10n.languageNumerals),
            value: settings.numeralStyle == NumeralStyle.arabicIndic,
            activeTrackColor: tokens.accentPrimary,
            onChanged: (arabicDigits) {
              context.read<SettingsCubit>().update(
                settings.copyWith(
                  numeralStyle: arabicDigits
                      ? NumeralStyle.arabicIndic
                      : NumeralStyle.western,
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.playbackMinDuration(settings.minTrackDurationSec)),
            subtitle: Slider(
              min: 0,
              max: 90,
              divisions: 9,
              value: settings.minTrackDurationSec.toDouble(),
              onChanged: (v) {
                final sec = v.round();
                context.read<SettingsCubit>().update(
                  settings.copyWith(minTrackDurationSec: sec),
                );
              },
            ),
          ),
          SwitchListTile.adaptive(
            title: Text(l10n.playbackFadePlayPause),
            value: settings.fadeOnPlayPause,
            activeTrackColor: tokens.accentPrimary,
            onChanged: (v) {
              final next = settings.copyWith(fadeOnPlayPause: v);
              context.read<SettingsCubit>().update(next);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsAbout),
            subtitle: Text('${l10n.appName} • ${l10n.appTagline}'),
          ),
          if (sl.isRegistered<MusicFoldersCubit>()) const SizedBox(height: 24),
        ],
      ),
    );
  }
}
