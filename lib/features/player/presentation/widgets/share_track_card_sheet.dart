import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/storage/cache_manager.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Allows sharing either a clean generated track card PNG or the local audio file.
void showShareTrackCardSheet(BuildContext context, WetarTrack track) {
  final l10n = AppLocalizations.of(context);
  final tokens = context.wetarTokens;
  final cardKey = GlobalKey();
  final thumbCache = sl<ThumbnailPathCache>();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RepaintBoundary(
              key: cardKey,
              child: Container(
                padding: EdgeInsets.all(tokens.spacingLg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      tokens.surfaceElevated,
                      Color.lerp(tokens.canvas, tokens.accentPrimary, 0.25)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(tokens.radiusCard * 1.2),
                  border: Border.all(
                    color: tokens.accentPrimary.withValues(alpha: 0.45),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    WetarArtworkImage(
                      cacheKey: track.albumKey,
                      size: 160,
                      artworkUri: track.artworkUri,
                      filePath: track.filePath,
                      customArtPath: track.customArtPath,
                      thumbnailCache: thumbCache,
                      decodeSizePx: 360,
                    ),
                    SizedBox(height: tokens.spacingMd),
                    Text(
                      track.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(ctx).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.displayArtist,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(ctx).textTheme.bodyMedium
                          ?.copyWith(color: tokens.inkMuted),
                    ),
                    SizedBox(height: tokens.spacingMd),
                    Text(
                      '${l10n.appName} • ${track.displayAlbum}',
                      style: Theme.of(ctx).textTheme.labelSmall
                          ?.copyWith(color: tokens.accentPrimary),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: tokens.spacingMd),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: tokens.accentPrimary,
                    ),
                    onPressed: () async {
                      final boundary =
                          cardKey.currentContext?.findRenderObject()
                              as RenderRepaintBoundary?;
                      if (boundary == null) return;
                      final image = await boundary.toImage(pixelRatio: 2.5);
                      final data = await image.toByteData(
                        format: ui.ImageByteFormat.png,
                      );
                      image.dispose();
                      if (data == null) return;
                      final cache = sl<CacheManager>();
                      await cache.init();
                      final outPath = p.join(
                        cache.exportsDir.path,
                        'wetar_card_${DateTime.now().millisecondsSinceEpoch}.png',
                      );
                      await File(outPath)
                          .writeAsBytes(data.buffer.asUint8List(), flush: true);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                      await sl<FolderPickerService>().shareFiles(
                        paths: <String>[outPath],
                        mimeType: 'image/png',
                        subject: track.title,
                      );
                    },
                    icon: const Icon(Icons.image_outlined),
                    label: Text(l10n.playerShareCard),
                  ),
                ),
                if (!track.filePath.startsWith('content://') &&
                    File(track.filePath).existsSync()) ...<Widget>[
                  SizedBox(width: tokens.spacingSm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        await sl<FolderPickerService>().shareFiles(
                          paths: <String>[track.filePath],
                          mimeType: track.mimeType,
                          subject: track.title,
                        );
                      },
                      icon: const Icon(Icons.audio_file_outlined),
                      label: Text(l10n.playerShareFile),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
