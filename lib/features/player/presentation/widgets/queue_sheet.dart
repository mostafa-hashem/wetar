import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/features/playlists/presentation/bloc/playlists_cubit.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Queue view supporting bottom sheet or desktop side panel, drag-to-reorder,
/// swipe-to-remove with undo, clear queue confirmation, and save-as-playlist.
class QueuePanel extends StatelessWidget {
  const QueuePanel({super.key, this.embedded = false});

  final bool embedded;

  Future<void> _saveQueueAsPlaylist(
    BuildContext context,
    List<WetarTrack> tracks,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.queueSaveAsPlaylist),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.playlistsNameHint),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.isNotEmpty && context.mounted) {
      final cubit = context.read<PlaylistsCubit>();
      final pid = await cubit.createPlaylist(name);
      await cubit.addTracks(pid, tracks);
      if (context.mounted) {
        WetarFeedback.showSuccess(
          context,
          l10n.playlistsImportedCount(tracks.length),
        );
      }
    }
  }

  Future<void> _confirmClearQueue(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.queueClearConfirmTitle),
        content: Text(l10n.queueClearConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: tokens.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<PlayerCubit>().clearQueue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final numerals = context.select((SettingsCubit c) => c.state.numeralStyle);
    final thumbCache = sl<ThumbnailPathCache>();

    return BlocBuilder<PlayerCubit, PlayerStateSnapshot>(
      buildWhen: (p, c) =>
          p.queue != c.queue || p.currentIndex != c.currentIndex,
      builder: (context, state) {
        return Column(
          children: <Widget>[
            if (!embedded)
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
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacingMd,
                vertical: tokens.spacingXs,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      NumeralFormatter.formatString(
                        l10n.queueCount(state.queue.length),
                        numerals,
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (state.queue.isNotEmpty) ...<Widget>[
                    IconButton(
                      tooltip: l10n.queueSaveAsPlaylist,
                      icon: const Icon(Icons.playlist_add_rounded),
                      onPressed: () =>
                          _saveQueueAsPlaylist(context, state.queue),
                    ),
                    IconButton(
                      tooltip: l10n.actionClear,
                      icon: const Icon(Icons.clear_all_rounded),
                      onPressed: () => _confirmClearQueue(context),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: state.queue.isEmpty
                  ? Center(child: Text(l10n.queueEmpty))
                  : ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      itemCount: state.queue.length,
                      onReorderItem: (oldIndex, newIndex) {
                        unawaited(
                          context.read<PlayerCubit>().reorderQueue(
                            oldIndex,
                            newIndex,
                          ),
                        );
                      },
                      itemBuilder: (ctx, i) {
                        final track = state.queue[i];
                        final active = i == state.currentIndex;
                        return Dismissible(
                          key: ValueKey<String>('${track.stableKey}_$i'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            final player = context.read<PlayerCubit>();
                            unawaited(player.removeFromQueueAt(i));
                            WetarFeedback.showUndo(
                              context,
                              message: l10n.queueRemovedUndo,
                              undoLabel: l10n.actionUndo,
                              onUndo: () => player.playNext(track),
                            );
                          },
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: WetarArtworkImage(
                                cacheKey: track.albumKey,
                                size: 42,
                                artworkUri: track.artworkUri,
                                filePath: track.filePath,
                                customArtPath: track.customArtPath,
                                thumbnailCache: thumbCache,
                                decodeSizePx: 128,
                              ),
                              title: Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: active
                                      ? tokens.accentPrimary
                                      : tokens.inkPrimary,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                track.displayArtist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: ReorderableDragStartListener(
                                index: i,
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.drag_handle_rounded),
                                ),
                              ),
                              onTap: () => context
                                  .read<PlayerCubit>()
                                  .skipToQueueIndex(i),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

void showWetarQueueSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => const FractionallySizedBox(
      heightFactor: 0.78,
      child: SafeArea(top: false, child: QueuePanel()),
    ),
  );
}
