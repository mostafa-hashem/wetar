import 'package:equatable/equatable.dart';

/// Canonical domain model for an audio track inside Wetar.
/// External Open-With files construct temporary [WetarTrack] instances with [isTemporaryExternal = true].
class WetarTrack extends Equatable {
  const WetarTrack({
    required this.stableKey,
    required this.folderId,
    required this.uri,
    required this.filePath,
    required this.folderPath,
    required this.title,
    required this.artist,
    required this.album,
    required this.albumArtist,
    required this.genre,
    required this.year,
    required this.trackNumber,
    required this.discNumber,
    required this.durationMs,
    required this.bitrateKbps,
    required this.sampleRateHz,
    required this.channels,
    required this.sizeBytes,
    required this.mimeType,
    required this.dateModifiedSec,
    required this.dateAddedSec,
    this.artworkUri,
    this.embeddedLyrics,
    this.replayGainTrackDb,
    this.replayGainAlbumDb,
    this.isFavorite = false,
    this.playCount = 0,
    this.lastPlayedAt,
    this.rememberedPositionMs,
    this.attachedLrcPath,
    this.lyricOffsetMs = 0,
    this.customArtPath,
    this.isCloudPending = false,
    this.isCorruptOrMissing = false,
    this.isTemporaryExternal = false,
  });

  final String stableKey;
  final int folderId;
  final String uri;
  final String filePath;
  final String folderPath;
  final String title;
  final String artist;
  final String album;
  final String albumArtist;
  final String genre;
  final int year;
  final int trackNumber;
  final int discNumber;
  final int durationMs;
  final int bitrateKbps;
  final int sampleRateHz;
  final int channels;
  final int sizeBytes;
  final String mimeType;
  final int dateModifiedSec;
  final int dateAddedSec;
  final String? artworkUri;
  final String? embeddedLyrics;
  final double? replayGainTrackDb;
  final double? replayGainAlbumDb;
  final bool isFavorite;
  final int playCount;
  final int? lastPlayedAt;
  final int? rememberedPositionMs;
  final String? attachedLrcPath;
  final int lyricOffsetMs;
  final String? customArtPath;
  final bool isCloudPending;
  final bool isCorruptOrMissing;
  final bool isTemporaryExternal;

  Duration get duration => Duration(milliseconds: durationMs);

  String get albumKey =>
      '${album.trim().toLowerCase()}__${(albumArtist.isNotEmpty ? albumArtist : artist).trim().toLowerCase()}';

  String get displayArtist => artist.isNotEmpty ? artist : 'Unknown Artist';
  String get displayAlbum => album.isNotEmpty ? album : 'Unknown Album';

  WetarTrack copyWith({
    bool? isFavorite,
    int? playCount,
    int? lastPlayedAt,
    int? rememberedPositionMs,
    String? attachedLrcPath,
    int? lyricOffsetMs,
    String? customArtPath,
    bool? isCloudPending,
    bool? isCorruptOrMissing,
    String? embeddedLyrics,
  }) {
    return WetarTrack(
      stableKey: stableKey,
      folderId: folderId,
      uri: uri,
      filePath: filePath,
      folderPath: folderPath,
      title: title,
      artist: artist,
      album: album,
      albumArtist: albumArtist,
      genre: genre,
      year: year,
      trackNumber: trackNumber,
      discNumber: discNumber,
      durationMs: durationMs,
      bitrateKbps: bitrateKbps,
      sampleRateHz: sampleRateHz,
      channels: channels,
      sizeBytes: sizeBytes,
      mimeType: mimeType,
      dateModifiedSec: dateModifiedSec,
      dateAddedSec: dateAddedSec,
      artworkUri: artworkUri,
      embeddedLyrics: embeddedLyrics ?? this.embeddedLyrics,
      replayGainTrackDb: replayGainTrackDb,
      replayGainAlbumDb: replayGainAlbumDb,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      rememberedPositionMs: rememberedPositionMs ?? this.rememberedPositionMs,
      attachedLrcPath: attachedLrcPath ?? this.attachedLrcPath,
      lyricOffsetMs: lyricOffsetMs ?? this.lyricOffsetMs,
      customArtPath: customArtPath ?? this.customArtPath,
      isCloudPending: isCloudPending ?? this.isCloudPending,
      isCorruptOrMissing: isCorruptOrMissing ?? this.isCorruptOrMissing,
      isTemporaryExternal: isTemporaryExternal,
    );
  }

  @override
  List<Object?> get props => [
    stableKey,
    folderId,
    uri,
    title,
    artist,
    album,
    durationMs,
    isFavorite,
    playCount,
    customArtPath,
    attachedLrcPath,
    lyricOffsetMs,
    isCloudPending,
    isCorruptOrMissing,
    isTemporaryExternal,
  ];
}

enum LibraryCategory {
  songs,
  albums,
  artists,
  albumArtists,
  genres,
  years,
  folders,
  playlists,
  favorites,
  recentlyAdded,
  recentlyPlayed,
  mostPlayed,
}

enum LibrarySortField { title, artist, album, dateAdded, duration, playCount }

class AlbumGroup extends Equatable {
  const AlbumGroup({
    required this.albumKey,
    required this.name,
    required this.artist,
    required this.year,
    required this.tracks,
  });

  final String albumKey;
  final String name;
  final String artist;
  final int year;
  final List<WetarTrack> tracks;

  WetarTrack get representative => tracks.first;
  int get trackCount => tracks.length;

  @override
  List<Object?> get props => [albumKey, name, artist, year, tracks];
}

class ArtistGroup extends Equatable {
  const ArtistGroup({
    required this.name,
    required this.tracks,
    required this.albumCount,
  });

  final String name;
  final List<WetarTrack> tracks;
  final int albumCount;

  WetarTrack? get representative => tracks.isEmpty ? null : tracks.first;

  @override
  List<Object?> get props => [name, tracks, albumCount];
}

class FacetGroup extends Equatable {
  const FacetGroup({required this.label, required this.tracks});

  final String label;
  final List<WetarTrack> tracks;

  @override
  List<Object?> get props => [label, tracks];
}
