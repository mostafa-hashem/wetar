import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/features/library/data/library_repository.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/personalization/data/custom_image_processor.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Displays audio format, bitrate, sample rate, duration, file size, copyable LTR path,
/// ReplayGain tags, and custom album art picker.
void showTrackDetailsSheet(
  BuildContext context, {
  required WetarTrack track,
  required NumeralStyle numerals,
}) {
  final l10n = AppLocalizations.of(context);
  final tokens = context.wetarTokens;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.inkMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                ),
              ),
            ),
            SizedBox(height: tokens.spacingMd),
            Text(
              track.title,
              style: Theme.of(ctx).textTheme.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${track.displayArtist} • ${track.displayAlbum}',
              style: Theme.of(ctx).textTheme.bodyMedium
                  ?.copyWith(color: tokens.inkMuted),
            ),
            SizedBox(height: tokens.spacingMd),
            _DetailRow(label: l10n.detailsFormat, value: track.mimeType),
            _DetailRow(
              label: l10n.detailsBitrate,
              value: track.bitrateKbps > 0
                  ? NumeralFormatter.formatString(
                      '${track.bitrateKbps} kbps',
                      numerals,
                    )
                  : '—',
            ),
            _DetailRow(
              label: l10n.detailsSampleRate,
              value: track.sampleRateHz > 0
                  ? NumeralFormatter.formatString(
                      '${track.sampleRateHz} Hz',
                      numerals,
                    )
                  : '—',
            ),
            _DetailRow(
              label: l10n.detailsChannels,
              value: NumeralFormatter.formatInt(track.channels, numerals),
            ),
            _DetailRow(
              label: l10n.detailsDuration,
              value: NumeralFormatter.formatDuration(track.duration, numerals),
            ),
            _DetailRow(
              label: l10n.detailsFileSize,
              value: NumeralFormatter.formatBytes(track.sizeBytes, numerals),
            ),
            _DetailRow(
              label: l10n.detailsReplayGain,
              value: track.replayGainTrackDb != null
                  ? '${track.replayGainTrackDb!.toStringAsFixed(2)} dB'
                  : '—',
            ),
            SizedBox(height: tokens.spacingSm),
            Text(
              l10n.detailsFilePath,
              style: Theme.of(ctx).textTheme.labelSmall,
            ),
            SizedBox(height: tokens.spacingXs),
            Container(
              padding: EdgeInsets.all(tokens.spacingSm),
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: BorderRadius.circular(tokens.radiusCard * 0.75),
                border: Border.all(color: tokens.borderSubtle),
              ),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SelectableText(
                  track.filePath,
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
              ),
            ),
            SizedBox(height: tokens.spacingMd),
            Wrap(
              spacing: tokens.spacingSm,
              runSpacing: tokens.spacingSm,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: track.filePath),
                    );
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      WetarFeedback.showSuccess(
                        context,
                        l10n.detailsPathCopied,
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(l10n.detailsCopyPath),
                ),
                if (!track.isTemporaryExternal)
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      final picked = await sl<FolderPickerService>().pickFile(
                        mimeTypes: const <String>['image/*'],
                      );
                      if (picked == null) return;
                      final stored = await sl<CustomImageProcessor>()
                          .processAndStoreAlbumArt(picked, track.stableKey);
                      if (stored != null) {
                        await sl<LibraryRepository>().setCustomArtPath(
                          track.stableKey,
                          stored,
                        );
                        sl<ThumbnailPathCache>().invalidate(track.albumKey);
                      }
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
                    icon: const Icon(Icons.image_outlined),
                    label: Text(l10n.playerChooseCustomArt),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wetarTokens;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: tokens.inkMuted),
          ),
          SizedBox(width: tokens.spacingMd),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
