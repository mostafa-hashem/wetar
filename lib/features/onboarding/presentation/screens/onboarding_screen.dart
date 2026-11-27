import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/widgets/wetar_brand_logo.dart';
import 'package:wetar/core/widgets/wetar_responsive.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/music_folders/presentation/screens/folder_picker_screen.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// 3-step skippable onboarding featuring live Arabic/English language selection,
/// Light/Dark theme selection, strictly scoped music folder setup, and starting Look presets.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onFinished,
    this.capabilities,
  });

  final VoidCallback onFinished;
  final PlatformCapabilities? capabilities;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int index) async {
    setState(() => _page = index);
    await _pageController.animateToPage(
      index,
      duration: context.wetarTokens.motionDuration,
      curve: context.wetarTokens.motionCurve,
    );
  }

  Future<void> _setThemeMode(WetarThemeMode mode) async {
    final cubit = context.read<PersonalizationCubit>();
    await cubit.updateSettings(
      cubit.state.settings.copyWith(
        themeMode: mode,
        scheduledDarkEnabled: false,
      ),
    );
  }

  Future<void> _finish() async {
    await context.read<SettingsCubit>().completeOnboarding();
    if (mounted) {
      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final caps =
        widget.capabilities ??
        (sl.isRegistered<PlatformCapabilities>()
            ? sl<PlatformCapabilities>()
            : PlatformCapabilities.detect());

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sidePad = WetarResponsive.horizontalInset(
              constraints.maxWidth,
              tokens.spacingMd,
              maxWidth: WetarResponsive.defaultWizardMaxWidth,
            );
            return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sidePad,
                    vertical: tokens.spacingSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: List<Widget>.generate(3, (i) {
                          final active = i == _page;
                          return AnimatedContainer(
                            duration: tokens.motionDuration,
                            margin: EdgeInsetsDirectional.only(
                              end: tokens.spacingSm,
                            ),
                            width: active ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? tokens.accentPrimary
                                  : tokens.borderSubtle,
                              borderRadius: BorderRadius.circular(
                                tokens.radiusPill,
                              ),
                            ),
                          );
                        }),
                      ),
                      TextButton(
                        onPressed: _finish,
                        child: Text(l10n.actionSkip),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _page = i),
                    children: <Widget>[
                      _WelcomeLanguageAndThemeStep(
                        onThemeSelected: _setThemeMode,
                        onContinue: () => _goToPage(1),
                      ),
                      _PermissionAndFoldersStep(
                        capabilities: caps,
                        onContinue: () => _goToPage(2),
                      ),
                      _LookOnboardingStep(
                        onThemeSelected: _setThemeMode,
                        onFinish: _finish,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeLanguageAndThemeStep extends StatelessWidget {
  const _WelcomeLanguageAndThemeStep({
    required this.onThemeSelected,
    required this.onContinue,
  });

  final ValueChanged<WetarThemeMode> onThemeSelected;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final textTheme = Theme.of(context).textTheme;
    final localeCode = context.select((SettingsCubit c) => c.state.localeCode);
    final appearance = context.select(
      (PersonalizationCubit c) => c.state.settings,
    );
    final isDark = WetarTokenResolver.resolveDarkMode(
      appearance,
      MediaQuery.platformBrightnessOf(context),
    );

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: WetarResponsive.listPadding(
          constraints.maxWidth,
          minHorizontal: tokens.spacingLg,
          top: tokens.spacingLg,
          bottom: tokens.spacingLg,
          maxWidth: WetarResponsive.defaultWizardMaxWidth,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: tokens.spacingSm),
            const Center(child: WetarBrandLogo(size: 86)),
            SizedBox(height: tokens.spacingMd),
            Text(
              l10n.onboardingWelcomeTitle,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: tokens.spacingXs),
            Text(
              l10n.onboardingWelcomeSubtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: tokens.inkMuted),
            ),
            SizedBox(height: tokens.spacingMd),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacingMd,
                  vertical: tokens.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: tokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                  border: Border.all(color: tokens.borderSubtle),
                ),
                child: Text(
                  l10n.onboardingOfflinePill,
                  style: textTheme.labelMedium?.copyWith(
                    color: tokens.accentSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(height: tokens.spacingLg),
            Text(
              l10n.onboardingLanguageLabel,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            Row(
              children: <Widget>[
                Expanded(
                  child: _ChoiceOptionCard(
                    icon: Icons.translate_rounded,
                    label: l10n.languageArabic,
                    selected: localeCode == 'ar',
                    onTap: () =>
                        context.read<SettingsCubit>().setLocaleCode('ar'),
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: _ChoiceOptionCard(
                    icon: Icons.language_rounded,
                    label: l10n.languageEnglish,
                    selected: localeCode == 'en',
                    onTap: () =>
                        context.read<SettingsCubit>().setLocaleCode('en'),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingMd),
            Text(
              l10n.onboardingThemeLabel,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            Row(
              children: <Widget>[
                Expanded(
                  child: _ChoiceOptionCard(
                    icon: Icons.light_mode_rounded,
                    label: l10n.personalizationThemeLight,
                    selected: !isDark,
                    onTap: () => onThemeSelected(WetarThemeMode.light),
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: _ChoiceOptionCard(
                    icon: Icons.dark_mode_rounded,
                    label: l10n.personalizationThemeDark,
                    selected: isDark,
                    onTap: () => onThemeSelected(WetarThemeMode.dark),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingLg),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: tokens.accentPrimary,
              ),
              onPressed: onContinue,
              child: Text(l10n.actionContinue),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceOptionCard extends StatelessWidget {
  const _ChoiceOptionCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wetarTokens;
    return Material(
      color: selected
          ? tokens.accentPrimary.withValues(alpha: 0.14)
          : tokens.surface,
      borderRadius: BorderRadius.circular(tokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusCard),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacingMd,
            vertical: tokens.spacingMd * 0.85,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radiusCard),
            border: Border.all(
              color: selected ? tokens.accentPrimary : tokens.borderSubtle,
              width: selected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 20,
                color: selected ? tokens.accentPrimary : tokens.inkMuted,
              ),
              SizedBox(width: tokens.spacingSm),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selected
                          ? tokens.accentPrimary
                          : tokens.inkPrimary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionAndFoldersStep extends StatelessWidget {
  const _PermissionAndFoldersStep({
    required this.capabilities,
    required this.onContinue,
  });

  final PlatformCapabilities capabilities;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<MusicFoldersCubit, MusicFoldersState>(
      builder: (context, state) {
        final needsAudioPermission =
            capabilities.supportsInAppFolderPicker &&
            !state.permissions.audioGranted;

        return LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: WetarResponsive.listPadding(
              constraints.maxWidth,
              minHorizontal: tokens.spacingLg,
              top: tokens.spacingLg,
              bottom: tokens.spacingLg,
              maxWidth: WetarResponsive.defaultWizardMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  l10n.onboardingFoldersTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: tokens.spacingSm),
                Text(
                  l10n.onboardingFoldersSubtitle,
                  style: textTheme.bodyMedium?.copyWith(color: tokens.inkMuted),
                ),
                SizedBox(height: tokens.spacingMd),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.folder_copy_outlined,
                              color: tokens.accentPrimary,
                            ),
                            SizedBox(width: tokens.spacingSm),
                            Expanded(
                              child: Text(
                                l10n.onboardingPermissionTitle,
                                style: textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: tokens.spacingSm),
                        Text(
                          l10n.onboardingPermissionBody,
                          style: textTheme.bodyMedium?.copyWith(
                            color: tokens.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: tokens.spacingLg),
                if (needsAudioPermission)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: tokens.accentPrimary,
                    ),
                    onPressed: () => context
                        .read<MusicFoldersCubit>()
                        .requestPermissions(includeNotifications: true),
                    icon: const Icon(Icons.verified_user_outlined),
                    label: Text(l10n.onboardingGrantPermission),
                  )
                else if (capabilities.supportsInAppFolderPicker) ...<Widget>[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed:
                        state.isLoadingDiscovery ||
                            state.scanProgress.isScanning
                        ? null
                        : () => context
                              .read<MusicFoldersCubit>()
                              .selectAllDiscoveredMusicFolders(),
                    icon: const Icon(Icons.library_music_outlined),
                    label: Text(l10n.onboardingSelectAllMusicFolders),
                  ),
                  SizedBox(height: tokens.spacingMd),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed:
                        state.isLoadingDiscovery ||
                            state.scanProgress.isScanning
                        ? null
                        : () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const FolderPickerScreen(),
                              ),
                            );
                          },
                    icon: const Icon(Icons.checklist_rounded),
                    label: Text(l10n.foldersChooseCta),
                  ),
                ] else
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: state.scanProgress.isScanning
                        ? null
                        : () => context
                              .read<MusicFoldersCubit>()
                              .pickSystemFolder(),
                    icon: const Icon(Icons.create_new_folder_outlined),
                    label: Text(l10n.foldersChooseCta),
                  ),
                SizedBox(height: tokens.spacingLg),
                if (state.isLoadingDiscovery || state.scanProgress.isScanning)
                  Container(
                    padding: EdgeInsets.all(tokens.spacingMd),
                    decoration: BoxDecoration(
                      color: tokens.surfaceElevated,
                      borderRadius: BorderRadius.circular(tokens.radiusCard),
                      border: Border.all(color: tokens.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (state.scanProgress.isScanning)
                          Text(
                            l10n.foldersScanProgress(
                              state.scanProgress.currentFolderName,
                              state.scanProgress.processedCount,
                              state.scanProgress.totalCount,
                            ),
                            style: textTheme.bodySmall,
                          ),
                        if (state.scanProgress.isScanning)
                          SizedBox(height: tokens.spacingXs),
                        LinearProgressIndicator(
                          value: state.scanProgress.isScanning
                              ? state.scanProgress.fraction
                              : null,
                        ),
                      ],
                    ),
                  )
                else if (state.selectedFolders.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(tokens.spacingMd),
                    decoration: BoxDecoration(
                      color: tokens.surfaceElevated,
                      borderRadius: BorderRadius.circular(tokens.radiusCard),
                      border: Border.all(color: tokens.borderSubtle),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.check_circle_outline, color: tokens.success),
                        SizedBox(width: tokens.spacingSm),
                        Expanded(
                          child: Text(
                            l10n.foldersSelectedSummary(
                              state.selectedFolders.length,
                              state.totalLibraryTracks,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: tokens.spacingLg),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: tokens.accentPrimary,
                  ),
                  onPressed: onContinue,
                  child: Text(l10n.actionContinue),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LookOnboardingStep extends StatelessWidget {
  const _LookOnboardingStep({
    required this.onThemeSelected,
    required this.onFinish,
  });

  final ValueChanged<WetarThemeMode> onThemeSelected;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final textTheme = Theme.of(context).textTheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocBuilder<PersonalizationCubit, PersonalizationState>(
      builder: (context, pState) {
        return LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: WetarResponsive.listPadding(
              constraints.maxWidth,
              minHorizontal: tokens.spacingLg,
              top: tokens.spacingLg,
              bottom: tokens.spacingLg,
              maxWidth: WetarResponsive.defaultWizardMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  l10n.onboardingLookTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: tokens.spacingXs),
                Text(
                  l10n.onboardingLookSubtitle,
                  style: textTheme.bodyMedium?.copyWith(color: tokens.inkMuted),
                ),
                SizedBox(height: tokens.spacingMd),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _ChoiceOptionCard(
                        icon: Icons.light_mode_rounded,
                        label: l10n.personalizationThemeLight,
                        selected: !tokens.isDark,
                        onTap: () => onThemeSelected(WetarThemeMode.light),
                      ),
                    ),
                    SizedBox(width: tokens.spacingSm),
                    Expanded(
                      child: _ChoiceOptionCard(
                        icon: Icons.dark_mode_rounded,
                        label: l10n.personalizationThemeDark,
                        selected: tokens.isDark,
                        onTap: () => onThemeSelected(WetarThemeMode.dark),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacingMd),
                Expanded(
                  child: GridView.builder(
                    itemCount: BuiltInLooks.all.length,
                    gridDelegate: WetarResponsive.presetGridDelegate(
                      maxTileExtent: 215,
                      aspectRatio: 1.7,
                    ),
                    itemBuilder: (context, idx) {
                      final look = BuiltInLooks.all[idx];
                      final selected =
                          pState.settings.accentArgb ==
                          look.settings.accentArgb;
                      final lookColor = look.settings.accentColor;
                      return InkWell(
                        borderRadius: BorderRadius.circular(tokens.radiusCard),
                        onTap: () => context
                            .read<PersonalizationCubit>()
                            .applyLook(look),
                        child: Container(
                          padding: EdgeInsets.all(tokens.spacingMd),
                          decoration: BoxDecoration(
                            color: tokens.isDark
                                ? tokens.surfaceElevated
                                : tokens.surface,
                            borderRadius: BorderRadius.circular(
                              tokens.radiusCard,
                            ),
                            border: Border.all(
                              color: selected ? lookColor : tokens.borderSubtle,
                              width: selected ? 2.2 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: lookColor,
                                  ),
                                  if (selected)
                                    Icon(
                                      Icons.check_circle,
                                      size: 18,
                                      color: lookColor,
                                    ),
                                ],
                              ),
                              Text(
                                isArabic ? look.nameAr : look.nameEn,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleSmall?.copyWith(
                                  color: tokens.inkPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: tokens.spacingMd),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: tokens.accentPrimary,
                  ),
                  onPressed: onFinish,
                  child: Text(l10n.actionDone),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
