import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/settings_repository.dart';
import '../../domain/playback_settings.dart';

/// Manages persisted playback, library, and locale preferences.
class SettingsCubit extends Cubit<PlaybackSettings> {
  SettingsCubit(this._repo) : super(_repo.loadPlayback());

  final SettingsRepository _repo;

  Future<void> update(PlaybackSettings next) async {
    emit(next);
    await _repo.savePlayback(next);
  }

  Future<void> setLocaleCode(String code) async {
    await update(state.copyWith(localeCode: code));
  }

  Future<void> completeOnboarding() async {
    await update(state.copyWith(hasCompletedOnboarding: true));
  }

  Future<void> markGestureHintShown() async {
    if (state.hasShownGestureHint) return;
    await update(state.copyWith(hasShownGestureHint: true));
  }
}
