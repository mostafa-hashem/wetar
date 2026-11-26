import 'dart:math' as math;

import '../../settings/domain/playback_settings.dart';

/// Pure-Dart ReplayGain linear gain multiplier calculation.
class ReplayGainCalculator {
  ReplayGainCalculator._();

  static double computeLinearVolume({
    required ReplayGainMode mode,
    required double preampDb,
    double? trackGainDb,
    double? albumGainDb,
  }) {
    if (mode == ReplayGainMode.off) return 1.0;
    final double? chosenDb = switch (mode) {
      ReplayGainMode.off => null,
      ReplayGainMode.track => trackGainDb ?? albumGainDb,
      ReplayGainMode.album => albumGainDb ?? trackGainDb,
    };
    if (chosenDb == null) return 1.0;
    final effectiveDb = chosenDb + preampDb;
    final linear = math.pow(10.0, effectiveDb / 20.0).toDouble();
    return linear.clamp(0.05, 1.0);
  }

  /// Parses ReplayGain strings such as "-4.25 dB" into a double.
  static double? parseDbTag(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final cleaned = raw.trim().toLowerCase().replaceAll('db', '').trim();
    return double.tryParse(cleaned);
  }
}
