import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/library/presentation/bloc/library_cubit.dart';
import 'package:wetar/features/library/presentation/screens/search_screen.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/music_folders/presentation/screens/folder_picker_screen.dart';
import 'package:wetar/features/music_folders/presentation/screens/music_folders_settings_screen.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/personalization/presentation/widgets/wetar_background_renderer.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Smart Home screen composed of reorderable & hideable user blocks.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onOpenNowPlaying,
    required this.onOpenFavorites,
    required this.onOpenPlaylists,
    required this.onOpenCarMode,
    required this.onOpenTrackDetails,
    required this.onAddToPlaylistRequested,
  });

  final VoidCallback onOpenNowPlaying;
  final VoidCallback onOpenFavorites;
  final VoidCallback onOpenPlaylists;
  final VoidCallback onOpenCarMode;
  final ValueChanged<WetarTrack> onOpenTrackDetails;
  final ValueChanged<List<WetarTrack>> onAddToPlaylistRequested;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final appearance = context.select(
      (PersonalizationCubit c) => c.state.settings,
    );
    final numerals = context.select((SettingsCubit c) => c.state.numeralStyle);
    final libState = context.watch<LibraryCubit>().state;
    final foldersState = context.watch<MusicFoldersCubit>().state;
    final playerState = context.watch<PlayerCubit>().state;
    final thumbCache = sl<ThumbnailPathCache>();

    final visibleBlocks = appearance.homeBlocksOrder
        .where((b) => !appearance.hiddenHomeBlocks.contains(b))
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: WetarBackgroundRenderer(
        surfaceLocation: BackgroundScope.homeAndPlayer,
        activeTrack: playerState.currentTrack,
        isPlaying: playerState.isPlaying,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              title: Text(l10n.appName),
              actions: <Widget>[
                IconButton(
                  tooltip: l10n.actionSearch,
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SearchScreen(
                        onOpenTrackDetails: onOpenTrackDetails,
                        onAddToPlaylistRequested: onAddToPlaylistRequested,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.playerCarMode,
                  icon: const Icon(Icons.directions_car_outlined),
                  onPressed: onOpenCarMode,
                ),
              ],
            ),
            if (foldersState.selectedFolders.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spacingLg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.folder_open_rounded,
                          size: 62,
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
                            if (sl<PlatformCapabilities>()
                                .supportsInAppFolderPicker) {
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const FolderPickerScreen(),
                                ),
                              );
                            } else {
                              await context
                                  .read<MusicFoldersCubit>()
                                  .pickSystemFolder();
                            }
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: Text(l10n.foldersChooseCta),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.all(tokens.spacingMd),
                sliver: SliverList.separated(
                  itemCount: visibleBlocks.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: tokens.spacingLg),
                  itemBuilder: (context, index) {
                    return _buildBlock(
                      context,
                      block: visibleBlocks[index],
                      libState: libState,
                      foldersState: foldersState,
                      playerState: playerState,
                      numerals: numerals,
                      thumbCache: thumbCache,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(
    BuildContext context, {
    required HomeBlockKind block,
    required LibraryState libState,
    required MusicFoldersState foldersState,
    required PlayerStateSnapshot playerState,
    required NumeralStyle numerals,
    required ThumbnailPathCache thumbCache,
  }) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;

    switch (block) {
      case HomeBlockKind.continueListening:
        final current = playerState.currentTrack;
        if (current == null) return const SizedBox.shrink();
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(tokens.radiusCard),
            onTap: onOpenNowPlaying,
            child: Padding(
              padding: EdgeInsets.all(tokens.spacingMd),
              child: Row(
                children: <Widget>[
                  WetarArtworkImage(
                    cacheKey: current.albumKey,
                    size: 64,
                    artworkUri: current.artworkUri,
                    filePath: current.filePath,
                    customArtPath: current.customArtPath,
                    thumbnailCache: thumbCache,
                  ),
                  SizedBox(width: tokens.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.homeContinueListening,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: tokens.accentPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          current.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          current.displayArtist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: tokens.accentPrimary,
                    ),
                    icon: Icon(
                      playerState.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    onPressed: () =>
                        context.read<PlayerCubit>().togglePlayPause(),
                  ),
                ],
              ),
            ),
          ),
        );

      case HomeBlockKind.quickActions:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.homeQuickActions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.spacingSm),
            Wrap(
              spacing: tokens.spacingSm,
              runSpacing: tokens.spacingSm,
              children: <Widget>[
                ActionChip(
                  avatar: Icon(
                    Icons.shuffle_rounded,
                    color: tokens.accentPrimary,
                  ),
                  label: Text(l10n.actionShuffleAll),
                  onPressed: () => context.read<PlayerCubit>().shuffleAll(
                    libState.allTracks,
                  ),
                ),
                ActionChip(
                  avatar: Icon(
                    Icons.favorite_rounded,
                    color: tokens.accentPrimary,
                  ),
                  label: Text(l10n.tabFavorites),
                  onPressed: onOpenFavorites,
                ),
                ActionChip(
                  avatar: Icon(
                    Icons.folder_copy_rounded,
                    color: tokens.accentSecondary,
                  ),
                  label: Text(l10n.homeYourFolders),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MusicFoldersSettingsScreen(),
                    ),
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.queue_music_rounded),
                  label: Text(l10n.homeYourPlaylists),
                  onPressed: onOpenPlaylists,
                ),
              ],
            ),
          ],
        );

      case HomeBlockKind.recentlyAdded:
        final recent = libState.recentlyAddedTracks;
        if (recent.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.homeRecentlyAdded,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.spacingSm),
            SizedBox(
              height: 172,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recent.length.clamp(0, 12),
                separatorBuilder: (context, index) =>
                    SizedBox(width: tokens.spacingMd),
                itemBuilder: (context, idx) {
                  final track = recent[idx];
                  return SizedBox(
                    width: 120,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(tokens.radiusCard),
                      onTap: () => context.read<PlayerCubit>().playTracks(
                        recent,
                        index: idx,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          WetarArtworkImage(
                            cacheKey: track.albumKey,
                            size: 120,
                            artworkUri: track.artworkUri,
                            filePath: track.filePath,
                            customArtPath: track.customArtPath,
                            thumbnailCache: thumbCache,
                          ),
                          SizedBox(height: tokens.spacingXs),
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
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
                  );
                },
              ),
            ),
          ],
        );

      case HomeBlockKind.mostPlayed:
        final top = libState.mostPlayedTracks;
        if (top.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.homeMostPlayed,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.spacingSm),
            for (var i = 0; i < top.length.clamp(0, 5); i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: WetarArtworkImage(
                  cacheKey: top[i].albumKey,
                  size: 46,
                  artworkUri: top[i].artworkUri,
                  filePath: top[i].filePath,
                  customArtPath: top[i].customArtPath,
                  thumbnailCache: thumbCache,
                ),
                title: Text(
                  top[i].title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(top[i].displayArtist),
                trailing: Text(
                  NumeralFormatter.formatInt(top[i].playCount, numerals),
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: tokens.accentPrimary),
                ),
                onTap: () =>
                    context.read<PlayerCubit>().playTracks(top, index: i),
              ),
          ],
        );

      case HomeBlockKind.folders:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.homeYourFolders,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.spacingSm),
            Wrap(
              spacing: tokens.spacingSm,
              runSpacing: tokens.spacingSm,
              children: foldersState.selectedFolders
                  .map(
                    (f) => InputChip(
                      avatar: const Icon(Icons.folder_rounded, size: 18),
                      label: Text(
                        '${f.displayName} (${NumeralFormatter.formatInt(f.trackCount, numerals)})',
                      ),
                      onPressed: () {
                        final folderTracks = libState.allTracks
                            .where((t) => t.folderId == f.id)
                            .toList();
                        if (folderTracks.isNotEmpty) {
                          context.read<PlayerCubit>().playTracks(folderTracks);
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        );

      case HomeBlockKind.playlists:
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.queue_music_rounded, color: tokens.accentPrimary),
          title: Text(l10n.homeYourPlaylists),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onOpenPlaylists,
        );
    }
  }
}
