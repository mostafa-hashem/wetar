import 'dart:convert';

import 'package:equatable/equatable.dart';

enum WetarRepeatMode { off, all, one }

/// Serializable snapshot of queue keys, active index, position, and playback modes.
class PersistedQueueState extends Equatable {
  const PersistedQueueState({
    required this.trackStableKeys,
    required this.currentIndex,
    required this.positionMs,
    required this.shuffleEnabled,
    required this.repeatMode,
  });

  final List<String> trackStableKeys;
  final int currentIndex;
  final int positionMs;
  final bool shuffleEnabled;
  final WetarRepeatMode repeatMode;

  String encodeItems() => jsonEncode(trackStableKeys);

  static PersistedQueueState decode({
    required String itemsJson,
    required int currentIndex,
    required int positionMs,
    required bool shuffleEnabled,
    required String repeatModeName,
  }) {
    List<String> keys = const <String>[];
    try {
      final decoded = jsonDecode(itemsJson);
      if (decoded is List) {
        keys = decoded.whereType<String>().where((s) => s.isNotEmpty).toList();
      }
    } catch (_) {}

    final repeat = WetarRepeatMode.values.firstWhere(
      (r) => r.name == repeatModeName,
      orElse: () => WetarRepeatMode.off,
    );
    final safeIndex = keys.isEmpty ? 0 : currentIndex.clamp(0, keys.length - 1);
    return PersistedQueueState(
      trackStableKeys: keys,
      currentIndex: safeIndex,
      positionMs: positionMs.clamp(0, 86400000),
      shuffleEnabled: shuffleEnabled,
      repeatMode: repeat,
    );
  }

  @override
  List<Object?> get props => [
    trackStableKeys,
    currentIndex,
    positionMs,
    shuffleEnabled,
    repeatMode,
  ];
}
