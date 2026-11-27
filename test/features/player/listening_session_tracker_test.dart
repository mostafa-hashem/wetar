import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/features/library/data/library_repository.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/player/domain/listening_session_tracker.dart';

WetarTrack _sampleTrack({
  required String stableKey,
  required String title,
  required int durationMs,
  int folderId = 1,
}) {
  return WetarTrack(
    stableKey: stableKey,
    folderId: folderId,
    uri: 'file://$stableKey',
    filePath: stableKey,
    folderPath: '/storage/emulated/0/Music',
    title: title,
    artist: 'Tester',
    album: 'Test Album',
    albumArtist: 'Tester',
    genre: 'Acoustic',
    year: 2025,
    trackNumber: 1,
    discNumber: 1,
    durationMs: durationMs,
    bitrateKbps: 320,
    sampleRateHz: 44100,
    channels: 2,
    sizeBytes: 4096000,
    mimeType: 'audio/mpeg',
    dateModifiedSec: 1700000000,
    dateAddedSec: 1700000000,
  );
}

void main() {
  test('cold-start or non-audible selection records zero listening time', () {
    var nowMs = 1000000;
    final tracker = ListeningSessionTracker(clockMs: () => nowMs);
    final track = _sampleTrack(
      stableKey: '/music/long_track.mp3',
      title: 'Long Track',
      durationMs: 300000, // 5 min
    );

    final startFlush = tracker.onTrackChanged(track, isActivelyAudible: false);
    expect(startFlush, isNull);

    nowMs += 60000; // 1 minute passes while paused
    expect(tracker.currentSessionListenedMs(), 0);
    expect(tracker.checkpoint(), isNull);

    final endFlush = tracker.endCurrentSession();
    expect(endFlush, isNotNull);
    expect(endFlush!.listenedMs, 0);
    expect(endFlush.shouldPersistHistory, isFalse);
    expect(endFlush.recordPlayCountNow, isFalse);
  });

  test(
    'tapping four 5-minute tracks briefly does NOT count full track lengths',
    () {
      var nowMs = 1000000;
      final tracker = ListeningSessionTracker(clockMs: () => nowMs);

      final persistedFlushes = <ListeningSessionFlush>[];
      var countedPlays = 0;

      for (var i = 0; i < 4; i++) {
        final track = _sampleTrack(
          stableKey: '/music/t_$i.mp3',
          title: 'Track $i',
          durationMs: 300000, // 5 min each = 20 min total if buggy!
        );
        final ended = tracker.onTrackChanged(track, isActivelyAudible: true);
        if (ended != null) {
          if (ended.shouldPersistHistory) persistedFlushes.add(ended);
          if (ended.recordPlayCountNow) countedPlays++;
        }
        nowMs += 400; // brief 400ms skip tap
      }
      final finalEnded = tracker.endCurrentSession();
      if (finalEnded != null) {
        if (finalEnded.shouldPersistHistory) persistedFlushes.add(finalEnded);
        if (finalEnded.recordPlayCountNow) countedPlays++;
      }

      expect(persistedFlushes, isEmpty);
      expect(countedPlays, 0);
    },
  );

  test(
    'pausing, resuming, and persisting updates single session row accurately',
    () async {
      final db = WetarDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final folderId = await db
          .into(db.selectedFolders)
          .insert(
            SelectedFoldersCompanion.insert(
              rootPath: '/music',
              displayName: 'Music',
              addedAt: 1000,
            ),
          );
      final track = _sampleTrack(
        stableKey: '/music/serenade.mp3',
        title: 'Serenade',
        durationMs: 240000, // 4 min
        folderId: folderId,
      );
      final libraryRepo = LibraryRepository(db);
      await db
          .into(db.tracks)
          .insert(
            TracksCompanion.insert(
              stableKey: track.stableKey,
              folderId: folderId,
              uri: track.uri,
              filePath: track.filePath,
              folderPath: track.folderPath,
              title: track.title,
              titleNormalized: 'serenade',
              artist: Value(track.artist),
              artistNormalized: const Value('tester'),
              album: Value(track.album),
              albumNormalized: const Value('test album'),
              durationMs: Value(track.durationMs),
            ),
          );

      var nowMs = 2000000;
      final tracker = ListeningSessionTracker(clockMs: () => nowMs);
      final rowIds = <int, int>{};

      Future<void> applyFlush(ListeningSessionFlush? f) async {
        if (f == null) return;
        if (f.shouldPersistHistory) {
          final id = await libraryRepo.upsertPlayHistorySession(
            eventId: rowIds[f.sessionId],
            track: f.track,
            playedAtMs: f.startedAtEpochMs,
            listenedMs: f.listenedMs,
          );
          if (id != null && !f.isSessionEnded) {
            rowIds[f.sessionId] = id;
          }
        }
        if (f.recordPlayCountNow) {
          await libraryRepo.incrementTrackPlayCount(
            f.track,
            playedAtMs: f.startedAtEpochMs,
          );
        }
        if (f.isSessionEnded) {
          rowIds.remove(f.sessionId);
        }
      }

      // Start playing for 4 seconds then pause.
      await applyFlush(tracker.onTrackChanged(track, isActivelyAudible: true));
      nowMs += 4000;
      await applyFlush(tracker.onAudibleStateChanged(false));

      var historyRows = await db.select(db.playHistoryEvents).get();
      var metaRows = await db.select(db.trackUserMeta).get();
      expect(historyRows, hasLength(1));
      expect(historyRows.single.listenedMs, 4000);
      expect(metaRows, isEmpty); // < 10s threshold, not counted as play yet

      // Sit paused for 2 minutes — must NOT add listening time!
      nowMs += 120000;

      // Resume for 8 seconds (total 12s >= 10s threshold).
      await applyFlush(tracker.onAudibleStateChanged(true));
      nowMs += 8000;
      await applyFlush(tracker.checkpoint());

      historyRows = await db.select(db.playHistoryEvents).get();
      metaRows = await db.select(db.trackUserMeta).get();
      expect(historyRows, hasLength(1)); // still single session row updated!
      expect(historyRows.single.listenedMs, 12000);
      expect(metaRows.single.playCount, 1);

      // Continue for another 18 seconds -> total 30s, playCount must stay 1.
      nowMs += 18000;
      await applyFlush(tracker.endCurrentSession());

      historyRows = await db.select(db.playHistoryEvents).get();
      metaRows = await db.select(db.trackUserMeta).get();
      expect(historyRows, hasLength(1));
      expect(historyRows.single.listenedMs, 30000);
      expect(metaRows.single.playCount, 1);
    },
  );

  test('Repeat-One rotation splits loop plays into distinct sessions', () {
    var nowMs = 5000000;
    final tracker = ListeningSessionTracker(clockMs: () => nowMs);
    final track = _sampleTrack(
      stableKey: '/music/short.mp3',
      title: 'Short',
      durationMs: 12000,
    );

    tracker.onTrackChanged(track, isActivelyAudible: true);
    nowMs += 12000;
    final firstPlay = tracker.rotateLoopOneSession(isActivelyAudible: true);
    expect(firstPlay, isNotNull);
    expect(firstPlay!.listenedMs, 12000);
    expect(firstPlay.recordPlayCountNow, isTrue);
    expect(firstPlay.isSessionEnded, isTrue);

    nowMs += 12000;
    final secondPlay = tracker.endCurrentSession();
    expect(secondPlay, isNotNull);
    expect(secondPlay!.sessionId, isNot(firstPlay.sessionId));
    expect(secondPlay.listenedMs, 12000);
    expect(secondPlay.recordPlayCountNow, isTrue);
  });

  test(
    'clearListeningHistory wipes play history while keeping favorites',
    () async {
      final db = WetarDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final track = _sampleTrack(
        stableKey: '/music/fav.mp3',
        title: 'Fav',
        durationMs: 180000,
      );
      final repo = LibraryRepository(db);
      await repo.toggleFavorite(track.stableKey, value: true);
      await repo.setRememberedPosition(track.stableKey, 45000);
      await repo.recordTrackPlay(track, listenedMs: 25000);

      expect(await db.select(db.playHistoryEvents).get(), hasLength(1));
      var meta = await (db.select(
        db.trackUserMeta,
      )..where((t) => t.stableKey.equals(track.stableKey))).getSingle();
      expect(meta.playCount, 1);
      expect(meta.isFavorite, isTrue);

      await repo.clearListeningHistory();

      expect(await db.select(db.playHistoryEvents).get(), isEmpty);
      meta = await (db.select(
        db.trackUserMeta,
      )..where((t) => t.stableKey.equals(track.stableKey))).getSingle();
      expect(meta.playCount, 0);
      expect(meta.lastPlayedAt, isNull);
      expect(meta.isFavorite, isTrue);
      expect(meta.rememberedPositionMs, 45000);
    },
  );
}
