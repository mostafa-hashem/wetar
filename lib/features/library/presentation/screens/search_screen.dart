import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/core/widgets/wetar_responsive.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/library/presentation/bloc/search_cubit.dart';
import 'package:wetar/features/library/presentation/widgets/track_list_tile.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Instant bilingual search screen with Arabic tashkeel/letter normalization,
/// filter chips, and persisted recent search queries.
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.onOpenTrackDetails,
    required this.onAddToPlaylistRequested,
  });

  final ValueChanged<WetarTrack> onOpenTrackDetails;
  final ValueChanged<List<WetarTrack>> onAddToPlaylistRequested;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  late final SearchCubit _searchCubit;

  @override
  void initState() {
    super.initState();
    _searchCubit = sl<SearchCubit>();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final settings = context.select((SettingsCubit c) => c.state);
    final thumbCache = sl<ThumbnailPathCache>();

    return BlocProvider<SearchCubit>.value(
      value: _searchCubit,
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (q) => _searchCubit.search(
                  q,
                  minDurationSec: settings.minTrackDurationSec,
                ),
                onSubmitted: (q) => _searchCubit.commitRecentSearch(q),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  border: InputBorder.none,
                ),
              ),
              actions: <Widget>[
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _controller.clear();
                      _searchCubit.search('');
                    },
                  ),
              ],
            ),
            body: SafeArea(
              top: false,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacingMd,
                      ),
                      children: <Widget>[
                        for (final scope in SearchScopeFilter.values)
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: tokens.spacingSm,
                            ),
                            child: ChoiceChip(
                              selected: state.scope == scope,
                              label: Text(switch (scope) {
                                SearchScopeFilter.all => l10n.searchFilterAll,
                                SearchScopeFilter.songs => l10n.tabSongs,
                                SearchScopeFilter.albums => l10n.tabAlbums,
                                SearchScopeFilter.artists => l10n.tabArtists,
                                SearchScopeFilter.playlists =>
                                  l10n.tabPlaylists,
                              }),
                              onSelected: (_) => _searchCubit.setScope(scope),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: state.query.trim().isEmpty
                        ? _RecentSearchesList(
                            queries: state.recentQueries,
                            onSelect: (q) {
                              _controller.text = q;
                              _searchCubit.search(
                                q,
                                minDurationSec: settings.minTrackDurationSec,
                              );
                            },
                            onClearAll: _searchCubit.clearRecent,
                          )
                        : !state.hasAnyResult && !state.isSearching
                        ? Center(child: Text(l10n.searchNoResults(state.query)))
                        : LayoutBuilder(
                            builder: (context, constraints) => ListView(
                              padding: WetarResponsive.listPadding(
                                constraints.maxWidth,
                                minHorizontal: 0,
                                top: 0,
                                bottom: tokens.spacingLg,
                                maxWidth: 960,
                              ),
                              children: <Widget>[
                                if ((state.scope == SearchScopeFilter.all ||
                                        state.scope ==
                                            SearchScopeFilter.albums) &&
                                    state.albums.isNotEmpty) ...<Widget>[
                                  _SectionHeader(title: l10n.tabAlbums),
                                  for (final album in state.albums.take(6))
                                    ListTile(
                                      leading: WetarArtworkImage(
                                        cacheKey: album.albumKey,
                                        size: 46,
                                        artworkUri:
                                            album.representative.artworkUri,
                                        filePath: album.representative.filePath,
                                        thumbnailCache: thumbCache,
                                      ),
                                      title: Text(album.name),
                                      subtitle: Text(album.artist),
                                      onTap: () {
                                        _searchCubit.commitRecentSearch(
                                          state.query,
                                        );
                                        context.read<PlayerCubit>().playTracks(
                                          album.tracks,
                                        );
                                      },
                                    ),
                                ],
                                if ((state.scope == SearchScopeFilter.all ||
                                        state.scope ==
                                            SearchScopeFilter.artists) &&
                                    state.artists.isNotEmpty) ...<Widget>[
                                  _SectionHeader(title: l10n.tabArtists),
                                  for (final artist in state.artists.take(6))
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: tokens.surfaceElevated,
                                        child: const Icon(Icons.person_rounded),
                                      ),
                                      title: Text(artist.name),
                                      subtitle: Text(
                                        l10n.foldersTrackCount(
                                          artist.tracks.length,
                                        ),
                                      ),
                                      onTap: () {
                                        _searchCubit.commitRecentSearch(
                                          state.query,
                                        );
                                        context.read<PlayerCubit>().playTracks(
                                          artist.tracks,
                                        );
                                      },
                                    ),
                                ],
                                if ((state.scope == SearchScopeFilter.all ||
                                        state.scope ==
                                            SearchScopeFilter.songs) &&
                                    state.tracks.isNotEmpty) ...<Widget>[
                                  _SectionHeader(title: l10n.tabSongs),
                                  for (var i = 0; i < state.tracks.length; i++)
                                    TrackListTile(
                                      track: state.tracks[i],
                                      isPlayingTrack: false,
                                      showArtwork: true,
                                      numeralStyle: settings.numeralStyle,
                                      thumbnailCache: thumbCache,
                                      onTap: () {
                                        _searchCubit.commitRecentSearch(
                                          state.query,
                                        );
                                        context.read<PlayerCubit>().playTracks(
                                          state.tracks,
                                          index: i,
                                        );
                                      },
                                      onMorePressed: () => widget
                                          .onOpenTrackDetails(state.tracks[i]),
                                    ),
                                ],
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wetarTokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacingMd,
        tokens.spacingMd,
        tokens.spacingMd,
        tokens.spacingXs,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: tokens.accentPrimary),
      ),
    );
  }
}

class _RecentSearchesList extends StatelessWidget {
  const _RecentSearchesList({
    required this.queries,
    required this.onSelect,
    required this.onClearAll,
  });

  final List<String> queries;
  final ValueChanged<String> onSelect;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    if (queries.isEmpty) {
      return Center(
        child: Text(
          l10n.searchHint,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: tokens.inkMuted),
        ),
      );
    }
    return ListView(
      padding: EdgeInsets.only(bottom: tokens.spacingLg),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacingMd,
            vertical: tokens.spacingSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                l10n.searchRecent,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextButton(onPressed: onClearAll, child: Text(l10n.actionClear)),
            ],
          ),
        ),
        for (final q in queries)
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: Text(q),
            onTap: () => onSelect(q),
          ),
      ],
    );
  }
}
