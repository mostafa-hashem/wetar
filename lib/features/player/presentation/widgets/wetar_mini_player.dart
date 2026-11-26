import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/wetar_artwork_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../personalization/domain/appearance_settings.dart';
import '../../../personalization/presentation/bloc/personalization_cubit.dart';
import '../../../personalization/presentation/theme/wetar_tokens.dart';
import '../bloc/player_cubit.dart';

/// Persistent Mini Player anchored above navigation with Hero artwork transition.
class WetarMiniPlayer extends StatelessWidget {
  const WetarMiniPlayer({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final appearance = context.select(
      (PersonalizationCubit c) => c.state.settings,
    );
    final thumbCache = sl<ThumbnailPathCache>();

    return BlocBuilder<PlayerCubit, PlayerStateSnapshot>(
      buildWhen: (prev, curr) =>
          prev.currentTrack != curr.currentTrack ||
          prev.isPlaying != curr.isPlaying ||
          (appearance.miniPlayerShowProgress && prev.position != curr.position),
      builder: (context, state) {
        final track = state.currentTrack;
        if (track == null) return const SizedBox.shrink();

        final isFloating =
            appearance.miniPlayerStyle == MiniPlayerStyle.floatingPill;
        final totalMs = track.durationMs <= 0 ? 1 : track.durationMs;
        final progress = (state.position.inMilliseconds / totalMs).clamp(
          0.0,
          1.0,
        );

        return Padding(
          padding: isFloating
              ? EdgeInsets.symmetric(
                  horizontal: tokens.spacingMd,
                  vertical: tokens.spacingXs,
                )
              : EdgeInsets.zero,
          child: Material(
            color: tokens.surfaceElevated,
            elevation: isFloating ? 4 : 0,
            borderRadius: isFloating
                ? BorderRadius.circular(tokens.radiusCard)
                : BorderRadius.zero,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                track.displayArtist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
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
                          onPressed: () =>
                              context.read<PlayerCubit>().togglePlayPause(),
                        ),
                        IconButton(
                          tooltip: l10n.actionNext,
                          icon: const Icon(Icons.skip_next_rounded),
                          onPressed: () => context.read<PlayerCubit>().next(),
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
        );
      },
    );
  }
}
