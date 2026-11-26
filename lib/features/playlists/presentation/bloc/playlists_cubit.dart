import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/playlists/data/playlists_repository.dart';

class PlaylistsState extends Equatable {
  const PlaylistsState({
    this.playlists = const <WetarPlaylistSummary>[],
    this.isLoading = true,
  });

  final List<WetarPlaylistSummary> playlists;
  final bool isLoading;

  @override
  List<Object?> get props => [playlists, isLoading];
}

class PlaylistsCubit extends Cubit<PlaylistsState> {
  PlaylistsCubit(this._repo) : super(const PlaylistsState()) {
    _sub = _repo.watchUserPlaylists().listen((list) {
      emit(PlaylistsState(playlists: list, isLoading: false));
    });
  }

  final PlaylistsRepository _repo;
  StreamSubscription<List<WetarPlaylistSummary>>? _sub;

  Future<int> createPlaylist(String name) => _repo.createPlaylist(name);

  Future<void> renamePlaylist(int id, String name) =>
      _repo.renamePlaylist(id, name);

  Future<void> deletePlaylist(int id) => _repo.deletePlaylist(id);

  Future<void> addTracks(int playlistId, List<WetarTrack> tracks) =>
      _repo.addTracksToPlaylist(playlistId, tracks);

  Future<void> removeTrack(int playlistId, String stableKey) =>
      _repo.removeTrackFromPlaylist(playlistId, stableKey);

  Future<void> reorderTracks(int playlistId, List<WetarTrack> tracks) =>
      _repo.reorderPlaylist(playlistId, tracks);

  Future<List<WetarTrack>> loadTracks(int playlistId) =>
      _repo.getPlaylistTracks(playlistId);

  Future<List<WetarTrack>> loadSmartTracks(
    SmartPlaylistKind kind, {
    int minDurationSec = 30,
  }) => _repo.getSmartPlaylistTracks(kind, minDurationSec: minDurationSec);

  Future<int> importM3u(String path) => _repo.importM3uFile(path);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
