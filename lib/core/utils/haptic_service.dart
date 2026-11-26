import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';

/// Centralized haptic helper honoring the user's configured intensity.
class HapticService {
  HapticService._();

  static void trigger(HapticsIntensity intensity, {bool heavy = false}) {
    switch (intensity) {
      case HapticsIntensity.off:
        return;
      case HapticsIntensity.light:
        unawaited(HapticFeedback.selectionClick());
      case HapticsIntensity.medium:
        unawaited(
          heavy ? HapticFeedback.mediumImpact() : HapticFeedback.lightImpact(),
        );
      case HapticsIntensity.strong:
        unawaited(
          heavy ? HapticFeedback.heavyImpact() : HapticFeedback.mediumImpact(),
        );
    }
  }
}
