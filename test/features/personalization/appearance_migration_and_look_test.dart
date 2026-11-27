import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';

void main() {
  group('AppearanceSettings migration & .wetarlook validation', () {
    test(
      'migrates legacy v0 payload cleanly without resetting user choices',
      () {
        final migrated = AppearanceSettingsMigration.fromJsonSafe(
          <String, dynamic>{
            'themeMode': 'amoled',
            'accentArgb': 0xFF10B981,
            'fontScale': 1.25,
            'arabicFontFamily': 'Alexandria',
            'playerLayout': 'vinylDisc',
          },
        );

        expect(migrated.schemaVersion, AppearanceSettings.currentSchemaVersion);
        expect(migrated.themeMode, WetarThemeMode.amoled);
        expect(migrated.accentArgb, 0xFF10B981);
        expect(migrated.fontScale, 1.25);
        expect(migrated.arabicFontFamily, 'Alexandria');
        expect(migrated.playerLayout, PlayerLayoutVariant.vinylDisc);
        expect(migrated.hiddenHomeBlocks, contains(HomeBlockKind.folders));
        expect(migrated.miniPlayerSwipeDownDismiss, isTrue);
      },
    );

    test('v1 migration hides Home folders block and enables paused swipe-down dismiss', () {
      final migrated = AppearanceSettingsMigration.fromJsonSafe(
        <String, dynamic>{
          'schemaVersion': 1,
          'hiddenHomeBlocks': <String>['playlists'],
        },
      );

      expect(migrated.schemaVersion, 2);
      expect(
        migrated.hiddenHomeBlocks,
        containsAll(<HomeBlockKind>[
          HomeBlockKind.playlists,
          HomeBlockKind.folders,
        ]),
      );
      expect(migrated.miniPlayerSwipeDownDismiss, isTrue);
    });

    test('v2 payload preserves explicit user choices for Home folders and swipe-down dismiss', () {
      final parsed = AppearanceSettingsMigration.fromJsonSafe(<String, dynamic>{
        'schemaVersion': 2,
        'hiddenHomeBlocks': <String>[],
        'miniPlayerSwipeDownDismiss': false,
      });

      expect(parsed.schemaVersion, 2);
      expect(parsed.hiddenHomeBlocks, isEmpty);
      expect(parsed.miniPlayerSwipeDownDismiss, isFalse);
    });

    test('v1 migration hides Home folders block and enables paused swipe-down dismiss', () {
      final migrated = AppearanceSettingsMigration.fromJsonSafe(
        <String, dynamic>{
          'schemaVersion': 1,
          'hiddenHomeBlocks': <String>['playlists'],
        },
      );

      expect(migrated.schemaVersion, 2);
      expect(
        migrated.hiddenHomeBlocks,
        containsAll(<HomeBlockKind>[
          HomeBlockKind.playlists,
          HomeBlockKind.folders,
        ]),
      );
      expect(migrated.miniPlayerSwipeDownDismiss, isTrue);
    });

    test('v2 payload preserves explicit user choices for Home folders and swipe-down dismiss', () {
      final parsed = AppearanceSettingsMigration.fromJsonSafe(<String, dynamic>{
        'schemaVersion': 2,
        'hiddenHomeBlocks': <String>[],
        'miniPlayerSwipeDownDismiss': false,
      });

      expect(parsed.schemaVersion, 2);
      expect(parsed.hiddenHomeBlocks, isEmpty);
      expect(parsed.miniPlayerSwipeDownDismiss, isFalse);
    });

    test('validates and sanitizes .wetarlook export/import', () {
      const preset = WetarLookPreset(
        id: 'test_look',
        nameEn: 'Oud Gold',
        nameAr: 'ذهب العود',
        isBuiltIn: false,
        settings: AppearanceSettings(
          accentArgb: 0xFFE69B3A,
          customBackgroundImagePath: '/unsafe/local/path.png',
          importedFontFamily: 'WetarUserFont_123',
        ),
      );
      final encoded = jsonEncode(preset.toExportJson());
      final imported = WetarLookPreset.tryParseExport(encoded);

      expect(imported, isNotNull);
      expect(imported!.nameEn, 'Oud Gold');
      expect(imported.settings.accentArgb, 0xFFE69B3A);
      // Local filesystem references must be stripped on cross-device look import.
      expect(imported.settings.customBackgroundImagePath, isNull);
      expect(imported.settings.importedFontFamily, isNull);

      expect(WetarLookPreset.tryParseExport('not json'), isNull);
      expect(WetarLookPreset.tryParseExport('{"format":"wrong"}'), isNull);
    });

    test('per-section reset preserves unrelated appearance sections', () {
      const modified = AppearanceSettings(
        themeMode: WetarThemeMode.amoled,
        arabicFontFamily: 'Almarai',
        listDensity: ListDensity.compact,
      );
      final afterFontReset = modified.resetTypography();
      expect(afterFontReset.arabicFontFamily, 'Cairo');
      expect(afterFontReset.themeMode, WetarThemeMode.amoled);
      expect(afterFontReset.listDensity, ListDensity.compact);
    });
  });
}
