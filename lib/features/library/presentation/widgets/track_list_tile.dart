import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Fixed-extent track row engineered for 60/120fps scrolling across 20,000+ tracks.
class TrackListTile extends StatelessWidget {
  const TrackListTile({
    super.key,
    required this.track,
    required this.isPlayingTrack,
    required this.showArtwork,
    required this.numeralStyle,
    required this.thumbnailCache,
    required this.onTap,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onLongPress,
    this.onMorePressed,
    this.onCloudTap,
  });

  final WetarTrack track;
  final bool isPlayingTrack;
  final bool showArtwork;
  final NumeralStyle numeralStyle;
  final ThumbnailPathCache? thumbnailCache;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onLongPress;
  final VoidCallback? onMorePressed;
  final VoidCallback? onCloudTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wetarTokens;
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapUp: (onMorePressed != null && !isSelectionMode)
          ? (_) => onMorePressed!()
          : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: tokens.listRowExtent),
        child: Material(
          color: isSelected
              ? tokens.accentPrimary.withValues(alpha: 0.14)
              : Colors.transparent,
          child: InkWell(
            onTap: track.isCloudPending ? onCloudTap : onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacingMd,
                vertical: tokens.spacingXs,
              ),
              child: Row(
                children: <Widget>[
                  if (isSelectionMode)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: tokens.spacingSm,
                      ),
                      child: Checkbox(
                        value: isSelected,
                        activeColor: tokens.accentPrimary,
                        onChanged: (_) => onTap(),
                      ),
                    )
                  else if (showArtwork) ...<Widget>[
                    WetarArtworkImage(
                      cacheKey: track.albumKey,
                      size: tokens.listRowExtent - 18,
                      artworkUri: track.artworkUri,
                      filePath: track.filePath,
                      customArtPath: track.customArtPath,
                      thumbnailCache: thumbnailCache,
                      decodeSizePx: 144,
                    ),
                    SizedBox(width: tokens.spacingMd * 0.75),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge?.copyWith(
                            color: isPlayingTrack
                                ? tokens.accentPrimary
                                : tokens.inkPrimary,
                            fontWeight: isPlayingTrack
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: <Widget>[
                            if (track.isCloudPending)
                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                  end: tokens.spacingXs,
                                ),
                                child: Icon(
                                  Icons.cloud_download_outlined,
                                  size: 14,
                                  color: tokens.accentSecondary,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                _subtitleLabel(track, l10n),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: tokens.spacingSm),
                  Text(
                    NumeralFormatter.formatDuration(
                      track.duration,
                      numeralStyle,
                    ),
                    style: textTheme.labelMedium?.copyWith(
                      color: tokens.inkMuted,
                    ),
                  ),
                  if (onMorePressed != null && !isSelectionMode)
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded, size: 20),
                      color: tokens.inkMuted,
                      onPressed: onMorePressed,
                      tooltip: l10n.playerTrackDetails,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _subtitleLabel(WetarTrack track, AppLocalizations l10n) {
    if (track.hasKnownArtist && track.hasKnownAlbum) {
      return '${track.artist.trim()} • ${track.album.trim()}';
    }
    if (track.hasKnownArtist) {
      return track.artist.trim();
    }
    if (track.hasKnownAlbum) {
      return '${l10n.libraryUnknownArtist} • ${track.album.trim()}';
    }
    return l10n.libraryUnknownArtist;
  }
}
