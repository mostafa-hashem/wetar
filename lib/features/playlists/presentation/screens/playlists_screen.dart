import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/library/presentation/widgets/track_list_tile.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/features/playlists/data/playlists_repository.dart';
import 'package:wetar/features/playlists/presentation/bloc/playlists_cubit.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Playlists hub featuring Smart Playlists, User Playlists with 2x2 cover collage,
/// create/rename/delete, drag-to-reorder, and M3U import/export.
class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({
    super.key,
    this.embedded = false,
    this.onOpenTrackDetails,
  });

  final bool embedded;
  final ValueChanged<WetarTrack>? onOpenTrackDetails;

  Future<void> _createDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.playlistsCreate),
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
      await context.read<PlaylistsCubit>().createPlaylist(name);
    }
  }

  Future<void> _importM3u(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final picked = await sl<FolderPickerService>().pickFile(
      mimeTypes: const <String>[
        'audio/x-mpegurl',
        'application/x-mpegurl',
        '*/*',
      ],
    );
    if (picked == null || !context.mounted) return;
    final count = await context.read<PlaylistsCubit>().importM3u(picked);
    if (context.mounted) {
      WetarFeedback.showSuccess(context, l10n.playlistsImportedCount(count));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final numerals = context.select((SettingsCubit c) => c.state.numeralStyle);
    final minDur = context.select(
      (SettingsCubit c) => c.state.minTrackDurationSec,
    );

    final smartItems = <(SmartPlaylistKind, String, IconData)>[
      (
        SmartPlaylistKind.mostPlayed,
        l10n.playlistsSmartMostPlayed,
        Icons.trending_up_rounded,
      ),
      (
        SmartPlaylistKind.recentlyAdded,
        l10n.playlistsSmartRecentlyAdded,
        Icons.fiber_new_rounded,
      ),
      (
        SmartPlaylistKind.neverPlayed,
        l10n.playlistsSmartNeverPlayed,
        Icons.hourglass_empty_rounded,
      ),
      (
        SmartPlaylistKind.longTracks,
        l10n.playlistsSmartLongTracks,
        Icons.menu_book_rounded,
      ),
    ];

    final content = BlocBuilder<PlaylistsCubit, PlaylistsState>(
      builder: (context, state) {
        return ListView(
          padding: EdgeInsets.fromLTRB(
            tokens.spacingMd,
            tokens.spacingMd,
            tokens.spacingMd,
            tokens.spacingLg,
          ),
          children: <Widget>[
            Wrap(
              spacing: tokens.spacingSm,
              runSpacing: tokens.spacingSm,
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: () => _createDialog(context),
                  icon: const Icon(Icons.playlist_add_rounded),
                  label: Text(l10n.playlistsCreate),
                ),
                OutlinedButton.icon(
                  onPressed: () => _importM3u(context),
                  icon: const Icon(Icons.file_open_outlined),
                  label: Text(l10n.playlistsImportM3u),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingLg),
            Text(
              l10n.playlistsSmartTitle,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: tokens.accentPrimary),
            ),
            SizedBox(height: tokens.spacingSm),
            for (final item in smartItems)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: tokens.surfaceElevated,
                  child: Icon(item.$3, color: tokens.accentSecondary),
                ),
                title: Text(
                  item.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final tracks = await context
                      .read<PlaylistsCubit>()
                      .loadSmartTracks(item.$1, minDurationSec: minDur);
                  if (!context.mounted) return;
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _PlaylistTracksView(
                        title: item.$2,
                        initialTracks: tracks,
                        onOpenTrackDetails: onOpenTrackDetails,
                      ),
                    ),
                  );
                },
              ),
            SizedBox(height: tokens.spacingLg),
            Text(
              l10n.playlistsUserTitle,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: tokens.accentPrimary),
            ),
            SizedBox(height: tokens.spacingSm),
            if (state.playlists.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: tokens.spacingLg),
                child: Center(child: Text(l10n.playlistsEmpty)),
              )
            else
              for (final pl in state.playlists)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: PlaylistCollageCover(
                    tracks: pl.coverTracks,
                    size: 52,
                  ),
                  title: Text(
                    pl.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    NumeralFormatter.formatString(
                      l10n.foldersTrackCount(pl.trackCount),
                      numerals,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action == 'rename') {
                        final ctrl = TextEditingController(text: pl.name);
                        final renamed = await showDialog<String>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.actionRename),
                            content: TextField(
                              controller: ctrl,
                              autofocus: true,
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text(l10n.actionCancel),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(ctrl.text.trim()),
                                child: Text(l10n.actionSave),
                              ),
                            ],
                          ),
                        );
                        ctrl.dispose();
                        if (renamed != null &&
                            renamed.isNotEmpty &&
                            context.mounted) {
                          await context.read<PlaylistsCubit>().renamePlaylist(
                            pl.id,
                            renamed,
                          );
                        }
                      } else if (action == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.playlistsDeleteTitle),
                            content: Text(l10n.playlistsDeleteBody(pl.name)),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text(l10n.actionCancel),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: tokens.danger,
                                ),
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text(l10n.actionDelete),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await context.read<PlaylistsCubit>().deletePlaylist(
                            pl.id,
                          );
                        }
                      }
                    },
                    itemBuilder: (_) => <PopupMenuEntry<String>>[
                      PopupMenuItem(
                        value: 'rename',
                        child: Text(l10n.actionRename),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.actionDelete),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final tracks = await context
                        .read<PlaylistsCubit>()
                        .loadTracks(pl.id);
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => _PlaylistTracksView(
                          playlistId: pl.id,
                          title: pl.name,
                          initialTracks: tracks,
                          onOpenTrackDetails: onOpenTrackDetails,
                        ),
                      ),
                    );
                  },
                ),
          ],
        );
      },
    );

    if (embedded) return content;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navPlaylists)),
      body: SafeArea(top: false, child: content),
    );
  }
}

/// Auto-generated 2x2 album artwork collage for playlists.
class PlaylistCollageCover extends StatelessWidget {
  const PlaylistCollageCover({
    super.key,
    required this.tracks,
    required this.size,
  });

  final List<WetarTrack> tracks;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wetarTokens;
    final thumbCache = sl<ThumbnailPathCache>();

    if (tracks.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(tokens.radiusCard * 0.75),
        ),
        child: Icon(Icons.queue_music_rounded, color: tokens.accentPrimary),
      );
    }
    if (tracks.length < 4) {
      final first = tracks.first;
      return WetarArtworkImage(
        cacheKey: first.albumKey,
        size: size,
        artworkUri: first.artworkUri,
        filePath: first.filePath,
        customArtPath: first.customArtPath,
        thumbnailCache: thumbCache,
        decodeSizePx: 144,
      );
    }

    final tile = size / 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusCard * 0.75),
      child: SizedBox(
        width: size,
        height: size,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                WetarArtworkImage(
                  cacheKey: tracks[0].albumKey,
                  size: tile,
                  artworkUri: tracks[0].artworkUri,
                  filePath: tracks[0].filePath,
                  customArtPath: tracks[0].customArtPath,
                  thumbnailCache: thumbCache,
                  borderRadius: BorderRadius.zero,
                  decodeSizePx: 96,
                ),
                WetarArtworkImage(
                  cacheKey: tracks[1].albumKey,
                  size: tile,
                  artworkUri: tracks[1].artworkUri,
                  filePath: tracks[1].filePath,
                  customArtPath: tracks[1].customArtPath,
                  thumbnailCache: thumbCache,
                  borderRadius: BorderRadius.zero,
                  decodeSizePx: 96,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                WetarArtworkImage(
                  cacheKey: tracks[2].albumKey,
                  size: tile,
                  artworkUri: tracks[2].artworkUri,
                  filePath: tracks[2].filePath,
                  customArtPath: tracks[2].customArtPath,
                  thumbnailCache: thumbCache,
                  borderRadius: BorderRadius.zero,
                  decodeSizePx: 96,
                ),
                WetarArtworkImage(
                  cacheKey: tracks[3].albumKey,
                  size: tile,
                  artworkUri: tracks[3].artworkUri,
                  filePath: tracks[3].filePath,
                  customArtPath: tracks[3].customArtPath,
                  thumbnailCache: thumbCache,
                  borderRadius: BorderRadius.zero,
                  decodeSizePx: 96,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistTracksView extends StatefulWidget {
  const _PlaylistTracksView({
    this.playlistId,
    required this.title,
    required this.initialTracks,
    this.onOpenTrackDetails,
  });

  final int? playlistId;
  final String title;
  final List<WetarTrack> initialTracks;
  final ValueChanged<WetarTrack>? onOpenTrackDetails;

  @override
  State<_PlaylistTracksView> createState() => _PlaylistTracksViewState();
}

class _PlaylistTracksViewState extends State<_PlaylistTracksView> {
  late List<WetarTrack> _tracks;

  @override
  void initState() {
    super.initState();
    _tracks = List<WetarTrack>.from(widget.initialTracks);
  }

  Future<void> _exportM3u() async {
    final m3uText = PlaylistsRepository.encodeM3u(widget.title, _tracks);
    final bytes = Uint8List.fromList(utf8.encode(m3uText));
    final ok = await sl<FolderPickerService>().saveFile(
      fileName: '${widget.title}.m3u8',
      mimeType: 'audio/x-mpegurl',
      bytes: bytes,
    );
    if (ok && mounted) {
      WetarFeedback.showSuccess(
        context,
        AppLocalizations.of(context).playlistsExportM3u,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final numerals = context.select((SettingsCubit c) => c.state.numeralStyle);
    final thumbCache = sl<ThumbnailPathCache>();
    final textScale = MediaQuery.textScalerOf(context).scale(14.0) / 14.0;
    final effectiveExtent = textScale > 1.2
        ? tokens.listRowExtent * (textScale * 0.72).clamp(1.0, 1.55)
        : tokens.listRowExtent;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.actionShuffleAll,
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: () => context.read<PlayerCubit>().shuffleAll(_tracks),
          ),
          IconButton(
            tooltip: l10n.playlistsExportM3u,
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: _tracks.isEmpty ? null : _exportM3u,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _tracks.isEmpty
            ? Center(child: Text(l10n.libraryFilteredEmpty))
            : widget.playlistId == null
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: tokens.spacingLg),
                itemExtent: effectiveExtent,
                itemCount: _tracks.length,
                itemBuilder: (ctx, i) => TrackListTile(
                  track: _tracks[i],
                  isPlayingTrack: false,
                  showArtwork: true,
                  numeralStyle: numerals,
                  thumbnailCache: thumbCache,
                  onTap: () =>
                      context.read<PlayerCubit>().playTracks(_tracks, index: i),
                  onMorePressed: widget.onOpenTrackDetails == null
                      ? null
                      : () => widget.onOpenTrackDetails!(_tracks[i]),
                ),
              )
            : ReorderableListView.builder(
                padding: EdgeInsets.only(bottom: tokens.spacingLg),
                itemExtent: effectiveExtent,
                itemCount: _tracks.length,
                onReorderItem: (oldIndex, newIndex) async {
                  if (oldIndex < 0 || oldIndex >= _tracks.length) return;
                  setState(() {
                    final moved = _tracks.removeAt(oldIndex);
                    final safeNew = newIndex.clamp(0, _tracks.length);
                    _tracks.insert(safeNew, moved);
                  });
                  await context.read<PlaylistsCubit>().reorderTracks(
                    widget.playlistId!,
                    _tracks,
                  );
                },
                itemBuilder: (ctx, i) {
                  final t = _tracks[i];
                  return Dismissible(
                    key: ValueKey<String>(t.stableKey),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) async {
                      final removed = _tracks[i];
                      setState(() => _tracks.removeAt(i));
                      await context.read<PlaylistsCubit>().removeTrack(
                        widget.playlistId!,
                        removed.stableKey,
                      );
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: TrackListTile(
                        track: t,
                        isPlayingTrack: false,
                        showArtwork: true,
                        numeralStyle: numerals,
                        thumbnailCache: thumbCache,
                        onTap: () => context.read<PlayerCubit>().playTracks(
                          _tracks,
                          index: i,
                        ),
                        onMorePressed: widget.onOpenTrackDetails == null
                            ? null
                            : () => widget.onOpenTrackDetails!(t),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
