import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/capabilities/platform_capabilities.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../music_folders/presentation/bloc/music_folders_cubit.dart';
import '../../../personalization/domain/appearance_settings.dart';
import '../../../personalization/presentation/bloc/personalization_cubit.dart';
import '../../../personalization/presentation/theme/wetar_tokens.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';

import 'package:wetar/features/music_folders/presentation/screens/folder_picker_screen.dart';

/// Minimal 3-step skippable onboarding explaining offline audio permissions,
/// guiding user-selected folder choice, and offering a starting Look preset.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

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
    final caps = sl<PlatformCapabilities>();

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacingMd,
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
                  TextButton(onPressed: _finish, child: Text(l10n.actionSkip)),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: <Widget>[
                  _WelcomeAndPermissionStep(
                    capabilities: caps,
                    onContinue: () => _goToPage(1),
                  ),
                  _FoldersOnboardingStep(
                    capabilities: caps,
                    onContinue: () => _goToPage(2),
                  ),
                  _LookOnboardingStep(onFinish: _finish),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeAndPermissionStep extends StatelessWidget {
  const _WelcomeAndPermissionStep({
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
        final granted = state.permissions.audioGranted;
        return SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: tokens.spacingMd),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.accentPrimary.withValues(alpha: 0.14),
                    border: Border.all(
                      color: tokens.accentPrimary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    size: 46,
                    color: tokens.accentPrimary,
                  ),
                ),
              ),
              SizedBox(height: tokens.spacingLg),
              Text(
                l10n.onboardingWelcomeTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: tokens.spacingSm),
              Text(
                l10n.onboardingWelcomeSubtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: tokens.inkMuted),
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
              if (capabilities.supportsInAppFolderPicker && !granted)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: tokens.accentPrimary,
                  ),
                  onPressed: () async {
                    final res = await context
                        .read<MusicFoldersCubit>()
                        .requestPermissions(includeNotifications: true);
                    if (res.audioGranted) {
                      onContinue();
                    }
                  },
                  icon: const Icon(Icons.verified_user_outlined),
                  label: Text(l10n.onboardingGrantPermission),
                )
              else
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
        );
      },
    );
  }
}

class _FoldersOnboardingStep extends StatelessWidget {
  const _FoldersOnboardingStep({
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
        return SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacingLg),
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
              SizedBox(height: tokens.spacingLg),
              if (capabilities.supportsInAppFolderPicker) ...<Widget>[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () async {
                    await context
                        .read<MusicFoldersCubit>()
                        .selectAllDiscoveredMusicFolders();
                  },
                  icon: const Icon(Icons.library_music_outlined),
                  label: Text(l10n.onboardingSelectAllMusicFolders),
                ),
                SizedBox(height: tokens.spacingMd),
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const FolderPickerScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.checklist_rounded),
                  label: Text(l10n.foldersChooseCta),
                ),
              ] else ...<Widget>[
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () =>
                      context.read<MusicFoldersCubit>().pickSystemFolder(),
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: Text(l10n.foldersChooseCta),
                ),
              ],
              SizedBox(height: tokens.spacingLg),
              if (state.selectedFolders.isNotEmpty)
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
        );
      },
    );
  }
}

class _LookOnboardingStep extends StatelessWidget {
  const _LookOnboardingStep({required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final textTheme = Theme.of(context).textTheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocBuilder<PersonalizationCubit, PersonalizationState>(
      builder: (context, pState) {
        return Padding(
          padding: EdgeInsets.all(tokens.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.onboardingLookTitle,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: tokens.spacingSm),
              Text(
                l10n.onboardingLookSubtitle,
                style: textTheme.bodyMedium?.copyWith(color: tokens.inkMuted),
              ),
              SizedBox(height: tokens.spacingMd),
              Expanded(
                child: GridView.builder(
                  itemCount: BuiltInLooks.all.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (context, idx) {
                    final look = BuiltInLooks.all[idx];
                    final selected =
                        pState.settings.accentArgb ==
                            look.settings.accentArgb &&
                        pState.settings.themeMode == look.settings.themeMode;
                    final lookColor = look.settings.accentColor;
                    final isLookDark =
                        look.settings.themeMode != WetarThemeMode.light;
                    return InkWell(
                      borderRadius: BorderRadius.circular(tokens.radiusCard),
                      onTap: () =>
                          context.read<PersonalizationCubit>().applyLook(look),
                      child: Container(
                        padding: EdgeInsets.all(tokens.spacingMd),
                        decoration: BoxDecoration(
                          color: isLookDark
                              ? const Color(0xFF1A1512)
                              : const Color(0xFFF6EFE4),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                color: isLookDark
                                    ? const Color(0xFFF6EFE6)
                                    : const Color(0xFF1F1915),
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
        );
      },
    );
  }
}
