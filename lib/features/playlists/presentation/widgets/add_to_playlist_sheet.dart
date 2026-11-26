import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/playlists/presentation/bloc/playlists_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Bottom sheet allowing the user to pick an existing playlist or create a new one.
void showAddToPlaylistSheet(
  BuildContext context, {
  required List<WetarTrack> tracks,
}) {
  if (tracks.isEmpty) return;
  final l10n = AppLocalizations.of(context);
  final tokens = context.wetarTokens;
  final cubit = context.read<PlaylistsCubit>();

  showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: BlocProvider<PlaylistsCubit>.value(
        value: cubit,
        child: BlocBuilder<PlaylistsCubit, PlaylistsState>(
          builder: (ctx, state) {
            return Column(
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
                ListTile(
                  leading: Icon(Icons.add_rounded, color: tokens.accentPrimary),
                  title: Text(l10n.playlistsCreate),
                  onTap: () async {
                    final ctrl = TextEditingController();
                    final name = await showDialog<String>(
                      context: ctx,
                      builder: (dCtx) => AlertDialog(
                        title: Text(l10n.playlistsCreate),
                        content: TextField(
                          controller: ctrl,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: l10n.playlistsNameHint,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(dCtx).pop(),
                            child: Text(l10n.actionCancel),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.of(dCtx).pop(ctrl.text.trim()),
                            child: Text(l10n.actionSave),
                          ),
                        ],
                      ),
                    );
                    ctrl.dispose();
                    if (name != null && name.isNotEmpty) {
                      final pid = await cubit.createPlaylist(name);
                      await cubit.addTracks(pid, tracks);
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                        WetarFeedback.showSuccess(
                          context,
                          l10n.playlistsImportedCount(tracks.length),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                for (final pl in state.playlists)
                  ListTile(
                    leading: const Icon(Icons.queue_music_rounded),
                    title: Text(pl.name),
                    subtitle: Text(l10n.foldersTrackCount(pl.trackCount)),
                    onTap: () async {
                      await cubit.addTracks(pl.id, tracks);
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                        WetarFeedback.showSuccess(
                          context,
                          l10n.playlistsImportedCount(tracks.length),
                        );
                      }
                    },
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
