import 'dart:async';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/features/music_folders/data/music_folders_repository.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/settings/data/settings_repository.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'OnboardingScreen switches Arabic/English and Light/Dark theme live',
    (tester) async {
      final repo = SettingsRepository.inMemory();
      final settingsCubit = SettingsCubit(repo);
      final personalizationCubit = PersonalizationCubit(repo);
      final db = WetarDatabase(NativeDatabase.memory());
      final fake = _FakePlatform();
      final foldersRepo = MusicFoldersRepository(db, fake, fake);
      const caps = PlatformCapabilities(
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
        supportsICloudStatus: false,
      );
      final foldersCubit = MusicFoldersCubit(foldersRepo, fake, caps);
      var completed = false;

      addTearDown(() async {
        await foldersCubit.close();
        await personalizationCubit.close();
        await settingsCubit.close();
        await db.close();
      });

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<PersonalizationCubit>.value(
              value: personalizationCubit,
            ),
            BlocProvider<MusicFoldersCubit>.value(value: foldersCubit),
          ],
          child: Builder(
            builder: (context) {
              final localeCode = context.select(
                (SettingsCubit c) => c.state.localeCode,
              );
              final appearance = context.select(
                (PersonalizationCubit c) => c.state.settings,
              );
              final theme = WetarTokenResolver.buildThemeData(
                appearance,
                platformBrightness: Brightness.dark,
                systemDisableAnimations: false,
                isArabicLocale: localeCode == 'ar',
              );
              return MaterialApp(
                locale: Locale(localeCode),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: <LocalizationsDelegate<dynamic>>[
                  AppLocalizations.delegate,
                  ...GlobalMaterialLocalizations.delegates,
                ],
                theme: theme,
                home: OnboardingScreen(
                  capabilities: caps,
                  onFinished: () => completed = true,
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default locale is Arabic ('ar') and Dark mode.
      expect(find.text('أهلاً بك في وتر'), findsOneWidget);

      // Tap Light theme card.
      await tester.tap(find.text('فاتح'));
      await tester.pumpAndSettle();
      expect(
        personalizationCubit.state.settings.themeMode,
        WetarThemeMode.light,
      );

      // Tap English language card -> switches text and direction live.
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(settingsCubit.state.localeCode, 'en');
      expect(find.text('Meet Wetar'), findsOneWidget);

      // Tap Dark theme card in English.
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(
        personalizationCubit.state.settings.themeMode,
        WetarThemeMode.dark,
      );

      // Switch back to Arabic.
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();
      expect(settingsCubit.state.localeCode, 'ar');
      expect(find.text('أهلاً بك في وتر'), findsOneWidget);
      expect(completed, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}

class _FakePlatform
    implements LibrarySource, FolderPickerService, SystemIntegrationService {
  @override
  Stream<PlatformIncomingEvent> get incomingEvents => const Stream.empty();

  @override
  Future<WetarPermissionsStatus> checkPermissions() async =>
      const WetarPermissionsStatus(
        audioGranted: true,
        notificationsGranted: true,
      );

  @override
  Future<List<DiscoveredAudioFolder>> listAudioFolders() async => const [];

  @override
  Future<FolderScanResult> scanSelectedFolders({
    required List<FolderScanRequest> folders,
    required Map<String, int> existingModifiedByStableKey,
  }) async => const FolderScanResult(
    availableFolderIds: <int>{},
    activeStableKeys: <String>{},
    changedTracks: <ScannedTrackDto>[],
  );

  @override
  Future<String?> loadAlbumArtThumbnail({
    required String? uri,
    required String? filePath,
    required String outputPath,
    int sizePx = 256,
  }) async => null;

  @override
  Future<bool> isIgnoringBatteryOptimizations() async => true;
  @override
  Future<bool> openAppSettings() async => true;
  @override
  Future<bool> openBatteryOptimizationSettings() async => true;
  @override
  Future<String?> pickFile({required List<String> mimeTypes}) async => null;

  @override
  Future<String?> pickGalleryImage() async => null;
  @override
  Future<PickedFolderResult?> pickSystemFolder() async => null;
  @override
  Future<WetarPermissionsStatus> requestPermissions({
    bool includeNotifications = true,
  }) async => checkPermissions();
  @override
  Future<bool> resolveBookmark(String bookmarkData) async => true;
  @override
  Future<bool> saveFile({
    required String fileName,
    required String mimeType,
    Uint8List? bytes,
    String? sourcePath,
  }) async => true;
  @override
  Future<bool> setCompactMiniPlayerMode(bool compact) async => true;
  @override
  Future<bool> setKeepScreenOn(bool keepOn) async => true;
  @override
  Future<bool> shareFiles({
    required List<String> paths,
    required String mimeType,
    String? subject,
  }) async => true;
  @override
  Future<void> startWatchingFolders(List<String> paths) async {}
  @override
  Future<void> stopAccessingBookmark(String bookmarkData) async {}
  @override
  Future<bool> triggerCloudDownload(String filePath) async => false;
  @override
  Future<void> updateHomeWidget({
    required String? title,
    required String? artist,
    required String? artworkPath,
    required bool isPlaying,
  }) async {}
}
