import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/storage/cache_manager.dart';
import 'package:wetar/core/widgets/wetar_brand_logo.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/domain/built_in_wallpapers.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/screens/appearance_studio_screen.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/personalization/presentation/widgets/wetar_background_renderer.dart';
import 'package:wetar/features/settings/data/settings_repository.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

class _GalleryTrackingPlatform
    implements LibrarySource, FolderPickerService, SystemIntegrationService {
  int galleryPickCalls = 0;

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
  Future<String?> pickGalleryImage() async {
    galleryPickCalls++;
    return null;
  }

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

void main() {
  testWidgets(
    'Backgrounds tab picks gallery images, applies nature wallpapers cleanly, and renders new logo',
    (tester) async {
      await sl.reset();
      final db = WetarDatabase(NativeDatabase.memory());
      final settingsRepo = SettingsRepository.inMemory();
      final platform = _GalleryTrackingPlatform();
      final settingsCubit = SettingsCubit(settingsRepo);
      await settingsCubit.setLocaleCode('en');
      final personalizationCubit = PersonalizationCubit(settingsRepo);
      const caps = PlatformCapabilities(
        supportsNativeEqualizer: false,
        supportsBassBoost: false,
        supportsVirtualizer: false,
        supportsLoudnessEnhancer: false,
        supportsSkipSilence: false,
        supportsPitchControl: false,
        supportsInAppFolderPicker: true,
        supportsSafFolderPicker: false,
        supportsSystemFolderBookmarks: false,
        supportsSystemDynamicColor: false,
        supportsHomeWidgets: false,
        supportsDesktopShell: false,
        supportsBatteryOptimizationGuide: false,
        supportsICloudStatus: false,
      );

      sl
        ..registerSingleton<WetarDatabase>(db)
        ..registerSingleton<CacheManager>(CacheManager())
        ..registerSingleton<FolderPickerService>(platform)
        ..registerSingleton<PlatformCapabilities>(caps);

      addTearDown(() async {
        await personalizationCubit.close();
        await settingsCubit.close();
        await db.close();
        await sl.reset();
      });

      final theme = WetarTokenResolver.buildThemeData(
        personalizationCubit.state.settings,
        platformBrightness: Brightness.dark,
        systemDisableAnimations: false,
        isArabicLocale: false,
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<PersonalizationCubit>.value(
              value: personalizationCubit,
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            theme: theme,
            home: const AppearanceStudioScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Backgrounds tab.
      final bgTab = find.text('Backgrounds');
      await tester.ensureVisible(bgTab);
      await tester.tap(bgTab);
      await tester.pumpAndSettle();

      // Verify Choose from Gallery invokes pickGalleryImage().
      final galleryBtn = find.text('Choose from Gallery');
      await tester.ensureVisible(galleryBtn);
      await tester.tap(galleryBtn);
      await tester.pumpAndSettle();
      expect(platform.galleryPickCalls, 1);

      // Select bundled nature wallpaper and verify state + renderer.
      final firstWallpaper = BuiltInWallpapers.all.first;
      final wallpaperCard = find.text(firstWallpaper.nameEn);
      await tester.ensureVisible(wallpaperCard);
      await tester.tap(wallpaperCard);
      await tester.pumpAndSettle();

      expect(
        personalizationCubit.state.settings.backgroundMode,
        BackgroundMode.customImage,
      );
      expect(
        personalizationCubit.state.settings.customBackgroundImagePath,
        firstWallpaper.sourceRef,
      );
      expect(
        personalizationCubit.state.settings.backgroundScope,
        BackgroundScope.homeAndPlayer,
      );

      // Render WetarBackgroundRenderer + WetarBrandLogo sizes without errors.
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<PersonalizationCubit>.value(
              value: personalizationCubit,
            ),
          ],
          child: MaterialApp(
            theme: theme,
            home: const WetarBackgroundRenderer(
              surfaceLocation: BackgroundScope.homeAndPlayer,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      WetarBrandLogo(size: 28),
                      WetarBrandLogo(size: 36, showTileBackground: false),
                      WetarBrandLogo(size: 86),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  test('WetarLookPreset preserves bundled nature wallpapers but clears local disk paths', () {
    final presetWithNature = WetarLookPreset(
      id: 'nature',
      nameEn: 'Nature',
      nameAr: 'طبيعة',
      isBuiltIn: false,
      settings: AppearanceSettings(
        backgroundMode: BackgroundMode.customImage,
        customBackgroundImagePath: BuiltInWallpapers.all.first.sourceRef,
      ),
    );
    final parsedNature = WetarLookPreset.tryParseExport(
      jsonEncode(presetWithNature.toExportJson()),
    );
    expect(parsedNature, isNotNull);
    expect(
      parsedNature!.settings.customBackgroundImagePath,
      BuiltInWallpapers.all.first.sourceRef,
    );

    const presetWithDiskFile = WetarLookPreset(
      id: 'disk',
      nameEn: 'Disk',
      nameAr: 'قرص',
      isBuiltIn: false,
      settings: AppearanceSettings(
        backgroundMode: BackgroundMode.customImage,
        customBackgroundImagePath: '/data/user/0/com.wetar/files/bg.png',
      ),
    );
    final parsedDisk = WetarLookPreset.tryParseExport(
      jsonEncode(presetWithDiskFile.toExportJson()),
    );
    expect(parsedDisk, isNotNull);
    expect(parsedDisk!.settings.customBackgroundImagePath, isNull);
  });
}
