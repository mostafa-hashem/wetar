import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/player/data/wetar_audio_handler.dart';
import 'package:wetar/features/player/domain/queue_snapshot_codec.dart';
import 'package:wetar/features/player/domain/sleep_timer_config.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';

WetarTrack _track(String key) => WetarTrack(
  stableKey: key,
  folderId: 1,
  uri: 'file:///music/$key.mp3',
  filePath: '/music/$key.mp3',
  folderPath: '/music',
  title: key,
  artist: 'Artist',
  album: 'Album',
  albumArtist: 'Artist',
  genre: 'Genre',
  year: 2024,
  trackNumber: 1,
  discNumber: 1,
  durationMs: 200000,
  bitrateKbps: 256,
  sampleRateHz: 44100,
  channels: 2,
  sizeBytes: 1000,
  mimeType: 'audio/mpeg',
  dateModifiedSec: 1,
  dateAddedSec: 1,
);

class _FakeHandler implements WetarAudioHandler {
  final queueSubject = BehaviorSubject<List<WetarTrack>>.seeded(
    const <WetarTrack>[],
  );
  final index = BehaviorSubject<int>.seeded(0);
  final playing = BehaviorSubject<bool>.seeded(false);
  final positionTicks = StreamController<Duration>.broadcast();
  Duration currentPosition = Duration.zero;

  @override
  Stream<List<WetarTrack>> get queueTracksStream => queueSubject.stream;
  @override
  Stream<int> get currentIndexStream => index.stream;
  @override
  int get currentIndex => index.value;
  @override
  Stream<bool> get playingStream => playing.stream;
  @override
  bool get isPlaying => playing.value;
  @override
  Stream<double> get speedStream => const Stream<double>.empty();
  @override
  Stream<double> get pitchStream => const Stream<double>.empty();
  @override
  Stream<bool> get shuffleStream => const Stream<bool>.empty();
  @override
  Stream<WetarRepeatMode> get repeatModeStream =>
      const Stream<WetarRepeatMode>.empty();
  @override
  Stream<SleepTimerState> get sleepTimerStream =>
      const Stream<SleepTimerState>.empty();
  @override
  Stream<AbLoopState> get abLoopStream => const Stream<AbLoopState>.empty();
  @override
  Stream<WetarTrack> get corruptTrackSkippedStream =>
      const Stream<WetarTrack>.empty();
  @override
  Stream<Duration> get positionStream => positionTicks.stream;
  @override
  Duration get position => currentPosition;
  @override
  Future<void> seek(Duration position) async {
    currentPosition = position;
  }

  Future<void> dispose() async {
    await queueSubject.close();
    await index.close();
    await playing.close();
    await positionTicks.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  late _FakeHandler handler;
  late PlayerCubit cubit;

  setUp(() async {
    handler = _FakeHandler();
    cubit = PlayerCubit(handler);
    handler.queueSubject.add(<WetarTrack>[_track('a'), _track('b')]);
    await _settle();
    handler.playing.add(true);
    await _settle();
  });

  tearDown(() async {
    await cubit.close();
    await handler.dispose();
  });

  test(
    'pause keeps the paused position when the index is re-emitted',
    () async {
      handler.currentPosition = const Duration(seconds: 45);
      handler.positionTicks.add(handler.currentPosition);
      await _settle();
      handler.currentPosition = const Duration(seconds: 45, milliseconds: 140);
      handler.playing.add(false);
      handler.index.add(0);
      await _settle();
      expect(cubit.state.isPlaying, isFalse);
      expect(
        cubit.state.position,
        const Duration(seconds: 45, milliseconds: 140),
      );
    },
  );

  test('seeking while paused updates the position immediately', () async {
    handler.playing.add(false);
    await _settle();
    await cubit.seek(const Duration(seconds: 95));
    expect(cubit.state.position, const Duration(seconds: 95));
  });

  test('switching to a different track resets the position', () async {
    handler.currentPosition = const Duration(seconds: 30);
    handler.positionTicks.add(handler.currentPosition);
    await _settle();
    handler.currentPosition = Duration.zero;
    handler.index.add(1);
    await _settle();
    expect(cubit.state.currentIndex, 1);
    expect(cubit.state.position, Duration.zero);
  });

  test('reordering keeps the position when the track stays the same', () async {
    handler.index.add(1);
    await _settle();
    handler.currentPosition = const Duration(seconds: 20);
    handler.positionTicks.add(handler.currentPosition);
    await _settle();
    handler.queueSubject.add(<WetarTrack>[_track('b'), _track('a')]);
    handler.index.add(0);
    await _settle();
    expect(cubit.state.currentTrack?.stableKey, 'b');
    expect(cubit.state.position, const Duration(seconds: 20));
  });
}
