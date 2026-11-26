import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/settings/data/backup_service.dart';
import 'package:wetar/features/settings/data/settings_repository.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';

void main() {
  test(
    'BackupService exports and restores appearance, playback, and folders',
    () async {
      final settingsRepo = SettingsRepository.inMemory();
      final db = WetarDatabase(NativeDatabase.memory());
      final pCubit = PersonalizationCubit(settingsRepo);
      final sCubit = SettingsCubit(settingsRepo);
      final backup = BackupService(db, pCubit, sCubit);

      await pCubit.updateSettings(
        const AppearanceSettings(
          themeMode: WetarThemeMode.amoled,
          accentArgb: 0xFF2DD4BF,
        ),
      );
      await sCubit.setLocaleCode('en');

      await db
          .into(db.selectedFolders)
          .insert(
            SelectedFoldersCompanion.insert(
              rootPath: '/storage/emulated/0/OudMusic',
              displayName: 'OudMusic',
              addedAt: 1000,
            ),
          );

      final jsonText = await backup.exportToJson();

      // Mutate state and wipe folders before restoring.
      await pCubit.resetAll();
      await sCubit.setLocaleCode('ar');
      await db.delete(db.selectedFolders).go();

      final ok = await backup.importFromJson(jsonText);
      expect(ok, isTrue);
      expect(pCubit.state.settings.themeMode, WetarThemeMode.amoled);
      expect(pCubit.state.settings.accentArgb, 0xFF2DD4BF);
      expect(sCubit.state.localeCode, 'en');
      final folders = await db.select(db.selectedFolders).get();
      expect(folders, hasLength(1));
      expect(folders.first.displayName, 'OudMusic');

      await pCubit.close();
      await sCubit.close();
      await db.close();
    },
  );
}
