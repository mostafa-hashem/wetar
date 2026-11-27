import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/settings/data/settings_repository.dart';

class PersonalizationState {
  const PersonalizationState({
    required this.settings,
    required this.savedLooks,
    this.artworkPrimary,
    this.artworkSecondary,
    this.systemAccent,
  });

  final AppearanceSettings settings;
  final List<WetarLookPreset> savedLooks;
  final Color? artworkPrimary;
  final Color? artworkSecondary;
  final Color? systemAccent;

  PersonalizationState copyWith({
    AppearanceSettings? settings,
    List<WetarLookPreset>? savedLooks,
    Color? artworkPrimary,
    Color? artworkSecondary,
    Color? systemAccent,
    bool clearArtworkColors = false,
  }) {
    return PersonalizationState(
      settings: settings ?? this.settings,
      savedLooks: savedLooks ?? this.savedLooks,
      artworkPrimary: clearArtworkColors
          ? null
          : (artworkPrimary ?? this.artworkPrimary),
      artworkSecondary: clearArtworkColors
          ? null
          : (artworkSecondary ?? this.artworkSecondary),
      systemAccent: systemAccent ?? this.systemAccent,
    );
  }
}

/// Manages live appearance updates, look presets, and per-section / global resets.
class PersonalizationCubit extends Cubit<PersonalizationState> {
  PersonalizationCubit(this._settingsRepo)
    : super(
        PersonalizationState(
          settings: _settingsRepo.loadAppearance(),
          savedLooks: _settingsRepo.loadSavedLooks(),
        ),
      );

  final SettingsRepository _settingsRepo;

  Future<void> updateSettings(AppearanceSettings next) async {
    emit(state.copyWith(settings: next));
    await _settingsRepo.saveAppearance(next);
  }

  /// Applies [look] while preserving the user's current Light/Dark/AMOLED/System
  /// theme mode unless [preserveThemeMode] is explicitly false.
  Future<void> applyLook(
    WetarLookPreset look, {
    bool preserveThemeMode = true,
  }) async {
    final next = preserveThemeMode
        ? look.settings.copyWith(
            themeMode: state.settings.themeMode,
            scheduledDarkEnabled: state.settings.scheduledDarkEnabled,
            scheduledDarkStartHour: state.settings.scheduledDarkStartHour,
            scheduledDarkEndHour: state.settings.scheduledDarkEndHour,
          )
        : look.settings;
    await updateSettings(next);
  }

  Future<void> saveCurrentAsLook({
    required String nameEn,
    String? nameAr,
  }) async {
    final preset = WetarLookPreset(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      nameEn: nameEn.trim(),
      nameAr: (nameAr ?? nameEn).trim(),
      isBuiltIn: false,
      settings: state.settings,
    );
    final updated = <WetarLookPreset>[preset, ...state.savedLooks];
    emit(state.copyWith(savedLooks: updated));
    await _settingsRepo.saveCustomLooks(updated);
  }

  Future<void> deleteSavedLook(String id) async {
    final updated = state.savedLooks.where((l) => l.id != id).toList();
    emit(state.copyWith(savedLooks: updated));
    await _settingsRepo.saveCustomLooks(updated);
  }

  Future<void> importLook(WetarLookPreset look) async {
    final updated = <WetarLookPreset>[look, ...state.savedLooks];
    emit(state.copyWith(settings: look.settings, savedLooks: updated));
    await _settingsRepo.saveCustomLooks(updated);
    await _settingsRepo.saveAppearance(look.settings);
  }

  void setArtworkColors({Color? primary, Color? secondary}) {
    if (primary == state.artworkPrimary &&
        secondary == state.artworkSecondary) {
      return;
    }
    emit(
      state.copyWith(
        artworkPrimary: primary,
        artworkSecondary: secondary,
        clearArtworkColors: primary == null && secondary == null,
      ),
    );
  }

  void setSystemAccent(Color? accent) {
    if (accent == state.systemAccent) return;
    emit(state.copyWith(systemAccent: accent));
  }

  Future<void> resetAll() async {
    await updateSettings(const AppearanceSettings());
  }
}
