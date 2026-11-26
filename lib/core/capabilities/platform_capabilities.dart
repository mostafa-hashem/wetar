import 'dart:io';

import 'package:equatable/equatable.dart';

/// Describes which platform-specific audio and OS features are supported cleanly.
/// Unsupported features are hidden from UI rather than mocked or failing at runtime.
class PlatformCapabilities extends Equatable {
  const PlatformCapabilities({
    required this.supportsNativeEqualizer,
    required this.supportsBassBoost,
    required this.supportsVirtualizer,
    required this.supportsLoudnessEnhancer,
    required this.supportsSkipSilence,
    required this.supportsPitchControl,
    required this.supportsInAppFolderPicker,
    required this.supportsSafFolderPicker,
    required this.supportsSystemFolderBookmarks,
    required this.supportsSystemDynamicColor,
    required this.supportsHomeWidgets,
    required this.supportsDesktopShell,
    required this.supportsBatteryOptimizationGuide,
    required this.supportsICloudStatus,
  });

  factory PlatformCapabilities.detect({
    bool hasHardwareBassBoost = true,
    bool hasHardwareVirtualizer = true,
  }) {
    if (Platform.isAndroid) {
      return PlatformCapabilities(
        supportsNativeEqualizer: true,
        supportsBassBoost: hasHardwareBassBoost,
        supportsVirtualizer: hasHardwareVirtualizer,
        supportsLoudnessEnhancer: true,
        supportsSkipSilence: true,
        supportsPitchControl: true,
        supportsInAppFolderPicker: true,
        supportsSafFolderPicker: true,
        supportsSystemFolderBookmarks: false,
        supportsSystemDynamicColor: true,
        supportsHomeWidgets: true,
        supportsDesktopShell: false,
        supportsBatteryOptimizationGuide: true,
        supportsICloudStatus: false,
      );
    }
    if (Platform.isMacOS) {
      return const PlatformCapabilities(
        supportsNativeEqualizer: false,
        supportsBassBoost: false,
        supportsVirtualizer: false,
        supportsLoudnessEnhancer: false,
        supportsSkipSilence: false,
        supportsPitchControl: false,
        supportsInAppFolderPicker: false,
        supportsSafFolderPicker: false,
        supportsSystemFolderBookmarks: true,
        supportsSystemDynamicColor: true,
        supportsHomeWidgets: false,
        supportsDesktopShell: true,
        supportsBatteryOptimizationGuide: false,
        supportsICloudStatus: false,
      );
    }
    if (Platform.isIOS) {
      return const PlatformCapabilities(
        supportsNativeEqualizer: false,
        supportsBassBoost: false,
        supportsVirtualizer: false,
        supportsLoudnessEnhancer: false,
        supportsSkipSilence: false,
        supportsPitchControl: false,
        supportsInAppFolderPicker: false,
        supportsSafFolderPicker: false,
        supportsSystemFolderBookmarks: true,
        supportsSystemDynamicColor: false,
        supportsHomeWidgets: false,
        supportsDesktopShell: false,
        supportsBatteryOptimizationGuide: false,
        supportsICloudStatus: true,
      );
    }
    return const PlatformCapabilities(
      supportsNativeEqualizer: false,
      supportsBassBoost: false,
      supportsVirtualizer: false,
      supportsLoudnessEnhancer: false,
      supportsSkipSilence: false,
      supportsPitchControl: false,
      supportsInAppFolderPicker: false,
      supportsSafFolderPicker: false,
      supportsSystemFolderBookmarks: false,
      supportsSystemDynamicColor: false,
      supportsHomeWidgets: false,
      supportsDesktopShell: false,
      supportsBatteryOptimizationGuide: false,
      supportsICloudStatus: false,
    );
  }

  final bool supportsNativeEqualizer;
  final bool supportsBassBoost;
  final bool supportsVirtualizer;
  final bool supportsLoudnessEnhancer;
  final bool supportsSkipSilence;
  final bool supportsPitchControl;
  final bool supportsInAppFolderPicker;
  final bool supportsSafFolderPicker;
  final bool supportsSystemFolderBookmarks;
  final bool supportsSystemDynamicColor;
  final bool supportsHomeWidgets;
  final bool supportsDesktopShell;
  final bool supportsBatteryOptimizationGuide;
  final bool supportsICloudStatus;

  bool get supportsAnyAudioEffects =>
      supportsNativeEqualizer ||
      supportsBassBoost ||
      supportsVirtualizer ||
      supportsLoudnessEnhancer;

  PlatformCapabilities copyWith({
    bool? supportsNativeEqualizer,
    bool? supportsBassBoost,
    bool? supportsVirtualizer,
    bool? supportsLoudnessEnhancer,
    bool? supportsSkipSilence,
    bool? supportsPitchControl,
    bool? supportsInAppFolderPicker,
    bool? supportsSafFolderPicker,
    bool? supportsSystemFolderBookmarks,
    bool? supportsSystemDynamicColor,
    bool? supportsHomeWidgets,
    bool? supportsDesktopShell,
    bool? supportsBatteryOptimizationGuide,
    bool? supportsICloudStatus,
  }) {
    return PlatformCapabilities(
      supportsNativeEqualizer:
          supportsNativeEqualizer ?? this.supportsNativeEqualizer,
      supportsBassBoost: supportsBassBoost ?? this.supportsBassBoost,
      supportsVirtualizer: supportsVirtualizer ?? this.supportsVirtualizer,
      supportsLoudnessEnhancer:
          supportsLoudnessEnhancer ?? this.supportsLoudnessEnhancer,
      supportsSkipSilence: supportsSkipSilence ?? this.supportsSkipSilence,
      supportsPitchControl: supportsPitchControl ?? this.supportsPitchControl,
      supportsInAppFolderPicker:
          supportsInAppFolderPicker ?? this.supportsInAppFolderPicker,
      supportsSafFolderPicker:
          supportsSafFolderPicker ?? this.supportsSafFolderPicker,
      supportsSystemFolderBookmarks:
          supportsSystemFolderBookmarks ?? this.supportsSystemFolderBookmarks,
      supportsSystemDynamicColor:
          supportsSystemDynamicColor ?? this.supportsSystemDynamicColor,
      supportsHomeWidgets: supportsHomeWidgets ?? this.supportsHomeWidgets,
      supportsDesktopShell: supportsDesktopShell ?? this.supportsDesktopShell,
      supportsBatteryOptimizationGuide:
          supportsBatteryOptimizationGuide ??
          this.supportsBatteryOptimizationGuide,
      supportsICloudStatus: supportsICloudStatus ?? this.supportsICloudStatus,
    );
  }

  @override
  List<Object?> get props => [
    supportsNativeEqualizer,
    supportsBassBoost,
    supportsVirtualizer,
    supportsLoudnessEnhancer,
    supportsSkipSilence,
    supportsPitchControl,
    supportsInAppFolderPicker,
    supportsSafFolderPicker,
    supportsSystemFolderBookmarks,
    supportsSystemDynamicColor,
    supportsHomeWidgets,
    supportsDesktopShell,
    supportsBatteryOptimizationGuide,
    supportsICloudStatus,
  ];
}
