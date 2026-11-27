import 'dart:math' as math;

import 'package:wetar/features/library/domain/library_models.dart';

/// Immutable persistence action emitted by [ListeningSessionTracker].
class ListeningSessionFlush {
  const ListeningSessionFlush({
    required this.sessionId,
    required this.track,
    required this.startedAtEpochMs,
    required this.listenedMs,
    required this.recordPlayCountNow,
    required this.isSessionEnded,
  });

  final int sessionId;
  final WetarTrack track;
  final int startedAtEpochMs;
  final int listenedMs;
  final bool recordPlayCountNow;
  final bool isSessionEnded;

  /// Ignores transient <1s taps and unplayed queue-restore selections.
  bool get shouldPersistHistory =>
      listenedMs >= ListeningSessionTracker.minHistoryRecordMs;
}

/// Tracks actual elapsed audible playback time per active track session.
///
/// Measures real wall-clock duration while the audio player is actively
/// playing (`playing == true` and `ready`), rather than assuming full track
/// duration on load or inflating durations across manual seeks.
class ListeningSessionTracker {
  ListeningSessionTracker({int Function()? clockMs})
    : _clockMs = clockMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  /// Minimum real audible milliseconds required before writing a history row.
  static const int minHistoryRecordMs = 1000;

  /// Guard against sudden system-clock leaps during a single uncheckpointed span.
  static const int maxSingleChunkMs = 4 * 3600 * 1000;

  /// Returns how many real audible milliseconds qualify as a counted play.
  ///
  /// Uses 10 seconds for standard tracks, or 50% of shorter tracks (minimum 3s).
  static int qualifyingPlayThresholdMs(int trackDurationMs) {
    if (trackDurationMs <= 0) return 10000;
    return math.min(10000, math.max(3000, trackDurationMs ~/ 2));
  }

  final int Function() _clockMs;

  int _nextSessionId = 0;
  int? _sessionId;
  WetarTrack? _activeTrack;
  int _startedAtEpochMs = 0;
  int _accumulatedMs = 0;
  int? _intervalStartMs;
  int _lastEmittedMs = 0;
  bool _playCountRecorded = false;
  bool _isAudible = false;

  WetarTrack? get activeTrack => _activeTrack;

  /// Live accumulated listening time for the current session in milliseconds.
  int currentSessionListenedMs() {
    if (_activeTrack == null) return 0;
    return _accumulatedMs + _openIntervalDeltaMs(_clockMs());
  }

  int _openIntervalDeltaMs(int nowMs) {
    final start = _intervalStartMs;
    if (start == null) return 0;
    final delta = nowMs - start;
    if (delta <= 0) return 0;
    return math.min(delta, maxSingleChunkMs);
  }

  void _commitOpenInterval(int nowMs, {required bool keepRunning}) {
    if (_intervalStartMs != null) {
      _accumulatedMs += _openIntervalDeltaMs(nowMs);
    }
    _intervalStartMs = keepRunning ? nowMs : null;
  }

  ListeningSessionFlush? _buildFlush({
    required bool isSessionEnded,
    bool forceOnEnd = false,
  }) {
    final track = _activeTrack;
    final id = _sessionId;
    if (track == null || id == null) return null;

    final qualifiesPlay =
        _accumulatedMs >= qualifyingPlayThresholdMs(track.durationMs);
    final shouldRecordPlay = qualifiesPlay && !_playCountRecorded;
    final changed = _accumulatedMs != _lastEmittedMs || shouldRecordPlay;

    if (!changed && !forceOnEnd) {
      return null;
    }

    if (shouldRecordPlay) {
      _playCountRecorded = true;
    }
    _lastEmittedMs = _accumulatedMs;

    return ListeningSessionFlush(
      sessionId: id,
      track: track,
      startedAtEpochMs: _startedAtEpochMs,
      listenedMs: _accumulatedMs,
      recordPlayCountNow: shouldRecordPlay,
      isSessionEnded: isSessionEnded,
    );
  }

  ListeningSessionFlush? _closeCurrentSession(int nowMs) {
    if (_activeTrack == null) return null;
    _commitOpenInterval(nowMs, keepRunning: false);
    final flush = _buildFlush(isSessionEnded: true, forceOnEnd: true);
    _activeTrack = null;
    _sessionId = null;
    _startedAtEpochMs = 0;
    _accumulatedMs = 0;
    _intervalStartMs = null;
    _lastEmittedMs = 0;
    _playCountRecorded = false;
    return flush;
  }

  void _openSession(
    WetarTrack? track,
    int nowMs, {
    required bool isActivelyAudible,
  }) {
    _isAudible = isActivelyAudible;
    if (track == null || track.isTemporaryExternal) {
      _activeTrack = null;
      _sessionId = null;
      _intervalStartMs = null;
      return;
    }
    _sessionId = ++_nextSessionId;
    _activeTrack = track;
    _startedAtEpochMs = nowMs;
    _accumulatedMs = 0;
    _lastEmittedMs = 0;
    _playCountRecorded = false;
    _intervalStartMs = isActivelyAudible ? nowMs : null;
  }

  /// Flushes the previous session (if any) and starts tracking [nextTrack].
  ListeningSessionFlush? onTrackChanged(
    WetarTrack? nextTrack, {
    required bool isActivelyAudible,
  }) {
    final nowMs = _clockMs();
    final endedFlush = _closeCurrentSession(nowMs);
    _openSession(nextTrack, nowMs, isActivelyAudible: isActivelyAudible);
    return endedFlush;
  }

  /// Starts or pauses the active listening stopwatch when playback starts/pauses.
  ListeningSessionFlush? onAudibleStateChanged(bool isActivelyAudible) {
    final nowMs = _clockMs();
    if (_activeTrack == null) {
      _isAudible = isActivelyAudible;
      return null;
    }
    if (isActivelyAudible == _isAudible) {
      return null;
    }
    _isAudible = isActivelyAudible;
    if (isActivelyAudible) {
      if (_accumulatedMs == 0 && _intervalStartMs == null) {
        _startedAtEpochMs = nowMs;
      }
      _intervalStartMs = nowMs;
      return null;
    }

    _commitOpenInterval(nowMs, keepRunning: false);
    return _buildFlush(isSessionEnded: false);
  }

  /// Commits elapsed time up to now and returns an incremental flush if dirty.
  ListeningSessionFlush? checkpoint() {
    if (_activeTrack == null) return null;
    final nowMs = _clockMs();
    _commitOpenInterval(nowMs, keepRunning: _isAudible);
    return _buildFlush(isSessionEnded: false);
  }

  /// Closes the current Repeat-One loop play and starts a fresh session for it.
  ListeningSessionFlush? rotateLoopOneSession({
    required bool isActivelyAudible,
  }) {
    final track = _activeTrack;
    if (track == null) return null;
    final nowMs = _clockMs();
    final endedFlush = _closeCurrentSession(nowMs);
    _openSession(track, nowMs, isActivelyAudible: isActivelyAudible);
    return endedFlush;
  }

  /// Ends the active session (e.g., on stop, queue clear, or app removal).
  ListeningSessionFlush? endCurrentSession() {
    if (_activeTrack == null) return null;
    return _closeCurrentSession(_clockMs());
  }
}
