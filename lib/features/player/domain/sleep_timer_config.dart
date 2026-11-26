import 'package:equatable/equatable.dart';

enum SleepTimerMode { off, duration, endOfTrack, afterTracks }

class SleepTimerState extends Equatable {
  const SleepTimerState({
    this.mode = SleepTimerMode.off,
    this.remainingDuration = Duration.zero,
    this.remainingTracks = 0,
  });

  final SleepTimerMode mode;
  final Duration remainingDuration;
  final int remainingTracks;

  bool get isActive => mode != SleepTimerMode.off;

  @override
  List<Object?> get props => [mode, remainingDuration, remainingTracks];
}

class AbLoopState extends Equatable {
  const AbLoopState({this.pointA, this.pointB});

  final Duration? pointA;
  final Duration? pointB;

  bool get isEnabled => pointA != null && pointB != null && pointB! > pointA!;

  @override
  List<Object?> get props => [pointA, pointB];
}
