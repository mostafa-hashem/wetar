import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/utils/arabic_normalizer.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/features/library/data/library_repository.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/library/presentation/bloc/library_cubit.dart';
import 'package:wetar/features/library/presentation/screens/search_screen.dart';
import 'package:wetar/features/library/presentation/widgets/track_list_tile.dart';
import 'package:wetar/features/library/presentation/widgets/wetar_fast_scrollbar.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/music_folders/presentation/screens/folder_picker_screen.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/features/playlists/presentation/screens/playlists_screen.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Multi-facet folder-scoped music library supporting List & Grid views,
/// fixed-extent lazy scrolling, fast alphabet rail, sort, and multi-select.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.onOpenTrackDetails,
    required this.onAddToPlaylistRequested,
  });

  final ValueChanged<WetarTrack> onOpenTrackDetails;
  final ValueChanged<List<WetarTrack>> onAddToPlaylistRequested;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _categoryLabel(AppLocalizations l10n, LibraryCategory cat) {
    return switch (cat) {
      LibraryCategory.songs => l10n.tabSongs,
      LibraryCategory.albums => l10n.tabAlbums,
      LibraryCategory.artists => l10n.tabArtists,
      LibraryCategory.albumArtists => l10n.tabAlbumArtists,
      LibraryCategory.genres => l10n.tabGenres,
      LibraryCategory.years => l10n.tabYears,
      LibraryCategory.folders => l10n.tabFolders,
      LibraryCategory.playlists => l10n.tabPlaylists,
      LibraryCategory.favorites => l10n.tabFavorites,
      LibraryCategory.recentlyAdded => l10n.tabRecentlyAdded,
      LibraryCategory.recentlyPlayed => l10n.tabRecentlyPlayed,
      LibraryCategory.mostPlayed => l10n.tabMostPlayed,
    };
  }

  void _showSortSheet(BuildContext context, LibraryState libState) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final fields = <(LibrarySortField, String)>[
          (LibrarySortField.title, l10n.librarySortTitle),
          (LibrarySortField.artist, l10n.librarySortArtist),
          (LibrarySortField.album, l10n.librarySortAlbum),
          (LibrarySortField.dateAdded, l10n.librarySortDateAdded),
          (LibrarySortField.duration, l10n.librarySortDuration),
          (LibrarySortField.playCount, l10n.librarySortPlayCount),
        ];
        return SafeArea(
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.spacingMd),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.librarySortBy,
                      style: Theme.of(ctx).textTheme.titleMedium,
                    ),
                  ),
                ),
                for (final item in fields)
                  ListTile(
                    title: Text(item.$2),
                    trailing: libState.sortField == item.$1
                        ? Icon(
                            libState.ascending
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: tokens.accentPrimary,
                          )
                        : null,
                    onTap: () {
                      context.read<LibraryCubit>().setSort(item.$1);
                      Navigator.of(ctx).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTrackActionsSheet(BuildContext context, WetarTrack track) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final player = context.read<PlayerCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
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
                ListTile(
                  leading: const Icon(Icons.playlist_add_rounded),
                  title: Text(l10n.actionAddToPlaylist),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    widget.onAddToPlaylistRequested(<WetarTrack>[track]);
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
                    context.read<LibraryCubit>().toggleFavorite(
                      track.stableKey,
                    );
                    Navigator.of(ctx).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(l10n.playerTrackDetails),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    widget.onOpenTrackDetails(track);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final appearance = context.select(
      (PersonalizationCubit c) => c.state.settings,
    );
    final playbackSettings = context.select((SettingsCubit c) => c.state);
    final foldersState = context.watch<MusicFoldersCubit>().state;
    final currentTrackKey = context.select(
      (PlayerCubit c) => c.state.currentTrack?.stableKey,
    );
    final thumbCache = sl<ThumbnailPathCache>();

    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, libState) {
        if (libState.isSelectionMode) {
          final selectedTracks = libState.allTracks
              .where((t) => libState.selectedKeys.contains(t.stableKey))
              .toList();
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.read<LibraryCubit>().clearSelection(),
              ),
              title: Text(
                NumeralFormatter.formatString(
                  l10n.librarySelectedCount(libState.selectedKeys.length),
                  playbackSettings.numeralStyle,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  tooltip: l10n.actionSelectAll,
                  icon: const Icon(Icons.select_all_rounded),
                  onPressed: () =>
                      context.read<LibraryCubit>().selectAllVisible(),
                ),
                IconButton(
                  tooltip: l10n.actionPlay,
                  icon: const Icon(Icons.play_arrow_rounded),
                  onPressed: () {
                    context.read<PlayerCubit>().playTracks(selectedTracks);
                    context.read<LibraryCubit>().clearSelection();
                  },
                ),
                IconButton(
                  tooltip: l10n.actionAddToQueue,
                  icon: const Icon(Icons.queue_music_rounded),
                  onPressed: () {
                    context.read<PlayerCubit>().addToQueue(selectedTracks);
                    context.read<LibraryCubit>().clearSelection();
                  },
                ),
                IconButton(
                  tooltip: l10n.actionAddToPlaylist,
                  icon: const Icon(Icons.playlist_add_rounded),
                  onPressed: () {
                    widget.onAddToPlaylistRequested(selectedTracks);
                    context.read<LibraryCubit>().clearSelection();
                  },
                ),
                IconButton(
                  tooltip: l10n.actionFavorite,
                  icon: const Icon(Icons.favorite_rounded),
                  onPressed: () =>
                      context.read<LibraryCubit>().favoriteSelected(),
                ),
              ],
            ),
            body: SafeArea(
              top: false,
              child: _buildTrackCollection(
                context,
                libState.sortedTracks,
                libState,
                appearance,
                playbackSettings.numeralStyle,
                currentTrackKey,
                thumbCache,
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.navLibrary),
            actions: <Widget>[
              IconButton(
                tooltip: l10n.actionSearch,
                icon: const Icon(Icons.search_rounded),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SearchScreen(
                      onOpenTrackDetails: widget.onOpenTrackDetails,
                      onAddToPlaylistRequested: widget.onAddToPlaylistRequested,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.libraryViewMode,
                icon: Icon(
                  appearance.useGridInLibrary
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                ),
                onPressed: () =>
                    context.read<PersonalizationCubit>().updateSettings(
                      appearance.copyWith(
                        useGridInLibrary: !appearance.useGridInLibrary,
                      ),
                    ),
              ),
              IconButton(
                tooltip: l10n.librarySortBy,
                icon: const Icon(Icons.sort_rounded),
                onPressed: () => _showSortSheet(context, libState),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: tokens.spacingMd),
                    itemCount: LibraryCategory.values.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(width: tokens.spacingSm),
                    itemBuilder: (context, index) {
                      final cat = LibraryCategory.values[index];
                      final selected = libState.activeCategory == cat;
                      return ChoiceChip(
                        selected: selected,
                        label: Text(_categoryLabel(l10n, cat)),
                        selectedColor: tokens.accentPrimary.withValues(
                          alpha: 0.2,
                        ),
                        onSelected: (_) =>
                            context.read<LibraryCubit>().setCategory(cat),
                      );
                    },
                  ),
                ),
                SizedBox(height: tokens.spacingXs),
                Expanded(
                  child: foldersState.selectedFolders.isEmpty
                      ? _EmptyNoFoldersView()
                      : libState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildCategoryBody(
                          context,
                          libState,
                          appearance,
                          playbackSettings.artistSeparators,
                          playbackSettings.numeralStyle,
                          currentTrackKey,
                          thumbCache,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryBody(
    BuildContext context,
    LibraryState libState,
    AppearanceSettings appearance,
    List<String> artistSeparators,
    NumeralStyle numerals,
    String? currentTrackKey,
    ThumbnailPathCache thumbCache,
  ) {
    final l10n = AppLocalizations.of(context);

    switch (libState.activeCategory) {
      case LibraryCategory.songs:
        return _buildTrackCollection(
          context,
          libState.sortedTracks,
          libState,
          appearance,
          numerals,
          currentTrackKey,
          thumbCache,
        );
      case LibraryCategory.favorites:
        return _buildTrackCollection(
          context,
          libState.favoriteTracks,
          libState,
          appearance,
          numerals,
          currentTrackKey,
          thumbCache,
        );
      case LibraryCategory.recentlyAdded:
        return _buildTrackCollection(
          context,
          libState.recentlyAddedTracks,
          libState,
          appearance,
          numerals,
          currentTrackKey,
          thumbCache,
        );
      case LibraryCategory.recentlyPlayed:
        return _buildTrackCollection(
          context,
          libState.recentlyPlayedTracks,
          libState,
          appearance,
          numerals,
          currentTrackKey,
          thumbCache,
        );
      case LibraryCategory.mostPlayed:
        return _buildTrackCollection(
          context,
          libState.mostPlayedTracks,
          libState,
          appearance,
          numerals,
          currentTrackKey,
          thumbCache,
        );
      case LibraryCategory.albums:
        final albums = LibraryRepository.groupAlbums(
          libState.allTracks,
          fallbackAlbum: l10n.libraryUnknownAlbum,
          fallbackArtist: l10n.libraryUnknownArtist,
        );
        return _GroupCollectionView<AlbumGroup>(
          items: albums,
          useGrid: appearance.useGridInLibrary,
          gridColumns: appearance.gridColumns,
          titleOf: (a) => a.name,
          subtitleOf: (a) =>
              '${a.artist} • ${l10n.foldersTrackCount(a.trackCount)}',
          artworkTrackOf: (a) => a.representative,
          thumbnailCache: thumbCache,
          onTap: (a) => _openTrackGroupScreen(context, a.name, a.tracks),
        );
      case LibraryCategory.artists:
      case LibraryCategory.albumArtists:
        final artists = LibraryRepository.groupArtists(
          libState.allTracks,
          separators: artistSeparators,
          useAlbumArtist:
              libState.activeCategory == LibraryCategory.albumArtists,
          fallbackArtist: l10n.libraryUnknownArtist,
        );
        return _GroupCollectionView<ArtistGroup>(
          items: artists,
          useGrid: appearance.useGridInLibrary,
          gridColumns: appearance.gridColumns,
          titleOf: (a) => a.name,
          subtitleOf: (a) => l10n.foldersTrackCount(a.tracks.length),
          artworkTrackOf: (a) => a.representative,
          thumbnailCache: thumbCache,
          onTap: (a) => _openTrackGroupScreen(context, a.name, a.tracks),
        );
      case LibraryCategory.genres:
        final genres = LibraryRepository.groupGenres(
          libState.allTracks,
          fallbackGenre: l10n.libraryUnknownGenre,
        );
        return _GroupCollectionView<FacetGroup>(
          items: genres,
          useGrid: appearance.useGridInLibrary,
          gridColumns: appearance.gridColumns,
          titleOf: (g) => g.label,
          subtitleOf: (g) => l10n.foldersTrackCount(g.tracks.length),
          artworkTrackOf: (g) => g.tracks.firstOrNull,
          thumbnailCache: thumbCache,
          onTap: (g) => _openTrackGroupScreen(context, g.label, g.tracks),
        );
      case LibraryCategory.years:
        final years = LibraryRepository.groupYears(libState.allTracks);
        return _GroupCollectionView<FacetGroup>(
          items: years,
          useGrid: appearance.useGridInLibrary,
          gridColumns: appearance.gridColumns,
          titleOf: (g) => NumeralFormatter.formatString(g.label, numerals),
          subtitleOf: (g) => l10n.foldersTrackCount(g.tracks.length),
          artworkTrackOf: (g) => g.tracks.firstOrNull,
          thumbnailCache: thumbCache,
          onTap: (g) => _openTrackGroupScreen(context, g.label, g.tracks),
        );
      case LibraryCategory.folders:
        final byFolder = <String, List<WetarTrack>>{};
        for (final t in libState.allTracks) {
          byFolder.putIfAbsent(t.folderPath, () => <WetarTrack>[]).add(t);
        }
        final folderGroups =
            byFolder.entries
                .map(
                  (e) => FacetGroup(
                    label: NumeralFormatter.shortenPath(e.key),
                    tracks: e.value,
                  ),
                )
                .toList()
              ..sort((a, b) => a.label.compareTo(b.label));
        return _GroupCollectionView<FacetGroup>(
          items: folderGroups,
          useGrid: appearance.useGridInLibrary,
          gridColumns: appearance.gridColumns,
          titleOf: (g) => g.label.split('/').last,
          subtitleOf: (g) =>
              '${g.label} • ${l10n.foldersTrackCount(g.tracks.length)}',
          artworkTrackOf: (g) => g.tracks.firstOrNull,
          thumbnailCache: thumbCache,
          onTap: (g) =>
              _openTrackGroupScreen(context, g.label.split('/').last, g.tracks),
        );
      case LibraryCategory.playlists:
        return PlaylistsScreen(
          embedded: true,
          onOpenTrackDetails: widget.onOpenTrackDetails,
        );
    }
  }

  void _openTrackGroupScreen(
    BuildContext context,
    String title,
    List<WetarTrack> tracks,
  ) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final appearance = context.read<PersonalizationCubit>().state.settings;
    final numerals = context.read<SettingsCubit>().state.numeralStyle;
    final thumbCache = sl<ThumbnailPathCache>();
    final textScale = MediaQuery.textScalerOf(context).scale(14.0) / 14.0;
    final effectiveExtent = textScale > 1.2
        ? tokens.listRowExtent * (textScale * 0.72).clamp(1.0, 1.55)
        : tokens.listRowExtent;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: <Widget>[
              IconButton(
                tooltip: l10n.actionShuffleAll,
                icon: const Icon(Icons.shuffle_rounded),
                onPressed: () => context.read<PlayerCubit>().shuffleAll(tracks),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: tokens.spacingLg),
              itemExtent: effectiveExtent,
              itemCount: tracks.length,
              itemBuilder: (ctx, i) {
                final track = tracks[i];
                return TrackListTile(
                  track: track,
                  isPlayingTrack: false,
                  showArtwork: appearance.showArtworkInLists,
                  numeralStyle: numerals,
                  thumbnailCache: thumbCache,
                  onTap: () =>
                      context.read<PlayerCubit>().playTracks(tracks, index: i),
                  onMorePressed: () => _showTrackActionsSheet(ctx, track),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackCollection(
    BuildContext context,
    List<WetarTrack> tracks,
    LibraryState libState,
    AppearanceSettings appearance,
    NumeralStyle numerals,
    String? currentTrackKey,
    ThumbnailPathCache thumbCache,
  ) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    if (tracks.isEmpty) {
      return Center(child: Text(l10n.libraryFilteredEmpty));
    }

    if (appearance.useGridInLibrary && !libState.isSelectionMode) {
      return Column(
        children: <Widget>[
          _buildTrackCountBar(context, tracks, numerals, tokens, l10n),
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(tokens.spacingMd),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: appearance.gridColumns,
                mainAxisSpacing: tokens.spacingMd,
                crossAxisSpacing: tokens.spacingMd,
                childAspectRatio: 0.78,
              ),
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(tokens.radiusCard),
                  onTap: () => context.read<PlayerCubit>().playTracks(
                    tracks,
                    index: index,
                  ),
                  onLongPress: () => context
                      .read<LibraryCubit>()
                      .toggleTrackSelection(track.stableKey),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, box) => WetarArtworkImage(
                            cacheKey: track.albumKey,
                            size: box.maxWidth,
                            artworkUri: track.artworkUri,
                            filePath: track.filePath,
                            customArtPath: track.customArtPath,
                            thumbnailCache: thumbCache,
                          ),
                        ),
                      ),
                      SizedBox(height: tokens.spacingXs),
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: track.stableKey == currentTrackKey
                              ? tokens.accentPrimary
                              : null,
                        ),
                      ),
                      Text(
                        track.resolvedArtist(l10n.libraryUnknownArtist),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    final textScale = MediaQuery.textScalerOf(context).scale(14.0) / 14.0;
    final effectiveExtent = textScale > 1.2
        ? tokens.listRowExtent * (textScale * 0.72).clamp(1.0, 1.55)
        : tokens.listRowExtent;

    final fastList = WetarFastScrollbar(
      controller: _scrollController,
      itemCount: tracks.length,
      itemExtent: effectiveExtent,
      labelForIndex: (idx) => ArabicNormalizer.indexLetter(tracks[idx].title),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: tokens.spacingMd),
        itemExtent: effectiveExtent,
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          return TrackListTile(
            key: ValueKey<String>(track.stableKey),
            track: track,
            isPlayingTrack: track.stableKey == currentTrackKey,
            showArtwork: appearance.showArtworkInLists,
            numeralStyle: numerals,
            thumbnailCache: thumbCache,
            isSelectionMode: libState.isSelectionMode,
            isSelected: libState.selectedKeys.contains(track.stableKey),
            onTap: () {
              if (libState.isSelectionMode) {
                context.read<LibraryCubit>().toggleTrackSelection(
                  track.stableKey,
                );
              } else {
                context.read<PlayerCubit>().playTracks(tracks, index: index);
              }
            },
            onLongPress: () => context
                .read<LibraryCubit>()
                .toggleTrackSelection(track.stableKey),
            onMorePressed: () => _showTrackActionsSheet(context, track),
            onCloudTap: () async {
              WetarFeedback.showInfo(context, l10n.foldersCloudDownloading);
              await sl<SystemIntegrationService>().triggerCloudDownload(
                track.filePath,
              );
            },
          );
        },
      ),
    );

    if (libState.isSelectionMode) {
      return fastList;
    }

    return Column(
      children: <Widget>[
        _buildTrackCountBar(context, tracks, numerals, tokens, l10n),
        Expanded(child: fastList),
      ],
    );
  }

  Widget _buildTrackCountBar(
    BuildContext context,
    List<WetarTrack> tracks,
    NumeralStyle numerals,
    WetarTokens tokens,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        tokens.spacingMd,
        tokens.spacingXs,
        tokens.spacingSm,
        tokens.spacingXs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              NumeralFormatter.formatString(
                l10n.foldersTrackCount(tracks.length),
                numerals,
              ),
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: tokens.inkMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: l10n.actionPlay,
            icon: Icon(Icons.play_arrow_rounded, color: tokens.accentPrimary),
            onPressed: () => context.read<PlayerCubit>().playTracks(tracks),
          ),
          IconButton(
            tooltip: l10n.actionShuffleAll,
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: () => context.read<PlayerCubit>().shuffleAll(tracks),
          ),
        ],
      ),
    );
  }
}

class _EmptyNoFoldersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final caps = sl<PlatformCapabilities>();
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.library_music_outlined,
              size: 60,
              color: tokens.accentPrimary,
            ),
            SizedBox(height: tokens.spacingMd),
            Text(
              l10n.libraryEmptyTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacingSm),
            Text(
              l10n.libraryEmptyBody,
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
                      builder: (_) => const FolderPickerScreen(),
                    ),
                  );
                } else {
                  await context.read<MusicFoldersCubit>().pickSystemFolder();
                }
              },
              icon: const Icon(Icons.folder_open_rounded),
              label: Text(l10n.foldersChooseCta),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCollectionView<T> extends StatelessWidget {
  const _GroupCollectionView({
    required this.items,
    required this.useGrid,
    required this.gridColumns,
    required this.titleOf,
    required this.subtitleOf,
    required this.artworkTrackOf,
    required this.thumbnailCache,
    required this.onTap,
  });

  final List<T> items;
  final bool useGrid;
  final int gridColumns;
  final String Function(T) titleOf;
  final String Function(T) subtitleOf;
  final WetarTrack? Function(T) artworkTrackOf;
  final ThumbnailPathCache thumbnailCache;
  final ValueChanged<T> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    if (items.isEmpty) {
      return Center(child: Text(l10n.libraryFilteredEmpty));
    }
    if (useGrid) {
      return GridView.builder(
        padding: EdgeInsets.all(tokens.spacingMd),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridColumns,
          mainAxisSpacing: tokens.spacingMd,
          crossAxisSpacing: tokens.spacingMd,
          childAspectRatio: 0.78,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final artTrack = artworkTrackOf(item);
          return InkWell(
            borderRadius: BorderRadius.circular(tokens.radiusCard),
            onTap: () => onTap(item),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => WetarArtworkImage(
                      cacheKey: artTrack?.albumKey ?? titleOf(item),
                      size: box.maxWidth,
                      artworkUri: artTrack?.artworkUri,
                      filePath: artTrack?.filePath,
                      customArtPath: artTrack?.customArtPath,
                      thumbnailCache: thumbnailCache,
                    ),
                  ),
                ),
                SizedBox(height: tokens.spacingXs),
                Text(
                  titleOf(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  subtitleOf(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      );
    }

    final textScale = MediaQuery.textScalerOf(context).scale(14.0) / 14.0;
    final effectiveExtent = textScale > 1.2
        ? tokens.listRowExtent * (textScale * 0.72).clamp(1.0, 1.55)
        : tokens.listRowExtent;

    return ListView.builder(
      padding: EdgeInsets.only(bottom: tokens.spacingMd),
      itemExtent: effectiveExtent,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final artTrack = artworkTrackOf(item);
        return ListTile(
          leading: WetarArtworkImage(
            cacheKey: artTrack?.albumKey ?? titleOf(item),
            size: tokens.listRowExtent - 18,
            artworkUri: artTrack?.artworkUri,
            filePath: artTrack?.filePath,
            customArtPath: artTrack?.customArtPath,
            thumbnailCache: thumbnailCache,
            decodeSizePx: 144,
          ),
          title: Text(
            titleOf(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            subtitleOf(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => onTap(item),
        );
      },
    );
  }
}
