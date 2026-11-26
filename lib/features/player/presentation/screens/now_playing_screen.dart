import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/numeral_formatter.dart';
import '../../../../core/widgets/wetar_artwork_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../library/presentation/bloc/library_cubit.dart';
import '../../../music_folders/presentation/bloc/music_folders_cubit.dart';
import '../../../personalization/presentation/bloc/personalization_cubit.dart';
import '../../../personalization/presentation/theme/wetar_tokens.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../domain/queue_snapshot_codec.dart';
import '../bloc/player_cubit.dart';

/// Full-screen Now Playing view (Phase 1 core controls + Open-With banner;
/// expanded with 5 layouts, Oud-string waveform seekbar, and 6 backgrounds in Phase 2).
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({
    super.key,
    this.onOpenQueue,
    this.onOpenLyrics,
    this.onOpenEqualizer,
  });

  final VoidCallback? onOpenQueue;
  final VoidCallback? onOpenLyrics;
  final VoidCallback? onOpenEqualizer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final appearance = context.select(
      (PersonalizationCubit c) => c.state.settings,
    );
    final numerals = context.select((SettingsCubit c) => c.state.numeralStyle);
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

        final totalMs = track.durationMs.clamp(1, 86400000);
        final posMs = state.position.inMilliseconds.clamp(0, totalMs);

        return Scaffold(
          backgroundColor: tokens.canvas,
          appBar: AppBar(
            title: Text(l10n.playerNowPlaying),
            actions: <Widget>[
              if (onOpenQueue != null)
                IconButton(
                  tooltip: l10n.playerQueue,
                  icon: const Icon(Icons.queue_music_rounded),
                  onPressed: onOpenQueue,
                ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(tokens.spacingLg),
              child: Column(
                children: <Widget>[
                  if (track.isTemporaryExternal &&
                      track.folderPath.isNotEmpty) ...<Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacingMd,
                        vertical: tokens.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(tokens.radiusCard),
                        border: Border.all(color: tokens.borderSubtle),
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
                            },
                            child: Text(l10n.playerExternalAddFolder),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: tokens.spacingMd),
                  ],
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, box) {
                          final size = box.biggest.shortestSide.clamp(
                            180.0,
                            340.0,
                          );
                          return Hero(
                            tag: 'wetar_artwork_${track.stableKey}',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  appearance.artworkCornerRadius,
                                ),
                                boxShadow: tokens.shadowAlpha <= 0
                                    ? null
                                    : <BoxShadow>[
                                        BoxShadow(
                                          color: tokens.accentPrimary
                                              .withValues(alpha: 0.22),
                                          blurRadius: 34,
                                          offset: const Offset(0, 14),
                                        ),
                                      ],
                              ),
                              child: WetarArtworkImage(
                                cacheKey: track.albumKey,
                                size: size,
                                artworkUri: track.artworkUri,
                                filePath: track.filePath,
                                customArtPath: track.customArtPath,
                                thumbnailCache: thumbCache,
                                borderRadius: BorderRadius.circular(
                                  appearance.artworkCornerRadius,
                                ),
                                decodeSizePx: 512,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: tokens.spacingMd),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${track.displayArtist} • ${track.displayAlbum}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: tokens.inkMuted),
                            ),
                          ],
                        ),
                      ),
                      if (!track.isTemporaryExternal)
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
                          onPressed: () => context
                              .read<LibraryCubit>()
                              .toggleFavorite(track.stableKey),
                        ),
                    ],
                  ),
                  SizedBox(height: tokens.spacingMd),
                  Directionality(
                    textDirection: appearance.mirrorTimelineInRtl
                        ? Directionality.of(context)
                        : TextDirection.ltr,
                    child: Column(
                      children: <Widget>[
                        Slider(
                          min: 0,
                          max: totalMs.toDouble(),
                          value: posMs.toDouble(),
                          activeColor: tokens.accentPrimary,
                          inactiveColor: tokens.borderSubtle,
                          onChanged: (v) => context.read<PlayerCubit>().seek(
                            Duration(milliseconds: v.round()),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: tokens.spacingSm,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                NumeralFormatter.formatDuration(
                                  state.position,
                                  numerals,
                                ),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Text(
                                NumeralFormatter.formatDuration(
                                  track.duration,
                                  numerals,
                                ),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: tokens.spacingMd),
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
                          onPressed: () =>
                              context.read<PlayerCubit>().toggleShuffle(),
                        ),
                        IconButton(
                          tooltip: l10n.actionPrevious,
                          iconSize: 34 * tokens.iconScale,
                          icon: const Icon(Icons.skip_previous_rounded),
                          onPressed: () =>
                              context.read<PlayerCubit>().previous(),
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
                            onPressed: () =>
                                context.read<PlayerCubit>().togglePlayPause(),
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
                          onPressed: () => context.read<PlayerCubit>().next(),
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
                          onPressed: () =>
                              context.read<PlayerCubit>().cycleRepeatMode(),
                        ),
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
}
