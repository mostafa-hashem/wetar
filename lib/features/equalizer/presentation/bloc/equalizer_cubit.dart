import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/features/player/data/wetar_audio_handler.dart';

class EqBandInfo extends Equatable {
  const EqBandInfo({
    required this.index,
    required this.centerFreqHz,
    required this.gainDb,
  });

  final int index;
  final double centerFreqHz;
  final double gainDb;

  @override
  List<Object?> get props => [index, centerFreqHz, gainDb];
}

class EqPresetItem extends Equatable {
  const EqPresetItem({
    required this.name,
    required this.isCustom,
    required this.bandGainsDb,
    this.bassBoost = 0,
    this.virtualizer = 0,
    this.loudnessDb = 0.0,
  });

  final String name;
  final bool isCustom;
  final List<double> bandGainsDb;
  final int bassBoost;
  final int virtualizer;
  final double loudnessDb;

  @override
  List<Object?> get props => [
    name,
    isCustom,
    bandGainsDb,
    bassBoost,
    virtualizer,
    loudnessDb,
  ];
}

class EqualizerState extends Equatable {
  const EqualizerState({
    this.isAvailable = false,
    this.isEnabled = false,
    this.minDb = -15.0,
    this.maxDb = 15.0,
    this.bands = const <EqBandInfo>[],
    this.bassBoostStrength = 0,
    this.virtualizerStrength = 0,
    this.loudnessBoostEnabled = false,
    this.loudnessGainDb = 0.0,
    this.activePresetName = 'Flat',
    this.presets = const <EqPresetItem>[],
  });

  final bool isAvailable;
  final bool isEnabled;
  final double minDb;
  final double maxDb;
  final List<EqBandInfo> bands;
  final int bassBoostStrength;
  final int virtualizerStrength;
  final bool loudnessBoostEnabled;
  final double loudnessGainDb;
  final String activePresetName;
  final List<EqPresetItem> presets;

  EqualizerState copyWith({
    bool? isAvailable,
    bool? isEnabled,
    double? minDb,
    double? maxDb,
    List<EqBandInfo>? bands,
    int? bassBoostStrength,
    int? virtualizerStrength,
    bool? loudnessBoostEnabled,
    double? loudnessGainDb,
    String? activePresetName,
    List<EqPresetItem>? presets,
  }) {
    return EqualizerState(
      isAvailable: isAvailable ?? this.isAvailable,
      isEnabled: isEnabled ?? this.isEnabled,
      minDb: minDb ?? this.minDb,
      maxDb: maxDb ?? this.maxDb,
      bands: bands ?? this.bands,
      bassBoostStrength: bassBoostStrength ?? this.bassBoostStrength,
      virtualizerStrength: virtualizerStrength ?? this.virtualizerStrength,
      loudnessBoostEnabled: loudnessBoostEnabled ?? this.loudnessBoostEnabled,
      loudnessGainDb: loudnessGainDb ?? this.loudnessGainDb,
      activePresetName: activePresetName ?? this.activePresetName,
      presets: presets ?? this.presets,
    );
  }

  @override
  List<Object?> get props => [
    isAvailable,
    isEnabled,
    minDb,
    maxDb,
    bands,
    bassBoostStrength,
    virtualizerStrength,
    loudnessBoostEnabled,
    loudnessGainDb,
    activePresetName,
    presets,
  ];
}

/// Coordinates AndroidEqualizer, AndroidLoudnessEnhancer, native BassBoost/Virtualizer,
/// and Drift-persisted custom presets behind PlatformCapabilities checks.
class EqualizerCubit extends Cubit<EqualizerState> {
  EqualizerCubit(
    this._db,
    this._handler,
    this._nativeEffects,
    this._capabilities,
  ) : super(const EqualizerState()) {
    unawaited(_init());
  }

  final WetarDatabase _db;
  final WetarAudioHandler _handler;
  final NativeAudioEffectsService _nativeEffects;
  final PlatformCapabilities _capabilities;

  AndroidEqualizerParameters? _params;
  StreamSubscription<List<EqualizerPreset>>? _customSub;

  static const List<EqPresetItem> builtInPresets = <EqPresetItem>[
    EqPresetItem(
      name: 'Flat',
      isCustom: false,
      bandGainsDb: <double>[0, 0, 0, 0, 0],
    ),
    EqPresetItem(
      name: 'Oud & Acoustic',
      isCustom: false,
      bandGainsDb: <double>[2.5, 4.0, 1.5, 3.0, 2.0],
      bassBoost: 180,
      virtualizer: 220,
    ),
    EqPresetItem(
      name: 'Vocal Clarity',
      isCustom: false,
      bandGainsDb: <double>[-2.0, 1.0, 4.5, 3.5, 1.0],
    ),
    EqPresetItem(
      name: 'Bass Boost',
      isCustom: false,
      bandGainsDb: <double>[6.5, 4.0, 0.0, 1.0, 2.0],
      bassBoost: 620,
    ),
    EqPresetItem(
      name: 'Classical',
      isCustom: false,
      bandGainsDb: <double>[3.5, 2.0, -1.0, 2.5, 4.0],
      virtualizer: 300,
    ),
    EqPresetItem(
      name: 'Podcast',
      isCustom: false,
      bandGainsDb: <double>[-3.0, 0.5, 4.0, 3.0, -1.0],
    ),
  ];

  Future<void> _init() async {
    _customSub =
        (_db.select(_db.equalizerPresets)
              ..orderBy(<OrderingTerm Function(EqualizerPresets)>[
                (t) => OrderingTerm.desc(t.updatedAt),
              ]))
            .watch()
            .listen((rows) {
              final custom = rows.map((r) {
                final decoded = (jsonDecode(r.bandGainsJson) as List<dynamic>)
                    .whereType<num>()
                    .map((n) => n.toDouble())
                    .toList();
                return EqPresetItem(
                  name: r.name,
                  isCustom: true,
                  bandGainsDb: decoded,
                  bassBoost: r.bassBoostStrength,
                  virtualizer: r.virtualizerStrength,
                  loudnessDb: r.loudnessGainMb / 100.0,
                );
              }).toList();
              emit(
                state.copyWith(
                  presets: <EqPresetItem>[...builtInPresets, ...custom],
                ),
              );
            });

    final eq = _handler.androidEqualizer;
    if (!_capabilities.supportsNativeEqualizer || eq == null) {
      emit(state.copyWith(isAvailable: false, presets: builtInPresets));
      return;
    }

    try {
      final params = await eq.parameters.timeout(const Duration(seconds: 3));
      _params = params;
      final bands = params.bands
          .map(
            (b) => EqBandInfo(
              index: b.index,
              centerFreqHz: b.centerFrequency,
              gainDb: b.gain,
            ),
          )
          .toList();
      emit(
        state.copyWith(
          isAvailable: true,
          isEnabled: eq.enabled,
          minDb: params.minDecibels,
          maxDb: params.maxDecibels,
          bands: bands,
          presets: state.presets.isEmpty ? builtInPresets : state.presets,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isAvailable: true,
          minDb: -15.0,
          maxDb: 15.0,
          bands: const <EqBandInfo>[
            EqBandInfo(index: 0, centerFreqHz: 60, gainDb: 0),
            EqBandInfo(index: 1, centerFreqHz: 230, gainDb: 0),
            EqBandInfo(index: 2, centerFreqHz: 910, gainDb: 0),
            EqBandInfo(index: 3, centerFreqHz: 3600, gainDb: 0),
            EqBandInfo(index: 4, centerFreqHz: 14000, gainDb: 0),
          ],
          presets: builtInPresets,
        ),
      );
    }
  }

  Future<void> setEnabled(bool enabled) async {
    emit(state.copyWith(isEnabled: enabled));
    await _handler.androidEqualizer?.setEnabled(enabled);
  }

  Future<void> setBandGain(int index, double gainDb) async {
    final clamped = gainDb.clamp(state.minDb, state.maxDb);
    final nextBands = state.bands
        .map(
          (b) => b.index == index
              ? EqBandInfo(
                  index: b.index,
                  centerFreqHz: b.centerFreqHz,
                  gainDb: clamped,
                )
              : b,
        )
        .toList();
    emit(state.copyWith(bands: nextBands, activePresetName: 'Custom'));
    final params = _params;
    if (params != null && index >= 0 && index < params.bands.length) {
      await params.bands[index].setGain(clamped);
    }
  }

  Future<void> setBassBoost(int strength) async {
    final clamped = strength.clamp(0, 1000);
    emit(state.copyWith(bassBoostStrength: clamped));
    await _nativeEffects.setBassBoost(enabled: clamped > 0, strength: clamped);
  }

  Future<void> setVirtualizer(int strength) async {
    final clamped = strength.clamp(0, 1000);
    emit(state.copyWith(virtualizerStrength: clamped));
    await _nativeEffects.setVirtualizer(
      enabled: clamped > 0,
      strength: clamped,
    );
  }

  Future<void> setLoudnessGain(double gainDb) async {
    final clamped = gainDb.clamp(0.0, 12.0);
    final enabled = clamped > 0.1;
    emit(
      state.copyWith(loudnessBoostEnabled: enabled, loudnessGainDb: clamped),
    );
    final loudness = _handler.androidLoudness;
    if (loudness != null) {
      await loudness.setEnabled(enabled);
      await loudness.setTargetGain(clamped);
    }
  }

  Future<void> applyPreset(EqPresetItem preset) async {
    await setEnabled(true);
    for (var i = 0; i < state.bands.length; i++) {
      final target = i < preset.bandGainsDb.length
          ? preset.bandGainsDb[i]
          : 0.0;
      await setBandGain(i, target);
    }
    await setBassBoost(preset.bassBoost);
    await setVirtualizer(preset.virtualizer);
    await setLoudnessGain(preset.loudnessDb);
    emit(state.copyWith(activePresetName: preset.name));
  }

  Future<void> saveCustomPreset(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) return;
    final gains = state.bands.map((b) => b.gainDb).toList();
    await _db
        .into(_db.equalizerPresets)
        .insert(
          EqualizerPresetsCompanion.insert(
            name: clean,
            isCustom: const Value(true),
            bandGainsJson: jsonEncode(gains),
            bassBoostStrength: Value(state.bassBoostStrength),
            virtualizerStrength: Value(state.virtualizerStrength),
            loudnessGainMb: Value((state.loudnessGainDb * 100).round()),
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
          mode: InsertMode.insertOrReplace,
        );
    emit(state.copyWith(activePresetName: clean));
  }

  Future<void> deleteCustomPreset(String name) async {
    await (_db.delete(
      _db.equalizerPresets,
    )..where((t) => t.name.equals(name) & t.isCustom.equals(true))).go();
  }

  @override
  Future<void> close() async {
    await _customSub?.cancel();
    return super.close();
  }
}
