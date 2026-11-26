import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/utils/haptic_service.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/library/presentation/bloc/library_cubit.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/personalization/presentation/widgets/wetar_background_renderer.dart';
import 'package:wetar/features/player/domain/queue_snapshot_codec.dart';
import 'package:wetar/features/player/domain/sleep_timer_config.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/features/player/presentation/widgets/wetar_seek_bar.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Signature Now Playing screen with 5 layout variants, customizable backgrounds,
/// Oud-string seekbar, A–B loop, sleep timer, speed/pitch, and remappable gestures.
class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({
    super.key,
    this.onOpenQueue,
    this.onOpenLyrics,
    this.onOpenEqualizer,
    this.onOpenCarMode,
    this.onOpenTrackDetails,
    this.onShareTrack,
  });

  final VoidCallback? onOpenQueue;
  final VoidCallback? onOpenLyrics;
  final VoidCallback? onOpenEqualizer;
  final VoidCallback? onOpenCarMode;
  final ValueChanged<WetarTrack>? onOpenTrackDetails;
  final ValueChanged<WetarTrack>? onShareTrack;

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _vinylController;
  bool _showGestureHint = false;

  @override
  void initState() {
    super.initState();
    _vinylController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    final settings = context.read<SettingsCubit>().state;
    if (!settings.hasShownGestureHint) {
      _showGestureHint = true;
      unawaited(context.read<SettingsCubit>().markGestureHintShown());
    }
  }

  @override
  void dispose() {
    _vinylController.dispose();
    super.dispose();
  }

  void _triggerGestureAction(GestureAction action, WetarTrack track) {
    final appearance = context.read<PersonalizationCubit>().state.settings;
    HapticService.trigger(appearance.hapticsIntensity);
    final player = context.read<PlayerCubit>();
    switch (action) {
      case GestureAction.none:
        return;
      case GestureAction.playPause:
        unawaited(player.togglePlayPause());
      case GestureAction.nextTrack:
        unawaited(player.next());
      case GestureAction.prevTrack:
        unawaited(player.previous());
      case GestureAction.toggleFavorite:
        if (!track.isTemporaryExternal) {
          unawaited(
            context.read<LibraryCubit>().toggleFavorite(track.stableKey),
          );
        }
      case GestureAction.openQueue:
        widget.onOpenQueue?.call();
      case GestureAction.openLyrics:
        widget.onOpenLyrics?.call();
    }
  }

  BorderRadius _resolveArtRadius(AppearanceSettings settings, double size) {
    return switch (settings.artworkShape) {
      ArtworkShapeStyle.circle => BorderRadius.circular(size),
      ArtworkShapeStyle.squircle => BorderRadius.circular(
        settings.artworkCornerRadius * 1.45,
      ),
      ArtworkShapeStyle.roundedSquare => BorderRadius.circular(
        settings.artworkCornerRadius,
      ),
    };
  }

  void _showSleepTimerSheet(BuildContext context, PlayerStateSnapshot state) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final player = context.read<PlayerCubit>();

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.inkMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(tokens.radiusPill),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spacingMd),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.playerSleepTimer,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
            ),
            for (final min in <int>[10, 15, 30, 45, 60])
              ListTile(
                title: Text(l10n.sleepTimerMinutes(min)),
                onTap: () {
                  player.setSleepTimerMinutes(min);
                  Navigator.of(ctx).pop();
                },
              ),
            ListTile(
              title: Text(l10n.sleepTimerEndOfTrack),
              onTap: () {
                player.setSleepTimerEndOfTrack();
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              title: Text(l10n.sleepTimerAfterTracks(3)),
              onTap: () {
                player.setSleepTimerAfterTracks(3);
                Navigator.of(ctx).pop();
              },
            ),
            if (state.sleepTimer.isActive)
              ListTile(
                leading: Icon(Icons.timer_off_outlined, color: tokens.danger),
                title: Text(l10n.sleepTimerOff),
                onTap: () {
                  player.cancelSleepTimer();
                  Navigator.of(ctx).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showSpeedPitchSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final caps = sl<PlatformCapabilities>();

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: BlocBuilder<PlayerCubit, PlayerStateSnapshot>(
          builder: (ctx, state) => Padding(
            padding: EdgeInsets.all(tokens.spacingMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.inkMuted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                  ),
                ),
                SizedBox(height: tokens.spacingMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(l10n.playerSpeedLabel),
                    Text('${state.speed.toStringAsFixed(2)}x'),
                  ],
                ),
                Slider(
                  min: 0.5,
                  max: 2.5,
                  divisions: 20,
                  value: state.speed,
                  activeColor: tokens.accentPrimary,
                  onChanged: (v) => context.read<PlayerCubit>().setSpeed(v),
                ),
                if (caps.supportsPitchControl) ...<Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(l10n.playerPitchLabel),
                      Text('${state.pitch.toStringAsFixed(2)}x'),
                    ],
                  ),
                  Slider(
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    value: state.pitch,
                    activeColor: tokens.accentSecondary,
                    onChanged: (v) => context.read<PlayerCubit>().setPitch(v),
                  ),
                ],
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () {
                      context.read<PlayerCubit>().setSpeed(1.0);
                      if (caps.supportsPitchControl) {
                        context.read<PlayerCubit>().setPitch(1.0);
                      }
                    },
                    child: Text(l10n.actionReset),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAbLoopSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final numerals = context.read<SettingsCubit>().state.numeralStyle;

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: BlocBuilder<PlayerCubit, PlayerStateSnapshot>(
          builder: (ctx, state) => Padding(
            padding: EdgeInsets.all(tokens.spacingMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.playerAbLoop,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spacingMd),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            context.read<PlayerCubit>().setAbPointA(),
                        child: Text(
                          state.abLoop.pointA != null
                              ? 'A: ${NumeralFormatter.formatDuration(state.abLoop.pointA!, numerals)}'
                              : l10n.playerAbSetA,
                        ),
                      ),
                    ),
                    SizedBox(width: tokens.spacingSm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            context.read<PlayerCubit>().setAbPointB(),
                        child: Text(
                          state.abLoop.pointB != null
                              ? 'B: ${NumeralFormatter.formatDuration(state.abLoop.pointB!, numerals)}'
                              : l10n.playerAbSetB,
                        ),
                      ),
                    ),
                    SizedBox(width: tokens.spacingSm),
                    TextButton(
                      onPressed: () =>
                          context.read<PlayerCubit>().clearAbLoop(),
                      child: Text(l10n.playerAbClear),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final appearance = context.select(
      (PersonalizationCubit c) => c.state.settings,
    );
    final numerals = context.select((SettingsCubit c) => c.state.numeralStyle);
    final caps = sl<PlatformCapabilities>();
    final thumbCache = sl<ThumbnailPathCache>();

    return BlocBuilder<PlayerCubit, PlayerStateSnapshot>(
      builder: (context, state) {
        final track = state.currentTrack;
        if (track == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.playerNowPlaying)),
            body: Center(child: Text(l10n.queueEmpty)),
          );
        }

        final shouldSpinVinyl =
            appearance.playerLayout == PlayerLayoutVariant.vinylDisc &&
            state.isPlaying &&
            !tokens.isLiteMode &&
            TickerMode.valuesOf(context).enabled;
        if (shouldSpinVinyl && !_vinylController.isAnimating) {
          _vinylController.repeat();
        } else if (!shouldSpinVinyl && _vinylController.isAnimating) {
          _vinylController.stop();
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: WetarBackgroundRenderer(
            surfaceLocation: BackgroundScope.playerOnly,
            activeTrack: track,
            isPlaying: state.isPlaying,
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacingSm,
                      vertical: tokens.spacingXs,
                    ),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          tooltip: l10n.actionClose,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Text(
                                l10n.playerNowPlaying,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              if (state.sleepTimer.isActive)
                                Text(
                                  state.sleepTimer.mode ==
                                          SleepTimerMode.duration
                                      ? l10n.sleepTimerActiveRemaining(
                                          NumeralFormatter.formatDuration(
                                            state.sleepTimer.remainingDuration,
                                            numerals,
                                          ),
                                        )
                                      : (state.sleepTimer.mode ==
                                                SleepTimerMode.endOfTrack
                                            ? l10n.sleepTimerEndOfTrack
                                            : l10n.sleepTimerAfterTracks(
                                                state
                                                    .sleepTimer
                                                    .remainingTracks,
                                              )),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(color: tokens.accentSecondary),
                                ),
                            ],
                          ),
                        ),
                        if (widget.onShareTrack != null)
                          IconButton(
                            tooltip: l10n.actionShare,
                            icon: const Icon(Icons.share_outlined),
                            onPressed: () => widget.onShareTrack!(track),
                          ),
                        if (widget.onOpenTrackDetails != null)
                          IconButton(
                            tooltip: l10n.playerTrackDetails,
                            icon: const Icon(Icons.more_horiz_rounded),
                            onPressed: () => widget.onOpenTrackDetails!(track),
                          ),
                      ],
                    ),
                  ),
                  if (_showGestureHint)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacingMd,
                      ),
                      child: Material(
                        color: tokens.surfaceElevated.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(tokens.radiusCard),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: tokens.spacingMd,
                            vertical: tokens.spacingXs,
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.touch_app_outlined,
                                size: 16,
                                color: tokens.accentPrimary,
                              ),
                              SizedBox(width: tokens.spacingSm),
                              Expanded(
                                child: Text(
                                  l10n.playerGestureHintOnce,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () =>
                                    setState(() => _showGestureHint = false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (track.isTemporaryExternal && track.folderPath.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacingMd,
                        vertical: tokens.spacingXs,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.spacingMd,
                          vertical: tokens.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.surfaceElevated,
                          borderRadius: BorderRadius.circular(
                            tokens.radiusCard,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                l10n.playerExternalTempBanner,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final name = track.folderPath.split('/').last;
                                context.read<MusicFoldersCubit>().addFolderPath(
                                  rootPath: track.folderPath,
                                  displayName: name.isEmpty
                                      ? track.folderPath
                                      : name,
                                );
                                WetarFeedback.showSuccess(
                                  context,
                                  l10n.foldersAddedSuccess(name),
                                );
                              },
                              child: Text(l10n.playerExternalAddFolder),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacingLg,
                      ),
                      child: _buildArtworkStage(
                        context,
                        track: track,
                        appearance: appearance,
                        tokens: tokens,
                        thumbCache: thumbCache,
                        isPlaying: state.isPlaying,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.spacingLg),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    appearance.playerLayout ==
                                        PlayerLayoutVariant.minimal
                                    ? CrossAxisAlignment.center
                                    : CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    track.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${track.displayArtist} • ${track.displayAlbum}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: tokens.inkMuted),
                                  ),
                                ],
                              ),
                            ),
                            if (!track.isTemporaryExternal &&
                                appearance.playerLayout !=
                                    PlayerLayoutVariant.minimal)
                              IconButton(
                                tooltip: l10n.actionFavorite,
                                icon: Icon(
                                  track.isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: track.isFavorite
                                      ? tokens.accentPrimary
                                      : tokens.inkMuted,
                                ),
                                onPressed: () {
                                  HapticService.trigger(
                                    appearance.hapticsIntensity,
                                  );
                                  context.read<LibraryCubit>().toggleFavorite(
                                    track.stableKey,
                                  );
                                },
                              ),
                          ],
                        ),
                        SizedBox(height: tokens.spacingSm),
                        Directionality(
                          textDirection: appearance.mirrorTimelineInRtl
                              ? Directionality.of(context)
                              : TextDirection.ltr,
                          child: Column(
                            children: <Widget>[
                              WetarSeekBar(
                                seedKey: track.stableKey,
                                style: appearance.seekBarStyle,
                                position: state.position,
                                duration: track.duration,
                                isPlaying: state.isPlaying,
                                abLoop: state.abLoop,
                                hapticsIntensity: appearance.hapticsIntensity,
                                onSeek: (d) =>
                                    context.read<PlayerCubit>().seek(d),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    NumeralFormatter.formatDuration(
                                      state.position,
                                      numerals,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall,
                                  ),
                                  Text(
                                    NumeralFormatter.formatDuration(
                                      track.duration,
                                      numerals,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: tokens.spacingSm),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              IconButton(
                                tooltip: l10n.actionShuffle,
                                icon: Icon(
                                  Icons.shuffle_rounded,
                                  color: state.shuffleEnabled
                                      ? tokens.accentPrimary
                                      : tokens.inkMuted,
                                ),
                                onPressed: () {
                                  HapticService.trigger(
                                    appearance.hapticsIntensity,
                                  );
                                  context.read<PlayerCubit>().toggleShuffle();
                                },
                              ),
                              IconButton(
                                tooltip: l10n.actionPrevious,
                                iconSize: 34 * tokens.iconScale,
                                icon: const Icon(Icons.skip_previous_rounded),
                                onPressed: () {
                                  HapticService.trigger(
                                    appearance.hapticsIntensity,
                                  );
                                  context.read<PlayerCubit>().previous();
                                },
                              ),
                              SizedBox(
                                width: 68,
                                height: 68,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    shape: const CircleBorder(),
                                    backgroundColor: tokens.accentPrimary,
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {
                                    HapticService.trigger(
                                      appearance.hapticsIntensity,
                                      heavy: true,
                                    );
                                    context
                                        .read<PlayerCubit>()
                                        .togglePlayPause();
                                  },
                                  child: Icon(
                                    state.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 36 * tokens.iconScale,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.actionNext,
                                iconSize: 34 * tokens.iconScale,
                                icon: const Icon(Icons.skip_next_rounded),
                                onPressed: () {
                                  HapticService.trigger(
                                    appearance.hapticsIntensity,
                                  );
                                  context.read<PlayerCubit>().next();
                                },
                              ),
                              IconButton(
                                tooltip: switch (state.repeatMode) {
                                  WetarRepeatMode.off => l10n.actionRepeatOff,
                                  WetarRepeatMode.all => l10n.actionRepeatAll,
                                  WetarRepeatMode.one => l10n.actionRepeatOne,
                                },
                                icon: Icon(
                                  state.repeatMode == WetarRepeatMode.one
                                      ? Icons.repeat_one_rounded
                                      : Icons.repeat_rounded,
                                  color: state.repeatMode != WetarRepeatMode.off
                                      ? tokens.accentPrimary
                                      : tokens.inkMuted,
                                ),
                                onPressed: () {
                                  HapticService.trigger(
                                    appearance.hapticsIntensity,
                                  );
                                  context.read<PlayerCubit>().cycleRepeatMode();
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: tokens.spacingSm),
                        _buildSecondaryActionsBar(
                          context,
                          appearance: appearance,
                          track: track,
                          state: state,
                          caps: caps,
                        ),
                        SizedBox(height: tokens.spacingMd),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArtworkStage(
    BuildContext context, {
    required WetarTrack track,
    required AppearanceSettings appearance,
    required WetarTokens tokens,
    required ThumbnailPathCache thumbCache,
    required bool isPlaying,
  }) {
    return GestureDetector(
      onDoubleTap: () =>
          _triggerGestureAction(appearance.doubleTapCoverAction, track),
      onLongPress: () =>
          _triggerGestureAction(appearance.longPressCoverAction, track),
      onHorizontalDragEnd: !appearance.swipeCoverHorizontal
          ? null
          : (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity.abs() < 220) return;
              if (velocity < 0) {
                unawaited(context.read<PlayerCubit>().next());
              } else {
                unawaited(context.read<PlayerCubit>().previous());
              }
            },
      child: Center(
        child: LayoutBuilder(
          builder: (context, box) {
            final maxSize = math.min(box.maxWidth, box.maxHeight);
            final artSize =
                appearance.playerLayout == PlayerLayoutVariant.immersiveBleed
                ? maxSize.clamp(200.0, 380.0)
                : (maxSize * 0.86).clamp(170.0, 320.0);

            Widget artwork = Hero(
              tag: 'wetar_artwork_${track.stableKey}',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      appearance.playerLayout == PlayerLayoutVariant.vinylDisc
                      ? BorderRadius.circular(artSize)
                      : _resolveArtRadius(appearance, artSize),
                  boxShadow: tokens.shadowAlpha <= 0
                      ? null
                      : <BoxShadow>[
                          BoxShadow(
                            color: tokens.accentPrimary.withValues(
                              alpha: tokens.shadowAlpha * 0.9,
                            ),
                            blurRadius: 34,
                            offset: const Offset(0, 14),
                          ),
                        ],
                ),
                child: WetarArtworkImage(
                  cacheKey: track.albumKey,
                  size: artSize,
                  artworkUri: track.artworkUri,
                  filePath: track.filePath,
                  customArtPath: track.customArtPath,
                  thumbnailCache: thumbCache,
                  borderRadius:
                      appearance.playerLayout == PlayerLayoutVariant.vinylDisc
                      ? BorderRadius.circular(artSize)
                      : _resolveArtRadius(appearance, artSize),
                  decodeSizePx: 512,
                ),
              ),
            );

            if (appearance.playerLayout == PlayerLayoutVariant.vinylDisc) {
              artwork = RotationTransition(
                turns: _vinylController,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    artwork,
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.canvas,
                        border: Border.all(
                          color: tokens.accentPrimary,
                          width: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (appearance.playerLayout ==
                PlayerLayoutVariant.oudStrings) {
              artwork = Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SizedBox(
                    width: artSize + 38,
                    height: artSize + 24,
                    child: CustomPaint(
                      painter: _OudCoverAuraPainter(
                        accent: tokens.accentPrimary,
                        secondary: tokens.accentSecondary,
                      ),
                    ),
                  ),
                  artwork,
                ],
              );
            } else if (appearance.playerLayout ==
                PlayerLayoutVariant.classicCard) {
              artwork = Container(
                padding: EdgeInsets.all(tokens.spacingMd),
                decoration: BoxDecoration(
                  color: tokens.surface.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(tokens.radiusCard * 1.4),
                  border: Border.all(color: tokens.borderSubtle),
                ),
                child: artwork,
              );
            }

            return artwork;
          },
        ),
      ),
    );
  }

  Widget _buildSecondaryActionsBar(
    BuildContext context, {
    required AppearanceSettings appearance,
    required WetarTrack track,
    required PlayerStateSnapshot state,
    required PlatformCapabilities caps,
  }) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;

    final buttons = <Widget>[];
    for (final action in appearance.secondaryActions) {
      switch (action) {
        case PlayerSecondaryAction.favorite:
          if (!track.isTemporaryExternal) {
            buttons.add(
              IconButton(
                tooltip: l10n.actionFavorite,
                icon: Icon(
                  track.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: track.isFavorite
                      ? tokens.accentPrimary
                      : tokens.inkMuted,
                ),
                onPressed: () => context.read<LibraryCubit>().toggleFavorite(
                  track.stableKey,
                ),
              ),
            );
          }
        case PlayerSecondaryAction.lyrics:
          if (widget.onOpenLyrics != null) {
            buttons.add(
              IconButton(
                tooltip: l10n.playerLyrics,
                icon: const Icon(Icons.lyrics_outlined),
                onPressed: widget.onOpenLyrics,
              ),
            );
          }
        case PlayerSecondaryAction.queue:
          if (widget.onOpenQueue != null) {
            buttons.add(
              IconButton(
                tooltip: l10n.playerQueue,
                icon: const Icon(Icons.queue_music_rounded),
                onPressed: widget.onOpenQueue,
              ),
            );
          }
        case PlayerSecondaryAction.sleepTimer:
          buttons.add(
            IconButton(
              tooltip: l10n.playerSleepTimer,
              icon: Icon(
                Icons.bedtime_outlined,
                color: state.sleepTimer.isActive ? tokens.accentPrimary : null,
              ),
              onPressed: () => _showSleepTimerSheet(context, state),
            ),
          );
        case PlayerSecondaryAction.speedPitch:
          buttons.add(
            IconButton(
              tooltip: l10n.playerSpeedPitch,
              icon: const Icon(Icons.speed_rounded),
              onPressed: () => _showSpeedPitchSheet(context),
            ),
          );
        case PlayerSecondaryAction.abLoop:
          buttons.add(
            IconButton(
              tooltip: l10n.playerAbLoop,
              icon: Icon(
                Icons.repeat_on_outlined,
                color: state.abLoop.isEnabled ? tokens.accentSecondary : null,
              ),
              onPressed: () => _showAbLoopSheet(context),
            ),
          );
        case PlayerSecondaryAction.equalizer:
          if (caps.supportsAnyAudioEffects && widget.onOpenEqualizer != null) {
            buttons.add(
              IconButton(
                tooltip: l10n.playerEqualizer,
                icon: const Icon(Icons.equalizer_rounded),
                onPressed: widget.onOpenEqualizer,
              ),
            );
          }
        case PlayerSecondaryAction.carMode:
          if (widget.onOpenCarMode != null) {
            buttons.add(
              IconButton(
                tooltip: l10n.playerCarMode,
                icon: const Icon(Icons.directions_car_outlined),
                onPressed: widget.onOpenCarMode,
              ),
            );
          }
        case PlayerSecondaryAction.details:
          if (widget.onOpenTrackDetails != null) {
            buttons.add(
              IconButton(
                tooltip: l10n.playerTrackDetails,
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () => widget.onOpenTrackDetails!(track),
              ),
            );
          }
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buttons,
      ),
    );
  }
}

class _OudCoverAuraPainter extends CustomPainter {
  const _OudCoverAuraPainter({required this.accent, required this.secondary});

  final Color accent;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 0; i < 6; i++) {
      final inset = i * 4.0;
      paint.color = (i.isEven ? accent : secondary).withValues(
        alpha: 0.24 - i * 0.03,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            inset,
            inset,
            size.width - inset * 2,
            size.height - inset * 2,
          ),
          Radius.circular(28 - i * 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OudCoverAuraPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.secondary != secondary;
  }
}
