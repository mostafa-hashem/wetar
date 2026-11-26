import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/library_repository.dart';
import '../../domain/library_models.dart';

enum SearchScopeFilter { all, songs, albums, artists, playlists }

class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.scope = SearchScopeFilter.all,
    this.tracks = const <WetarTrack>[],
    this.albums = const <AlbumGroup>[],
    this.artists = const <ArtistGroup>[],
    this.recentQueries = const <String>[],
    this.isSearching = false,
  });

  final String query;
  final SearchScopeFilter scope;
  final List<WetarTrack> tracks;
  final List<AlbumGroup> albums;
  final List<ArtistGroup> artists;
  final List<String> recentQueries;
  final bool isSearching;

  bool get hasAnyResult =>
      tracks.isNotEmpty || albums.isNotEmpty || artists.isNotEmpty;

  SearchState copyWith({
    String? query,
    SearchScopeFilter? scope,
    List<WetarTrack>? tracks,
    List<AlbumGroup>? albums,
    List<ArtistGroup>? artists,
    List<String>? recentQueries,
    bool? isSearching,
  }) {
    return SearchState(
      query: query ?? this.query,
      scope: scope ?? this.scope,
      tracks: tracks ?? this.tracks,
      albums: albums ?? this.albums,
      artists: artists ?? this.artists,
      recentQueries: recentQueries ?? this.recentQueries,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
    query,
    scope,
    tracks,
    albums,
    artists,
    recentQueries,
    isSearching,
  ];
}

/// Instant Arabic-normalized search over folder-scoped library tracks.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repo) : super(const SearchState()) {
    _recentSub = _repo.watchRecentSearches().listen((queries) {
      emit(state.copyWith(recentQueries: queries));
    });
  }

  final LibraryRepository _repo;
  StreamSubscription<List<String>>? _recentSub;
  int _generation = 0;

  Future<void> search(String query, {int minDurationSec = 30}) async {
    final trimmed = query.trim();
    final gen = ++_generation;
    if (trimmed.isEmpty) {
      emit(
        state.copyWith(
          query: '',
          tracks: const <WetarTrack>[],
          albums: const <AlbumGroup>[],
          artists: const <ArtistGroup>[],
          isSearching: false,
        ),
      );
      return;
    }
    emit(state.copyWith(query: query, isSearching: true));
    final tracks = await _repo.searchTracks(
      trimmed,
      minDurationSec: minDurationSec,
    );
    if (gen != _generation) return;
    final albums = LibraryRepository.groupAlbums(tracks);
    final artists = LibraryRepository.groupArtists(tracks);
    emit(
      state.copyWith(
        query: query,
        tracks: tracks,
        albums: albums,
        artists: artists,
        isSearching: false,
      ),
    );
  }

  void setScope(SearchScopeFilter scope) {
    emit(state.copyWith(scope: scope));
  }

  Future<void> commitRecentSearch(String query) =>
      _repo.saveRecentSearch(query);

  Future<void> clearRecent() => _repo.clearRecentSearches();

  @override
  Future<void> close() async {
    await _recentSub?.cancel();
    return super.close();
  }
}
