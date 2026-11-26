import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/library_repository.dart';
import '../../domain/library_models.dart';

class LibraryState extends Equatable {
  const LibraryState({
    this.isLoading = true,
    this.allTracks = const <WetarTrack>[],
    this.sortField = LibrarySortField.title,
    this.ascending = true,
    this.activeCategory = LibraryCategory.songs,
    this.selectedKeys = const <String>{},
  });

  final bool isLoading;
  final List<WetarTrack> allTracks;
  final LibrarySortField sortField;
  final bool ascending;
  final LibraryCategory activeCategory;
  final Set<String> selectedKeys;

  bool get isSelectionMode => selectedKeys.isNotEmpty;

  List<WetarTrack> get sortedTracks {
    final list = List<WetarTrack>.from(allTracks);
    int cmp(WetarTrack a, WetarTrack b) {
      switch (sortField) {
        case LibrarySortField.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case LibrarySortField.artist:
          return a.displayArtist.toLowerCase().compareTo(
            b.displayArtist.toLowerCase(),
          );
        case LibrarySortField.album:
          return a.displayAlbum.toLowerCase().compareTo(
            b.displayAlbum.toLowerCase(),
          );
        case LibrarySortField.dateAdded:
          return a.dateAddedSec.compareTo(b.dateAddedSec);
        case LibrarySortField.duration:
          return a.durationMs.compareTo(b.durationMs);
        case LibrarySortField.playCount:
          return a.playCount.compareTo(b.playCount);
      }
    }

    list.sort((a, b) => ascending ? cmp(a, b) : cmp(b, a));
    return list;
  }

  List<WetarTrack> get favoriteTracks =>
      sortedTracks.where((t) => t.isFavorite).toList();

  List<WetarTrack> get recentlyAddedTracks {
    final list = List<WetarTrack>.from(allTracks)
      ..sort((a, b) => b.dateAddedSec.compareTo(a.dateAddedSec));
    return list.take(60).toList();
  }

  List<WetarTrack> get recentlyPlayedTracks {
    final played = allTracks.where((t) => (t.lastPlayedAt ?? 0) > 0).toList()
      ..sort((a, b) => (b.lastPlayedAt ?? 0).compareTo(a.lastPlayedAt ?? 0));
    return played.take(60).toList();
  }

  List<WetarTrack> get mostPlayedTracks {
    final played = allTracks.where((t) => t.playCount > 0).toList()
      ..sort((a, b) => b.playCount.compareTo(a.playCount));
    return played.take(60).toList();
  }

  LibraryState copyWith({
    bool? isLoading,
    List<WetarTrack>? allTracks,
    LibrarySortField? sortField,
    bool? ascending,
    LibraryCategory? activeCategory,
    Set<String>? selectedKeys,
  }) {
    return LibraryState(
      isLoading: isLoading ?? this.isLoading,
      allTracks: allTracks ?? this.allTracks,
      sortField: sortField ?? this.sortField,
      ascending: ascending ?? this.ascending,
      activeCategory: activeCategory ?? this.activeCategory,
      selectedKeys: selectedKeys ?? this.selectedKeys,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    allTracks,
    sortField,
    ascending,
    activeCategory,
    selectedKeys,
  ];
}

/// Manages folder-scoped library tracks, sorting, multi-select, and favorites.
class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(this._repo, {int minDurationSec = 30})
    : _minDurationSec = minDurationSec,
      super(const LibraryState()) {
    _subscribe();
  }

  final LibraryRepository _repo;
  int _minDurationSec;
  StreamSubscription<List<WetarTrack>>? _sub;

  void _subscribe() {
    _sub?.cancel();
    _sub = _repo.watchLibraryTracks(minDurationSec: _minDurationSec).listen((
      tracks,
    ) {
      emit(state.copyWith(isLoading: false, allTracks: tracks));
    });
  }

  void updateMinDurationSec(int seconds) {
    if (seconds == _minDurationSec) return;
    _minDurationSec = seconds;
    _subscribe();
  }

  void setCategory(LibraryCategory category) {
    emit(state.copyWith(activeCategory: category));
  }

  void setSort(LibrarySortField field, {bool? ascending}) {
    final nextAsc =
        ascending ?? (state.sortField == field ? !state.ascending : true);
    emit(state.copyWith(sortField: field, ascending: nextAsc));
  }

  void toggleTrackSelection(String stableKey) {
    final next = Set<String>.from(state.selectedKeys);
    if (!next.add(stableKey)) {
      next.remove(stableKey);
    }
    emit(state.copyWith(selectedKeys: next));
  }

  void selectAllVisible() {
    emit(
      state.copyWith(
        selectedKeys: state.allTracks.map((t) => t.stableKey).toSet(),
      ),
    );
  }

  void clearSelection() {
    if (state.selectedKeys.isEmpty) return;
    emit(state.copyWith(selectedKeys: const <String>{}));
  }

  Future<void> toggleFavorite(String stableKey, {bool? value}) =>
      _repo.toggleFavorite(stableKey, value: value);

  Future<void> favoriteSelected() async {
    for (final key in state.selectedKeys) {
      await _repo.toggleFavorite(key, value: true);
    }
    clearSelection();
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
