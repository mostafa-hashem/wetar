import 'package:equatable/equatable.dart';

import '../../../core/utils/artist_splitter.dart';
import '../../../core/utils/numeral_formatter.dart';

enum ReplayGainMode { off, track, album }

/// Typed, versioned playback, library, and locale preferences.
class PlaybackSettings extends Equatable {
  const PlaybackSettings({
    this.schemaVersion = 1,
    this.localeCode = 'ar',
    this.numeralStyle = NumeralStyle.western,
    this.minTrackDurationSec = 30,
    this.artistSeparators = ArtistSplitter.defaultSeparators,
    this.fadeOnPlayPause = true,
    this.skipSilence = false,
    this.replayGainMode = ReplayGainMode.track,
    this.replayGainPreampDb = 0.0,
    this.rememberLongTrackPosition = true,
    this.autoPlayOnHeadsetConnect = false,
    this.playbackSpeed = 1.0,
    this.playbackPitch = 1.0,
    this.hasCompletedOnboarding = false,
    this.hasShownGestureHint = false,
    this.carModeKeepAwake = true,
  });

  final int schemaVersion;
  final String localeCode;
  final NumeralStyle numeralStyle;
  final int minTrackDurationSec;
  final List<String> artistSeparators;
  final bool fadeOnPlayPause;
  final bool skipSilence;
  final ReplayGainMode replayGainMode;
  final double replayGainPreampDb;
  final bool rememberLongTrackPosition;
  final bool autoPlayOnHeadsetConnect;
  final double playbackSpeed;
  final double playbackPitch;
  final bool hasCompletedOnboarding;
  final bool hasShownGestureHint;
  final bool carModeKeepAwake;

  PlaybackSettings copyWith({
    String? localeCode,
    NumeralStyle? numeralStyle,
    int? minTrackDurationSec,
    List<String>? artistSeparators,
    bool? fadeOnPlayPause,
    bool? skipSilence,
    ReplayGainMode? replayGainMode,
    double? replayGainPreampDb,
    bool? rememberLongTrackPosition,
    bool? autoPlayOnHeadsetConnect,
    double? playbackSpeed,
    double? playbackPitch,
    bool? hasCompletedOnboarding,
    bool? hasShownGestureHint,
    bool? carModeKeepAwake,
  }) {
    return PlaybackSettings(
      schemaVersion: schemaVersion,
      localeCode: localeCode ?? this.localeCode,
      numeralStyle: numeralStyle ?? this.numeralStyle,
      minTrackDurationSec: (minTrackDurationSec ?? this.minTrackDurationSec)
          .clamp(0, 120),
      artistSeparators: artistSeparators ?? this.artistSeparators,
      fadeOnPlayPause: fadeOnPlayPause ?? this.fadeOnPlayPause,
      skipSilence: skipSilence ?? this.skipSilence,
      replayGainMode: replayGainMode ?? this.replayGainMode,
      replayGainPreampDb: (replayGainPreampDb ?? this.replayGainPreampDb).clamp(
        -12.0,
        12.0,
      ),
      rememberLongTrackPosition:
          rememberLongTrackPosition ?? this.rememberLongTrackPosition,
      autoPlayOnHeadsetConnect:
          autoPlayOnHeadsetConnect ?? this.autoPlayOnHeadsetConnect,
      playbackSpeed: (playbackSpeed ?? this.playbackSpeed).clamp(0.5, 2.5),
      playbackPitch: (playbackPitch ?? this.playbackPitch).clamp(0.5, 2.0),
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      hasShownGestureHint: hasShownGestureHint ?? this.hasShownGestureHint,
      carModeKeepAwake: carModeKeepAwake ?? this.carModeKeepAwake,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'schemaVersion': schemaVersion,
    'localeCode': localeCode,
    'numeralStyle': numeralStyle.name,
    'minTrackDurationSec': minTrackDurationSec,
    'artistSeparators': artistSeparators,
    'fadeOnPlayPause': fadeOnPlayPause,
    'skipSilence': skipSilence,
    'replayGainMode': replayGainMode.name,
    'replayGainPreampDb': replayGainPreampDb,
    'rememberLongTrackPosition': rememberLongTrackPosition,
    'autoPlayOnHeadsetConnect': autoPlayOnHeadsetConnect,
    'playbackSpeed': playbackSpeed,
    'playbackPitch': playbackPitch,
    'hasCompletedOnboarding': hasCompletedOnboarding,
    'hasShownGestureHint': hasShownGestureHint,
    'carModeKeepAwake': carModeKeepAwake,
  };

  static PlaybackSettings fromJsonSafe(Map<String, dynamic> raw) {
    const d = PlaybackSettings();
    final rgName = raw['replayGainMode'] as String?;
    final rgMode = ReplayGainMode.values.firstWhere(
      (m) => m.name == rgName,
      orElse: () => d.replayGainMode,
    );
    final rawSeps = raw['artistSeparators'];
    final seps = rawSeps is List
        ? rawSeps.whereType<String>().where((s) => s.isNotEmpty).toList()
        : d.artistSeparators;
    final rawLocale = raw['localeCode'] as String?;
    return PlaybackSettings(
      schemaVersion: 1,
      localeCode: rawLocale == 'en' ? 'en' : 'ar',
      numeralStyle: NumeralStyle.fromKey(raw['numeralStyle'] as String?),
      minTrackDurationSec:
          ((raw['minTrackDurationSec'] as num?)?.toInt() ??
                  d.minTrackDurationSec)
              .clamp(0, 120),
      artistSeparators: seps.isEmpty ? d.artistSeparators : seps,
      fadeOnPlayPause: raw['fadeOnPlayPause'] as bool? ?? d.fadeOnPlayPause,
      skipSilence: raw['skipSilence'] as bool? ?? d.skipSilence,
      replayGainMode: rgMode,
      replayGainPreampDb:
          ((raw['replayGainPreampDb'] as num?)?.toDouble() ??
                  d.replayGainPreampDb)
              .clamp(-12.0, 12.0),
      rememberLongTrackPosition:
          raw['rememberLongTrackPosition'] as bool? ??
          d.rememberLongTrackPosition,
      autoPlayOnHeadsetConnect:
          raw['autoPlayOnHeadsetConnect'] as bool? ??
          d.autoPlayOnHeadsetConnect,
      playbackSpeed:
          ((raw['playbackSpeed'] as num?)?.toDouble() ?? d.playbackSpeed).clamp(
            0.5,
            2.5,
          ),
      playbackPitch:
          ((raw['playbackPitch'] as num?)?.toDouble() ?? d.playbackPitch).clamp(
            0.5,
            2.0,
          ),
      hasCompletedOnboarding:
          raw['hasCompletedOnboarding'] as bool? ?? d.hasCompletedOnboarding,
      hasShownGestureHint:
          raw['hasShownGestureHint'] as bool? ?? d.hasShownGestureHint,
      carModeKeepAwake: raw['carModeKeepAwake'] as bool? ?? d.carModeKeepAwake,
    );
  }

  @override
  List<Object?> get props => [
    schemaVersion,
    localeCode,
    numeralStyle,
    minTrackDurationSec,
    artistSeparators,
    fadeOnPlayPause,
    skipSilence,
    replayGainMode,
    replayGainPreampDb,
    rememberLongTrackPosition,
    autoPlayOnHeadsetConnect,
    playbackSpeed,
    playbackPitch,
    hasCompletedOnboarding,
    hasShownGestureHint,
    carModeKeepAwake,
  ];
}
