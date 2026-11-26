import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/utils/haptic_service.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/features/library/presentation/bloc/library_cubit.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Distraction-free Car / Driving Mode with oversized 76dp+ touch targets,
/// high-contrast typography, and optional screen-keep-awake.
class CarModeScreen extends StatefulWidget {
  const CarModeScreen({super.key});

  @override
  State<CarModeScreen> createState() => _CarModeScreenState();
}

class _CarModeScreenState extends State<CarModeScreen> {
  @override
  void initState() {
    super.initState();
    final keepAwake = context.read<SettingsCubit>().state.carModeKeepAwake;
    if (keepAwake) {
      unawaited(sl<SystemIntegrationService>().setKeepScreenOn(true));
    }
  }

  @override
  void dispose() {
    unawaited(sl<SystemIntegrationService>().setKeepScreenOn(false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final haptics = context.select(
      (PersonalizationCubit c) => c.state.settings.hapticsIntensity,
    );
    final numerals = context.select((SettingsCubit c) => c.state.numeralStyle);

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        title: Text(l10n.playerCarMode),
        leading: IconButton(
          iconSize: 32,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<PlayerCubit, PlayerStateSnapshot>(
          builder: (context, state) {
            final track = state.currentTrack;
            if (track == null) {
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(tokens.spacingLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        l10n.queueEmpty,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: tokens.spacingLg),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(240, 68),
                          backgroundColor: tokens.accentPrimary,
                        ),
                        onPressed: () {
                          final tracks = context
                              .read<LibraryCubit>()
                              .state
                              .allTracks;
                          unawaited(
                            context.read<PlayerCubit>().shuffleAll(tracks),
                          );
                        },
                        icon: const Icon(Icons.shuffle_rounded, size: 32),
                        label: Text(l10n.actionShuffleAll),
                      ),
                    ],
                  ),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: EdgeInsets.all(tokens.spacingLg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - tokens.spacingLg * 2)
                        .clamp(0.0, double.infinity),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            track.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: tokens.spacingSm),
                          Text(
                            track.displayArtist,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: tokens.inkMuted),
                          ),
                          SizedBox(height: tokens.spacingMd),
                          Text(
                            '${NumeralFormatter.formatDuration(state.position, numerals)} / ${NumeralFormatter.formatDuration(track.duration, numerals)}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: tokens.accentPrimary),
                          ),
                        ],
                      ),
                      SizedBox(height: tokens.spacingMd),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _CarButton(
                              icon: Icons.skip_previous_rounded,
                              size: 76,
                              color: tokens.surfaceElevated,
                              iconColor: tokens.inkPrimary,
                              onTap: () {
                                HapticService.trigger(haptics);
                                unawaited(
                                  context.read<PlayerCubit>().previous(),
                                );
                              },
                            ),
                            _CarButton(
                              icon: state.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 108,
                              color: tokens.accentPrimary,
                              iconColor: Colors.white,
                              onTap: () {
                                HapticService.trigger(haptics, heavy: true);
                                unawaited(
                                  context.read<PlayerCubit>().togglePlayPause(),
                                );
                              },
                            ),
                            _CarButton(
                              icon: Icons.skip_next_rounded,
                              size: 76,
                              color: tokens.surfaceElevated,
                              iconColor: tokens.inkPrimary,
                              onTap: () {
                                HapticService.trigger(haptics);
                                unawaited(context.read<PlayerCubit>().next());
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: tokens.spacingMd),
                      if (!track.isTemporaryExternal)
                        FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(64),
                          ),
                          onPressed: () {
                            HapticService.trigger(haptics);
                            unawaited(
                              context.read<LibraryCubit>().toggleFavorite(
                                track.stableKey,
                              ),
                            );
                          },
                          icon: Icon(
                            track.isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 32,
                            color: track.isFavorite
                                ? tokens.accentPrimary
                                : null,
                          ),
                          label: Text(
                            track.isFavorite
                                ? l10n.actionUnfavorite
                                : l10n.actionFavorite,
                          ),
                        )
                      else
                        const SizedBox(height: 64),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CarButton extends StatelessWidget {
  const _CarButton({
    required this.icon,
    required this.size,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(icon, size: size * 0.52, color: iconColor),
        ),
      ),
    );
  }
}
