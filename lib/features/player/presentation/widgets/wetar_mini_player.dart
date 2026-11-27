import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/utils/haptic_service.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Persistent Mini Player anchored above navigation with Hero artwork transition,
/// swipe-up to open Now Playing, and optional swipe-down / button close when paused.
class WetarMiniPlayer extends StatefulWidget {
  const WetarMiniPlayer({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<WetarMiniPlayer> createState() => _WetarMiniPlayerState();
}

class _WetarMiniPlayerState extends State<WetarMiniPlayer> {
  double _dragOffsetY = 0.0;

  void _resetDrag() {
    if (_dragOffsetY != 0.0) {
      setState(() => _dragOffsetY = 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final appearance = context.select(
      (PersonalizationCubit c) => c.state.settings,
    );
    final thumbCache = sl<ThumbnailPathCache>();

    return BlocListener<PlayerCubit, PlayerStateSnapshot>(
      listenWhen: (prev, curr) =>
          (!prev.isPlaying && curr.isPlaying) ||
          prev.currentTrack?.stableKey != curr.currentTrack?.stableKey,
      listener: (context, state) {
        if (state.isPlaying || state.currentTrack == null) {
          _resetDrag();
        } else {
          _resetDrag();
        }
      },
      child: BlocBuilder<PlayerCubit, PlayerStateSnapshot>(
        buildWhen: (prev, curr) =>
            prev.currentTrack != curr.currentTrack ||
            prev.isPlaying != curr.isPlaying ||
            (appearance.miniPlayerShowProgress &&
                prev.position != curr.position),
        builder: (context, state) {
          final track = state.currentTrack;
          if (track == null) return const SizedBox.shrink();

          final isFloating =
              appearance.miniPlayerStyle == MiniPlayerStyle.floatingPill;
          final canSwipeDismiss =
              !state.isPlaying && appearance.miniPlayerSwipeDownDismiss;
          final totalMs = track.durationMs <= 0 ? 1 : track.durationMs;
          final progress = (state.position.inMilliseconds / totalMs).clamp(
            0.0,
            1.0,
          );
          final effectiveOffsetY = canSwipeDismiss
              ? _dragOffsetY
              : _dragOffsetY.clamp(-20.0, 0.0);
          final dragOpacity = effectiveOffsetY > 0
              ? (1.0 - (effectiveOffsetY / 88.0)).clamp(0.15, 1.0)
              : 1.0;

          return Padding(
            padding: isFloating
                ? EdgeInsets.symmetric(
                    horizontal: tokens.spacingMd,
                    vertical: tokens.spacingXs,
                  )
                : EdgeInsets.zero,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (details) {
                final maxDown = canSwipeDismiss ? 96.0 : 0.0;
                final next = (_dragOffsetY + details.delta.dy).clamp(
                  -20.0,
                  maxDown,
                );
                if (next != _dragOffsetY) {
                  setState(() => _dragOffsetY = next);
                }
              },
              onVerticalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0.0;
                final currentOffset = _dragOffsetY;
                _resetDrag();
                if (currentOffset <= -18 || velocity < -220) {
                  HapticService.trigger(appearance.hapticsIntensity);
                  widget.onTap();
                  return;
                }
                if (canSwipeDismiss &&
                    (currentOffset >= 32 || velocity > 200)) {
                  HapticService.trigger(appearance.hapticsIntensity);
                  unawaited(context.read<PlayerCubit>().dismissPausedPlayer());
                }
              },
              onVerticalDragCancel: _resetDrag,
              child: Opacity(
                opacity: dragOpacity,
                child: Transform.translate(
                  offset: Offset(0, effectiveOffsetY),
                  child: Material(
                    color: tokens.surfaceElevated,
                    elevation: isFloating ? 4 : 0,
                    shape: isFloating
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              tokens.radiusCard,
                            ),
                            side: BorderSide(color: tokens.borderSubtle),
                          )
                        : null,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: widget.onTap,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (canSwipeDismiss)
                            Container(
                              margin: EdgeInsets.only(
                                top: tokens.spacingXs * 1.25,
                              ),
                              width: 28,
                              height: 3,
                              decoration: BoxDecoration(
                                color: tokens.inkMuted.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(
                                  tokens.radiusPill,
                                ),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: tokens.spacingMd * 0.75,
                              vertical: tokens.spacingSm,
                            ),
                            child: Row(
                              children: <Widget>[
                                Hero(
                                  tag: 'wetar_artwork_${track.stableKey}',
                                  child: WetarArtworkImage(
                                    cacheKey: track.albumKey,
                                    size: 44,
                                    artworkUri: track.artworkUri,
                                    filePath: track.filePath,
                                    customArtPath: track.customArtPath,
                                    thumbnailCache: thumbCache,
                                    decodeSizePx: 144,
                                  ),
                                ),
                                SizedBox(width: tokens.spacingSm * 1.25),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        track.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        track.resolvedArtist(
                                          l10n.libraryUnknownArtist,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: state.isPlaying
                                      ? l10n.actionPause
                                      : l10n.actionPlay,
                                  icon: Icon(
                                    state.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: tokens.accentPrimary,
                                  ),
                                  onPressed: () => context
                                      .read<PlayerCubit>()
                                      .togglePlayPause(),
                                ),
                                IconButton(
                                  tooltip: l10n.actionNext,
                                  icon: const Icon(Icons.skip_next_rounded),
                                  onPressed: () =>
                                      context.read<PlayerCubit>().next(),
                                ),
                                if (!state.isPlaying)
                                  IconButton(
                                    tooltip: l10n.playerDismissPaused,
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: tokens.inkMuted,
                                    ),
                                    onPressed: () {
                                      HapticService.trigger(
                                        appearance.hapticsIntensity,
                                      );
                                      unawaited(
                                        context
                                            .read<PlayerCubit>()
                                            .dismissPausedPlayer(),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                          if (appearance.miniPlayerShowProgress)
                            Directionality(
                              textDirection: appearance.mirrorTimelineInRtl
                                  ? Directionality.of(context)
                                  : TextDirection.ltr,
                              child: LinearProgressIndicator(
                                minHeight: 2.5,
                                value: progress,
                                backgroundColor: tokens.borderSubtle,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  tokens.accentPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
