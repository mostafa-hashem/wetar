import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:drift/drift.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/capabilities/platform_capabilities.dart';
import '../../../core/database/wetar_database.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/platform/platform_interfaces.dart';
import '../../../core/widgets/wetar_artwork_image.dart';
import '../../library/data/library_repository.dart';
import '../../library/domain/library_models.dart';
import '../../settings/data/settings_repository.dart';
import '../../settings/domain/playback_settings.dart';
import '../domain/listening_session_tracker.dart';
import '../domain/queue_snapshot_codec.dart';
import '../domain/replay_gain_math.dart';
import '../domain/sleep_timer_config.dart';

/// Single source of truth for all audio playback, queue management,
/// audio focus, interruptions, ReplayGain, A–B loop, sleep timer, and state restoration.
class WetarAudioHandler extends BaseAudioHandler with SeekHandler {
  WetarAudioHandler({
    required WetarDatabase db,
    required LibraryRepository libraryRepo,
    required SettingsRepository settingsRepo,
    required NativeAudioEffectsService nativeEffects,
    required SystemIntegrationService systemService,
    required ThumbnailPathCache thumbnailCache,
    required PlatformCapabilities capabilities,
  }) : _db = db,
       _libraryRepo = libraryRepo,
       _settingsRepo = settingsRepo,
       _nativeEffects = nativeEffects,
       _systemService = systemService,
       _thumbnailCache = thumbnailCache,
       _capabilities = capabilities {
    _androidEqualizer = Platform.isAndroid ? AndroidEqualizer() : null;
    _androidLoudness = Platform.isAndroid ? AndroidLoudnessEnhancer() : null;
    _player = AudioPlayer(
      audioPipeline: Platform.isAndroid
          ? AudioPipeline(
              androidAudioEffects: <AndroidAudioEffect>[
                _androidEqualizer!,
                _androidLoudness!,
              ],
            )
          : null,
    );
    _settings = _settingsRepo.loadPlayback();
    unawaited(_initAudioSessionAndListeners());
  }

  final WetarDatabase _db;
  final LibraryRepository _libraryRepo;
  final SettingsRepository _settingsRepo;
  final NativeAudioEffectsService _nativeEffects;
  final SystemIntegrationService _systemService;
  final ThumbnailPathCache _thumbnailCache;
  final PlatformCapabilities _capabilities;

  late final AudioPlayer _player;
  AndroidEqualizer? _androidEqualizer;
  AndroidLoudnessEnhancer? _androidLoudness;
  late PlaybackSettings _settings;

  final BehaviorSubject<List<WetarTrack>> _queueTracksSubject =
      BehaviorSubject<List<WetarTrack>>.seeded(const <WetarTrack>[]);
  final BehaviorSubject<int> _currentIndexSubject = BehaviorSubject<int>.seeded(
    0,
  );
  final BehaviorSubject<SleepTimerState> _sleepTimerSubject =
      BehaviorSubject<SleepTimerState>.seeded(const SleepTimerState());
  final BehaviorSubject<AbLoopState> _abLoopSubject =
      BehaviorSubject<AbLoopState>.seeded(const AbLoopState());
  final BehaviorSubject<WetarRepeatMode> _repeatModeSubject =
      BehaviorSubject<WetarRepeatMode>.seeded(WetarRepeatMode.off);
  final BehaviorSubject<bool> _shuffleSubject = BehaviorSubject<bool>.seeded(
    false,
  );
  final PublishSubject<WetarTrack> _corruptSkippedSubject =
      PublishSubject<WetarTrack>();

  bool _resumeAfterInterruption = false;
  bool _isFading = false;
  int _lastPersistMs = 0;
  int _lastHistoryCheckpointMs = 0;
  int _lastObservedPosMs = 0;
  int _lastManualSeekEpochMs = 0;
  String? _activeTrackKey;
  Duration? _pendingInitialPosition;
  final ListeningSessionTracker _listeningTracker = ListeningSessionTracker();
  final Map<int, int> _sessionHistoryRowIds = <int, int>{};
  Future<void> _listeningFlushTail = Future<void>.value();
  Timer? _sleepTimerTicker;
  StreamSubscription<PlaybackEvent>? _eventSub;
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<int?>? _sessionIdSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<void>? _noisySub;
  StreamSubscription<AudioDevicesChangedEvent>? _devicesSub;

  AndroidEqualizer? get androidEqualizer => _androidEqualizer;
  AndroidLoudnessEnhancer? get androidLoudness => _androidLoudness;

  Stream<List<WetarTrack>> get queueTracksStream => _queueTracksSubject.stream;
  List<WetarTrack> get queueTracks => _queueTracksSubject.value;

  Stream<int> get currentIndexStream => _currentIndexSubject.stream;
  int get currentIndex => _currentIndexSubject.value;

  WetarTrack? get currentTrack {
    final idx = _currentIndexSubject.value;
    final list = _queueTracksSubject.value;
    if (idx < 0 || idx >= list.length) return null;
    return list[idx];
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Duration get position => _pendingInitialPosition ?? _player.position;
  Stream<bool> get playingStream => _player.playingStream;
  bool get isPlaying => _player.playing;
  Stream<double> get speedStream => _player.speedStream;
  Stream<double> get pitchStream => _player.pitchStream;
  Stream<bool> get shuffleStream => _shuffleSubject.stream;
  Stream<WetarRepeatMode> get repeatModeStream => _repeatModeSubject.stream;
  Stream<SleepTimerState> get sleepTimerStream => _sleepTimerSubject.stream;
  Stream<AbLoopState> get abLoopStream => _abLoopSubject.stream;
  Stream<WetarTrack> get corruptTrackSkippedStream =>
      _corruptSkippedSubject.stream;

  Future<void> _initAudioSessionAndListeners() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      _interruptionSub = session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              unawaited(_player.setVolume(_targetTrackVolume() * 0.3));
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              _resumeAfterInterruption = _player.playing;
              if (_player.playing) unawaited(pause());
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              unawaited(_player.setVolume(_targetTrackVolume()));
            case AudioInterruptionType.pause:
              if (_resumeAfterInterruption) {
                _resumeAfterInterruption = false;
                unawaited(play());
              }
            case AudioInterruptionType.unknown:
              _resumeAfterInterruption = false;
          }
        }
      });

      _noisySub = session.becomingNoisyEventStream.listen((_) {
        if (_player.playing) {
          AppLogger.info('AudioHandler', 'Becoming noisy: pausing playback');
          unawaited(pause());
        }
      });

      _devicesSub = session.devicesChangedEventStream.listen((event) {
        if (_settings.autoPlayOnHeadsetConnect &&
            event.devicesAdded.any((d) => d.isOutput) &&
            !_player.playing &&
            currentTrack != null) {
          unawaited(play());
        }
      });
    } catch (e, st) {
      AppLogger.error(
        'AudioHandler',
        'AudioSession init failed',
        errorObj: e,
        stackTrace: st,
      );
    }

    _eventSub = _player.playbackEventStream.listen(
      _broadcastPlaybackState,
      onError: (Object e, StackTrace st) {
        AppLogger.warn('AudioHandler', 'Playback stream error: $e');
        unawaited(_handlePlaybackFailure());
      },
    );

    _indexSub = _player.currentIndexStream.listen((idx) {
      if (idx == null) return;
      final list = _queueTracksSubject.value;
      if (idx < 0 || idx >= list.length) return;
      final previousIdx = _currentIndexSubject.value;
      final indexChanged = previousIdx != idx;
      if (indexChanged) {
        _currentIndexSubject.add(idx);
      }
      final track = list[idx];
      final trackChanged = _activeTrackKey != track.stableKey;
      if (!indexChanged && !trackChanged) return;
      _activeTrackKey = track.stableKey;
      unawaited(_onActiveTrackChanged(track, indexChanged || trackChanged));
    });

    _durationSub = _player.durationStream.listen((dur) {
      if (dur == null || dur.inMilliseconds <= 0) return;
      final idx = _currentIndexSubject.value;
      final list = _queueTracksSubject.value;
      if (idx < 0 || idx >= list.length) return;
      final current = list[idx];
      if (current.durationMs > 0) return;
      final updated = current.copyWith(durationMs: dur.inMilliseconds);
      final nextList = List<WetarTrack>.from(list);
      nextList[idx] = updated;
      _queueTracksSubject.add(List<WetarTrack>.unmodifiable(nextList));
      mediaItem.add(_toMediaItem(updated, artUri: mediaItem.value?.artUri));
      if (!updated.isTemporaryExternal) {
        unawaited(
          _libraryRepo.updateTrackDurationMs(
            updated.stableKey,
            dur.inMilliseconds,
          ),
        );
      }
    });

    _posSub = _player.positionStream.listen((pos) {
      _handlePositionTick(pos);
    });

    _playerStateSub = _player.playerStateStream.listen((state) {
      _broadcastPlaybackState(_player.playbackEvent);
      unawaited(
        _enqueueListeningFlush(
          _listeningTracker.onAudibleStateChanged(_isActivelyAudible),
        ),
      );
      if (state.processingState == ProcessingState.completed) {
        unawaited(_handleQueueCompleted());
      }
    });

    if (Platform.isAndroid) {
      _sessionIdSub = _player.androidAudioSessionIdStream.listen((sessionId) {
        if (sessionId != null && sessionId > 0) {
          unawaited(_nativeEffects.attachSession(sessionId));
        }
      });
    }

    await applyPlaybackSettings(_settings);
  }

  Future<void> applyPlaybackSettings(PlaybackSettings next) async {
    _settings = next;
    try {
      await _player.setSpeed(next.playbackSpeed);
      if (_capabilities.supportsPitchControl) {
        await _player.setPitch(next.playbackPitch);
      }
      if (_capabilities.supportsSkipSilence) {
        await _player.setSkipSilenceEnabled(next.skipSilence);
      }
      if (!_isFading) {
        await _player.setVolume(_targetTrackVolume());
      }
    } catch (e) {
      AppLogger.warn('AudioHandler', 'Failed applying playback settings: $e');
    }
  }

  double _targetTrackVolume() {
    final track = currentTrack;
    if (track == null) return 1.0;
    return ReplayGainCalculator.computeLinearVolume(
      mode: _settings.replayGainMode,
      preampDb: _settings.replayGainPreampDb,
      trackGainDb: track.replayGainTrackDb,
      albumGainDb: track.replayGainAlbumDb,
    );
  }

  /// Restores the last persisted queue, active index, and millisecond offset lazily.
  Future<void> restorePersistedQueue() async {
    try {
      final snapshot = await (_db.select(
        _db.queueSnapshots,
      )..where((t) => t.id.equals(1))).getSingleOrNull();
      if (snapshot == null) return;
      final decoded = PersistedQueueState.decode(
        itemsJson: snapshot.itemsJson,
        currentIndex: snapshot.currentIndex,
        positionMs: snapshot.positionMs,
        shuffleEnabled: snapshot.shuffleEnabled,
        repeatModeName: snapshot.repeatMode,
      );
      if (decoded.trackStableKeys.isEmpty) return;
      final resolvedTracks = await _libraryRepo.findTracksByStableKeys(
        decoded.trackStableKeys,
      );
      if (resolvedTracks.isEmpty) return;

      final safeIndex = decoded.currentIndex.clamp(
        0,
        resolvedTracks.length - 1,
      );
      await setQueueAndPlay(
        resolvedTracks,
        initialIndex: safeIndex,
        initialPosition: Duration(milliseconds: decoded.positionMs),
        autoPlay: false,
      );
      await setShuffleMode(
        decoded.shuffleEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      );
      await setRepeatMode(switch (decoded.repeatMode) {
        WetarRepeatMode.off => AudioServiceRepeatMode.none,
        WetarRepeatMode.all => AudioServiceRepeatMode.all,
        WetarRepeatMode.one => AudioServiceRepeatMode.one,
      });
    } catch (e, st) {
      AppLogger.error(
        'AudioHandler',
        'restorePersistedQueue failed',
        errorObj: e,
        stackTrace: st,
      );
    }
  }

  Future<void> setQueueAndPlay(
    List<WetarTrack> tracks, {
    int initialIndex = 0,
    Duration? initialPosition,
    bool autoPlay = true,
  }) async {
    if (tracks.isEmpty) return;
    final clampedIdx = initialIndex.clamp(0, tracks.length - 1);
    final selectedTrack = tracks[clampedIdx];
    final resumePos =
        initialPosition ??
        (_settings.rememberLongTrackPosition &&
                selectedTrack.durationMs >= 15 * 60 * 1000 &&
                (selectedTrack.rememberedPositionMs ?? 0) > 2000
            ? Duration(milliseconds: selectedTrack.rememberedPositionMs!)
            : Duration.zero);

    _activeTrackKey = selectedTrack.stableKey;
    _pendingInitialPosition = resumePos;
    if (_currentIndexSubject.value != clampedIdx) {
      _currentIndexSubject.add(clampedIdx);
    }
    _queueTracksSubject.add(List<WetarTrack>.unmodifiable(tracks));
    _abLoopSubject.add(const AbLoopState());
    await _syncMediaQueue(tracks);

    try {
      await _player.setAudioSources(
        tracks.map(_buildAudioSource).toList(),
        initialIndex: clampedIdx,
        initialPosition: resumePos,
        preload: true,
      );
      if (resumePos > Duration.zero &&
          (_player.position - resumePos).abs() >
              const Duration(milliseconds: 500)) {
        await _player.seek(resumePos);
      }
      _pendingInitialPosition = null;
      await _onActiveTrackChanged(selectedTrack, true);
      if (autoPlay) {
        await play();
      } else {
        await _persistQueueSnapshot(force: true);
      }
    } catch (e, st) {
      _pendingInitialPosition = null;
      AppLogger.error(
        'AudioHandler',
        'setQueueAndPlay failed',
        errorObj: e,
        stackTrace: st,
      );
      await _handlePlaybackFailure();
    }
  }

  Future<void> playExternalTrack(WetarTrack tempTrack) async {
    await setQueueAndPlay(
      <WetarTrack>[tempTrack],
      initialIndex: 0,
      autoPlay: true,
    );
  }

  Future<void> playNext(WetarTrack track) async {
    final list = List<WetarTrack>.from(_queueTracksSubject.value);
    if (list.isEmpty) {
      await setQueueAndPlay(<WetarTrack>[track]);
      return;
    }
    final insertAt = (_currentIndexSubject.value + 1).clamp(0, list.length);
    list.insert(insertAt, track);
    _queueTracksSubject.add(List<WetarTrack>.unmodifiable(list));
    await _player.insertAudioSource(insertAt, _buildAudioSource(track));
    await _syncMediaQueue(list);
    await _persistQueueSnapshot(force: true);
  }

  Future<void> addToQueue(List<WetarTrack> tracks) async {
    if (tracks.isEmpty) return;
    final list = List<WetarTrack>.from(_queueTracksSubject.value);
    if (list.isEmpty) {
      await setQueueAndPlay(tracks);
      return;
    }
    list.addAll(tracks);
    _queueTracksSubject.add(List<WetarTrack>.unmodifiable(list));
    await _player.addAudioSources(tracks.map(_buildAudioSource).toList());
    await _syncMediaQueue(list);
    await _persistQueueSnapshot(force: true);
  }

  Future<void> removeFromQueueAt(int index) async {
    final list = List<WetarTrack>.from(_queueTracksSubject.value);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    if (list.isEmpty) {
      await clearQueue();
      return;
    }
    _queueTracksSubject.add(List<WetarTrack>.unmodifiable(list));
    await _player.removeAudioSourceAt(index);
    await _syncMediaQueue(list);
    await _persistQueueSnapshot(force: true);
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    final list = List<WetarTrack>.from(_queueTracksSubject.value);
    if (oldIndex < 0 || oldIndex >= list.length) return;
    final targetIndex = newIndex.clamp(0, list.length - 1);
    if (targetIndex == oldIndex) return;
    final moved = list.removeAt(oldIndex);
    list.insert(targetIndex, moved);
    _queueTracksSubject.add(List<WetarTrack>.unmodifiable(list));
    await _player.moveAudioSource(oldIndex, targetIndex);
    await _syncMediaQueue(list);
    await _persistQueueSnapshot(force: true);
  }

  bool get _isActivelyAudible =>
      _player.playing && _player.processingState == ProcessingState.ready;

  /// Flushes accumulated listening time for the current track session to storage.
  Future<void> flushListeningSession({bool endSession = false}) {
    final flush = endSession
        ? _listeningTracker.endCurrentSession()
        : _listeningTracker.checkpoint();
    return _enqueueListeningFlush(flush);
  }

  Future<void> _enqueueListeningFlush(ListeningSessionFlush? flush) {
    if (flush == null) return _listeningFlushTail;
    _listeningFlushTail = _listeningFlushTail
        .catchError((_) {})
        .then((_) => _applyListeningFlush(flush));
    return _listeningFlushTail;
  }

  Future<void> _applyListeningFlush(ListeningSessionFlush flush) async {
    try {
      if (flush.shouldPersistHistory) {
        final existingId = _sessionHistoryRowIds[flush.sessionId];
        final rowId = await _libraryRepo.upsertPlayHistorySession(
          eventId: existingId,
          track: flush.track,
          playedAtMs: flush.startedAtEpochMs,
          listenedMs: flush.listenedMs,
        );
        if (rowId != null && !flush.isSessionEnded) {
          _sessionHistoryRowIds[flush.sessionId] = rowId;
        }
      }
      if (flush.recordPlayCountNow) {
        await _libraryRepo.incrementTrackPlayCount(
          flush.track,
          playedAtMs: flush.startedAtEpochMs,
        );
      }
    } catch (e, st) {
      AppLogger.warn('AudioHandler', 'Listening history flush failed: $e\n$st');
    } finally {
      if (flush.isSessionEnded) {
        _sessionHistoryRowIds.remove(flush.sessionId);
      }
    }
  }

  Future<void> clearQueue() async {
    cancelSleepTimer();
    final current = currentTrack;
    final posMs = _player.position.inMilliseconds;
    if (current != null &&
        !current.isTemporaryExternal &&
        _settings.rememberLongTrackPosition &&
        current.durationMs >= 15 * 60 * 1000 &&
        posMs > 2000) {
      unawaited(_libraryRepo.setRememberedPosition(current.stableKey, posMs));
    }
    await flushListeningSession(endSession: true);
    await _player.stop();
    _activeTrackKey = null;
    _pendingInitialPosition = null;
    _queueTracksSubject.add(const <WetarTrack>[]);
    _currentIndexSubject.add(0);
    _abLoopSubject.add(const AbLoopState());
    mediaItem.add(null);
    queue.add(const <MediaItem>[]);
    playbackState.add(
      playbackState.value.copyWith(
        controls: const <MediaControl>[],
        androidCompactActionIndices: const <int>[],
        playing: false,
        processingState: AudioProcessingState.idle,
        updatePosition: Duration.zero,
      ),
    );
    await _db.delete(_db.queueSnapshots).go();
    await _systemService.updateHomeWidget(
      title: null,
      artist: null,
      artworkPath: null,
      isPlaying: false,
    );
  }

  AudioSource _buildAudioSource(WetarTrack track) {
    final Uri uri =
        track.uri.startsWith('content://') || track.uri.startsWith('file://')
        ? Uri.parse(track.uri)
        : Uri.file(track.filePath);
    return AudioSource.uri(uri, tag: _toMediaItem(track));
  }

  MediaItem _toMediaItem(WetarTrack track, {Uri? artUri}) {
    return MediaItem(
      id: track.stableKey,
      title: track.title,
      artist: track.displayArtist,
      album: track.displayAlbum,
      duration: track.duration,
      artUri: artUri,
      extras: <String, Object?>{
        'filePath': track.filePath,
        'isTemp': track.isTemporaryExternal,
      },
    );
  }

  Future<void> _syncMediaQueue(List<WetarTrack> tracks) async {
    queue.add(tracks.map(_toMediaItem).toList());
  }

  Future<void> _onActiveTrackChanged(
    WetarTrack track,
    bool indexChanged,
  ) async {
    if (indexChanged) {
      _abLoopSubject.add(const AbLoopState());
    }
    if (!_isFading) {
      await _player.setVolume(_targetTrackVolume());
    }
    String? cachedArtPath;
    if (!track.isTemporaryExternal) {
      cachedArtPath = await _thumbnailCache.resolve(
        cacheKey: track.albumKey,
        customArtPath: track.customArtPath,
        artworkUri: track.artworkUri,
        filePath: track.filePath,
        sizePx: 320,
      );
    }
    final artUri = cachedArtPath != null ? Uri.file(cachedArtPath) : null;
    mediaItem.add(_toMediaItem(track, artUri: artUri));
    await _systemService.updateHomeWidget(
      title: track.title,
      artist: track.displayArtist,
      artworkPath: cachedArtPath,
      isPlaying: _player.playing,
    );

    if (indexChanged ||
        _listeningTracker.activeTrack?.stableKey != track.stableKey) {
      unawaited(
        _enqueueListeningFlush(
          _listeningTracker.onTrackChanged(
            track,
            isActivelyAudible: _isActivelyAudible,
          ),
        ),
      );
      _lastObservedPosMs = _player.position.inMilliseconds;
    }

    if (indexChanged) {
      _checkAfterTracksSleepTimer();
      await _persistQueueSnapshot(force: true);
    }
  }

  void _checkAfterTracksSleepTimer() {
    final timer = _sleepTimerSubject.value;
    if (timer.mode == SleepTimerMode.endOfTrack) {
      unawaited(_fadeOutAndPauseTimer());
    } else if (timer.mode == SleepTimerMode.afterTracks) {
      final nextCount = timer.remainingTracks - 1;
      if (nextCount <= 0) {
        unawaited(_fadeOutAndPauseTimer());
      } else {
        _sleepTimerSubject.add(
          SleepTimerState(
            mode: SleepTimerMode.afterTracks,
            remainingTracks: nextCount,
          ),
        );
      }
    }
  }

  void setSleepTimerMinutes(int minutes) {
    _sleepTimerTicker?.cancel();
    if (minutes <= 0) {
      cancelSleepTimer();
      return;
    }
    var remaining = Duration(minutes: minutes);
    _sleepTimerSubject.add(
      SleepTimerState(
        mode: SleepTimerMode.duration,
        remainingDuration: remaining,
      ),
    );
    _sleepTimerTicker = Timer.periodic(const Duration(seconds: 1), (t) {
      remaining -= const Duration(seconds: 1);
      if (remaining <= Duration.zero) {
        t.cancel();
        unawaited(_fadeOutAndPauseTimer());
      } else {
        _sleepTimerSubject.add(
          SleepTimerState(
            mode: SleepTimerMode.duration,
            remainingDuration: remaining,
          ),
        );
      }
    });
  }

  void setSleepTimerEndOfTrack() {
    _sleepTimerTicker?.cancel();
    _sleepTimerSubject.add(
      const SleepTimerState(mode: SleepTimerMode.endOfTrack),
    );
  }

  void setSleepTimerAfterTracks(int count) {
    _sleepTimerTicker?.cancel();
    _sleepTimerSubject.add(
      SleepTimerState(
        mode: SleepTimerMode.afterTracks,
        remainingTracks: count.clamp(1, 50),
      ),
    );
  }

  void cancelSleepTimer() {
    _sleepTimerTicker?.cancel();
    _sleepTimerSubject.add(const SleepTimerState());
  }

  Future<void> _fadeOutAndPauseTimer() async {
    _sleepTimerTicker?.cancel();
    _sleepTimerSubject.add(const SleepTimerState());
    if (_player.playing) {
      await _rampVolume(_targetTrackVolume(), 0.0, const Duration(seconds: 3));
      await _player.pause();
      await _player.setVolume(_targetTrackVolume());
    }
  }

  void setAbLoopPointA() {
    final pos = _player.position;
    final current = _abLoopSubject.value;
    final clearB = current.pointB != null && current.pointB! <= pos;
    _abLoopSubject.add(
      AbLoopState(pointA: pos, pointB: clearB ? null : current.pointB),
    );
  }

  void setAbLoopPointB() {
    final pos = _player.position;
    final a = _abLoopSubject.value.pointA ?? Duration.zero;
    if (pos <= a) return;
    _abLoopSubject.add(AbLoopState(pointA: a, pointB: pos));
  }

  void clearAbLoop() {
    _abLoopSubject.add(const AbLoopState());
  }

  void _handlePositionTick(Duration pos) {
    final ab = _abLoopSubject.value;
    if (ab.isEnabled && pos >= ab.pointB!) {
      unawaited(_player.seek(ab.pointA!));
      return;
    }

    final posMs = pos.inMilliseconds;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final recentlySought = nowMs - _lastManualSeekEpochMs < 1500;
    if (!recentlySought &&
        _repeatModeSubject.value == WetarRepeatMode.one &&
        _lastObservedPosMs > 5000 &&
        posMs < 1500 &&
        _listeningTracker.currentSessionListenedMs() >= 3000) {
      unawaited(
        _enqueueListeningFlush(
          _listeningTracker.rotateLoopOneSession(
            isActivelyAudible: _isActivelyAudible,
          ),
        ),
      );
    }
    _lastObservedPosMs = posMs;

    if (_isActivelyAudible && nowMs - _lastHistoryCheckpointMs >= 5000) {
      _lastHistoryCheckpointMs = nowMs;
      unawaited(flushListeningSession());
    }

    if (_player.playing && nowMs - _lastPersistMs >= 10000) {
      unawaited(_persistQueueSnapshot());
    }
  }

  Future<void> _handleQueueCompleted() async {
    if (_sleepTimerSubject.value.mode == SleepTimerMode.endOfTrack) {
      cancelSleepTimer();
    }
    await flushListeningSession();
    await _persistQueueSnapshot(force: true);
  }

  Future<void> _handlePlaybackFailure() async {
    final failed = currentTrack;
    if (failed == null) return;
    if (!failed.isTemporaryExternal) {
      await _libraryRepo.markCorruptOrMissing(failed.stableKey, true);
    }
    _corruptSkippedSubject.add(failed);
    if (_player.hasNext) {
      await skipToNext();
    } else {
      await pause();
    }
  }

  @override
  Future<void> play() async {
    if (_player.playing) return;
    final targetVol = _targetTrackVolume();
    if (_settings.fadeOnPlayPause) {
      await _player.setVolume(0.05);
      unawaited(_player.play());
      await _rampVolume(0.05, targetVol, const Duration(milliseconds: 180));
    } else {
      await _player.setVolume(targetVol);
      await _player.play();
    }
    await _systemService.updateHomeWidget(
      title: currentTrack?.title,
      artist: currentTrack?.displayArtist,
      artworkPath: mediaItem.value?.artUri?.toFilePath(),
      isPlaying: true,
    );
  }

  @override
  Future<void> pause() async {
    if (_settings.fadeOnPlayPause && _player.playing) {
      await _rampVolume(
        _targetTrackVolume(),
        0.05,
        const Duration(milliseconds: 160),
      );
    }
    await _player.pause();
    await flushListeningSession();
    await _player.setVolume(_targetTrackVolume());
    await _persistQueueSnapshot(force: true);
    await _systemService.updateHomeWidget(
      title: currentTrack?.title,
      artist: currentTrack?.displayArtist,
      artworkPath: mediaItem.value?.artUri?.toFilePath(),
      isPlaying: false,
    );
  }

  Future<void> _rampVolume(double from, double to, Duration duration) async {
    _isFading = true;
    const steps = 6;
    final stepDelay = Duration(
      milliseconds: (duration.inMilliseconds / steps).round().clamp(10, 500),
    );
    try {
      for (var i = 1; i <= steps; i++) {
        final vol = from + (to - from) * (i / steps);
        await _player.setVolume(vol.clamp(0.0, 1.0));
        await Future<void>.delayed(stepDelay);
      }
    } finally {
      _isFading = false;
    }
  }

  @override
  Future<void> seek(Duration position) {
    _pendingInitialPosition = null;
    _lastManualSeekEpochMs = DateTime.now().millisecondsSinceEpoch;
    _lastObservedPosMs = position.inMilliseconds;
    return _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
      if (!_player.playing) await play();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _queueTracksSubject.value.length) return;
    await _player.seek(Duration.zero, index: index);
    if (!_player.playing) await play();
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode != AudioServiceShuffleMode.none;
    _shuffleSubject.add(enabled);
    await _player.setShuffleModeEnabled(enabled);
    await _persistQueueSnapshot(force: true);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final WetarRepeatMode mode;
    final LoopMode loop;
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        mode = WetarRepeatMode.off;
        loop = LoopMode.off;
      case AudioServiceRepeatMode.one:
        mode = WetarRepeatMode.one;
        loop = LoopMode.one;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        mode = WetarRepeatMode.all;
        loop = LoopMode.all;
    }
    _repeatModeSubject.add(mode);
    await _player.setLoopMode(loop);
    await _persistQueueSnapshot(force: true);
  }

  @override
  Future<void> setSpeed(double speed) async {
    final clamped = speed.clamp(0.5, 2.5);
    await _player.setSpeed(clamped);
    _settings = _settings.copyWith(playbackSpeed: clamped);
    await _settingsRepo.savePlayback(_settings);
  }

  Future<void> setPitch(double pitch) async {
    if (!_capabilities.supportsPitchControl) return;
    final clamped = pitch.clamp(0.5, 2.0);
    await _player.setPitch(clamped);
    _settings = _settings.copyWith(playbackPitch: clamped);
    await _settingsRepo.savePlayback(_settings);
  }

  Future<void> _persistQueueSnapshot({bool force = false}) async {
    final list = _queueTracksSubject.value;
    if (list.isEmpty) return;
    final persistedList = list.where((t) => !t.isTemporaryExternal).toList();
    if (persistedList.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (!force && now - _lastPersistMs < 8000) return;
    _lastPersistMs = now;

    final posMs = _player.position.inMilliseconds;
    final current = currentTrack;
    if (current != null &&
        !current.isTemporaryExternal &&
        _settings.rememberLongTrackPosition &&
        current.durationMs >= 15 * 60 * 1000) {
      unawaited(_libraryRepo.setRememberedPosition(current.stableKey, posMs));
    }

    final snapshot = PersistedQueueState(
      trackStableKeys: persistedList.map((t) => t.stableKey).toList(),
      currentIndex: _currentIndexSubject.value.clamp(
        0,
        persistedList.length - 1,
      ),
      positionMs: posMs,
      shuffleEnabled: _shuffleSubject.value,
      repeatMode: _repeatModeSubject.value,
    );

    await _db
        .into(_db.queueSnapshots)
        .insert(
          QueueSnapshotsCompanion.insert(
            id: const Value(1),
            itemsJson: snapshot.encodeItems(),
            currentIndex: Value(snapshot.currentIndex),
            positionMs: Value(snapshot.positionMs),
            shuffleEnabled: Value(snapshot.shuffleEnabled),
            repeatMode: Value(snapshot.repeatMode.name),
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  void _broadcastPlaybackState(PlaybackEvent event) {
    if (_queueTracksSubject.value.isEmpty) {
      playbackState.add(
        playbackState.value.copyWith(
          controls: const <MediaControl>[],
          androidCompactActionIndices: const <int>[],
          playing: false,
          processingState: AudioProcessingState.idle,
          updatePosition: Duration.zero,
        ),
      );
      return;
    }
    final playing = _player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: <MediaControl>[
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const <MediaAction>{
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const <int>[0, 1, 2],
        processingState: switch (_player.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
        shuffleMode: _shuffleSubject.value
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        repeatMode: switch (_repeatModeSubject.value) {
          WetarRepeatMode.off => AudioServiceRepeatMode.none,
          WetarRepeatMode.all => AudioServiceRepeatMode.all,
          WetarRepeatMode.one => AudioServiceRepeatMode.one,
        },
      ),
    );
  }

  @override
  Future<void> onTaskRemoved() async {
    await flushListeningSession(endSession: true);
    await _persistQueueSnapshot(force: true);
    await super.onTaskRemoved();
  }

  @override
  Future<void> stop() async {
    await flushListeningSession(endSession: true);
    await _persistQueueSnapshot(force: true);
    await _player.stop();
    await super.stop();
  }

  Future<void> disposeHandler() async {
    await flushListeningSession(endSession: true);
    _sleepTimerTicker?.cancel();
    await _eventSub?.cancel();
    await _indexSub?.cancel();
    await _durationSub?.cancel();
    await _posSub?.cancel();
    await _sessionIdSub?.cancel();
    await _playerStateSub?.cancel();
    await _interruptionSub?.cancel();
    await _noisySub?.cancel();
    await _devicesSub?.cancel();
    await _queueTracksSubject.close();
    await _currentIndexSubject.close();
    await _sleepTimerSubject.close();
    await _abLoopSubject.close();
    await _repeatModeSubject.close();
    await _shuffleSubject.close();
    await _corruptSkippedSubject.close();
    await _player.dispose();
  }
}
