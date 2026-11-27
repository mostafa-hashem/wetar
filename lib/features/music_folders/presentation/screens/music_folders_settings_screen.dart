import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/library/presentation/bloc/library_cubit.dart';
import 'package:wetar/features/library/presentation/widgets/track_list_tile.dart';
import 'package:wetar/features/music_folders/domain/music_folder_models.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/music_folders/presentation/screens/folder_picker_screen.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Music Folders view with 1-tap folder playback, folder track browsing,
/// instant folder filter, include-subfolders toggle, exclusions, and rescan/remove.
class MusicFoldersSettingsScreen extends StatefulWidget {
  const MusicFoldersSettingsScreen({
    super.key,
    this.onOpenTrackDetails,
    this.onAddToPlaylistRequested,
  });

  final ValueChanged<WetarTrack>? onOpenTrackDetails;
  final ValueChanged<List<WetarTrack>>? onAddToPlaylistRequested;

  @override
  State<MusicFoldersSettingsScreen> createState() =>
      _MusicFoldersSettingsScreenState();
}

class _MusicFoldersSettingsScreenState
    extends State<MusicFoldersSettingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  LibraryState? _maybeWatchLibrary(BuildContext context) {
    try {
      return BlocProvider.of<LibraryCubit>(context, listen: true).state;
    } catch (_) {
      return null;
    }
  }

  PlayerCubit? _maybeReadPlayer(BuildContext context) {
    try {
      return BlocProvider.of<PlayerCubit>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final caps = sl<PlatformCapabilities>();
    final numerals = context.select((SettingsCubit c) => c.state.numeralStyle);
    final libState = _maybeWatchLibrary(context);
    final playerCubit = _maybeReadPlayer(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.foldersTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.actionRescan,
            onPressed: () => context.read<MusicFoldersCubit>().rescanAll(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: l10n.foldersAddButton,
            onPressed: () async {
              if (caps.supportsInAppFolderPicker) {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FolderPickerScreen(),
                  ),
                );
              } else {
                await context.read<MusicFoldersCubit>().pickSystemFolder();
              }
            },
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<MusicFoldersCubit, MusicFoldersState>(
          builder: (context, state) {
            final cleanQuery = _query.trim().toLowerCase();
            final visibleFolders = cleanQuery.isEmpty
                ? state.selectedFolders
                : state.selectedFolders
                      .where(
                        (f) =>
                            f.displayName.toLowerCase().contains(cleanQuery) ||
                            f.rootPath.toLowerCase().contains(cleanQuery),
                      )
                      .toList();

            return Column(
              children: <Widget>[
                if (state.scanProgress.isScanning)
                  Material(
                    color: tokens.surfaceElevated,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacingMd,
                        vertical: tokens.spacingSm,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  l10n.foldersScanProgress(
                                    state.scanProgress.currentFolderName,
                                    state.scanProgress.processedCount,
                                    state.scanProgress.totalCount,
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                SizedBox(height: tokens.spacingXs),
                                LinearProgressIndicator(
                                  value: state.scanProgress.fraction,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<MusicFoldersCubit>().cancelScan();
                              WetarFeedback.showInfo(
                                context,
                                l10n.foldersScanCancelled,
                              );
                            },
                            child: Text(l10n.actionCancel),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (state.selectedFolders.length >= 5)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      tokens.spacingMd,
                      tokens.spacingSm,
                      tokens.spacingMd,
                      0,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                tooltip: l10n.actionClear,
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        hintText: l10n.foldersSearchHint,
                        filled: true,
                        fillColor: tokens.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            tokens.radiusCard,
                          ),
                          borderSide: BorderSide(color: tokens.borderSubtle),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: state.selectedFolders.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(tokens.spacingLg),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.folder_off_outlined,
                                  size: 56,
                                  color: tokens.accentPrimary,
                                ),
                                SizedBox(height: tokens.spacingMd),
                                Text(
                                  l10n.foldersEmptyTitle,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: tokens.spacingSm),
                                Text(
                                  l10n.foldersEmptySubtitle,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: tokens.inkMuted),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: tokens.spacingLg),
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: tokens.accentPrimary,
                                  ),
                                  onPressed: () async {
                                    if (caps.supportsInAppFolderPicker) {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              const FolderPickerScreen(),
                                        ),
                                      );
                                    } else {
                                      await context
                                          .read<MusicFoldersCubit>()
                                          .pickSystemFolder();
                                    }
                                  },
                                  icon: const Icon(Icons.folder_open_rounded),
                                  label: Text(l10n.foldersChooseCta),
                                ),
                              ],
                            ),
                          ),
                        )
                      : visibleFolders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(l10n.libraryFilteredEmpty),
                              SizedBox(height: tokens.spacingSm),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                                child: Text(l10n.actionClearFilters),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            tokens.spacingMd,
                            tokens.spacingMd,
                            tokens.spacingMd,
                            tokens.spacingLg,
                          ),
                          itemCount: visibleFolders.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: tokens.spacingSm),
                          itemBuilder: (context, index) {
                            final folder = visibleFolders[index];
                            final folderTracks = libState == null
                                ? const <WetarTrack>[]
                                : libState.allTracks
                                      .where((t) => t.folderId == folder.id)
                                      .toList();
                            return _FolderCard(
                              folder: folder,
                              folderTracks: folderTracks,
                              hasLibrary: libState != null,
                              playerCubit: playerCubit,
                              numerals: numerals,
                              onOpenTrackDetails: widget.onOpenTrackDetails,
                              onAddToPlaylistRequested:
                                  widget.onAddToPlaylistRequested,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({
    required this.folder,
    required this.folderTracks,
    required this.hasLibrary,
    required this.playerCubit,
    required this.numerals,
    this.onOpenTrackDetails,
    this.onAddToPlaylistRequested,
  });

  final SelectedFolderEntity folder;
  final List<WetarTrack> folderTracks;
  final bool hasLibrary;
  final PlayerCubit? playerCubit;
  final NumeralStyle numerals;
  final ValueChanged<WetarTrack>? onOpenTrackDetails;
  final ValueChanged<List<WetarTrack>>? onAddToPlaylistRequested;

  Future<void> _showExcludeDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final subDirs = <String>[];
    if (!folder.rootPath.startsWith('content://')) {
      final dir = Directory(folder.rootPath);
      if (dir.existsSync()) {
        await for (final entity in dir.list(followLinks: false)) {
          if (entity is Directory) {
            subDirs.add(entity.path);
          }
        }
      }
    }

    if (!context.mounted) return;
    final selectedExcluded = Set<String>.from(folder.excludedSubfolders);
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: Text(l10n.foldersExcludeSubfolder),
              content: SizedBox(
                width: 360,
                child: subDirs.isEmpty
                    ? Text(l10n.foldersExcludedCount(selectedExcluded.length))
                    : ListView(
                        shrinkWrap: true,
                        children: subDirs.map((path) {
                          final checked = selectedExcluded.contains(path);
                          return CheckboxListTile(
                            value: checked,
                            activeColor: tokens.accentPrimary,
                            title: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                NumeralFormatter.shortenPath(path),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onChanged: (v) {
                              setStateDialog(() {
                                if (v ?? false) {
                                  selectedExcluded.add(path);
                                } else {
                                  selectedExcluded.remove(path);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    await context
                        .read<MusicFoldersCubit>()
                        .setExcludedSubfolders(
                          folder.id,
                          selectedExcluded.toList(),
                        );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: Text(l10n.actionApply),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _removeWithUndo(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<MusicFoldersCubit>();
    await cubit.removeFolder(folder.id);
    if (context.mounted) {
      WetarFeedback.showUndo(
        context,
        message: l10n.foldersRemovedUndo(folder.displayName),
        undoLabel: l10n.actionUndo,
        onUndo: () {
          cubit.addFolderPath(
            rootPath: folder.rootPath,
            displayName: folder.displayName,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: folder.isAvailable && hasLibrary
            ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _FolderTracksScreen(
                    folder: folder,
                    onOpenTrackDetails: onOpenTrackDetails,
                    onAddToPlaylistRequested: onAddToPlaylistRequested,
                  ),
                ),
              )
            : null,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacingMd,
            vertical: tokens.spacingSm * 1.25,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    folder.isAvailable
                        ? Icons.folder_rounded
                        : Icons.folder_off_rounded,
                    color: folder.isAvailable
                        ? tokens.accentPrimary
                        : tokens.danger,
                  ),
                  SizedBox(width: tokens.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          folder.displayName,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            NumeralFormatter.shortenPath(folder.rootPath),
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (folderTracks.isNotEmpty && playerCubit != null)
                    IconButton(
                      tooltip: l10n.foldersPlayFolder,
                      icon: Icon(
                        Icons.play_arrow_rounded,
                        color: tokens.accentPrimary,
                      ),
                      onPressed: () => playerCubit!.playTracks(folderTracks),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (action) async {
                      switch (action) {
                        case 'shuffle':
                          if (folderTracks.isNotEmpty && playerCubit != null) {
                            await playerCubit!.shuffleAll(folderTracks);
                          }
                        case 'subfolders':
                          await context
                              .read<MusicFoldersCubit>()
                              .toggleIncludeSubfolders(
                                folder.id,
                                !folder.includeSubfolders,
                              );
                        case 'exclude':
                          await _showExcludeDialog(context);
                        case 'rescan':
                          await context.read<MusicFoldersCubit>().rescanFolder(
                            folder.id,
                          );
                        case 'remove':
                          await _removeWithUndo(context);
                      }
                    },
                    itemBuilder: (_) => <PopupMenuEntry<String>>[
                      if (folderTracks.isNotEmpty && playerCubit != null)
                        PopupMenuItem<String>(
                          value: 'shuffle',
                          child: Text(l10n.foldersShuffleFolder),
                        ),
                      CheckedPopupMenuItem<String>(
                        value: 'subfolders',
                        checked: folder.includeSubfolders,
                        child: Text(l10n.foldersIncludeSubfolders),
                      ),
                      PopupMenuItem<String>(
                        value: 'exclude',
                        child: Text(l10n.foldersExcludeSubfolder),
                      ),
                      PopupMenuItem<String>(
                        value: 'rescan',
                        child: Text(l10n.actionRescan),
                      ),
                      PopupMenuItem<String>(
                        value: 'remove',
                        child: Text(l10n.actionRemove),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: tokens.spacingXs),
              Wrap(
                spacing: tokens.spacingSm,
                runSpacing: tokens.spacingXs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    NumeralFormatter.formatString(
                      l10n.foldersTrackCount(folder.trackCount),
                      numerals,
                    ),
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: tokens.accentSecondary),
                  ),
                  if (folder.excludedSubfolders.isNotEmpty)
                    Text(
                      '• ${l10n.foldersExcludedCount(folder.excludedSubfolders.length)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                ],
              ),
              if (!folder.isAvailable) ...<Widget>[
                SizedBox(height: tokens.spacingXs),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacingSm,
                    vertical: tokens.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.danger.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                  ),
                  child: Text(
                    l10n.foldersUnavailableBadge,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: tokens.danger),
                  ),
                ),
                SizedBox(height: tokens.spacingXs),
                Text(
                  l10n.foldersUnavailableHint,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: tokens.danger),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderTracksScreen extends StatelessWidget {
  const _FolderTracksScreen({
    required this.folder,
    this.onOpenTrackDetails,
    this.onAddToPlaylistRequested,
  });

  final SelectedFolderEntity folder;
  final ValueChanged<WetarTrack>? onOpenTrackDetails;
  final ValueChanged<List<WetarTrack>>? onAddToPlaylistRequested;

  void _showTrackActionsSheet(BuildContext context, WetarTrack track) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final player = context.read<PlayerCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: SingleChildScrollView(
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
              ListTile(
                leading: const Icon(Icons.playlist_play_rounded),
                title: Text(l10n.actionPlayNext),
                onTap: () {
                  player.playNext(track);
                  Navigator.of(ctx).pop();
                  WetarFeedback.showSuccess(context, l10n.actionPlayNext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.queue_music_rounded),
                title: Text(l10n.actionAddToQueue),
                onTap: () {
                  player.addToQueue(<WetarTrack>[track]);
                  Navigator.of(ctx).pop();
                  WetarFeedback.showSuccess(context, l10n.actionAddToQueue);
                },
              ),
              if (onAddToPlaylistRequested != null)
                ListTile(
                  leading: const Icon(Icons.playlist_add_rounded),
                  title: Text(l10n.actionAddToPlaylist),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onAddToPlaylistRequested!(<WetarTrack>[track]);
                  },
                ),
              ListTile(
                leading: Icon(
                  track.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: track.isFavorite ? tokens.accentPrimary : null,
                ),
                title: Text(
                  track.isFavorite
                      ? l10n.actionUnfavorite
                      : l10n.actionFavorite,
                ),
                onTap: () {
                  context.read<LibraryCubit>().toggleFavorite(track.stableKey);
                  Navigator.of(ctx).pop();
                },
              ),
              if (onOpenTrackDetails != null)
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(l10n.playerTrackDetails),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onOpenTrackDetails!(track);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final showArt = context.select(
      (PersonalizationCubit c) => c.state.settings.showArtworkInLists,
    );
    final numerals = context.select((SettingsCubit c) => c.state.numeralStyle);
    final minDurationSec = context.select(
      (SettingsCubit c) => c.state.minTrackDurationSec,
    );
    final currentTrackKey = context.select(
      (PlayerCubit c) => c.state.currentTrack?.stableKey,
    );
    final tracks = context.select(
      (LibraryCubit c) =>
          c.state.sortedTracks.where((t) => t.folderId == folder.id).toList(),
    );
    final thumbCache = sl<ThumbnailPathCache>();
    final textScale = MediaQuery.textScalerOf(context).scale(14.0) / 14.0;
    final effectiveExtent = textScale > 1.2
        ? tokens.listRowExtent * (textScale * 0.72).clamp(1.0, 1.55)
        : tokens.listRowExtent;

    return Scaffold(
      appBar: AppBar(
        title: Text(folder.displayName),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.actionShuffleAll,
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: tracks.isEmpty
                ? null
                : () => context.read<PlayerCubit>().shuffleAll(tracks),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: tracks.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacingLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        l10n.libraryFilteredEmpty,
                        textAlign: TextAlign.center,
                      ),
                      if (folder.trackCount > 0 &&
                          minDurationSec > 0) ...<Widget>[
                        SizedBox(height: tokens.spacingSm),
                        Text(
                          l10n.playbackMinDuration(minDurationSec),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: tokens.inkMuted),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: tokens.spacingMd),
                        FilledButton.tonal(
                          onPressed: () {
                            final settings = context.read<SettingsCubit>();
                            settings.update(
                              settings.state.copyWith(minTrackDurationSec: 0),
                            );
                          },
                          child: Text(l10n.playbackMinDuration(0)),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.only(bottom: tokens.spacingLg),
                itemExtent: effectiveExtent,
                itemCount: tracks.length,
                itemBuilder: (ctx, i) {
                  final track = tracks[i];
                  return TrackListTile(
                    key: ValueKey<String>(track.stableKey),
                    track: track,
                    isPlayingTrack: track.stableKey == currentTrackKey,
                    showArtwork: showArt,
                    numeralStyle: numerals,
                    thumbnailCache: thumbCache,
                    onTap: () => context.read<PlayerCubit>().playTracks(
                      tracks,
                      index: i,
                    ),
                    onMorePressed: () => _showTrackActionsSheet(ctx, track),
                  );
                },
              ),
      ),
    );
  }
}
