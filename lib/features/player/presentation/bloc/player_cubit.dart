import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/player/data/wetar_audio_handler.dart';
import 'package:wetar/features/player/domain/queue_snapshot_codec.dart';
import 'package:wetar/features/player/domain/sleep_timer_config.dart';

class PlayerStateSnapshot extends Equatable {
  const PlayerStateSnapshot({
    this.queue = const <WetarTrack>[],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.speed = 1.0,
    this.pitch = 1.0,
    this.shuffleEnabled = false,
    this.repeatMode = WetarRepeatMode.off,
    this.sleepTimer = const SleepTimerState(),
    this.abLoop = const AbLoopState(),
    this.lastCorruptSkippedTitle,
  });

  final List<WetarTrack> queue;
  final int currentIndex;
  final bool isPlaying;
  final Duration position;
  final double speed;
  final double pitch;
  final bool shuffleEnabled;
  final WetarRepeatMode repeatMode;
  final SleepTimerState sleepTimer;
  final AbLoopState abLoop;
  final String? lastCorruptSkippedTitle;

  WetarTrack? get currentTrack {
    if (currentIndex < 0 || currentIndex >= queue.length) return null;
    return queue[currentIndex];
  }

  PlayerStateSnapshot copyWith({
    List<WetarTrack>? queue,
    int? currentIndex,
    bool? isPlaying,
    Duration? position,
    double? speed,
    double? pitch,
    bool? shuffleEnabled,
    WetarRepeatMode? repeatMode,
    SleepTimerState? sleepTimer,
    AbLoopState? abLoop,
    String? lastCorruptSkippedTitle,
    bool clearCorruptNotice = false,
  }) {
    return PlayerStateSnapshot(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      speed: speed ?? this.speed,
      pitch: pitch ?? this.pitch,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      sleepTimer: sleepTimer ?? this.sleepTimer,
      abLoop: abLoop ?? this.abLoop,
      lastCorruptSkippedTitle: clearCorruptNotice
          ? null
          : (lastCorruptSkippedTitle ?? this.lastCorruptSkippedTitle),
    );
  }

  @override
  List<Object?> get props => [
    queue,
    currentIndex,
    isPlaying,
    position,
    speed,
    pitch,
    shuffleEnabled,
    repeatMode,
    sleepTimer,
    abLoop,
    lastCorruptSkippedTitle,
  ];
}

/// Bridges UI playback intents to the singleton [WetarAudioHandler]
/// while pausing UI position ticks whenever the screen/app goes to background.
class PlayerCubit extends Cubit<PlayerStateSnapshot> {
  PlayerCubit(this._handler) : super(const PlayerStateSnapshot()) {
    _bindStreams();
  }

  final WetarAudioHandler _handler;
  bool _uiVisible = true;
  int _lastPositionEmitMs = 0;

  StreamSubscription<List<WetarTrack>>? _queueSub;
  StreamSubscription<int>? _indexSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<double>? _speedSub;
  StreamSubscription<double>? _pitchSub;
  StreamSubscription<bool>? _shuffleSub;
  StreamSubscription<WetarRepeatMode>? _repeatSub;
  StreamSubscription<SleepTimerState>? _sleepSub;
  StreamSubscription<AbLoopState>? _abSub;
  StreamSubscription<WetarTrack>? _corruptSub;

  void _bindStreams() {
    _queueSub = _handler.queueTracksStream.listen((q) {
      if (q.isEmpty) {
        emit(
          state.copyWith(queue: q, currentIndex: 0, position: Duration.zero),
        );
        return;
      }
      final safeIdx = _handler.currentIndex.clamp(0, q.length - 1);
      final prevKey = state.currentTrack?.stableKey;
      final sameTrack = prevKey != null && prevKey == q[safeIdx].stableKey;
      emit(
        state.copyWith(
          queue: q,
          currentIndex: safeIdx,
          position: sameTrack ? state.position : _handler.position,
        ),
      );
    });
    _indexSub = _handler.currentIndexStream.listen((i) {
      if (i == state.currentIndex) return;
      final nextTrack = (i >= 0 && i < state.queue.length)
          ? state.queue[i]
          : null;
      final sameTrack =
          nextTrack != null &&
          nextTrack.stableKey == state.currentTrack?.stableKey;
      emit(
        state.copyWith(
          currentIndex: i,
          position: sameTrack ? state.position : _handler.position,
        ),
      );
    });
    _playingSub = _handler.playingStream.listen((playing) {
      final syncedPos = state.queue.isEmpty ? Duration.zero : _handler.position;
      _lastPositionEmitMs = DateTime.now().millisecondsSinceEpoch;
      emit(state.copyWith(isPlaying: playing, position: syncedPos));
    });
    _speedSub = _handler.speedStream.listen((speed) {
      emit(state.copyWith(speed: speed));
    });
    _pitchSub = _handler.pitchStream.listen((pitch) {
      emit(state.copyWith(pitch: pitch));
    });
    _shuffleSub = _handler.shuffleStream.listen((shuffle) {
      emit(state.copyWith(shuffleEnabled: shuffle));
    });
    _repeatSub = _handler.repeatModeStream.listen((repeat) {
      emit(state.copyWith(repeatMode: repeat));
    });
    _sleepSub = _handler.sleepTimerStream.listen((timer) {
      emit(state.copyWith(sleepTimer: timer));
    });
    _abSub = _handler.abLoopStream.listen((ab) {
      emit(state.copyWith(abLoop: ab));
    });
    _corruptSub = _handler.corruptTrackSkippedStream.listen((track) {
      emit(state.copyWith(lastCorruptSkippedTitle: track.title));
    });
    _attachPositionListener();
  }

  void _attachPositionListener() {
    _posSub?.cancel();
    if (!_uiVisible) return;
    _posSub = _handler.positionStream.listen((pos) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final jumped =
          (pos - state.position).abs() >= const Duration(milliseconds: 900);
      if (!_handler.isPlaying || jumped || now - _lastPositionEmitMs >= 200) {
        _lastPositionEmitMs = now;
        emit(state.copyWith(position: pos));
      }
    });
  }

  /// Pauses UI position updates when the screen turns off or app backgrounds.
  void setUiVisible(bool visible) {
    if (_uiVisible == visible) return;
    _uiVisible = visible;
    if (visible) {
      emit(state.copyWith(position: _handler.position));
      _attachPositionListener();
    } else {
      _posSub?.cancel();
      _posSub = null;
    }
  }

  void clearCorruptNotice() {
    emit(state.copyWith(clearCorruptNotice: true));
  }

  Future<void> playTracks(List<WetarTrack> tracks, {int index = 0}) =>
      _handler.setQueueAndPlay(tracks, initialIndex: index);

  Future<void> shuffleAll(List<WetarTrack> tracks) async {
    if (tracks.isEmpty) return;
    final shuffled = List<WetarTrack>.from(tracks)..shuffle();
    await _handler.setQueueAndPlay(shuffled, initialIndex: 0);
  }

  Future<void> playExternal(WetarTrack tempTrack) =>
      _handler.playExternalTrack(tempTrack);

  Future<void> togglePlayPause() =>
      _handler.isPlaying ? _handler.pause() : _handler.play();

  Future<void> seek(Duration pos) {
    _lastPositionEmitMs = DateTime.now().millisecondsSinceEpoch;
    emit(state.copyWith(position: pos));
    return _handler.seek(pos);
  }

  Future<void> next() => _handler.skipToNext();
  Future<void> previous() => _handler.skipToPrevious();
  Future<void> skipToQueueIndex(int idx) => _handler.skipToQueueItem(idx);
  Future<void> playNext(WetarTrack track) => _handler.playNext(track);
  Future<void> addToQueue(List<WetarTrack> tracks) =>
      _handler.addToQueue(tracks);
  Future<void> removeFromQueueAt(int index) =>
      _handler.removeFromQueueAt(index);
  Future<void> reorderQueue(int oldIndex, int newIndex) =>
      _handler.reorderQueue(oldIndex, newIndex);
  Future<void> clearQueue() => _handler.clearQueue();

  /// Dismisses and clears the queue only when playback is paused.
  Future<void> dismissPausedPlayer() async {
    if (state.isPlaying) return;
    await _handler.clearQueue();
  }

  Future<void> toggleShuffle() => _handler.setShuffleMode(
    state.shuffleEnabled
        ? AudioServiceShuffleMode.none
        : AudioServiceShuffleMode.all,
  );

  Future<void> cycleRepeatMode() {
    final next = switch (state.repeatMode) {
      WetarRepeatMode.off => AudioServiceRepeatMode.all,
      WetarRepeatMode.all => AudioServiceRepeatMode.one,
      WetarRepeatMode.one => AudioServiceRepeatMode.none,
    };
    return _handler.setRepeatMode(next);
  }

  Future<void> setSpeed(double speed) => _handler.setSpeed(speed);
  Future<void> setPitch(double pitch) => _handler.setPitch(pitch);

  void setSleepTimerMinutes(int min) => _handler.setSleepTimerMinutes(min);
  void setSleepTimerEndOfTrack() => _handler.setSleepTimerEndOfTrack();
  void setSleepTimerAfterTracks(int count) =>
      _handler.setSleepTimerAfterTracks(count);
  void cancelSleepTimer() => _handler.cancelSleepTimer();

  void setAbPointA() => _handler.setAbLoopPointA();
  void setAbPointB() => _handler.setAbLoopPointB();
  void clearAbLoop() => _handler.clearAbLoop();

  @override
  Future<void> close() async {
    await _queueSub?.cancel();
    await _indexSub?.cancel();
    await _playingSub?.cancel();
    await _posSub?.cancel();
    await _speedSub?.cancel();
    await _pitchSub?.cancel();
    await _shuffleSub?.cancel();
    await _repeatSub?.cancel();
    await _sleepSub?.cancel();
    await _abSub?.cancel();
    await _corruptSub?.cancel();
    return super.close();
  }
}
