import 'dart:io';
import 'dart:isolate';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/features/library/data/library_repository.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/lyrics/domain/lrc_parser.dart';

class LyricsState extends Equatable {
  const LyricsState({
    this.isLoading = false,
    this.trackStableKey,
    this.parsed = const ParsedLyrics(lines: <LyricLine>[], isSynced: false),
    this.userOffsetMs = 0,
    this.fontSize = 19.0,
  });

  final bool isLoading;
  final String? trackStableKey;
  final ParsedLyrics parsed;
  final int userOffsetMs;
  final double fontSize;

  LyricsState copyWith({
    bool? isLoading,
    String? trackStableKey,
    ParsedLyrics? parsed,
    int? userOffsetMs,
    double? fontSize,
  }) {
    return LyricsState(
      isLoading: isLoading ?? this.isLoading,
      trackStableKey: trackStableKey ?? this.trackStableKey,
      parsed: parsed ?? this.parsed,
      userOffsetMs: userOffsetMs ?? this.userOffsetMs,
      fontSize: (fontSize ?? this.fontSize).clamp(14.0, 32.0),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    trackStableKey,
    parsed,
    userOffsetMs,
    fontSize,
  ];
}

/// Resolves attached `.lrc`, sidecar `.lrc`, or embedded tag lyrics in an isolate.
class LyricsCubit extends Cubit<LyricsState> {
  LyricsCubit(this._libraryRepo, this._picker) : super(const LyricsState());

  final LibraryRepository _libraryRepo;
  final FolderPickerService _picker;

  Future<void> loadForTrack(WetarTrack? track) async {
    if (track == null) {
      emit(const LyricsState());
      return;
    }
    if (state.trackStableKey == track.stableKey &&
        state.parsed.lines.isNotEmpty) {
      return;
    }
    emit(
      state.copyWith(
        isLoading: true,
        trackStableKey: track.stableKey,
        userOffsetMs: track.lyricOffsetMs,
      ),
    );

    String? rawLyrics;
    // 1. User-attached .lrc file
    if (track.attachedLrcPath != null &&
        File(track.attachedLrcPath!).existsSync()) {
      rawLyrics = await _readFileSafely(track.attachedLrcPath!);
    }

    // 2. Sidecar <basename>.lrc in same folder
    if ((rawLyrics == null || rawLyrics.trim().isEmpty) &&
        !track.filePath.startsWith('content://')) {
      final sidecarPath = p.setExtension(track.filePath, '.lrc');
      if (File(sidecarPath).existsSync()) {
        rawLyrics = await _readFileSafely(sidecarPath);
      }
    }

    // 3. Cached DB embedded lyrics
    if ((rawLyrics == null || rawLyrics.trim().isEmpty) &&
        track.embeddedLyrics != null &&
        track.embeddedLyrics!.trim().isNotEmpty) {
      rawLyrics = track.embeddedLyrics;
    }

    // 4. Direct tag read via audio_metadata_reader in isolate
    if ((rawLyrics == null || rawLyrics.trim().isEmpty) &&
        !track.filePath.startsWith('content://') &&
        File(track.filePath).existsSync()) {
      final path = track.filePath;
      rawLyrics = await Isolate.run(() {
        try {
          final meta = readMetadata(File(path), getImage: false);
          return meta.lyrics;
        } catch (_) {
          return null;
        }
      });
    }

    final parsed = rawLyrics == null || rawLyrics.trim().isEmpty
        ? const ParsedLyrics(lines: <LyricLine>[], isSynced: false)
        : LrcParser.parse(rawLyrics);

    emit(
      state.copyWith(
        isLoading: false,
        trackStableKey: track.stableKey,
        parsed: parsed,
        userOffsetMs: track.lyricOffsetMs,
      ),
    );
  }

  Future<void> attachLrcFromPicker(WetarTrack track) async {
    final picked = await _picker.pickFile(
      mimeTypes: const <String>[
        'text/plain',
        'application/octet-stream',
        '*/*',
      ],
    );
    if (picked == null) return;
    await _libraryRepo.setAttachedLrc(track.stableKey, picked);
    final raw = await _readFileSafely(picked);
    if (raw == null) return;
    emit(
      state.copyWith(
        trackStableKey: track.stableKey,
        parsed: LrcParser.parse(raw),
      ),
    );
  }

  Future<void> adjustOffset(WetarTrack track, int deltaMs) async {
    final nextOffset = (state.userOffsetMs + deltaMs).clamp(-15000, 15000);
    emit(state.copyWith(userOffsetMs: nextOffset));
    if (!track.isTemporaryExternal) {
      await _libraryRepo.setLyricOffset(track.stableKey, nextOffset);
    }
  }

  void setFontSize(double size) {
    emit(state.copyWith(fontSize: size));
  }

  Future<String?> _readFileSafely(String path) async {
    try {
      return await File(path).readAsString();
    } catch (_) {
      return null;
    }
  }
}
